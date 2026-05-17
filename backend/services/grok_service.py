from openai import OpenAI
import os
import re
import json
import random
import time
from typing import Dict, List, Tuple
from config.settings import settings
from logger import get_logger

logger = get_logger(__name__)

# Optional RAG
try:
    import numpy as np
    from sklearn.feature_extraction.text import TfidfVectorizer
    from sklearn.metrics.pairwise import cosine_similarity
    import pickle
    SKLEARN_AVAILABLE = True
except:
    SKLEARN_AVAILABLE = False


class GrokService:
    def __init__(self):
        self.client = OpenAI(
            api_key=settings.GROQ_API_KEY,
            base_url=settings.GROQ_BASE_URL
        )
        self.models = self._build_model_priority()

        self.safety_prompts = ["kill", "bomb", "hate", "illegal", "hack", "drug"]
        self.datasets = self.load_datasets()

        self.vectorizers = {}
        self.tfidf_matrices = {}

        if SKLEARN_AVAILABLE:
            self.initialize_rag()

    def _build_model_priority(self) -> List[str]:
        models: List[str] = [settings.GROK_MODEL, *settings.GROK_FALLBACK_MODELS]
        deduped: List[str] = []
        for model in models:
            if model and model not in deduped:
                deduped.append(model)
        return deduped

    def _is_model_decommissioned_error(self, error: Exception) -> bool:
        message = str(error).lower()
        return (
            "model_decommissioned" in message
            or "decommissioned" in message
            or "no longer supported" in message
        )

    def _create_completion(self, messages, temperature=0.7, max_tokens=1500):
        last_error = None

        for index, model in enumerate(self.models):
            try:
                response = self.client.chat.completions.create(
                    model=model,
                    messages=messages,
                    temperature=temperature,
                    max_tokens=max_tokens,
                )
                if index > 0:
                    logger.warning("Primary model unavailable; fallback model used: %s", model)
                return response
            except Exception as error:
                last_error = error
                if self._is_model_decommissioned_error(error):
                    logger.warning("Model '%s' is unavailable, trying next fallback", model)
                    continue
                raise

        if last_error:
            raise last_error
        raise RuntimeError("No AI model configured for completion")

    # ---------------- DATA ---------------- #
    def load_datasets(self) -> Dict[str, List[Dict]]:
        datasets = {}
        base_path = "datasets/"

        for subject in ["coding", "math", "ielts", "physics"]:
            path = os.path.join(base_path, subject, "train_clean.json")
            if os.path.exists(path):
                with open(path, "r", encoding="utf-8") as f:
                    datasets[subject] = json.load(f)

        return datasets

    # ---------------- RAG ---------------- #
    def initialize_rag(self):
        for subject, data in self.datasets.items():
            texts = [f"{d['prompt']} {d['answer']}" for d in data]
            vectorizer = TfidfVectorizer(max_features=1000)
            matrix = vectorizer.fit_transform(texts)

            self.vectorizers[subject] = vectorizer
            self.tfidf_matrices[subject] = matrix

    def retrieve_context(self, subject: str, query: str, top_k=3):
        if subject not in self.vectorizers:
            return ""

        vec = self.vectorizers[subject].transform([query])
        sims = cosine_similarity(vec, self.tfidf_matrices[subject])[0]
        idxs = sims.argsort()[-top_k:][::-1]

        data = self.datasets[subject]
        return "\n".join([data[i]["answer"] for i in idxs])

    # ---------------- UTIL ---------------- #
    def is_safe(self, prompt):
        return not any(word in prompt.lower() for word in self.safety_prompts)

    def detect_language(self, text):
        if any(w in text.lower() for w in ["kya", "kaise", "kyun"]):
            return "Roman Urdu"
        return "English"

    # ---------------- CORE ---------------- #
    def generate_response(self, prompt: str, subject="general"):
        if not self.is_safe(prompt):
            return "Only educational queries allowed."

        lang = self.detect_language(prompt)
        context = self.retrieve_context(subject, prompt)

        system_prompt = f"""
You are an expert {subject} tutor.

Language: {lang}

Context:
{context}

Explain clearly with steps and examples.
"""

        try:
            response = self._create_completion(
                messages=[
                    {"role": "system", "content": system_prompt},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1500
            )

            return response.choices[0].message.content

        except Exception as e:
            logger.exception("AI response generation failed")
            return "Error: AI service is temporarily unavailable. Please try again in a moment."

    # ---------------- CODE ANALYSIS ---------------- #
    def analyze_code(self, code: str):
        prompt = f"""
Analyze this code and fix errors:

```python
{code}
```
"""

        try:
            response = self._create_completion(
                messages=[
                    {"role": "system", "content": "You are an expert Python tutor and debugger."},
                    {"role": "user", "content": prompt}
                ],
                temperature=0.7,
                max_tokens=1500
            )

            return response.choices[0].message.content

        except Exception as e:
            logger.exception("Code analysis failed")
            return "Error: AI service is temporarily unavailable. Please try again in a moment."