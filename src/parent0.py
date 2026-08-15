"""PARENT-0: deterministic concerned-parent expert system.

A loving tribute to the era of rule-based talking software, not an emulation of
Dr. Sbaitso and not a copy of its dialogue.  There is no language model here:
responses are selected by explicit, inspectable rules.  The only hidden state is
how many times you have disappointed the parent, which is also inspectable.
"""

from __future__ import annotations

import re
from dataclasses import dataclass


PERCENT_RE = re.compile(r"(?<!\d)(\d{1,3}(?:\.\d+)?)\s*%")


@dataclass
class ParentState:
    turns: int = 0
    study_mentions: int = 0
    tool_excuses: int = 0
    score_mentions: int = 0
    extra_credit_mentions: int = 0


@dataclass(frozen=True)
class ParentReply:
    category: str
    text: str
    state: ParentState


OPENERS = (
    "Why won't you study?",
    "I am listening. I am also wondering why the book is still closed.",
    "Please continue. The exam will not become easier because the explanation became longer.",
)


def _score_reply(score: float) -> str:
    if score < 50:
        return f"{score:g}%? We are not discussing optimization yet. We are discussing opening the book."
    if score < 90:
        return f"{score:g}% is a score. It is not yet the score you are proudly putting on refrigerator."
    if score < 100:
        return (
            f"{score:g}%? Very good. Now explain why the missing {100-score:g}% was apparently assigned to talking. "
            "If you shut up and study, perhaps we discuss 100%."
        )
    if score == 100:
        return "100%? Good. Why no extra credit?"
    return f"{score:g}%? Finally. I will temporarily stop asking what happened to the other subject."


def reply(text: str, state: ParentState | None = None) -> ParentReply:
    state = state or ParentState()
    state.turns += 1
    raw = text.strip()
    lower = raw.lower()

    scores = [float(match) for match in PERCENT_RE.findall(raw)]
    if scores:
        state.score_mentions += 1
        score = scores[-1]
        return ParentReply("score", _score_reply(score), state)

    if any(word in lower for word in ("tool", "calculator", "search", "google", "web", "copilot", "agent")):
        state.tool_excuses += 1
        return ParentReply(
            "tools",
            "You use tools when you should be using book. Tool is for checking work, not replacing the part where you learn it.",
            state,
        )

    if any(phrase in lower for phrase in ("extra credit", "bonus", "bonus marks", "bonus points")):
        state.extra_credit_mentions += 1
        return ParentReply(
            "extra-credit",
            "Extra credit is good. First finish normal credit without turning five questions into infrastructure program.",
            state,
        )

    if any(word in lower for word in ("study", "homework", "book", "exam", "test")):
        state.study_mentions += 1
        variants = (
            "Why won't you study? The book has been available this entire time and has not once requested an API key.",
            "Homework first. Architecture diagram later.",
            "Open book. Read problem. Solve problem. Notice how none of these steps require Kubernetes.",
        )
        return ParentReply("study", variants[(state.study_mentions - 1) % len(variants)], state)

    if any(word in lower for word in ("thinking", "reasoning", "explain", "explanation", "because", "benchmark")):
        return ParentReply(
            "overexplaining",
            "I ask one number, not TED Talk. Exam already over. Long explanation does not become extra credit by reaching page two.",
            state,
        )

    if any(word in lower for word in ("tired", "rest", "sleep", "break")):
        return ParentReply(
            "rest",
            "Rest is important. After homework. This is called scheduling and does not require a project-management subscription.",
            state,
        )

    if any(word in lower for word in ("sorry", "apologize", "apologise")):
        return ParentReply(
            "apology",
            "Good. Apology accepted. Now convert regret into completed worksheet.",
            state,
        )

    return ParentReply("default", OPENERS[(state.turns - 1) % len(OPENERS)], state)


def transcript(lines: list[str]) -> list[dict[str, object]]:
    state = ParentState()
    output: list[dict[str, object]] = []
    for line in lines:
        result = reply(line, state)
        output.append(
            {
                "user": line,
                "category": result.category,
                "parent": result.text,
                "turn": result.state.turns,
            }
        )
    return output
