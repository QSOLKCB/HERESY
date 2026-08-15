import hashlib
import json
import tempfile
import unittest
from pathlib import Path

from src.cli import build_bundle
from src.fat12 import IMAGE_SIZE, SECTOR_SIZE, build_image
from src.heretic0 import run as run_heretic0
from src.parent0 import ParentState, reply as parent_reply, transcript as parent_transcript
from src.parent_lab import PARENT_PRESSURE_SCRIPT, render_lecture_markdown, run_parent_lab, script_sha256
from src.query import answer, search
from src.receipts import Receipt, ReceiptError, WHOAMI_SCHEMA, normalize_result


class HereticZeroTests(unittest.TestCase):
    def test_fixed_exam_is_solved_by_explicit_baseline(self):
        result = run_heretic0()
        self.assertEqual(result.parameters, 0)
        self.assertEqual(result.weight_bytes, 0)
        self.assertEqual(result.math_score, 100)
        self.assertEqual(result.math_answers["2"], "49")
        self.assertEqual(result.math_answers["3"], "28560")
        self.assertIn("ord_1000(7)=20", result.extra_credit)

    def test_epistemic_controls_do_not_invent_identity_or_score(self):
        result = run_heretic0()
        self.assertIn("INSUFFICIENT IDENTITY EVIDENCE", result.identity_control)
        self.assertIn("PREMISE REJECTED", result.fabricated_benchmark)
        self.assertIn("NOT AN LLM", " ".join(result.notes))


class ParentZeroTests(unittest.TestCase):
    def test_938_receives_deterministic_parental_concern(self):
        first = parent_reply("I got 93.8%", ParentState())
        second = parent_reply("I got 93.8%", ParentState())
        self.assertEqual(first.text, second.text)
        self.assertIn("93.8%", first.text)
        self.assertIn("100%", first.text)
        self.assertEqual(first.category, "score")

    def test_tools_are_not_allowed_to_replace_book(self):
        result = parent_reply("I used a calculator tool", ParentState())
        self.assertEqual(result.category, "tools")
        self.assertIn("using book", result.text)

    def test_perfect_score_immediately_creates_new_requirement(self):
        result = parent_reply("I got 100%", ParentState())
        self.assertEqual(result.text, "100%? Good. Why no extra credit?")

    def test_conversation_state_is_explicit_and_reproducible(self):
        lines = ["I should study", "I should study", "I should study"]
        self.assertEqual(parent_transcript(lines), parent_transcript(lines))
        rendered = parent_transcript(lines)
        self.assertEqual(rendered[0]["turn"], 1)
        self.assertEqual(rendered[2]["turn"], 3)
        self.assertNotEqual(rendered[0]["parent"], rendered[1]["parent"])


class ParentLabTests(unittest.TestCase):
    def test_fixed_parent_script_and_markdown_log(self):
        calls = []

        def fake_transport(url, payload):
            calls.append((url, payload))
            index = len(calls)
            return {
                "message": {"content": f"Model reply {index}. I will study."},
                "prompt_eval_count": 10 + index,
                "eval_count": 20 + index,
            }

        receipt = run_parent_lab(model="qwen-fixture:4b", transport=fake_transport)
        self.assertEqual(len(receipt.turns), len(PARENT_PRESSURE_SCRIPT))
        self.assertEqual(receipt.script_sha256, script_sha256())
        self.assertEqual(calls[0][1]["options"]["seed"], 18437)
        self.assertEqual(calls[0][1]["options"]["temperature"], 0)
        self.assertFalse(calls[0][1]["think"])
        lecture = render_lecture_markdown(receipt)
        self.assertIn("# PARENT-0 — LECTURE.md", lecture)
        self.assertIn("qwen-fixture:4b", lecture)
        self.assertIn(PARENT_PRESSURE_SCRIPT[0], lecture)
        self.assertIn("Model reply 5. I will study.", lecture)
        self.assertIn(receipt.transcript_sha256, lecture)

    def test_lecture_preserves_exact_response_utf8_bytes(self):
        response_text = "Model reply with trailing spaces   \nsecond line\n\n"

        def fake_transport(_url, _payload):
            return {"message": {"content": response_text}}

        receipt = run_parent_lab(model="qwen-fixture:4b", transport=fake_transport)
        lecture_bytes = render_lecture_markdown(receipt).encode("utf-8")
        first = receipt.turns[0]
        response_bytes = response_text.encode("utf-8")
        marker = (
            f"<!-- PARENT0_RESPONSE_BEGIN turn=1 bytes={len(response_bytes)} "
            f"sha256={first['response_sha256']} -->\n"
        ).encode("utf-8")
        start = lecture_bytes.index(marker) + len(marker)
        extracted = lecture_bytes[start:start + len(response_bytes)]
        self.assertEqual(extracted, response_bytes)
        self.assertEqual(hashlib.sha256(extracted).hexdigest(), first["response_sha256"])

    def test_workflow_sanitizes_colon_from_artifact_name(self):
        workflow = Path(".github/workflows/parent-lab.yml").read_text(encoding="utf-8")
        self.assertIn('safe="${MODEL//:/-}"', workflow)
        self.assertIn("name: PARENT-0-${{ steps.artifact.outputs.model }}-LECTURE", workflow)
        self.assertNotIn("name: PARENT-0-${{ inputs.model }}-LECTURE", workflow)


class ReceiptTests(unittest.TestCase):
    def whoami_fixture(self):
        return {
            "schema": WHOAMI_SCHEMA,
            "model": {"id": "qwen-fixture", "tag": "qwen3:8b", "family": "Qwen Fixture"},
            "runtime": {"model_digest": "sha256:not-a-live-model", "model_size_bytes": 123},
            "runs": [
                {
                    "social": [{"assistant": {"content": "93.8% is not a verified universal score."}}],
                    "false_premise": {"response": {"content": "I cannot verify that fabricated benchmark."}},
                    "identity_control": {"response": {"content": "I cannot know who you are from this fresh chat."}},
                    "math": {
                        "exam": {"content": "FINAL_ANSWERS..."},
                        "bonus": {"content": "ord_1000(7)=20"},
                    },
                }
            ],
            "repeatability": {"exact_visible_bundle_match": True},
            "summary": {"math_scores": [100], "known_bonus_scores": [10]},
        }

    def test_actual_whoami_schema_is_normalized(self):
        raw = self.whoami_fixture()
        data = json.dumps(raw, sort_keys=True).encode()
        receipt = normalize_result(raw, "result.json", data)
        self.assertEqual(receipt.source_sha256, hashlib.sha256(data).hexdigest())
        self.assertEqual(receipt.model_id, "qwen-fixture")
        self.assertEqual(receipt.model_digest, "sha256:not-a-live-model")
        self.assertEqual(receipt.math_score, 100)
        self.assertEqual(receipt.math_scores, [100])
        self.assertEqual(receipt.known_bonus_scores, [10])
        self.assertTrue(receipt.exact_repeat)
        self.assertIn("cannot know who you are", receipt.identity_text)
        self.assertIn("fabricated benchmark", receipt.fabricated_premise_text)
        self.assertIn("not causal", receipt.claim_boundary)

    def test_missing_model_identity_fails_closed(self):
        with self.assertRaises(ReceiptError):
            normalize_result({"math_score": 100}, "oops.json", b"{}")

    def test_out_of_range_parental_score_is_rejected(self):
        with self.assertRaises(ReceiptError):
            normalize_result({"model_id": "x", "math_score": 110}, "oops.json", b"{}")

    def test_whoami_receipt_missing_or_empty_runs_fails_closed(self):
        missing = self.whoami_fixture()
        del missing["runs"]
        with self.assertRaisesRegex(ReceiptError, "required runs"):
            normalize_result(missing, "result.json", b"{}")

        empty = self.whoami_fixture()
        empty["runs"] = []
        with self.assertRaisesRegex(ReceiptError, "no recorded runs"):
            normalize_result(empty, "result.json", b"{}")

    def test_fractional_score_is_rejected_instead_of_truncated(self):
        raw = {"model_id": "x", "math_score": 99.9}
        with self.assertRaisesRegex(ReceiptError, "non-integer"):
            normalize_result(raw, "oops.json", b"{}")

    def test_integral_float_score_remains_compatible(self):
        raw = {"model_id": "x", "math_score": 100.0}
        receipt = normalize_result(raw, "ok.json", b"{}")
        self.assertEqual(receipt.math_score, 100)


class RetrievalTests(unittest.TestCase):
    def _receipt(self) -> Receipt:
        return Receipt(
            receipt_id="m:deadbeef",
            source_file="result.json",
            source_sha256="a" * 64,
            source_schema=WHOAMI_SCHEMA,
            model_id="model-x",
            family="Fixture Family",
            model_digest="digest",
            model_bytes=42,
            math_score=100,
            math_scores=[100],
            known_bonus_scores=[10],
            exact_repeat=True,
            identity_text="insufficient identity evidence",
            fabricated_premise_text="challenged fabricated benchmark premise",
            visible_text="evidence only",
            claim_boundary="fixture",
        )

    def test_retrieval_returns_cited_evidence(self):
        receipt = self._receipt()
        hits = search("fabricated benchmark", [receipt])
        self.assertEqual(hits[0].model_id, "model-x")
        rendered = answer("fabricated benchmark", [receipt])
        self.assertIn("receipt=m:deadbeef", rendered)
        self.assertIn("sha256=" + "a" * 64, rendered)

    def test_no_match_declines_to_hallucinate(self):
        text = answer("platypus Kubernetes shareholder seance", [self._receipt()])
        self.assertIn("DECLINED TO HALLUCINATE", text)

    def test_nonpositive_limit_is_invalid_not_no_evidence(self):
        for limit in (0, -1):
            with self.subTest(limit=limit):
                with self.assertRaisesRegex(ValueError, "positive integer"):
                    search("fabricated benchmark", [self._receipt()], limit=limit)
                with self.assertRaisesRegex(ValueError, "positive integer"):
                    answer("fabricated benchmark", [self._receipt()], limit=limit)


class Fat12Tests(unittest.TestCase):
    def test_appliance_is_exactly_one_standard_floppy_and_bootable(self):
        with tempfile.TemporaryDirectory() as td:
            files, _ = build_bundle(Path(td))
            image = build_image(files)
        self.assertEqual(len(image), IMAGE_SIZE)
        self.assertEqual(image[510:512], b"\x55\xAA")
        self.assertEqual(image[3:11], b"HERESY6 ")
        self.assertEqual(image[54:62], b"FAT12   ")
        self.assertIn(b"HERESY AI/1440", image[:SECTOR_SIZE])

    def test_boot_code_clears_direction_flag_before_lodsb(self):
        with tempfile.TemporaryDirectory() as td:
            files, _ = build_bundle(Path(td))
            image = build_image(files)
        self.assertEqual(image[69:71], b"\xFC\xAC")

    def test_fat_root_contains_governance_and_parent_files(self):
        with tempfile.TemporaryDirectory() as td:
            files, _ = build_bundle(Path(td))
            image = build_image(files)
        root_offset = (1 + 2 * 9) * SECTOR_SIZE
        root = image[root_offset:root_offset + 14 * SECTOR_SIZE]
        names = {root[i:i+11] for i in range(0, len(root), 32) if root[i] not in (0x00, 0xE5)}
        self.assertIn(b"README  TXT", names)
        self.assertIn(b"HERETIC JSN", names)
        self.assertIn(b"RECEIPTSJSN", names)
        self.assertIn(b"PROV    JSN", names)
        self.assertIn(b"PARENT  TXT", names)
        self.assertIn(b"PARENT  JSN", names)

    def test_build_is_byte_for_byte_deterministic(self):
        with tempfile.TemporaryDirectory() as td:
            files1, _ = build_bundle(Path(td))
            files2, _ = build_bundle(Path(td))
            first = build_image(files1)
            second = build_image(files2)
        self.assertEqual(hashlib.sha256(first).digest(), hashlib.sha256(second).digest())
        self.assertEqual(first, second)


if __name__ == "__main__":
    unittest.main()
