import requests
from schemas import FactCheckClaim
from config import GOOGLE_API_KEY

FACT_CHECK_URL = "https://factchecktools.googleapis.com/v1alpha1/claims:search"

def search_fact_checks(claim):
    if not GOOGLE_API_KEY:
        return [], False
    try:
        resp = requests.get(FACT_CHECK_URL, params={
            "query": claim,
            "key": GOOGLE_API_KEY,
            "pageSize": 5,
            "languageCode": "en-US"
        }, timeout=5)
        resp.raise_for_status()
        results = []
        for item in resp.json().get("claims", []):
            review = item.get("claimReview", [{}])[0]
            results.append(FactCheckClaim(
                text=item.get("text", ""),
                claimant=item.get("claimant"),
                rating=review.get("textualRating"),
                url=review.get("url")
            ))
        return results, True
    except Exception:
        return [], False
