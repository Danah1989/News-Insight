import requests
from config import ANTHROPIC_API_KEY

RATING_MAP = {
    "pants on fire":      ("Misleading", 99),
    "false":              ("Misleading", 95),
    "mostly false":       ("Misleading", 80),
    "misleading":         ("Misleading", 75),
    "spins the facts":    ("Misleading", 70),
    "distorts the facts": ("Misleading", 70),
    "no evidence":        ("Misleading", 75),
    "incorrect":          ("Misleading", 85),
    "fabricated":         ("Misleading", 95),
    "not credible":       ("Misleading", 80),
    "rejected":           ("Misleading", 80),
    "baseless":           ("Misleading", 85),
    "unfounded":          ("Misleading", 80),
    "mostly true":        ("Reliable", 80),
    "true":               ("Reliable", 95),
    "correct":            ("Reliable", 95),
    "accurate":           ("Reliable", 95),
    "verified":           ("Reliable", 99),
}

def get_fact_check_verdict(fact_check_hits):
    best_label = None
    best_confidence = 0
    for hit in fact_check_hits:
        if not hit.rating:
            continue
        low = hit.rating.lower().strip()
        for key, (label, confidence) in RATING_MAP.items():
            if key in low:
                if confidence > best_confidence:
                    best_confidence = confidence
                    best_label = label
                break
    if best_label:
        return best_label, best_confidence
    return None, None

def generate_awareness_and_verdict(text, model_label, model_confidence, fact_check_hits):
    if not ANTHROPIC_API_KEY:
        return "", model_label, model_confidence, "model", None, None

    fc_label, fc_confidence = get_fact_check_verdict(fact_check_hits)

    if fact_check_hits:
        ratings = [f"{hit.claimant}: {hit.rating}" for hit in fact_check_hits if hit.rating]
        fact_check_summary = "Fact check findings: " + ", ".join(ratings)
    else:
        fact_check_summary = "No matching fact checks found."

    if fc_label:
        final_label = fc_label
        final_confidence = fc_confidence
        verdict_source = "fact_check"
    else:
        final_label = model_label
        final_confidence = model_confidence
        verdict_source = "model"

    if verdict_source == "fact_check":
        prompt_text = ""
    else:
        prompt_text = "For additional verification, we recommend checking trusted news sources."

    awareness_prompt = f"""You are an educational assistant helping users think critically about news claims.

A user saw this text: {text}

Write a short explanation (2–3 sentences) that:

- supports and is consistent with the model’s prediction (Reliable or Misleading)
- Explains why the text was classified this way by pointing out specific signals in the content
- Includes a subtle educational insight that helps the user understand how to evaluate similar news in general
- Uses simple, conversational language suitable for non-technical users
- Uses cautious, non-absolute language (e.g., "suggests", "appears", "tends to") to avoid implying complete certainty
-Suggests general types of sources to verify this specific claim (e.g., official statements, scientific organizations, trusted news outlets) without implying direct verification

Rules:
- Do not mention any verdict, result, score, or what any system thinks
- Do not express your own opinion on whether it is true or false
- Return plain text only, no markdown, no headers, no bullet points"""

    try:
        response = requests.post(
            "https://api.anthropic.com/v1/messages",
            headers={
                "x-api-key": ANTHROPIC_API_KEY,
                "anthropic-version": "2023-06-01",
                "content-type": "application/json"
            },
            json={
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 150,
                "messages": [{"role": "user", "content": awareness_prompt}]
            },
            timeout=10
        )
        awareness = response.json()["content"][0]["text"].strip()
    except Exception:
        awareness = ""

    return awareness, prompt_text, final_label, final_confidence, verdict_source, fc_label, fc_confidence
