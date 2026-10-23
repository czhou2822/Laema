"""Mechanical full-library evidence and static review composites; no art synthesis."""
import hashlib
import importlib.util
import json
import math
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
ASSETS = ROOT / "assets/prototype/enemy/skeleton/remaster_v01"
REPORT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("necropolis_helper", ROOT / "tools/art/necropolis_remaster.py")
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
plan = helper.creature("skeleton")
posemap = helper.posemap(plan)
manifest = helper.read(ASSETS / "source_manifest.json")
preparation = helper.read(ASSETS / "_source/preparation.json")
inputs = helper.read(REPORT / "full-pass-inputs.json")
frames = {}
pose_checks = []
errors = []
WINDOW = (256, 176, 800, 560)
WIDTH, HEIGHT = 544, 384


def sha(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def relative(path):
    return Path(path).relative_to(ROOT).as_posix()


def plate(frame, background):
    output = Image.new("RGBA", frame.size, background)
    output.alpha_composite(frame)
    return output.convert("RGB")


def comparison(ids, mirrored=False):
    cols = min(4, len(ids))
    row_height = HEIGHT * 2 + 48
    out = Image.new("RGB", (WIDTH * cols, row_height * math.ceil(len(ids) / cols)), (25, 36, 47))
    draw = ImageDraw.Draw(out)
    for index, pid in enumerate(ids):
        x, y = index % cols * WIDTH, index // cols * row_height
        draw.text((x + 8, y + 4), pid + " / original above, candidate below", fill=(235, 240, 243))
        if pid not in frames:
            draw.text((x + 8, y + 24), "MISSING", fill=(255, 100, 100))
            continue
        original, candidate = frames[pid]
        window = WINDOW
        if mirrored:
            original, candidate = ImageOps.mirror(original), ImageOps.mirror(candidate)
            window = (1024 - WINDOW[2], WINDOW[1], 1024 - WINDOW[0], WINDOW[3])
        for row, im in enumerate([original, candidate]):
            out.paste(plate(im.crop(window), (25, 36, 47) if row == 0 else (57, 62, 66)), (x, y + 24 + row * (HEIGHT + 12)))
    return out


for record in manifest["poses"]:
    pid = record["pose_id"]
    candidate = Image.open(ROOT / record["registered_pose_file"]).convert("RGBA")
    mirror = Image.open(ROOT / record["mirror_file"]).convert("RGBA")
    original = helper.projected_original(posemap[pid])
    frames[pid] = (original, candidate)
    box = helper.bbox(candidate, 0)
    alpha = candidate.getchannel("A").getextrema()
    checks = {
        "fixed_cell": candidate.size == (1024, 768),
        "genuine_alpha": alpha[0] == 0 and alpha[1] >= 250,
        "safe_padding": bool(box) and box[0] >= 40 and box[1] >= 40 and box[2] <= 984 and box[3] <= 728,
        "exact_mirror": ImageOps.mirror(candidate).tobytes() == mirror.tobytes(),
        "pose_hash": sha(ROOT / record["registered_pose_file"]) == record["registered_pose_sha256"],
        "mirror_hash": sha(ROOT / record["mirror_file"]) == record["mirror_sha256"],
        "isolated_hash": sha(ROOT / record["isolated_source"]) == record["isolated_sha256"],
        "raw_hash": sha(ROOT / record["raw_source"]) == record["raw_sha256"],
        "review_hash_fresh": isinstance(record["visual_review"], dict) and record["visual_review"].get("source_sha256_at_review") == record["registered_pose_sha256"] and record["visual_review"].get("mirror_sha256_at_review") == record["mirror_sha256"],
    }
    errors.extend(pid + ": " + name for name, passed in checks.items() if not passed)
    pose_checks.append({"pose_id": pid, "checks": checks, "visible_bounds": box, "alpha_range": alpha,
                        "artwork_origin": record["artwork_origin"], "raw_source": record["raw_source"],
                        "registration": record["registration"], "visual_review": record["visual_review"],
                        "source_occurrences": [{"group_id": o["group_id"], "block": o["original_block"], "frame_index": o["frame_index"]} for o in posemap[pid]["occurrences"]]})

outputs = []
for index, batch in enumerate(preparation["batches"]):
    for mirrored in [False, True]:
        name = "full_batch_%03d_%s_comparison.png" % (index, "mirror" if mirrored else "source")
        path = ASSETS / "contacts" / name
        comparison(batch["pose_ids"], mirrored).save(path)
        outputs.append(relative(path))
    ids = batch["pose_ids"]
    light = Image.new("RGB", (WIDTH * 4, (HEIGHT + 24) * math.ceil(len(ids) / 4)), (236, 239, 241))
    draw = ImageDraw.Draw(light)
    for slot, pid in enumerate(ids):
        if pid not in frames:
            continue
        x, y = slot % 4 * WIDTH, slot // 4 * (HEIGHT + 24)
        draw.text((x + 8, y + 4), pid + " / light alpha check", fill=(20, 30, 40))
        light.paste(plate(frames[pid][1].crop(WINDOW), (236, 239, 241)), (x, y + 24))
    light_path = ASSETS / "contacts" / ("full_batch_%03d_light_alpha.png" % index)
    light.save(light_path)
    outputs.append(relative(light_path))

groups = []
for group in manifest["groups"]:
    if not group["complete"]:
        continue
    atlas = Image.open(ROOT / group["file"]).convert("RGBA")
    mirrored_atlas = Image.open(ROOT / group["mirror_file"]).convert("RGBA")
    exact = True
    for index, pid in enumerate(group["pose_ids_in_source_order"]):
        region = group["frame_regions"][index]
        candidate = frames[pid][1]
        exact &= helper.crop(atlas, region).tobytes() == candidate.tobytes()
        exact &= helper.crop(mirrored_atlas, region).tobytes() == ImageOps.mirror(candidate).tobytes()
    gifs = []
    for orientation, gif_path in [("source", group["preview"]), ("mirror", group["mirror_preview"])]:
        source = Image.open(ROOT / gif_path)
        durations, timeline = [], []
        for index in range(source.n_frames):
            source.seek(index)
            ms = source.info.get("duration", 0)
            durations.append(ms)
            timeline.extend([source.convert("RGB").copy()] * (ms // 100))
        count = len(group["pose_ids_in_source_order"])
        cols = min(count, 4)
        strip = Image.new("RGB", (WIDTH * cols, (HEIGHT + 24) * math.ceil(count / cols)), (25, 36, 47))
        draw = ImageDraw.Draw(strip)
        for index, frame in enumerate(timeline):
            x, y = index % cols * WIDTH, index // cols * (HEIGHT + 24)
            window = (128, 88, 400, 280) if orientation == "source" else (112, 88, 384, 280)
            strip.paste(frame.crop(window).resize((WIDTH, HEIGHT), Image.Resampling.NEAREST), (x, y + 24))
            draw.text((x + 8, y + 4), "G%d F%d %s" % (group["group_id"], index, group["pose_ids_in_source_order"][index]), fill=(235, 240, 243))
        path = ASSETS / "contacts" / ("full_g%02d_%s_gif_timeline.png" % (group["group_id"], orientation))
        strip.save(path)
        outputs.append(relative(path))
        gifs.append({"orientation": orientation, "physical_frames": source.n_frames,
                     "encoded_durations_ms": durations, "logical_100ms_positions": len(timeline),
                     "total_duration_ms": sum(durations), "timeline_contact": relative(path)})
        if len(timeline) != count or any(ms % 100 for ms in durations):
            errors.append("GIF timeline mismatch G" + str(group["group_id"]) + orientation)
    if not exact:
        errors.append("Atlas order/mirror mismatch G" + str(group["group_id"]))
    for mirrored in [False, True]:
        path = ASSETS / "contacts" / ("full_g%02d_%s_comparison.png" % (group["group_id"], "mirror" if mirrored else "source"))
        comparison(group["pose_ids_in_source_order"], mirrored).save(path)
        outputs.append(relative(path))
    groups.append({"group_id": group["group_id"], "block": group["original_block"],
                   "purpose": group["purpose_interpretation"], "source_order": group["pose_ids_in_source_order"],
                   "exact_aliases": group["exact_aliases"], "atlas_cells_exact": exact, "gifs": gifs})

baseline_checks = []
for item in inputs["files"]:
    matched = sha(ROOT / item["path"]) == item["sha256"]
    baseline_checks.append({**item, "unchanged": matched})
    if not matched:
        errors.append("Baseline input or retained pilot changed: " + item["path"])

attempts = []
for path in sorted((ASSETS / "_source").glob("*.tool-metadata.json")):
    metadata = helper.read(path)
    original_path = Path(re.search(r" as (.+?) by default\.", metadata["returned_metadata"]["output_hint"]).group(1))
    copy = ROOT / metadata["raw_copy"]
    same = original_path.read_bytes() == copy.read_bytes()
    request = helper.read(ROOT / metadata["request"])
    refs = [{"path": relative(Path(p)), "sha256": sha(p)} for p in request["referenced_image_paths"]]
    attempts.append({"metadata": relative(path), "raw_copy": relative(copy), "sha256": sha(copy),
                     "byte_identical_to_builtin_output": same, "request": metadata["request"],
                     "references": refs, "model_returned": None, "seed_returned": None})
    if not same:
        errors.append("Builtin raw copy differs: " + copy.name)

resources = []
for name in ["original_groups.tres", "original_groups_mirrored.tres"]:
    path = ASSETS / name
    if path.exists():
        resources.append({"path": relative(path), "sha256": sha(path)})

aliases = []
group_map = {group["group_id"]: group for group in manifest["groups"]}
for group in manifest["groups"]:
    for alias in group["exact_aliases"]:
        if group["group_id"] > alias:
            continue
        other = group_map[alias]
        matches = group["pose_ids_in_source_order"] == other["pose_ids_in_source_order"] and sha(ROOT / group["file"]) == sha(ROOT / other["file"]) and sha(ROOT / group["mirror_file"]) == sha(ROOT / other["mirror_file"])
        aliases.append({"groups": [group["group_id"], alias], "order_and_atlas_bytes_equal": matches})
        if not matches:
            errors.append("Exact alias mismatch " + str(group["group_id"]) + "/" + str(alias))

print(json.dumps({"creature_id": "skeleton", "scope": "full generation-plan coverage",
                  "coverage": manifest["coverage"], "pose_checks": pose_checks, "group_checks": groups,
                  "baseline_immutability": baseline_checks, "builtin_attempts": attempts,
                  "spriteframes_resources": resources, "exact_alias_checks": aliases,
                  "comparison_outputs": outputs, "errors": errors,
                  "shared_helper_sha256": sha(ROOT / "tools/art/necropolis_remaster.py"),
                  "human_animation_acceptance": False, "original_timing_verified": False,
                  "engine_or_browser_run": False, "live_animation_playback": False}, indent=2))
