"""Evidence-based ranking for candidate short-form clips.

The AI's editorial score remains the main signal. This module makes ranking more
consistent by adding measurable audio-energy and speech-coverage evidence.
It does not claim to understand gameplay visuals.
"""
from __future__ import annotations

import math


def _clamp(value: float, low: float, high: float) -> float:
    return max(low, min(high, value))


def evidence_score(clip: dict, words: list, loudness_z) -> int:
    """Return a 0-100 score using editorial score, audio peaks and speech coverage."""
    raw_score = clip.get("score", 50)
    editorial = _clamp(float(50 if raw_score is None else raw_score), 0, 100)
    start = max(0.0, float(clip.get("start", 0) or 0))
    end = max(start, float(clip.get("end", start) or start))
    duration = max(1.0, end - start)

    timed_words = []
    for word in words or []:
        try:
            ws, we = float(word["s"]), float(word["e"])
            if we >= start and ws <= end:
                timed_words.append((max(start, ws), min(end, we)))
        except (KeyError, TypeError, ValueError):
            continue

    # Speech coverage rewards clips with enough context, without rewarding endless talking.
    spoken = sum(max(0.0, we - ws) for ws, we in timed_words)
    coverage = _clamp(spoken / duration, 0.0, 1.0)
    speech_score = _clamp(coverage / 0.55, 0.0, 1.0) * 100

    peak_score = 50.0
    try:
        values = [float(v) for v in loudness_z[int(start):int(end) + 1]]
        values = [v for v in values if math.isfinite(v)]
        if values:
            peak = max(values)
            # A modest peak is useful evidence; extreme peaks are capped.
            peak_score = _clamp((peak + 0.5) / 3.0, 0.0, 1.0) * 100
    except (TypeError, ValueError, IndexError):
        pass

    combined = editorial * 0.70 + peak_score * 0.20 + speech_score * 0.10
    return int(round(_clamp(combined, 0, 100)))
