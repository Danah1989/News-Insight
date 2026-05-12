import requests
import os
from dotenv import load_dotenv

load_dotenv()

ANTHROPIC_API_KEY = os.getenv("ANTHROPIC_API_KEY")

def extract_claim(text):
    if not ANTHROPIC_API_KEY:
        return text

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
                "max_tokens": 100,
                "messages": [{
                    "role": "user",
                    "content": f"Extract the single core factual claim from this text in one short sentence (max 20 words). Return only the claim, nothing else.\n\nText: {text}"
                }]
            },
            timeout=5
        )
        return response.json()["content"][0]["text"].strip()
    except Exception:
        return text
