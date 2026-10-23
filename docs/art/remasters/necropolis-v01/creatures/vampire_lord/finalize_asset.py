"""Run the existing helper's authorized asset-only completion sequence."""
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[6]
spec = importlib.util.spec_from_file_location("necropolis_remaster", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
evidence = h.read(Path(__file__).with_name("visual-review.json"))
assert len(evidence["poses"]) == 62 and len(evidence["groups"]) == 18
for review in evidence["poses"]:
    record = h.read(h.dest("vampire_lord") / "poses" / (review["pose_id"] + ".json"))
    assert record["registered_pose_sha256"] == review["registered_pose_sha256"]
    assert record["mirror_sha256"] == review["mirror_sha256"]
    h.mark_review("vampire_lord", [review["pose_id"]],
        "Inspected enlarged raw/source guide and registered native OG/new/exact mirror comparison. "
        + review["observation"] + " Worker candidate review only; no human animation acceptance.")
print(json.dumps({"step":"review", "poses":62}), flush=True)
print(json.dumps({"step":"build", "result":h.build("vampire_lord")}), flush=True)
first = h.validate("vampire_lord")
print(json.dumps({"step":"validate_before_spriteframes", "result":first}), flush=True)
if first["errors"] or not first["complete"]:
    raise SystemExit(1)
print(json.dumps({"step":"spriteframes", "result":h.spriteframes("vampire_lord")}), flush=True)
final = h.validate("vampire_lord")
print(json.dumps({"step":"final_validate", "result":final}), flush=True)
if final["errors"] or not final["complete"]:
    raise SystemExit(1)
