from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from schemas import AnalyzeRequest, AnalyzeResponse
from predictor import predict
from fact_check import search_fact_checks
from claim_extractor import extract_claim
from awareness import generate_awareness_and_verdict

app = FastAPI()
app.add_middleware(CORSMiddleware, allow_origins=["*"], allow_methods=["*"], allow_headers=["*"])

@app.get("/health")
def health():
    return {"status": "ok"}

@app.post("/analyze", response_model=AnalyzeResponse)
def analyze(request: AnalyzeRequest):
    try:
        model_result = predict(request.text)
    except Exception as e:
        raise HTTPException(status_code=503, detail=str(e))

    claim = extract_claim(request.text)
    fact_hits, fc_available = search_fact_checks(claim)
    awareness, prompt_text, final_label, final_confidence, verdict_source, fc_label, fc_confidence = generate_awareness_and_verdict(
        request.text,
        model_result["model_label"],
        model_result["confidence"],
        fact_hits
    )

    return AnalyzeResponse(
        model_label=model_result["model_label"],
        model_confidence=model_result["confidence"],
        fact_check_label=fc_label,
        fact_check_confidence=fc_confidence,
        verdict_source=verdict_source,
        fact_check_hits=fact_hits,
        fact_check_available=fc_available,
        extracted_claim=claim,
        awareness=awareness,
        prompt=prompt_text
    )
