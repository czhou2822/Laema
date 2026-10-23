"""Read-only Wight source/preparation audit. Run with Python -B."""

import hashlib
import importlib.util
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[6]
HELPER = ROOT / "tools/art/necropolis_remaster.py"
spec = importlib.util.spec_from_file_location("necropolis_wight_readonly", HELPER)
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
c = helper.creature("wight")
plan = helper.load_plan()
native = helper.read(ROOT / c["original_metadata"])
preparation = helper.read(helper.dest("wight") / "_source/preparation.json")
errors = []


def check(condition, message):
    if not condition:
        errors.append(message)


hashes = {}
for label, path_key, hash_key in [
    ("master", "appearance_reference", "appearance_reference_sha256"),
    ("metadata", "original_metadata", "original_metadata_sha256"),
    ("def", "original_def", "original_def_sha256"),
]:
    actual = helper.sha(ROOT / c[path_key])
    hashes[label] = {"path": c[path_key], "sha256": actual}
    check(actual == c[hash_key], f"{label}: plan hash mismatch")
check(native["def_sha256"] == hashes["def"]["sha256"], "Metadata DEF hash mismatch")
check(c["geometry"] == plan["geometry"] == helper.geometry(), "Geometry mismatch")
check(c["appearance_reference_approved"] is True, "Appearance approval missing")
approval = helper.read(ROOT / "docs/art/remasters/necropolis-v01/master-approval.json")
approved = [a for a in approval["entries"] if a["creature_id"] == "wight"]
check(len(approved) == 1, "Expected one Wight approval entry")
if len(approved) == 1:
    check(approved[0]["sha256"] == hashes["master"]["sha256"], "Approval master hash mismatch")
    check(approved[0]["master"] == c["appearance_reference"], "Approval master path mismatch")
check(helper.sha(helper.dest("wight") / "_source/appearance-master.png") == hashes["master"]["sha256"], "Prepared master copy mismatch")

groups = {g["group_id"]: g for g in c["groups"]}
native_groups = {g["id"]: g for g in native["groups"]}
poses = helper.posemap(c)
expected_occurrences = {}
sheet_paths = set()
for g in c["groups"]:
    gid = g["group_id"]
    ng = native_groups[gid]
    check(g["original_group_record"] == ng, f"G{gid}: complete original record mismatch")
    check(g["original_block"] == ng["block"], f"G{gid}: block mismatch")
    check(g["frame_count"] == len(ng["frames"]) == len(g["pose_ids_in_source_order"]), f"G{gid}: count mismatch")
    aliases = [h["group_id"] for h in c["groups"] if h is not g and h["pose_ids_in_source_order"] == g["pose_ids_in_source_order"]]
    check(g["exact_aliases"] == aliases, f"G{gid}: alias mismatch")
    for f, pid in zip(ng["frames"], g["pose_ids_in_source_order"]):
        expected_occurrences[(gid, ng["block"], f["index"])] = pid

seen_occurrences = {}
indexed_images = {}
pixel_hash_checks = 0
mapped_rects = []
for p in c["poses"]:
    pid = p["pose_id"]
    check(p["representative"] == p["occurrences"][0], f"{pid}: representative mismatch")
    for r in p["occurrences"]:
        gid, block, index = r["group_id"], r["original_block"], r["frame_index"]
        key = (gid, block, index)
        check(key not in seen_occurrences, f"{pid}: duplicate occurrence {key}")
        seen_occurrences[key] = pid
        ng = native_groups[gid]
        f = ng["frames"][index]
        check(r["source_record"] == f, f"{pid}: source record mismatch at {key}")
        check(helper.signature(f) == p["original_signature"], f"{pid}: signature mismatch at {key}")
        page = ng["pages"][f["page"]]
        check(r["sheet_cell_region"] == [f["x"], f["y"], ng["cell_width"], ng["cell_height"]], f"{pid}: cell mismatch at {key}")
        for field, page_field in [("rgba_sheet", "preview"), ("indexed_sheet", "indexed")]:
            expected_path = (Path(c["original_metadata"]).parent / page[page_field]).as_posix()
            check(r[field] == expected_path, f"{pid}: {field} mismatch at {key}")
            sheet_paths.add(r[field])
            check((ROOT / r[field]).is_file(), f"{pid}: missing {field}")
        if r["indexed_sheet"] not in indexed_images:
            im = Image.open(ROOT / r["indexed_sheet"])
            check(im.mode == "P", f"{pid}: indexed sheet mode {im.mode}")
            indexed_images[r["indexed_sheet"]] = im
        indexed = indexed_images[r["indexed_sheet"]]
        x, y = f["x"] + f["left"], f["y"] + f["top"]
        pixel_hash = hashlib.sha256(indexed.crop((x, y, x + f["width"], y + f["height"])).tobytes()).hexdigest()
        check(pixel_hash == f["index_sha256"], f"{pid}: indexed pixels mismatch at {key}")
        pixel_hash_checks += 1
    im = helper.original(p)
    bb = helper.bbox(im, 160)
    check(bb is not None, f"{pid}: no opaque body")
    if bb:
        rect = [bb[0], bb[1], bb[2] - bb[0], bb[3] - bb[1]]
        check(rect == p["opaque_body_rect"], f"{pid}: opaque body mismatch")
        mapped = [512 + (bb[0] - 196) * helper.SCALE, 512 + (bb[1] - 268) * helper.SCALE, 512 + (bb[2] - 196) * helper.SCALE, 512 + (bb[3] - 268) * helper.SCALE]
        mapped_rects.append(mapped)
        check(mapped[0] >= 40 and mapped[1] >= 40 and mapped[2] <= 984 and mapped[3] <= 728, f"{pid}: fixed geometry padding failure")
check(expected_occurrences == seen_occurrences, "Complete occurrence mapping mismatch")
check(len(groups) == c["original_group_slots"] == 18, "Group count mismatch")
check(len(seen_occurrences) == c["original_frame_positions"] == 102, "Position count mismatch")
check(len(poses) == c["unique_registered_poses"] == 57, "Pose count mismatch")
check(len({p["original_signature"] for p in c["poses"]}) == 57, "Source signatures not unique")

guide_pose_ids = []
guides = []
for b in preparation["batches"]:
    mapping_path = (ROOT / b["guide"]).with_suffix(".json")
    check(helper.read(mapping_path) == b, f"Guide mapping mismatch: {mapping_path.name}")
    guide_pose_ids.extend(b["pose_ids"])
    with Image.open(ROOT / b["guide"]) as im:
        check(im.size == (512 * b["columns"], 512 * b["rows"]), f"Guide dimensions mismatch: {b['guide']}")
        guides.append({"path": b["guide"], "size": list(im.size), "pose_ids": b["pose_ids"], "sha256": helper.sha(ROOT / b["guide"])})
check(guide_pose_ids == preparation["pending_pose_ids"], "Pending guide order mismatch")
check(guide_pose_ids == [p["pose_id"] for p in c["poses"]], "Expected all 57 poses pending")
with Image.open(ROOT / c["appearance_reference"]) as master:
    master_image = {"mode": master.mode, "size": list(master.size), "alpha_extrema": list(master.getchannel("A").getextrema())}

result = {
    "creature_id": "wight",
    "status": "source_integrity_verified" if not errors else "source_issues_found",
    "source_hashes": hashes,
    "master_image": master_image,
    "groups": len(groups),
    "source_positions": len(seen_occurrences),
    "unique_poses": len(poses),
    "unique_ordered_sequences": len({tuple(g["pose_ids_in_source_order"]) for g in c["groups"]}),
    "indexed_occurrences_hash_checked": pixel_hash_checks,
    "source_sheet_files": len(sheet_paths),
    "exact_alias_pairs": [[g["group_id"], a] for g in c["groups"] for a in g["exact_aliases"] if g["group_id"] < a],
    "projected_opaque_union_ltrb": [min(r[0] for r in mapped_rects), min(r[1] for r in mapped_rects), max(r[2] for r in mapped_rects), max(r[3] for r in mapped_rects)],
    "guides": guides,
    "supplied_remaster_poses": len(list((helper.dest("wight") / "poses").glob("wight_p*.json"))),
    "missing_remaster_poses": sum(not (helper.dest("wight") / "poses" / (p["pose_id"] + ".json")).is_file() for p in c["poses"]),
    "errors": errors,
}
print(json.dumps(result, indent=2))
raise SystemExit(bool(errors))
