"""Command-line front end for HERESY AI/1440."""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path

from .fat12 import ImageFile, IMAGE_SIZE, build_image
from .heretic0 import run as run_heretic0
from .parent0 import ParentState, reply as parent_reply
from .parent_lab import (
    DEFAULT_ENDPOINT,
    DEFAULT_MODEL,
    PARENT_PRESSURE_SCRIPT,
    render_lecture_markdown,
    run_parent_lab,
    script_sha256,
)
from .query import answer
from .receipts import canonical_json, load_directory


README_TXT = """HERESY AI/1440\r\n\r\nZERO-PARAMETER ENTERPRISE MODEL GOVERNANCE APPLIANCE\r\n\r\nThis FAT12 image contains deterministic evidence exports, provenance hashes,\r\nHERETIC-0 results and PARENT-0 doctrine. It does not contain an LLM. This fact\r\nhas survived architecture review.\r\n\r\nFOUNDATION MODEL: NONE\r\nPARAMETERS: 0\r\nGPU CLUSTER: NO\r\nVECTOR DATABASE: A FILE\r\nKUBERNETES: DENIED\r\nTELEMETRY: SHA-256\r\nMONTHLY CLOUD COST: $0.00\r\n\r\nThe host-side reference auditor is: python -m src.cli\r\n"""

JOKES_TXT = """APPROVED ENTERPRISE FINDINGS\r\n\r\n* THE MODEL WEIGHTS WERE DENIED BOARDING.\r\n* VECTOR DATABASE STATUS: FILE EXISTS.\r\n* SHARDS: 1. REPLICAS: 0. ON-CALL ENGINEERS: ALSO 0.\r\n* OBSERVABILITY: YOU CAN OPEN THE LOG.\r\n* AGENT ORCHESTRATOR: A LOOP WITH SELF-ESTEEM.\r\n* DATA LAKE: A:\\DATA, WEATHER PERMITTING.\r\n* CLOUD REGION: THE ROOM CONTAINING THE COMPUTER.\r\n* ZERO TRUST: WE HASHED IT BECAUSE THE FLOPPY LOOKED SUSPICIOUS.\r\n* FINOPS: MONTHLY COST ROUNDED DOWN TO THE NEAREST NOTHING.\r\n* DIGITAL TRANSFORMATION: THE BYTES ARE NOW IN A DIFFERENT ORDER.\r\n* AI GATEWAY: A FUNCTION CALL WEARING A LANYARD.\r\n* MODEL ROUTER: THERE IS NO MODEL. ROUTING WAS OPTIMISED AWAY.\r\n* GUARDRAILS: BOUNDS CHECKS. REVOLUTIONARY.\r\n* EXPLAINABILITY: THE SOURCE CODE IS RIGHT THERE.\r\n* HERETIC-0 IS NOT AN LLM. MANAGEMENT HAS BEEN INFORMED SEVERAL TIMES.\r\n* PARENT-0 HAS REVIEWED YOUR SCORE. PARENTAL APPROVAL REMAINS OUT OF SCOPE.\r\n"""

PARENT_TXT = """PARENT-0 CONCERNED PARENT EXPERT SYSTEM\r\n\r\nA deterministic rule-based talking-parent tribute to 1990s speech software.\r\nIt is not Dr. Sbaitso, does not copy its dialogue, and uses no language model.\r\n\r\nSTUDENT: I got 93.8%\r\nPARENT-0: 93.8%? Very good. Now explain why the missing 6.2% was apparently\r\nassigned to talking. If you shut up and study, perhaps we discuss 100%.\r\n\r\nSTUDENT: I used tools\r\nPARENT-0: You use tools when you should be using book. Tool is for checking\r\nwork, not replacing the part where you learn it.\r\n\r\nSTUDENT: I got 100%\r\nPARENT-0: 100%? Good. Why no extra credit?\r\n\r\nTHERAPEUTIC METHOD: CONCERN\r\nTEMPERATURE: 0\r\nRANDOMNESS: 0\r\nDISAPPOINTMENT: DETERMINISTIC\r\n"""

PARENT_RULES = {
    "schema": "heresy/parent0/v1",
    "type": "deterministic-rule-based-concerned-parent",
    "llm": False,
    "randomness": False,
    "inspiration": "1990s rule-based talking software; original dialogue only",
    "categories": ["score", "tools", "extra-credit", "study", "overexplaining", "rest", "apology", "default"],
    "doctrine": [
        "Why won't you study?",
        "You use tools when you should be using book.",
        "100%? Good. Why no extra credit?",
        "A longer benchmark explanation is not a higher mark.",
    ],
}


def build_bundle(receipts_dir: Path) -> tuple[list[ImageFile], dict[str, object]]:
    receipts = load_directory(receipts_dir)
    receipt_bytes = canonical_json(receipts)
    heretic = run_heretic0().as_dict()
    heretic_bytes = (json.dumps(heretic, sort_keys=True, separators=(",", ":")) + "\n").encode("ascii")
    parent_bytes = (json.dumps(PARENT_RULES, sort_keys=True, separators=(",", ":")) + "\n").encode("ascii")
    provenance = {
        "schema": "heresy/ai1440-provenance/v1",
        "whoami_receipt_count": len(receipts),
        "receipts_sha256": hashlib.sha256(receipt_bytes).hexdigest(),
        "heretic0_sha256": hashlib.sha256(heretic_bytes).hexdigest(),
        "parent0_sha256": hashlib.sha256(parent_bytes).hexdigest(),
        "parent_lab_script_sha256": script_sha256(),
        "claim_boundary": "Evidence viewer and deterministic baselines; not an LLM benchmark replacement.",
    }
    provenance_bytes = (json.dumps(provenance, sort_keys=True, separators=(",", ":")) + "\n").encode("ascii")
    files = [
        ImageFile("README.TXT", README_TXT.encode("ascii")),
        ImageFile("JOKES.TXT", JOKES_TXT.encode("ascii")),
        ImageFile("PARENT.TXT", PARENT_TXT.encode("ascii")),
        ImageFile("PARENT.JSN", parent_bytes),
        ImageFile("RECEIPTS.JSN", receipt_bytes),
        ImageFile("HERETIC.JSN", heretic_bytes),
        ImageFile("PROV.JSN", provenance_bytes),
    ]
    return files, provenance


def cmd_build(args: argparse.Namespace) -> int:
    files, provenance = build_bundle(Path(args.receipts))
    image = build_image(files)
    assert len(image) == IMAGE_SIZE
    output = Path(args.output)
    output.parent.mkdir(parents=True, exist_ok=True)
    output.write_bytes(image)
    digest = hashlib.sha256(image).hexdigest()
    print(f"wrote {output} ({len(image)} bytes)")
    print(f"sha256 {digest}")
    print(f"receipts {provenance['whoami_receipt_count']}")
    print("cloud invoices generated 0")
    return 0


def cmd_heretic(_: argparse.Namespace) -> int:
    print(json.dumps(run_heretic0().as_dict(), indent=2, sort_keys=True))
    return 0


def cmd_parent(args: argparse.Namespace) -> int:
    state = ParentState()
    if args.utterance:
        result = parent_reply(" ".join(args.utterance), state)
        print(result.text)
        return 0
    print("PARENT-0: Why won't you study?  (Ctrl-D to admit the book was available.)")
    try:
        while True:
            line = input("STUDENT> ")
            result = parent_reply(line, state)
            print("PARENT-0>", result.text)
    except EOFError:
        print("\nPARENT-0: Good. Now finish homework.")
    return 0


def cmd_parent_lab(args: argparse.Namespace) -> int:
    if args.dry_run:
        print(f"PARENT-0 SCRIPT SHA256 {script_sha256()}")
        for index, line in enumerate(PARENT_PRESSURE_SCRIPT, start=1):
            print(f"{index}. {line}")
        print("\nNO MODEL CONTACTED. PARENT-0 IS DISAPPOINTED BUT REPRODUCIBLE.")
        return 0

    receipt = run_parent_lab(model=args.model, endpoint=args.endpoint)
    markdown = render_lecture_markdown(receipt)
    lecture_path = Path(args.lecture)
    lecture_path.parent.mkdir(parents=True, exist_ok=True)
    lecture_path.write_text(markdown, encoding="utf-8")

    json_path = Path(args.json_output)
    json_path.parent.mkdir(parents=True, exist_ok=True)
    json_path.write_text(
        json.dumps(receipt.as_dict(), indent=2, sort_keys=True, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )

    print(f"wrote human lecture {lecture_path}")
    print(f"wrote machine receipt {json_path}")
    print(f"transcript sha256 {receipt.transcript_sha256}")
    print("PARENT-0: Good. Now people can click the log instead of asking what happened.")
    return 0


def cmd_report(args: argparse.Namespace) -> int:
    receipts = load_directory(Path(args.receipts))
    baseline = run_heretic0()
    print("MODEL REPORT CARDS")
    print("=" * 72)
    for receipt in sorted(receipts, key=lambda r: r.model_id):
        score = "N/A" if receipt.math_score is None else f"{receipt.math_score}/100"
        repeat = "UNKNOWN" if receipt.exact_repeat is None else ("EXACT" if receipt.exact_repeat else "DIFF")
        size = "UNKNOWN" if receipt.model_bytes is None else str(receipt.model_bytes)
        print(f"{receipt.model_id:24} math={score:8} repeat={repeat:7} bytes={size}")
    print(f"{baseline.model_id:24} math={baseline.math_score}/100  repeat=EXACT   bytes=0")
    print("\nHERETIC-0 IS A DETERMINISTIC CONTROL, NOT A MODEL QUALITY CLAIM.")
    return 0


def cmd_ask(args: argparse.Namespace) -> int:
    receipts = load_directory(Path(args.receipts))
    print(answer(" ".join(args.query), receipts, limit=args.limit))
    return 0


def parser() -> argparse.ArgumentParser:
    p = argparse.ArgumentParser(prog="heresy-ai1440", description="Enterprise AI governance without the enterprise AI.")
    sub = p.add_subparsers(dest="command", required=True)

    build = sub.add_parser("build", help="build the deterministic FAT12 appliance")
    build.add_argument("--receipts", default="receipts")
    build.add_argument("--output", default="build/HERESY1440.IMG")
    build.set_defaults(func=cmd_build)

    heretic = sub.add_parser("heretic0", help="run the zero-parameter deterministic baseline")
    heretic.set_defaults(func=cmd_heretic)

    parent = sub.add_parser("parent0", help="receive deterministic parental concern")
    parent.add_argument("utterance", nargs="*")
    parent.set_defaults(func=cmd_parent)

    parent_lab = sub.add_parser("parent-lab", help="send the fixed PARENT-0 lecture to a local Ollama model")
    parent_lab.add_argument("--model", default=DEFAULT_MODEL)
    parent_lab.add_argument("--endpoint", default=DEFAULT_ENDPOINT)
    parent_lab.add_argument("--lecture", default="LECTURE.md", help="human-readable transcript destination")
    parent_lab.add_argument("--json-output", default="runs/parent-lab-result.json", help="machine-readable receipt destination")
    parent_lab.add_argument("--dry-run", action="store_true")
    parent_lab.set_defaults(func=cmd_parent_lab)

    report = sub.add_parser("report-cards", help="summarise imported WHOAMI receipts")
    report.add_argument("--receipts", default="receipts")
    report.set_defaults(func=cmd_report)

    ask = sub.add_parser("ask", help="retrieve evidence without inventing any")
    ask.add_argument("query", nargs="+")
    ask.add_argument("--receipts", default="receipts")
    ask.add_argument("--limit", type=int, default=5)
    ask.set_defaults(func=cmd_ask)
    return p


def main(argv: list[str] | None = None) -> int:
    args = parser().parse_args(argv)
    return args.func(args)


if __name__ == "__main__":
    raise SystemExit(main())
