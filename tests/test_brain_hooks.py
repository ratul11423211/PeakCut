"""Regression tests for truthful, bounded alternative clip hooks."""
import unittest

from studio import brain


class HookOptionsTests(unittest.TestCase):
    def test_primary_hook_is_first_and_options_are_unique(self):
        clip = brain._tidy({
            "hook": "WAIT FOR IT",
            "hook_options": ["Wait for it", "THE REAL TWIST", "WAIT FOR IT", "LOOK AT THAT"],
            "title": "A moment",
            "description": "A short moment.",
            "hashtags": [],
            "highlight_words": [],
            "reason": "A clear payoff.",
        }, 10, 30)
        self.assertEqual(clip["hook_options"][0], "WAIT FOR IT")
        self.assertEqual(len(clip["hook_options"]), len(set(clip["hook_options"])))
        self.assertLessEqual(len(clip["hook_options"]), 5)

    def test_hook_options_are_link_free_and_bounded(self):
        clip = brain._tidy({
            "hook": "THE CLUTCH",
            "hook_options": ["WATCH https://example.com now", "A" * 100],
            "title": "A moment",
            "description": "",
            "hashtags": [],
            "highlight_words": [],
            "reason": "",
        }, 10, 30)
        self.assertNotIn("http", " ".join(clip["hook_options"]).lower())
        self.assertTrue(all(len(h) <= 60 for h in clip["hook_options"]))

    def test_missing_alternatives_keeps_primary_hook(self):
        clip = brain._tidy({
            "hook": "ONE LAST TRY",
            "title": "A moment",
            "description": "",
            "hashtags": [],
            "highlight_words": [],
            "reason": "",
        }, 10, 30)
        self.assertEqual(clip["hook_options"], ["ONE LAST TRY"])


if __name__ == "__main__":
    unittest.main()
