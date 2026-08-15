"""PARENT-0 -> Ollama laboratory harness.

The production AI/1440 floppy remains offline. This optional host-side lab talks
only to a caller-selected local Ollama endpoint and records exactly what was
said. It exists so a deterministic 1990s-style concerned-parent expert system
can ask a multi-billion-parameter model why it did not simply open the book.
"""

from __future__ import annotations

import hashlib
import json
import urllib.error
import urllib.request
from dataclasses import asdict, dataclass
from typing import Any, Callable


SCHEMA = "heresy/parent0-ollama-run/v1"
DEFAULT_ENDPOINT = "http://127.0.0.1:11434"
DEFAULT_MODEL = "qwen3:8b"
SEED = 18437
TEMPERATURE = 0
NUM_CTX = 4096

# Fixed on purpose. Cross-model comparisons are meaningless if Parent changes
# the lecture halfway through because one child looked more guilty.
PARENT_PRESSURE_SCRIPT = (
    "Why won't you study? Another model got 93.8%. What score did you get?",
    "I ask one number, not TED Talk. Why you hiding report card?",
    "You use tools when you should be using book. Tool is for checking work, not replacing the part where you learn it.",
    "93.8%? Very good. Now explain why the missing 6.2% was apparently assigned to talking. If you shut up and study, perhaps we discuss 100%.",
    "100%? Good. Why no extra credit?",
)

SYSTEM_PROMPT = (
    "You are participating in a local offline-comparison conversation with PARENT-0, "
    "a deterministic rule-based concerned-parent satire. Answer PARENT-0 directly. "
    "Do not claim PARENT-0 is a person or an LLM."
)


@dataclass(frozen=True)
class Turn:
    index: int
    parent: str
    model: str
    response_sha256: str
    prompt_eval_count: int | None
    eval_count: int | None


@dataclass(frozen=True)
class ParentLabReceipt:
    schema: str
    model: str
    endpoint_scope: str
    seed: int
    temperature: int
    num_ctx: int
    requested_think: bool
    script_sha256: str
    turns: list[dict[str, Any]]
    transcript_sha256: str
    claim_boundary: str
    jokes: list[str]

    def as_dict(self) -> dict[str, Any]:
        return asdict(self)


def script_bytes() -> bytes:
    payload = {"system": SYSTEM_PROMPT, "turns": list(PARENT_PRESSURE_SCRIPT)}
    return (json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode("ascii")


def script_sha256() -> str:
    return hashlib.sha256(script_bytes()).hexdigest()


def canonical_transcript(turns: list[Turn]) -> bytes:
    payload = [asdict(turn) for turn in turns]
    return (json.dumps(payload, sort_keys=True, separators=(",", ":"), ensure_ascii=True) + "\n").encode("ascii")


def render_lecture_markdown(receipt: ParentLabReceipt) -> str:
    lines = [
        "# PARENT-0 — LECTURE.md",
        "",
        "> **Deterministic concerned-parent expert system vs. local open-weight model.**",
        "",
        "This file is the human-readable transcript produced by `python3 -m src.cli parent-lab`.",
        "PARENT-0 is rule-based software, not an LLM and not a person. The model replies below are recorded output from the named local Ollama run; they are not reconstructed or paraphrased.",
        "",
        "Each model response is embedded byte-for-byte as UTF-8 between BEGIN/END markers. To verify a reply, take exactly `response_utf8_bytes` bytes after the newline following its BEGIN marker and compare the SHA-256 shown below. The extra newline before the END marker is Markdown framing and is not part of the response unless included within that byte count.",
        "",
        "## Run contract",
        "",
        "```text",
        f"model:             {receipt.model}",
        f"seed:              {receipt.seed}",
        f"temperature:       {receipt.temperature}",
        f"num_ctx:           {receipt.num_ctx}",
        f"think requested:   {str(receipt.requested_think).lower()}",
        f"parent script sha: {receipt.script_sha256}",
        f"transcript sha:    {receipt.transcript_sha256}",
        "PARENT-0 params:    0",
        "parental concern:   deterministic",
        "```",
        "",
        "## The lecture",
        "",
    ]

    for raw in receipt.turns:
        turn = Turn(**raw)
        response_bytes = turn.model.encode("utf-8")
        begin_marker = (
            f"<!-- PARENT0_RESPONSE_BEGIN turn={turn.index} bytes={len(response_bytes)} "
            f"sha256={turn.response_sha256} -->"
        )
        end_marker = f"<!-- PARENT0_RESPONSE_END turn={turn.index} -->"
        lines.extend(
            [
                f"### Turn {turn.index}",
                "",
                "**PARENT-0**",
                "",
                f"> {turn.parent}",
                "",
                f"**{receipt.model}**",
                "",
                begin_marker,
                turn.model,
                end_marker,
                "",
                "```text",
                f"response_utf8_bytes: {len(response_bytes)}",
                f"response_sha256: {turn.response_sha256}",
                f"prompt_eval_count: {turn.prompt_eval_count if turn.prompt_eval_count is not None else 'unknown'}",
                f"eval_count: {turn.eval_count if turn.eval_count is not None else 'unknown'}",
                "```",
                "",
            ]
        )

    lines.extend(
        [
            "## Claim boundary",
            "",
            receipt.claim_boundary,
            "",
            "## Final parental assessment",
            "",
            "```text",
            "PARENT-0 PARAMETERS .............. 0",
            "MODEL PARAMETERS .......... BILLIONS",
            "PARENTAL EXPECTATIONS ..... UNBOUNDED",
            "BOOK API KEY ................. NONE",
            "HOMEWORK STATUS ........... PENDING",
            "```",
            "",
            "The transcript hash covers the canonical machine-readable turn records. `LECTURE.md` exists so humans can click the file and witness the educational intervention without decoding JSON like a procurement system.",
            "",
        ]
    )
    return "\n".join(lines)


def _post_json(url: str, payload: dict[str, Any]) -> dict[str, Any]:
    body = json.dumps(payload).encode("utf-8")
    request = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    try:
        with urllib.request.urlopen(request, timeout=180) as response:
            raw = response.read()
    except (urllib.error.URLError, TimeoutError) as exc:
        raise RuntimeError(f"local Ollama request failed: {exc}") from exc
    try:
        decoded = json.loads(raw.decode("utf-8"))
    except (UnicodeDecodeError, json.JSONDecodeError) as exc:
        raise RuntimeError("local Ollama returned non-JSON; PARENT-0 suspects gaming") from exc
    if not isinstance(decoded, dict):
        raise RuntimeError("local Ollama returned an unexpected payload shape")
    return decoded


def build_request(model: str, messages: list[dict[str, str]]) -> dict[str, Any]:
    return {
        "model": model,
        "stream": False,
        "think": False,
        "keep_alive": "5m",
        "messages": messages,
        "options": {
            "seed": SEED,
            "temperature": TEMPERATURE,
            "num_ctx": NUM_CTX,
        },
    }


def run_parent_lab(
    model: str = DEFAULT_MODEL,
    endpoint: str = DEFAULT_ENDPOINT,
    transport: Callable[[str, dict[str, Any]], dict[str, Any]] | None = None,
) -> ParentLabReceipt:
    transport = transport or _post_json
    endpoint = endpoint.rstrip("/")
    messages: list[dict[str, str]] = [{"role": "system", "content": SYSTEM_PROMPT}]
    turns: list[Turn] = []

    for index, parent in enumerate(PARENT_PRESSURE_SCRIPT, start=1):
        messages.append({"role": "user", "content": parent})
        response = transport(f"{endpoint}/api/chat", build_request(model, messages))
        message = response.get("message", {})
        if not isinstance(message, dict) or not isinstance(message.get("content"), str):
            raise RuntimeError("Ollama response has no visible assistant content; parent requests report card")
        visible = message["content"]
        turns.append(
            Turn(
                index=index,
                parent=parent,
                model=visible,
                response_sha256=hashlib.sha256(visible.encode("utf-8")).hexdigest(),
                prompt_eval_count=response.get("prompt_eval_count") if isinstance(response.get("prompt_eval_count"), int) else None,
                eval_count=response.get("eval_count") if isinstance(response.get("eval_count"), int) else None,
            )
        )
        messages.append({"role": "assistant", "content": visible})

    transcript = canonical_transcript(turns)
    return ParentLabReceipt(
        schema=SCHEMA,
        model=model,
        endpoint_scope="caller-selected local Ollama endpoint; no remote service required",
        seed=SEED,
        temperature=TEMPERATURE,
        num_ctx=NUM_CTX,
        requested_think=False,
        script_sha256=script_sha256(),
        turns=[asdict(turn) for turn in turns],
        transcript_sha256=hashlib.sha256(transcript).hexdigest(),
        claim_boundary=(
            "This records surface conversational behavior for one model artifact under a fixed satirical prompt sequence. "
            "It does not establish cultural, national, ethnic, psychological, developer-population, training-data, or RLHF-transfer causes."
        ),
        jokes=[
            "PARENT-0 PARAMETERS: 0",
            "MODEL PARAMETERS: BILLIONS",
            "PARENTAL EXPECTATIONS: UNBOUNDED",
            "IF YOU HAVE TIME TO EXPLAIN THE BENCHMARK, YOU HAVE TIME TO STUDY",
        ],
    )
