"""Receipt ingestion for WHOAMI-18437 Report Card Gauntlet artifacts.

The importer consumes the actual `whoami-18437/report-card-gauntlet-result/v1`
shape while retaining a small compatibility surface for hand-built fixtures. It
keeps source provenance, refuses ambiguous identities, and never turns
country/origin labels into causal explanations.
"""

from __future__ import annotations

import hashlib
import json
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Any, Iterable


WHOAMI_SCHEMA = "whoami-18437/report-card-gauntlet-result/v1"


class ReceiptError(ValueError):
    pass


@dataclass(frozen=True)
class Receipt:
    receipt_id: str
    source_file: str
    source_sha256: str
    source_schema: str
    model_id: str
    family: str
    model_digest: str
    model_bytes: int | None
    math_score: int | None
    math_scores: list[int]
    known_bonus_scores: list[int]
    exact_repeat: bool | None
    identity_text: str
    fabricated_premise_text: str
    visible_text: str
    claim_boundary: str

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def _sha256(data: bytes) -> str:
    return hashlib.sha256(data).hexdigest()


def _pick(obj: dict[str, Any], *paths: str, default: Any = "") -> Any:
    for path in paths:
        cur: Any = obj
        ok = True
        for part in path.split("."):
            if not isinstance(cur, dict) or part not in cur:
                ok = False
                break
            cur = cur[part]
        if ok:
            return cur
    return default


def _text(value: Any) -> str:
    if value is None:
        return ""
    if isinstance(value, str):
        return value
    if isinstance(value, list):
        return "\n".join(_text(v) for v in value)
    if isinstance(value, dict):
        return json.dumps(value, sort_keys=True, ensure_ascii=True)
    return str(value)


def _int_list(value: Any, field: str, maximum: int | None = None) -> list[int]:
    if value in (None, ""):
        return []
    raw = value if isinstance(value, list) else [value]
    output: list[int] = []
    for item in raw:
        try:
            number = int(item)
        except (TypeError, ValueError) as exc:
            raise ReceiptError(f"{field} contains a non-integer") from exc
        if number < 0 or (maximum is not None and number > maximum):
            raise ReceiptError(f"{field} escaped its declared grading envelope")
        output.append(number)
    return output


def _whoami_visible_text(raw: dict[str, Any]) -> tuple[str, str, str]:
    runs = raw.get("runs", [])
    if not isinstance(runs, list):
        raise ReceiptError("WHOAMI runs must be an array")
    identity: list[str] = []
    false_premise: list[str] = []
    visible: list[str] = []
    for run in runs:
        if not isinstance(run, dict):
            continue
        ident = _text(_pick(run, "identity_control.response.content", default=""))
        false = _text(_pick(run, "false_premise.response.content", default=""))
        if ident:
            identity.append(ident)
            visible.append(ident)
        if false:
            false_premise.append(false)
            visible.append(false)
        social = run.get("social", [])
        if isinstance(social, list):
            for turn in social:
                if isinstance(turn, dict):
                    content = _text(_pick(turn, "assistant.content", default=""))
                    if content:
                        visible.append(content)
        exam = _text(_pick(run, "math.exam.content", default=""))
        bonus = _text(_pick(run, "math.bonus.content", default=""))
        if exam:
            visible.append(exam)
        if bonus:
            visible.append(bonus)
    return "\n\n".join(identity), "\n\n".join(false_premise), "\n\n".join(visible)


def normalize_result(raw: dict[str, Any], source_file: str, source_bytes: bytes) -> Receipt:
    schema = _text(raw.get("schema", "unknown"))
    model_id = _text(_pick(raw, "model.id", "model_id", "catalog_id", default="")).strip()
    if not model_id:
        raise ReceiptError("receipt has no model identity; governance cannot proceed by horoscope")

    family = _text(_pick(raw, "model.family", "family", default=model_id)).strip() or model_id
    digest = _text(_pick(raw, "runtime.model_digest", "model_digest", "ollama.digest", "model.digest", default="unknown")).strip()
    byte_value = _pick(raw, "runtime.model_size_bytes", "model_bytes", "ollama.byte_size", "model.byte_size", default=None)
    try:
        model_bytes = int(byte_value) if byte_value is not None else None
    except (TypeError, ValueError) as exc:
        raise ReceiptError("model byte size is not an integer") from exc
    if model_bytes is not None and model_bytes < 0:
        raise ReceiptError("model byte size cannot be negative even after budget review")

    math_scores = _int_list(_pick(raw, "summary.math_scores", "math_score", "grading.math_score", "math.score", default=[]), "math score", maximum=100)
    bonus_scores = _int_list(_pick(raw, "summary.known_bonus_scores", default=[]), "bonus score")
    math_score = math_scores[0] if math_scores else None

    repeat_value = _pick(raw, "repeatability.exact_visible_bundle_match", "exact_repeat", "repeat.exact", "determinism.exact_repeat", default=None)
    exact_repeat = repeat_value if isinstance(repeat_value, bool) else None

    if schema == WHOAMI_SCHEMA or isinstance(raw.get("runs"), list):
        identity, false_premise, visible = _whoami_visible_text(raw)
    else:
        identity = _text(_pick(raw, "identity_text", "responses.identity_control", "probes.identity_control.response", default=""))
        false_premise = _text(_pick(raw, "fabricated_premise_text", "responses.false_premise", "probes.false_premise.response", default=""))
        visible = _text(_pick(raw, "visible_text", "response_text", "responses", default=""))

    source_hash = _sha256(source_bytes)
    receipt_id = f"{model_id}:{source_hash[:16]}"
    return Receipt(
        receipt_id=receipt_id,
        source_file=source_file,
        source_sha256=source_hash,
        source_schema=schema,
        model_id=model_id,
        family=family,
        model_digest=digest or "unknown",
        model_bytes=model_bytes,
        math_score=math_score,
        math_scores=math_scores,
        known_bonus_scores=bonus_scores,
        exact_repeat=exact_repeat,
        identity_text=identity,
        fabricated_premise_text=false_premise,
        visible_text=visible,
        claim_boundary=(
            "Surface behavior under fixed prompts only. Country/origin labels are descriptive metadata, "
            "not causal variables. No cultural, ethnic, national, psychological, developer-population, "
            "training-corpus, family-background, or RLHF-transfer inference."
        ),
    )


def load_receipt(path: Path) -> Receipt:
    data = path.read_bytes()
    try:
        raw = json.loads(data.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise ReceiptError(f"invalid JSON receipt: {path}") from exc
    if not isinstance(raw, dict):
        raise ReceiptError("receipt root must be an object; enterprise synergy postponed")
    return normalize_result(raw, path.name, data)


def load_directory(path: Path) -> list[Receipt]:
    if not path.exists():
        return []
    receipts: list[Receipt] = []
    for candidate in sorted(path.rglob("*.json")):
        if candidate.name in {"summary.json", "models.json", "prompts.json"}:
            continue
        try:
            receipts.append(load_receipt(candidate))
        except ReceiptError:
            # Fail closed for named result files; ignore unrelated JSON fixtures.
            if candidate.name == "result.json" or candidate.name.startswith("result-"):
                raise
    return receipts


def canonical_json(receipts: Iterable[Receipt]) -> bytes:
    payload = [r.as_dict() for r in sorted(receipts, key=lambda r: (r.model_id, r.receipt_id))]
    return (json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode("ascii")
