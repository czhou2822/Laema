"""Apply only the worker's actually inspected Wight observations via parent helper."""
import importlib.util
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location("wight_review_helper", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
observations = h.read(Path(__file__).parent / "pose-review-observations.json")
for item in observations["poses"]:
    assert item["worker_candidate_reviewed"] and item["pose_id"].startswith("wight_p")
    h.mark_review("wight", [item["pose_id"]], item["observation"] + " Inspected registered-scale OG/candidate and both facings; 2x source comparison. Worker candidate review only.")
print("Marked 57 actually inspected Wight candidate poses")
