import logging
import sys
import argparse
import os
import boto3
import torch
import torch.nn as nn
import numpy as np

from transformers import (
    AutoModelForSequenceClassification,
    AutoTokenizer,
    DataCollatorWithPadding,
    EarlyStoppingCallback,
    Trainer,
    TrainingArguments,
)

from datasets import load_from_disk

from sklearn.metrics import (
    accuracy_score,
    precision_recall_fscore_support,
    confusion_matrix,
    classification_report,
    roc_auc_score,
    matthews_corrcoef,
    roc_curve,
    auc,
)

from sklearn.utils.class_weight import compute_class_weight

import matplotlib.pyplot as plt
import seaborn as sns
import pandas as pd

from scipy.special import softmax


if __name__ == "__main__":

    parser = argparse.ArgumentParser()

    parser.add_argument("--epochs", type=int, default=5)
    parser.add_argument("--train_batch_size", type=int, default=16)
    parser.add_argument("--eval_batch_size", type=int, default=32)
    parser.add_argument("--warmup_steps", type=int, default=300)
    parser.add_argument("--model_name", type=str, default="distilroberta-base")
    parser.add_argument("--tokenizer_name", type=str, default="distilroberta-base")
    parser.add_argument("--learning_rate", type=str, default="2e-5")
    parser.add_argument("--weight_decay", type=float, default=0.05)
    parser.add_argument("--num_labels", type=int, default=2)
    parser.add_argument("--early_stopping_patience", type=int, default=2)
    parser.add_argument("--label_smoothing", type=float, default=0.05)
    parser.add_argument("--gradient_accumulation_steps", type=int, default=2)
    parser.add_argument("--seed", type=int, default=42)


    parser.add_argument("--s3_bucket", type=str, default=None)

    parser.add_argument("--output-data-dir", type=str, default=os.environ["SM_OUTPUT_DATA_DIR"])
    parser.add_argument("--model-dir", type=str, default=os.environ["SM_MODEL_DIR"])
    parser.add_argument("--training_dir", type=str, default=os.environ["SM_CHANNEL_TRAIN"])
    parser.add_argument("--test_dir", type=str, default=os.environ["SM_CHANNEL_TEST"])
    parser.add_argument("--validation_dir", type=str, default=os.environ.get("SM_CHANNEL_VALIDATION", None))

    args, _ = parser.parse_known_args()

    os.makedirs(args.output_data_dir, exist_ok=True)
    os.makedirs(args.model_dir, exist_ok=True)

    logger = logging.getLogger(__name__)
    logging.basicConfig(
        level=logging.getLevelName("INFO"),
        handlers=[logging.StreamHandler(sys.stdout)],
        format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
    )

    train_dataset = load_from_disk(args.training_dir)
    test_dataset = load_from_disk(args.test_dir)
    validation_dataset = load_from_disk(args.validation_dir) if args.validation_dir else test_dataset

    id2label = {0: "FAKE", 1: "REAL"}
    label2id = {"FAKE": 0, "REAL": 1}

    train_labels = np.array(train_dataset["labels"])
    class_weights = compute_class_weight(
        class_weight="balanced",
        classes=np.unique(train_labels),
        y=train_labels,
    )
    class_weights_tensor = torch.tensor(class_weights, dtype=torch.float)

    class WeightedTrainer(Trainer):
        def compute_loss(self, model, inputs, return_outputs=False, **kwargs):
            labels = inputs.pop("labels")
            outputs = model(**inputs)
            logits = outputs.logits

            weights = class_weights_tensor.to(logits.device)

            loss = nn.CrossEntropyLoss(
                weight=weights,
                label_smoothing=args.label_smoothing
            )(logits, labels)

            return (loss, outputs) if return_outputs else loss

    def compute_metrics(pred):
        labels = pred.label_ids
        preds = pred.predictions.argmax(-1)
        probs = softmax(pred.predictions, axis=1)[:, 1]

        acc = accuracy_score(labels, preds)

        precision_weighted, recall_weighted, f1_weighted, _ = precision_recall_fscore_support(
            labels, preds, average="weighted", zero_division=0
        )

        precision_macro, recall_macro, f1_macro, _ = precision_recall_fscore_support(
            labels, preds, average="macro", zero_division=0
        )

        auc_score = roc_auc_score(labels, probs)
        mcc = matthews_corrcoef(labels, preds)

        precision_per_class, recall_per_class, f1_per_class, _ = precision_recall_fscore_support(
            labels, preds, average=None, zero_division=0
        )

        return {
            "accuracy": round(acc, 6),
            "precision": round(precision_weighted, 6),
            "recall": round(recall_weighted, 6),
            "f1_weighted": round(f1_weighted, 6),
            "precision_macro": round(precision_macro, 6),
            "recall_macro": round(recall_macro, 6),
            "f1_macro": round(f1_macro, 6),
            "auc": round(auc_score, 6),
            "mcc": round(mcc, 6),
            "precision_fake": round(precision_per_class[0], 6),
            "precision_real": round(precision_per_class[1], 6),
            "recall_fake": round(recall_per_class[0], 6),
            "recall_real": round(recall_per_class[1], 6),
            "f1_fake": round(f1_per_class[0], 6),
            "f1_real": round(f1_per_class[1], 6),
        }

    model = AutoModelForSequenceClassification.from_pretrained(
        args.model_name,
        num_labels=args.num_labels,
        id2label=id2label,
        label2id=label2id,
    )

    for param in model.roberta.embeddings.parameters():
        param.requires_grad = False

    for layer in model.roberta.encoder.layer[:-2]:
        for param in layer.parameters():
            param.requires_grad = False

    tokenizer = AutoTokenizer.from_pretrained(args.tokenizer_name)
    data_collator = DataCollatorWithPadding(tokenizer=tokenizer)

    training_args = TrainingArguments(
        output_dir=args.model_dir,
        num_train_epochs=args.epochs,
        per_device_train_batch_size=args.train_batch_size,
        per_device_eval_batch_size=args.eval_batch_size,
        gradient_accumulation_steps=args.gradient_accumulation_steps,
        warmup_steps=args.warmup_steps,
        weight_decay=args.weight_decay,
        evaluation_strategy="epoch",
        save_strategy="epoch",
        logging_dir=f"{args.output_data_dir}/logs",
        logging_steps=100,
        learning_rate=float(args.learning_rate),
        fp16=True,
        load_best_model_at_end=True,
        metric_for_best_model="eval_f1_macro",
        greater_is_better=True,
        save_total_limit=2,
        seed=args.seed,
        max_grad_norm=1.0,
    )

    trainer = WeightedTrainer(
        model=model,
        args=training_args,
        compute_metrics=compute_metrics,
        train_dataset=train_dataset,
        eval_dataset=validation_dataset,
        tokenizer=tokenizer,
        data_collator=data_collator,
        callbacks=[
            EarlyStoppingCallback(
                early_stopping_patience=args.early_stopping_patience
            )
        ],
    )

    logger.info("Starting training...")
    train_result = trainer.train()

    logger.info("Evaluating on test set...")
    eval_result = trainer.evaluate(eval_dataset=test_dataset)

    pd.DataFrame([eval_result]).to_csv(
        os.path.join(args.output_data_dir, "eval_results.csv"),
        index=False
    )

    pd.DataFrame([train_result.metrics]).to_csv(
        os.path.join(args.output_data_dir, "train_results.csv"),
        index=False
    )

    predictions = trainer.predict(test_dataset)

    y_true = predictions.label_ids
    y_pred = predictions.predictions.argmax(-1)

    y_probs_all = softmax(predictions.predictions, axis=1)
    y_prob = y_probs_all[:, 1]
    confidence_scores = np.max(y_probs_all, axis=1)

    class_names = ["FAKE", "REAL"]

    cm = confusion_matrix(y_true, y_pred)

    plt.figure(figsize=(6, 5))
    sns.heatmap(
        cm,
        annot=True,
        fmt="d",
        cmap="Blues",
        xticklabels=class_names,
        yticklabels=class_names,
    )
    plt.title("Confusion Matrix")
    plt.xlabel("Predicted")
    plt.ylabel("Actual")
    plt.tight_layout()
    plt.savefig(os.path.join(args.output_data_dir, "confusion_matrix.png"))
    plt.close()

    report_dict = classification_report(
        y_true,
        y_pred,
        target_names=["FAKE (0)", "REAL (1)"],
        output_dict=True,
        zero_division=0
    )

    report_df = pd.DataFrame(report_dict).transpose().reset_index()
    report_df = report_df.rename(
        columns={
            "index": "Class",
            "precision": "Precision",
            "recall": "Recall",
            "f1-score": "F1-score",
            "support": "Support",
        }
    )

    report_df.to_csv(
        os.path.join(args.output_data_dir, "classification_report.csv"),
        index=False
    )

    print("\nClassification Report:\n")
    print(
        classification_report(
            y_true,
            y_pred,
            target_names=class_names,
            zero_division=0
        )
    )

    fpr, tpr, _ = roc_curve(y_true, y_prob)
    roc_auc = auc(fpr, tpr)

    plt.figure(figsize=(6, 5))
    plt.plot(fpr, tpr, label=f"AUC = {roc_auc:.6f}")
    plt.plot([0, 1], [0, 1], "k--")
    plt.xlabel("False Positive Rate")
    plt.ylabel("True Positive Rate")
    plt.title("ROC Curve")
    plt.legend()
    plt.tight_layout()
    plt.savefig(os.path.join(args.output_data_dir, "roc_curve.png"))
    plt.close()

    plt.figure(figsize=(6, 5))
    plt.hist(confidence_scores, bins=20, edgecolor="black")
    plt.xlabel("Confidence Score")
    plt.ylabel("Number of Predictions")
    plt.title("Confidence Distribution")
    plt.tight_layout()
    plt.savefig(os.path.join(args.output_data_dir, "confidence_distribution.png"))
    plt.close()

    logs = pd.DataFrame(trainer.state.log_history)
    logs.to_csv(
        os.path.join(args.output_data_dir, "training_history.csv"),
        index=False
    )

    if "loss" in logs.columns and "eval_loss" in logs.columns:
        train_loss = logs[logs["loss"].notna()]
        eval_loss = logs[logs["eval_loss"].notna()]

        if not train_loss.empty and not eval_loss.empty:
            plt.figure(figsize=(6, 5))
            plt.plot(train_loss["step"], train_loss["loss"], label="Training Loss", linewidth=2)
            plt.plot(eval_loss["step"], eval_loss["eval_loss"], label="Validation Loss", linewidth=2)
            plt.legend()
            plt.title("Training vs Validation Loss")
            plt.xlabel("Steps")
            plt.ylabel("Loss")
            plt.tight_layout()
            plt.savefig(os.path.join(args.output_data_dir, "loss_curve.png"))
            plt.close()

    if "eval_accuracy" in logs.columns:
        eval_acc = logs[logs["eval_accuracy"].notna()]

        if not eval_acc.empty:
            plt.figure(figsize=(6, 5))
            plt.plot(eval_acc["step"], eval_acc["eval_accuracy"], label="Validation Accuracy", linewidth=2)
            plt.legend()
            plt.title("Validation Accuracy")
            plt.xlabel("Steps")
            plt.ylabel("Accuracy")
            plt.tight_layout()
            plt.savefig(os.path.join(args.output_data_dir, "accuracy_curve.png"))
            plt.close()

    if "eval_f1_macro" in logs.columns:
        eval_f1 = logs[logs["eval_f1_macro"].notna()]

        if not eval_f1.empty:
            plt.figure(figsize=(6, 5))
            plt.plot(eval_f1["step"], eval_f1["eval_f1_macro"], label="Validation Macro F1", linewidth=2)
            plt.legend()
            plt.title("Validation Macro F1 Score")
            plt.xlabel("Steps")
            plt.ylabel("Macro F1 Score")
            plt.tight_layout()
            plt.savefig(os.path.join(args.output_data_dir, "f1_curve.png"))
            plt.close()


    if args.s3_bucket:
        try:
            s3 = boto3.client("s3")
            job_name = os.environ.get("SM_TRAINING_JOB_NAME", "unknown")

            image_files = [
                "confusion_matrix.png",
                "roc_curve.png",
                "loss_curve.png",
                "accuracy_curve.png",
                "f1_curve.png",
                "confidence_distribution.png",
            ]

            for image_file in image_files:
                local_path = os.path.join(args.output_data_dir, image_file)

                if os.path.exists(local_path):
                    s3.upload_file(
                        local_path,
                        args.s3_bucket,
                        f"{job_name}/plots/{image_file}"
                    )
                    logger.info(
                        f"Uploaded {image_file} to s3://{args.s3_bucket}/{job_name}/plots/{image_file}"
                    )

        except Exception as e:
            logger.warning(f"Failed to upload plots to S3: {e}")

    model.config.id2label = id2label
    model.config.label2id = label2id

    trainer.save_model(args.model_dir)
    tokenizer.save_pretrained(args.model_dir)

    logger.info("Training complete!")