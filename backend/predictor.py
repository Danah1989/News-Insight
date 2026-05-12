import boto3
import json
from config import SAGEMAKER_ENDPOINT, AWS_REGION

client = boto3.client("sagemaker-runtime", region_name=AWS_REGION)

LABEL_MAP = {"FAKE": "Misleading", "REAL": "Reliable"}

def predict(text):
    response = client.invoke_endpoint(
        EndpointName=SAGEMAKER_ENDPOINT,
        ContentType="application/json",
        Body=json.dumps({"inputs": text})
    )
    result = json.loads(response["Body"].read())
    top = max(result, key=lambda x: x["score"])
    label = LABEL_MAP.get(top["label"], top["label"])
    confidence = round(top["score"] * 100, 2)
    return {"model_label": label, "confidence": confidence}
