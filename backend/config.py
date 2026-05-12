import os
from dotenv import load_dotenv

load_dotenv()

SAGEMAKER_ENDPOINT = os.getenv("SAGEMAKER_ENDPOINT")
AWS_REGION         = os.getenv("AWS_REGION", "us-east-1")
GOOGLE_API_KEY     = os.getenv("GOOGLE_API_KEY")
ANTHROPIC_API_KEY  = os.getenv("ANTHROPIC_API_KEY")
