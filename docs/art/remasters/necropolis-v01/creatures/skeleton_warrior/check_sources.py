"""Read-only Skeleton Warrior source/preparation audit; run with Python -B.

Checks asset provenance and mappings only. Does not validate generated art,
motion, original timing, engine behavior, or human animation acceptance.
"""
import hashlib
import json
from collections import Counter
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
CID = "skeleton_warrior"
DOC = ROOT / "docs/art/remasters/necropolis-v01"
DEST = ROOT / "assets/prototype/enemy" / CID / "remaster_v01"


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def signature(frame):
    keys = ("index_sha256", "left", "top", "width", "height", "full_width", "full_height")
    return ":".join(str(frame[key]) for key in keys)


def audit():
    plan = read(DOC / "generation-plan.json")
    matches = [c for c in plan["creatures"] if c["creature_id"] == CID]
    assert len(matches) == 1
    creature = matches[0]
    metadata_path = ROOT / creature["original_metadata"]
    metadata = read(metadata_path)
    hashes = {}
    for key in ("appearance_reference", "original_metadata", "original_def"):
        hashes[key] = sha(ROOT / creature[key])
        assert hashes[key] == creature[key + "_sha256"], key
    approval = read(DOC / "master-approval.json")
    selected = [e for e in approval["entries"] if e["creature_id"] == CID]
    assert len(selected) == 1
    assert selected[0]["sha256"] == hashes["appearance_reference"]
    assert selected[0]["master"] == creature["appearance_reference"]
    assert approval["appearance_approved"] and creature["appearance_reference_approved"]
    assert metadata["def_sha256"] == hashes["original_def"]
    assert [g["original_group_record"] for g in creature["groups"]] == metadata["groups"]
    poses = {p["pose_id"]: p for p in creature["poses"]}
    assert len(poses) == len(creature["poses"]) == 57
    occurrences = {pid: [] for pid in poses}
    indexed_hashes_checked = 0
    rgba_bounds_checked = 0
    sheets = set()
    group_counts = []
    for group in creature["groups"]:
        native = group["original_group_record"]
        ids = group["pose_ids_in_source_order"]
        assert group["frame_count"] == len(ids) == len(native["frames"])
        aliases = [g["group_id"] for g in creature["groups"]
                   if g is not group and g["pose_ids_in_source_order"] == ids]
        assert aliases == group["exact_aliases"]
        for frame, pid in zip(native["frames"], ids):
            page = native["pages"][frame["page"]]
            preview = metadata_path.parent / page["preview"]
            indexed = metadata_path.parent / page["indexed"]
            sheets.update((preview, indexed))
            occurrence = {
                "group_id": group["group_id"], "original_block": group["original_block"],
                "frame_index": frame["index"],
                "rgba_sheet": preview.relative_to(ROOT).as_posix(),
                "indexed_sheet": indexed.relative_to(ROOT).as_posix(),
                "sheet_cell_region": [frame["x"], frame["y"], native["cell_width"], native["cell_height"]],
                "source_record": frame,
            }
            occurrences[pid].append(occurrence)
            assert poses[pid]["original_signature"] == signature(frame)
            with Image.open(indexed) as im:
                assert im.mode == "P" and im.size == (page["width"], page["height"])
                x = frame["x"] + frame["left"] - native["origin_x"]
                y = frame["y"] + frame["top"] - native["origin_y"]
                body = im.crop((x, y, x + frame["width"], y + frame["height"]))
                assert hashlib.sha256(body.tobytes()).hexdigest() == frame["index_sha256"]
                indexed_hashes_checked += 1
            with Image.open(preview) as im:
                assert im.size == (page["width"], page["height"])
                x, y, w, h = occurrence["sheet_cell_region"]
                body = im.convert("RGBA").crop((x, y, x + w, y + h))
                bounds = body.getchannel("A").point(lambda a: 255 if a > 160 else 0).getbbox()
                assert bounds
                left, top, right, bottom = bounds
                assert [left, top, right - left, bottom - top] == poses[pid]["opaque_body_rect"]
                rgba_bounds_checked += 1
        group_counts.append({"group": group["group_id"], "block": group["original_block"],
                             "positions": len(ids), "unique": len(set(ids)), "aliases": aliases})
    for pid, pose in poses.items():
        assert pose["occurrences"] == occurrences[pid], pid
        assert pose["representative"] == occurrences[pid][0], pid
        x, y, w, h = pose["opaque_body_rect"]
        scale = 180 / 73
        rect = (512 + (x - 196) * scale, 512 + (y - 268) * scale,
                512 + (x + w - 196) * scale, 512 + (y + h - 268) * scale)
        assert rect[0] >= 40 and rect[1] >= 40 and rect[2] <= 984 and rect[3] <= 728
    prep = read(DEST / "_source/preparation.json")
    pending = [pid for pid in poses if not (DEST / "poses" / (pid + ".json")).exists()]
    # The initial preparation snapshot remains history after production begins.
    assert prep["pending_pose_ids"] == list(poses)
    assert [pid for batch in prep["batches"] for pid in batch["pose_ids"]] == prep["pending_pose_ids"]
    guide_counts = []
    for batch in prep["batches"]:
        path = ROOT / batch["guide"]
        assert read(path.with_suffix(".json")) == batch
        with Image.open(path) as im:
            assert im.size == (512 * batch["columns"], 512 * batch["rows"])
            guide_counts.append({"guide": path.name, "poses": len(batch["pose_ids"]), "size": list(im.size)})
    assert sha(DEST / "_source/appearance-master.png") == hashes["appearance_reference"]
    assert sum(g["positions"] for g in group_counts) == metadata["frame_count"] == 86
    assert len(group_counts) == creature["original_group_slots"] == 15
    assert creature["original_frame_positions"] == 86 and creature["unique_registered_poses"] == 57
    with Image.open(ROOT / creature["appearance_reference"]) as master:
        master_info = {"mode": master.mode, "size": list(master.size),
                       "alpha_extrema": list(master.getchannel("A").getextrema())}
    return {"creature_id": CID, "status": "source_audit_passed", "hashes": hashes,
            "master": master_info, "groups": group_counts, "frame_positions": 86,
            "unique_poses": 57, "extra_repeat_occurrences": 29, "source_sheet_files": len(sheets),
            "indexed_frame_hashes_checked": indexed_hashes_checked,
            "rgba_body_bounds_checked": rgba_bounds_checked,
            "pose_occurrence_histogram": dict(sorted(Counter(len(o) for o in occurrences.values()).items())),
            "pending_poses": len(pending), "guides": guide_counts,
            "generated_pose_records": len(list((DEST / "poses").glob("*.json"))),
            "original_timing_verified": False, "animation_acceptance": False}


if __name__ == "__main__":
    print(json.dumps(audit(), indent=2))
