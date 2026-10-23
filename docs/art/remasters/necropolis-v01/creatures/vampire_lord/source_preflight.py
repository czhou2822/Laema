"""Read-only, bounded Vampire Lord source inspection. Run with Python -B."""

import argparse
import hashlib
import importlib.util
import json
from collections import Counter
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[6]
CID = "vampire_lord"


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(__doc__)
    parser.add_argument("--groups", action="store_true")
    parser.add_argument("--poses", nargs=2, type=int, default=[0, 0])
    parser.add_argument("--frames", nargs=2, type=int, default=[0, 0])
    args = parser.parse_args()
    spec = importlib.util.spec_from_file_location(
        "necropolis_remaster", ROOT / "tools/art/necropolis_remaster.py"
    )
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    plan = helper.load_plan()
    c = next(c for c in plan["creatures"] if c["creature_id"] == CID)
    native = helper.read(ROOT / c["original_metadata"])
    approval = helper.read(ROOT / helper.DOC / "master-approval.json")
    approved = next(a for a in approval["entries"] if a["creature_id"] == CID)
    hashes = {}
    for key in ["original_metadata", "original_def", "appearance_reference"]:
        actual = digest(ROOT / c[key])
        assert actual == c[key + "_sha256"], key
        hashes[key] = {"path": c[key], "sha256": actual}
    assert approved["sha256"] == hashes["appearance_reference"]["sha256"]
    assert approved["master"] == c["appearance_reference"]
    assert native["def_sha256"] == c["original_def_sha256"]
    assert c["geometry"] == helper.geometry()
    assert len(native["groups"]) == c["original_group_slots"] == len(c["groups"])
    pm = helper.posemap(c)
    seen = Counter()
    flattened = []
    sheets = set()
    for g, ng in zip(c["groups"], native["groups"]):
        assert g["original_group_record"] == ng, g["group_id"]
        assert g["group_id"] == ng["id"] and g["original_block"] == ng["block"]
        assert len(ng["frames"]) == g["frame_count"] == len(g["pose_ids_in_source_order"])
        aliases = [h["group_id"] for h in c["groups"] if h is not g and
                   h["pose_ids_in_source_order"] == g["pose_ids_in_source_order"]]
        assert aliases == g["exact_aliases"]
        for f, pid in zip(ng["frames"], g["pose_ids_in_source_order"]):
            p = pm[pid]
            assert helper.signature(f) == p["original_signature"]
            page = ng["pages"][f["page"]]
            expected = {
                "group_id": g["group_id"], "original_block": g["original_block"],
                "frame_index": f["index"],
                "rgba_sheet": (Path(c["original_metadata"]).parent / page["preview"]).as_posix(),
                "indexed_sheet": (Path(c["original_metadata"]).parent / page["indexed"]).as_posix(),
                "sheet_cell_region": [f["x"], f["y"], ng["cell_width"], ng["cell_height"]],
                "source_record": f,
            }
            assert expected in p["occurrences"], (pid, f["index"])
            seen[pid] += 1
            flattened.append({"group": g["group_id"], "pose": pid, **f})
            for key, mode in [("rgba_sheet", "RGBA"), ("indexed_sheet", "P")]:
                path = ROOT / expected[key]
                with Image.open(path) as im:
                    assert im.mode == mode, (path, im.mode)
                    assert im.size == (page["width"], page["height"])
                sheets.add(expected[key])
    assert len(flattened) == c["original_frame_positions"] == native["frame_count"]
    assert len(pm) == c["unique_registered_poses"]
    assert len({p["original_signature"] for p in c["poses"]}) == len(pm)
    for p in c["poses"]:
        assert len(p["occurrences"]) == seen[p["pose_id"]]
        assert p["representative"] == p["occurrences"][0]
        bb = helper.bbox(helper.original(p), 160)
        assert p["opaque_body_rect"] == [bb[0], bb[1], bb[2]-bb[0], bb[3]-bb[1]]
    master = Image.open(ROOT / c["appearance_reference"])
    alpha_histogram = master.getchannel("A").histogram()
    prepared = ROOT / "assets/prototype/enemy" / CID / "remaster_v01/_source/preparation.json"
    preparation = None
    if prepared.exists():
        prep = helper.read(prepared)
        pending = [pid for batch in prep["batches"] for pid in batch["pose_ids"]]
        assert pending == prep["pending_pose_ids"] == list(pm)
        assert len(pending) == len(set(pending))
        assert digest(prepared.parent / "appearance-master.png") == c["appearance_reference_sha256"]
        for batch in prep["batches"]:
            assert helper.read(ROOT / batch["guide"].replace(".png", ".json")) == batch
            assert batch["columns"] == min(4, len(batch["pose_ids"]))
            with Image.open(ROOT / batch["guide"]) as guide:
                assert guide.size == (512*batch["columns"], 512*batch["rows"])
        preparation = {"pending_poses": len(pending), "batches": len(prep["batches"]),
                       "all_pose_order_and_guide_dimensions_verified": True,
                       "copied_master_hash_matches": True}
    print(json.dumps({"status": "PASS", "counts": {"groups": len(c["groups"]),
        "positions": len(flattened), "poses": len(pm), "source_sheets": len(sheets)},
        "hashes": hashes, "native_header": {k:v for k,v in native.items() if k not in ["groups", "palette"]},
        "master": {"mode": master.mode, "size": master.size, "alpha_bbox": helper.bbox(master, 8),
                   "alpha_range": master.getchannel("A").getextrema(),
                   "transparent_pixels": alpha_histogram[0], "opaque_pixels": alpha_histogram[255],
                   "partial_alpha_pixels": sum(alpha_histogram[1:255])},
        "preparation": preparation,
        "idle_reference": c["og_idle_reference_pose_id"]}, sort_keys=True))
    for g in c["groups"] if args.groups else []:
        extras = {k:v for k,v in g["original_group_record"].items() if k != "frames"}
        print("GROUP", json.dumps({k:v for k,v in g.items() if k != "original_group_record"}, separators=(",", ":")))
        print("NATIVE_GROUP", json.dumps(extras, separators=(",", ":")))
    for p in c["poses"][args.poses[0]:args.poses[1]]:
        rep = p["representative"]
        print("POSE", json.dumps({"id": p["pose_id"], "signature": p["original_signature"],
            "body_rect": p["opaque_body_rect"], "representative": [rep["group_id"], rep["original_block"], rep["frame_index"]],
            "occurrences": [[r["group_id"], r["original_block"], r["frame_index"], *r["sheet_cell_region"]] for r in p["occurrences"]]}, separators=(",", ":")))
    if args.frames[1] > args.frames[0]:
        columns = list(flattened[0])
        print("FRAME_COLUMNS", json.dumps(columns))
        for f in flattened[args.frames[0]:args.frames[1]]:
            print("FRAME", json.dumps([f[k] for k in columns], separators=(",", ":")))
    print("READ_ONLY: no preparation, generation, reuse, ingestion, review acceptance, export, or runtime operation performed.")


if __name__ == "__main__":
    main()
