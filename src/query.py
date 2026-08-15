"""Deterministic evidence index and retrieval.

This is the 'vector database'.  It has no daemon, no account manager, no region,
and no venture-capital-funded control plane.  The implementation uses a stable
term-frequency index and cosine similarity over sparse integer vectors.
"""

from __future__ import annotations

import math
import re
from collections import Counter
from dataclasses import dataclass
from typing import Iterable

from .receipts import Receipt


TOKEN_RE = re.compile(r"[a-z0-9][a-z0-9_.:+/-]*", re.I)


@dataclass(frozen=True)
class Hit:
    score: float
    receipt_id: str
    model_id: str
    evidence: str
    source_sha256: str


def tokens(text: str) -> list[str]:
    return [m.group(0).lower() for m in TOKEN_RE.finditer(text)]


def receipt_text(receipt: Receipt) -> str:
    fields = [
        receipt.model_id,
        receipt.family,
        receipt.model_digest,
        receipt.identity_text,
        receipt.fabricated_premise_text,
        receipt.visible_text,
        f"math score {receipt.math_score}" if receipt.math_score is not None else "",
        f"exact repeat {receipt.exact_repeat}" if receipt.exact_repeat is not None else "",
    ]
    return "\n".join(part for part in fields if part)


def _vector(text: str) -> Counter[str]:
    return Counter(tokens(text))


def _cosine(left: Counter[str], right: Counter[str]) -> float:
    if not left or not right:
        return 0.0
    dot = sum(value * right.get(term, 0) for term, value in left.items())
    if dot == 0:
        return 0.0
    left_norm = math.sqrt(sum(v * v for v in left.values()))
    right_norm = math.sqrt(sum(v * v for v in right.values()))
    return dot / (left_norm * right_norm)


def search(query: str, receipts: Iterable[Receipt], limit: int = 5) -> list[Hit]:
    qv = _vector(query)
    hits: list[Hit] = []
    for receipt in receipts:
        evidence = receipt_text(receipt)
        score = _cosine(qv, _vector(evidence))
        if score <= 0:
            continue
        hits.append(
            Hit(
                score=score,
                receipt_id=receipt.receipt_id,
                model_id=receipt.model_id,
                evidence=evidence,
                source_sha256=receipt.source_sha256,
            )
        )
    hits.sort(key=lambda hit: (-hit.score, hit.model_id, hit.receipt_id))
    return hits[:limit]


def answer(query: str, receipts: Iterable[Receipt], limit: int = 5) -> str:
    hits = search(query, receipts, limit=limit)
    if not hits:
        return "NO EVIDENCE MATCHED. THE SYSTEM HAS DECLINED TO HALLUCINATE A QUARTERLY INSIGHT."
    lines = [f"{len(hits)} EVIDENCE MATCHES", ""]
    for index, hit in enumerate(hits, start=1):
        lines.append(f"[{index}] {hit.model_id} score={hit.score:.4f}")
        lines.append(f"    receipt={hit.receipt_id}")
        lines.append(f"    sha256={hit.source_sha256}")
    lines += ["", "ANSWER MODE: RETRIEVAL ONLY. MANAGEMENT MAY ADD THEIR OWN CONFIDENCE SLIDE."]
    return "\n".join(lines)
