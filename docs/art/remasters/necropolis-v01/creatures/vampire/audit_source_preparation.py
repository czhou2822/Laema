"""Vampire-only source/guide audit. Run with Python -B; no art generation."""

import hashlib
import importlib.util
import json
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
CID = "vampire"


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative(path):
    return path.resolve().relative_to(ROOT).as_posix()


def main():
    helper_path = ROOT / "tools/art/necropolis_remaster.py"
    spec = importlib.util.spec_from_file_location("vampire_readonly_helper", helper_path)
    helper = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(helper)
    plan_path = ROOT / "docs/art/remasters/necropolis-v01/generation-plan.json"
    plan = read(plan_path)
    entry = next(c for c in plan["creatures"] if c["creature_id"] == CID)
    metadata_path = ROOT / entry["original_metadata"]
    native = read(metadata_path)
    approval_path = ROOT / "docs/art/remasters/necropolis-v01/master-approval.json"
    approval = read(approval_path)
    approved = next(c for c in approval["entries"] if c["creature_id"] == CID)
    fingerprints = {}
    for field, hash_field in (
        ("original_metadata", "original_metadata_sha256"),
        ("original_def", "original_def_sha256"),
        ("appearance_reference", "appearance_reference_sha256"),
    ):
        actual = sha(ROOT / entry[field])
        assert actual == entry[hash_field], field
        fingerprints[field] = {"path": entry[field], "sha256": actual, "matches_plan": True}
    assert approved["master"] == entry["appearance_reference"]
    assert approved["sha256"] == entry["appearance_reference_sha256"]
    assert approval["appearance_approved"] and not approval["animation_approved"]
    assert native["def_sha256"] == entry["original_def_sha256"]

    native_groups = {g["id"]: g for g in native["groups"]}
    poses = {p["pose_id"]: p for p in entry["poses"]}
    sheets = {}
    files = {}

    def sheet(path):
        if path not in sheets:
            sheets[path] = Image.open(ROOT / path).copy()
            files[path] = {"sha256": sha(ROOT / path), "mode": sheets[path].mode,
                           "size": list(sheets[path].size)}
        return sheets[path]

    expected_occurrences = {pid: [] for pid in poses}
    group_rows = []
    indexed_checks = 0
    rgba_checks = 0
    for group in entry["groups"]:
        gid = group["group_id"]
        source = native_groups[gid]
        assert group["original_group_record"] == source, ("native group", gid)
        assert group["original_block"] == source["block"]
        assert len(source["frames"]) == group["frame_count"]
        assert len(group["pose_ids_in_source_order"]) == group["frame_count"]
        aliases = [other["group_id"] for other in entry["groups"]
                   if other is not group and other["pose_ids_in_source_order"] == group["pose_ids_in_source_order"]]
        assert aliases == group["exact_aliases"], ("alias", gid)
        for frame, pid in zip(source["frames"], group["pose_ids_in_source_order"]):
            page = source["pages"][frame["page"]]
            rgba_path = relative(metadata_path.parent / page["preview"])
            indexed_path = relative(metadata_path.parent / page["indexed"])
            occurrence = {"group_id": gid, "original_block": source["block"],
                          "frame_index": frame["index"], "rgba_sheet": rgba_path,
                          "indexed_sheet": indexed_path,
                          "sheet_cell_region": [frame["x"], frame["y"], source["cell_width"], source["cell_height"]],
                          "source_record": frame}
            expected_occurrences[pid].append(occurrence)
            pose = poses[pid]
            assert helper.signature(frame) == pose["original_signature"], ("signature", gid, frame["index"])
            index_image = sheet(indexed_path)
            assert index_image.mode == "P"
            assert list(index_image.size) == [page["width"], page["height"]]
            x = frame["x"] + frame["left"]
            y = frame["y"] + frame["top"]
            index_crop = index_image.crop((x, y, x + frame["width"], y + frame["height"]))
            assert hashlib.sha256(index_crop.tobytes()).hexdigest() == frame["index_sha256"], ("indexed bytes", gid, frame["index"])
            indexed_checks += 1
            rgba_image = sheet(rgba_path).convert("RGBA")
            assert list(rgba_image.size) == [page["width"], page["height"]]
            region = occurrence["sheet_cell_region"]
            occurrence_image = helper.crop(rgba_image, region)
            assert occurrence_image.tobytes() == helper.original(pose).tobytes(), ("RGBA occurrence", gid, frame["index"])
            rgba_checks += 1
        group_rows.append({k: group[k] for k in (
            "group_id", "original_block", "purpose_interpretation", "frame_count",
            "pose_ids_in_source_order", "exact_aliases", "original_timing_verified")})

    pose_rows = []
    for pid, pose in poses.items():
        assert pose["occurrences"] == expected_occurrences[pid], ("occurrence map", pid)
        assert pose["representative"] == expected_occurrences[pid][0], ("representative", pid)
        bounds = helper.bbox(helper.original(pose), 160)
        actual = [bounds[0], bounds[1], bounds[2] - bounds[0], bounds[3] - bounds[1]]
        assert actual == pose["opaque_body_rect"], ("body rectangle", pid)
        pose_rows.append({"pose_id": pid, "native_name": pose["representative"]["source_record"]["name"],
                          "original_signature": pose["original_signature"], "opaque_body_rect": actual,
                          "occurrences": [{"group_id": o["group_id"], "original_block": o["original_block"],
                                           "frame_index": o["frame_index"], "sheet_cell_region": o["sheet_cell_region"]}
                                          for o in pose["occurrences"]]})

    asset_root = ROOT / "assets/prototype/enemy/vampire/remaster_v01"
    preparation_path = asset_root / "_source/preparation.json"
    preparation = read(preparation_path)
    assert preparation["geometry"] == entry["geometry"] == plan["geometry"] == helper.geometry()
    assert preparation["pending_pose_ids"] == list(poses)
    guides = []
    flattened = []
    for batch in preparation["batches"]:
        image_path = ROOT / batch["guide"]
        assert read(image_path.with_suffix(".json")) == batch
        assert batch["appearance_reference_sha256"] == entry["appearance_reference_sha256"]
        with Image.open(image_path) as image:
            size = list(image.size)
        assert size == [batch["columns"] * 512, batch["rows"] * 512]
        flattened.extend(batch["pose_ids"])
        guides.append({"path": batch["guide"], "sha256": sha(image_path), "size": size,
                       "pose_ids": batch["pose_ids"], "columns": batch["columns"], "rows": batch["rows"]})
    assert flattened == list(poses)
    appearance_copy = asset_root / "_source/appearance-master.png"
    assert sha(appearance_copy) == entry["appearance_reference_sha256"]
    with Image.open(appearance_copy) as master:
        master_rgba = master.convert("RGBA")
        master_record = {"path": relative(appearance_copy), "sha256": sha(appearance_copy),
                         "mode": master.mode, "size": list(master.size),
                         "alpha_extrema": list(master_rgba.getchannel("A").getextrema()),
                         "alpha_gt8_bounds": list(helper.bbox(master_rgba, 8))}
    palette_path = metadata_path.parent / native["palette"]
    files[relative(palette_path)] = {"sha256": sha(palette_path)}
    count_positions = sum(g["frame_count"] for g in entry["groups"])
    assert len(native_groups) == entry["original_group_slots"] == 15
    assert count_positions == native["frame_count"] == entry["original_frame_positions"] == 90
    assert len(poses) == len({p["original_signature"] for p in poses.values()}) == entry["unique_registered_poses"] == 56
    output = {
        "creature_id": CID, "phase": "source_preparation_only", "status": "source_checks_passed_awaiting_pilot_clearance",
        "plan_path": relative(plan_path), "plan_file_sha256": sha(plan_path),
        "helper_path": relative(helper_path), "helper_sha256": sha(helper_path),
        "approval_path": relative(approval_path), "appearance_approved": True, "animation_approved": False,
        "fingerprints": fingerprints, "native": {k: native[k] for k in ("name", "archive", "type", "category", "header_width", "header_height", "frame_count")},
        "counts": {"groups": 15, "timeline_positions": 90, "registered_poses": 56, "prepared_batches": len(guides),
                   "indexed_frame_hashes_verified": indexed_checks, "rgba_occurrences_verified": rgba_checks,
                   "new_artwork_calls": 0, "ingested_poses": 0, "exports_created": 0},
        "geometry": entry["geometry"], "idle_reference_pose": entry["og_idle_reference_pose_id"],
        "absent_group_ids_within_0_to_21": sorted(set(range(22)) - set(native_groups)),
        "groups": group_rows, "poses": pose_rows, "guides": guides,
        "appearance_copy": master_record, "source_files": files,
        "checks": {"native_groups_equal_plan_records": True, "occurrence_map_exact": True,
                   "representatives_exact": True, "opaque_body_rectangles_verified": True,
                   "aliases_recomputed": True, "approved_master_hash_verified": True,
                   "prepared_pose_coverage_exact": True},
        "limits": ["Static source and metadata checks only; no new artwork or idle reuse ingested.",
                   "No final atlas, mirror, SpriteFrames, offline package, browser, engine or playback validation.",
                   "Source order and repeated cells are verified; original timing and slot gameplay meaning remain unverified."],
    }
    output_path = REPORT / "source-preparation-audit.json"
    output_path.write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"report": relative(output_path), "counts": output["counts"], "master": master_record,
                      "aliases": {str(g["group_id"]): g["exact_aliases"] for g in group_rows if g["exact_aliases"]},
                      "checks": output["checks"]}, indent=2))


if __name__ == "__main__":
    main()
