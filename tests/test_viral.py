"""Tests for evidence-based clip ranking."""
import sys
import unittest

sys.path.insert(0, ".")

from studio.viral import evidence_score


class ViralScoreTests(unittest.TestCase):
    def test_score_is_bounded(self):
        clip = {"start": 0, "end": 10, "score": 120}
        self.assertLessEqual(evidence_score(clip, [], [0] * 20), 100)
        self.assertGreaterEqual(evidence_score({**clip, "score": -20}, [], [0] * 20), 0)

    def test_speech_and_audio_evidence_affect_score(self):
        clip = {"start": 0, "end": 10, "score": 60}
        quiet = evidence_score(clip, [], [0] * 20)
        words = [{"s": i * 0.5, "e": i * 0.5 + 0.4, "w": "hello"} for i in range(20)]
        energetic = evidence_score(clip, words, [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 4])
        self.assertGreater(energetic, quiet)

    def test_zero_editorial_score_is_not_treated_as_missing(self):
        score = evidence_score({"start": 0, "end": 10, "score": 0}, [], [0] * 20)
        self.assertLessEqual(score, 5)

    def test_empty_inputs_are_safe(self):
        self.assertIsInstance(evidence_score({"start": 0, "end": 8}, [], []), int)


if __name__ == "__main__":
    unittest.main()
