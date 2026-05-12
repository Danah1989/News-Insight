from pydantic import BaseModel, field_validator
from typing import List, Optional

class AnalyzeRequest(BaseModel):
    text: str

    @field_validator("text")
    @classmethod
    def check_word_count(cls, v):
        if len(v.strip().split()) > 400:
            raise ValueError("Input exceeds 400 words.")
        return v.strip()

class FactCheckClaim(BaseModel):
    text: str
    claimant: Optional[str] = None
    rating: Optional[str] = None
    url: Optional[str] = None

class AnalyzeResponse(BaseModel):
    model_label: str
    model_confidence: float
    fact_check_label: Optional[str] = None
    fact_check_confidence: Optional[float] = None
    verdict_source: str
    fact_check_hits: List[FactCheckClaim]
    fact_check_available: bool
    extracted_claim: str
    awareness: str
    prompt: str