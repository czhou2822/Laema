"""Read-only Lich source/occurrence audit. Run with Python -B; JSON goes to stdout."""
import hashlib
import importlib.util
import json
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
PLAN = ROOT / "docs/art/remasters/necropolis-v01/generation-plan.json"


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def need(condition, message):
    if not condition:
        raise ValueError(message)


spec = importlib.util.spec_from_file_location(
    "necropolis_readonly", ROOT / "tools/art/necropolis_remaster.py"
)
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
plan = read(PLAN)
c = next(v for v in plan["creatures"] if v["creature_id"] == "lich")
native = read(ROOT / c["original_metadata"])
masters = ROOT / "docs/art/production/necropolis-creature-assets-v01"
job = read(masters / "lich/job.json")
approval = next(
    v for v in read(PLAN.parent / "master-approval.json")["entries"]
    if v["creature_id"] == "lich"
)
chosen = next(v for v in read(masters / "selected-masters.json")["entries"] if v["slug"] == "lich")
hashes = {}
for path_key, hash_key in (
    ("original_metadata", "original_metadata_sha256"),
    ("original_def", "original_def_sha256"),
    ("appearance_reference", "appearance_reference_sha256"),
):
    actual = sha(ROOT / c[path_key])
    need(actual == c[hash_key], "Plan hash mismatch: " + path_key)
    hashes[path_key] = {"path": c[path_key], "actual_sha256": actual, "matches_plan": True}
need(hashes["original_def"]["actual_sha256"] == native["def_sha256"] == job["original_def_sha256"], "Native/job DEF mismatch")
need(hashes["original_metadata"]["actual_sha256"] == job["source_metadata_sha256"], "Job metadata mismatch")
need(hashes["appearance_reference"]["actual_sha256"] == approval["sha256"] == chosen["master_sha256"], "Approval/selection master mismatch")
need(c["appearance_reference"] == approval["master"], "Approval path mismatch")
need((masters / chosen["master"]).resolve() == (ROOT / c["appearance_reference"]).resolve(), "Selected master path mismatch")
need(len(c["groups"]) == len(native["groups"]) == c["original_group_slots"], "Group count mismatch")
pm = {p["pose_id"]: p for p in c["poses"]}
need(len(pm) == len(c["poses"]) == c["unique_registered_poses"], "Pose count mismatch")
need(len({p["original_signature"] for p in c["poses"]}) == len(pm), "Duplicate signature")
expected_occurrences = {pid: [] for pid in pm}
groups = []
sheet_hashes = {}
indexed_hash_checks = 0
rgba_bounds_checks = 0
for group, ng in zip(c["groups"], native["groups"]):
    need(group["original_group_record"] == ng, "Native group record mismatch")
    need(group["group_id"] == ng["id"] and group["original_block"] == ng["block"], "Group binding mismatch")
    seq = group["pose_ids_in_source_order"]
    need(group["frame_count"] == len(seq) == len(ng["frames"]), "Timeline length mismatch")
    aliases = [other["group_id"] for other in c["groups"] if other is not group and other["pose_ids_in_source_order"] == seq]
    need(group["exact_aliases"] == aliases, "Alias mismatch")
    for f, pid in zip(ng["frames"], seq):
        page = ng["pages"][f["page"]]
        rgba_path = (ROOT / c["original_metadata"]).parent / page["preview"]
        indexed_path = (ROOT / c["original_metadata"]).parent / page["indexed"]
        r = {
            "group_id": ng["id"], "original_block": ng["block"], "frame_index": f["index"],
            "rgba_sheet": rgba_path.relative_to(ROOT).as_posix(),
            "indexed_sheet": indexed_path.relative_to(ROOT).as_posix(),
            "sheet_cell_region": [f["x"], f["y"], ng["cell_width"], ng["cell_height"]],
            "source_record": f,
        }
        need(helper.signature(f) == pm[pid]["original_signature"], "Frame signature mismatch")
        expected_occurrences[pid].append(r)
        for sheet_path in (rgba_path, indexed_path):
            key = sheet_path.relative_to(ROOT).as_posix()
            if key not in sheet_hashes:
                with Image.open(sheet_path) as sheet:
                    need(sheet.size == (page["width"], page["height"]), "Sheet dimensions mismatch")
                    sheet_hashes[key] = {"sha256": sha(sheet_path), "size": list(sheet.size), "mode": sheet.mode}
        with Image.open(indexed_path) as indexed:
            need(indexed.mode == "P", "Indexed sheet is not paletted")
            x, y = f["x"] + f["left"], f["y"] + f["top"]
            indices = indexed.crop((x, y, x + f["width"], y + f["height"]))
            need(hashlib.sha256(indices.tobytes()).hexdigest() == f["index_sha256"], "Indexed drawing hash mismatch")
            indexed_hash_checks += 1
        with Image.open(rgba_path) as sheet:
            x, y, w, h = r["sheet_cell_region"]
            cell = sheet.convert("RGBA").crop((x, y, x + w, y + h))
            box = helper.bbox(cell, 160)
            need(box is not None, "Empty opaque source body")
            need([box[0], box[1], box[2] - box[0], box[3] - box[1]] == pm[pid]["opaque_body_rect"], "Opaque-body rect mismatch")
            rgba_bounds_checks += 1
    groups.append({k: group[k] for k in (
        "group_id", "original_block", "purpose_interpretation", "frame_count", "pose_ids_in_source_order", "exact_aliases"
    )})
poses = []
mapped_bounds = []
for pid, p in pm.items():
    need(p["occurrences"] == expected_occurrences[pid], "Occurrence map mismatch: " + pid)
    need(p["representative"] == expected_occurrences[pid][0], "Representative mismatch: " + pid)
    x, y, w, h = p["opaque_body_rect"]
    scale = c["geometry"]["uniform_scale"]
    ax, ay = c["geometry"]["anchor"]
    sx, sy = c["geometry"]["source_anchor"]
    mapped = [ax + (x - sx) * scale, ay + (y - sy) * scale,
              ax + (x + w - sx) * scale, ay + (y + h - sy) * scale]
    need(mapped[0] >= 40 and mapped[1] >= 40 and mapped[2] <= 984 and mapped[3] <= 728, "Source transform padding mismatch")
    mapped_bounds.append(mapped)
    poses.append({
        "pose_id": pid, "original_signature": p["original_signature"], "opaque_body_rect": p["opaque_body_rect"],
        "occurrences": [{k: r[k] for k in ("group_id", "original_block", "frame_index")} for r in p["occurrences"]],
    })
need(sum(g["frame_count"] for g in groups) == native["frame_count"] == c["original_frame_positions"], "Total timeline mismatch")
with Image.open(ROOT / c["appearance_reference"]) as master:
    master_info = {"size": list(master.size), "mode": master.mode, "alpha_extrema": list(master.getchannel("A").getextrema()), "alpha_gt_8_bounds": list(helper.bbox(master, 8))}
dd = helper.dest("lich")
preparation = None
if (dd / "_source/preparation.json").exists():
    prep = read(dd / "_source/preparation.json")
    need(sha(dd / "_source/appearance-master.png") == c["appearance_reference_sha256"], "Prepared master hash mismatch")
    flat = []
    for batch in prep["batches"]:
        fp = ROOT / batch["guide"]
        need(read(fp.with_suffix(".json")) == batch, "Guide mapping mismatch")
        with Image.open(fp) as im:
            need(im.size == (512 * batch["columns"], 512 * batch["rows"]), "Guide size mismatch")
        flat.extend(batch["pose_ids"])
    need(flat == prep["pending_pose_ids"], "Guide pose order mismatch")
    preparation = {"pending_poses": len(flat), "batch_count": len(prep["batches"]), "guides": prep["batches"], "master_copy_matches": True}
print(json.dumps({
    "creature_id": "lich", "scope": "source preparation only; no animation artwork review",
    "complete_creature_entry_parsed": True, "generation_plan_sha256": sha(PLAN),
    "creature_entry_sha256": hashlib.sha256(json.dumps(c, sort_keys=True, separators=(",", ":")).encode()).hexdigest(),
    "source_hashes": hashes, "native_header": {k: v for k, v in native.items() if k != "groups"},
    "master": master_info, "geometry": c["geometry"], "idle_pose_id": c["og_idle_reference_pose_id"],
    "mapped_opaque_union_ltrb": [min(v[0] for v in mapped_bounds), min(v[1] for v in mapped_bounds), max(v[2] for v in mapped_bounds), max(v[3] for v in mapped_bounds)],
    "counts": {"groups": len(groups), "timeline_positions": indexed_hash_checks, "registered_poses": len(pm), "rgba_body_bounds_checked": rgba_bounds_checks, "source_sheets": len(sheet_hashes)},
    "checks_passed": ["DEF/metadata/master hashes", "master selection and approval", "all native group records", "all source sequence entries", "all indexed crop hashes", "all opaque body bounds", "all representatives and occurrence maps", "all exact group aliases", "fixed-transform source bounds and padding"],
    "groups": groups, "poses": poses, "source_sheets": sheet_hashes, "preparation": preparation,
    "artwork_created": 0, "approved_idle_reused": 0, "runtime_or_playback_checked": False,
}, indent=2))
