"""Read-only artwork checks and mechanical pilot comparison contacts.

No artwork synthesis or retouching. PNG outputs are review composites only.
JSON evidence is printed; the worker saves the record using apply_patch.
"""
import hashlib
import importlib.util
import json
import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps


ROOT = Path(__file__).resolve().parents[6]
ASSETS = ROOT / "assets/prototype/enemy/skeleton/remaster_v01"
PILOT = ["skeleton_p033", "skeleton_p034", "skeleton_p035", "skeleton_p036",
         "skeleton_p043", "skeleton_p044", "skeleton_p045", "skeleton_p046",
         "skeleton_p047", "skeleton_p042"]
spec = importlib.util.spec_from_file_location("necropolis_helper", ROOT / "tools/art/necropolis_remaster.py")
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)
plan = helper.creature("skeleton")
poses = helper.posemap(plan)
manifest = helper.read(ASSETS / "source_manifest.json")


def digest(path):
    return hashlib.sha256(Path(path).read_bytes()).hexdigest()


def relative(path):
    return Path(path).relative_to(ROOT).as_posix()


def plate(frame, background):
    result = Image.new("RGBA", frame.size, background)
    result.alpha_composite(frame)
    return result.convert("RGB")


def contact(frames, factor, mirrored=False):
    # One shared window for all poses, never a per-action normalization.
    window = (352, 208, 784, 544)
    width = (window[2] - window[0]) * factor
    height = (window[3] - window[1]) * factor
    row_height = height * 2 + 52
    result = Image.new("RGB", (width * 5, row_height * 2), (25, 36, 47))
    draw = ImageDraw.Draw(result)
    for index, pid in enumerate(PILOT):
        original, candidate = frames[pid]
        if mirrored:
            original = ImageOps.mirror(original)
            candidate = ImageOps.mirror(candidate)
            # Symmetric window to preserve one constant display transform.
            region = (1024 - window[2], window[1], 1024 - window[0], window[3])
        else:
            region = window
        x = index % 5 * width
        y = index // 5 * row_height
        draw.text((x + 8, y + 4), pid + " / OG above, candidate below", fill=(236, 239, 241))
        for row, frame in enumerate([original, candidate]):
            tile = plate(frame.crop(region), (25, 36, 47) if row == 0 else (57, 62, 66))
            if factor != 1:
                tile = tile.resize((width, height), Image.Resampling.NEAREST)
            result.paste(tile, (x, y + 24 + row * (height + 12)))
    return result


frames = {}
checks = []
errors = []
actual_ids = sorted(record["pose_id"] for record in manifest["poses"])
if actual_ids != sorted(PILOT):
    errors.append("Active pose set differs from the exact ten pilot IDs")
for pid in PILOT:
    record = helper.read(ASSETS / "poses" / (pid + ".json"))
    original = helper.projected_original(poses[pid])
    candidate = Image.open(ROOT / record["registered_pose_file"]).convert("RGBA")
    mirror = Image.open(ROOT / record["mirror_file"]).convert("RGBA")
    frames[pid] = (original, candidate)
    raw = Image.open(ROOT / record["raw_source"]).convert("RGBA")
    bbox = candidate.getbbox()
    passed = {
        "fixed_cell": candidate.size == (1024, 768),
        "genuine_alpha": candidate.getchannel("A").getextrema() == (0, 255),
        "exact_mirror": ImageOps.mirror(candidate).tobytes() == mirror.tobytes(),
        "registered_hash": digest(ROOT / record["registered_pose_file"]) == record["registered_pose_sha256"],
        "mirror_hash": digest(ROOT / record["mirror_file"]) == record["mirror_sha256"],
        "raw_hash": digest(ROOT / record["raw_source"]) == record["raw_sha256"],
        "safe_padding": bool(bbox) and bbox[0] >= 40 and bbox[1] >= 40 and bbox[2] <= 984 and bbox[3] <= 728,
    }
    errors.extend(pid + ": " + key for key, value in passed.items() if not value)
    checks.append({"pose_id": pid, "checks": passed, "visible_bounds": bbox,
                   "raw_size": raw.size, "raw_alpha_range": raw.getchannel("A").getextrema(),
                   "component_isolation": record.get("component_isolation", False),
                   "source_occurrences": [{"group_id": o["group_id"], "block": o["original_block"], "frame_index": o["frame_index"]} for o in poses[pid]["occurrences"]]})

outputs = []
for suffix, factor, mirrored in [("source_1x", 1, False), ("source_2x", 2, False), ("mirror_1x", 1, True)]:
    output = ASSETS / "contacts" / ("pilot_comparison_" + suffix + ".png")
    contact(frames, factor, mirrored).save(output)
    outputs.append(relative(output))

light = Image.new("RGB", (432 * 5, 360 * 2), (236, 239, 241))
draw = ImageDraw.Draw(light)
for index, pid in enumerate(PILOT):
    x = index % 5 * 432
    y = index // 5 * 360
    draw.text((x + 8, y + 4), pid + " / light alpha review", fill=(20, 30, 40))
    light.paste(plate(frames[pid][1].crop((352, 208, 784, 544)), (236, 239, 241)), (x, y + 24))
light_path = ASSETS / "contacts/pilot_alpha_light_contact.png"
light.save(light_path)
outputs.append(relative(light_path))

groups = []
for group in manifest["groups"]:
    if not group["complete"]:
        continue
    atlas = Image.open(ROOT / group["file"]).convert("RGBA")
    mirrored = Image.open(ROOT / group["mirror_file"]).convert("RGBA")
    cells_match = True
    for index, pid in enumerate(group["pose_ids_in_source_order"]):
        region = group["frame_regions"][index]
        candidate = frames[pid][1]
        cells_match &= helper.crop(atlas, region).tobytes() == candidate.tobytes()
        cells_match &= helper.crop(mirrored, region).tobytes() == ImageOps.mirror(candidate).tobytes()
    gif_data = []
    for orientation, path in [("source", group["preview"]), ("mirror", group["mirror_preview"])]:
        gif = Image.open(ROOT / path)
        durations = []
        filmstrip = Image.new("RGB", (432 * group["frame_count"], 336), (25, 36, 47))
        for index in range(gif.n_frames):
            gif.seek(index)
            durations.append(gif.info.get("duration", 0))
            window = (176, 104, 392, 272) if orientation == "source" else (120, 104, 336, 272)
            frame = gif.convert("RGB").crop(window).resize((432, 336), Image.Resampling.NEAREST)
            filmstrip.paste(frame, (index * 432, 0))
        strip = ASSETS / "contacts" / ("pilot_g%02d_%s_gif_frames.png" % (group["group_id"], orientation))
        filmstrip.save(strip)
        outputs.append(relative(strip))
        gif_data.append({"orientation": orientation, "frames": gif.n_frames, "duration_ms": sum(durations), "per_frame_ms": durations})
    group_ok = cells_match and all(item["duration_ms"] == group["frame_count"] * 100 for item in gif_data)
    if not group_ok:
        errors.append("Group %s source order, mirror or preview duration failure" % group["group_id"])
    groups.append({"group_id": group["group_id"], "block": group["original_block"], "pose_ids_in_source_order": group["pose_ids_in_source_order"], "atlas_cells_match": cells_match, "gif_data": gif_data})

immutable = {}
for key in ["appearance_reference", "original_metadata", "original_def"]:
    actual = digest(ROOT / plan[key])
    immutable[key] = {"path": plan[key], "sha256": actual, "expected_sha256": plan[key + "_sha256"], "matches": actual == plan[key + "_sha256"]}
    if not immutable[key]["matches"]:
        errors.append("Immutable reference hash differs: " + key)

tool_requests = []
for path in sorted((ASSETS / "_source/prompts").glob("*.request.json")):
    request = helper.read(path)
    tool_requests.append({"request": relative(path), "request_sha256": digest(path),
                          "references": [{"path": relative(Path(ref)), "sha256": digest(ref)} for ref in request["referenced_image_paths"]],
                          "executed": (ASSETS / "_source" / (path.name.replace(".request.json", ".tool-metadata.json"))).exists()})

attempt_copies = []
for path in sorted((ASSETS / "_source").glob("*.tool-metadata.json")):
    metadata = helper.read(path)
    generated = Path(re.search(r" as (.+?) by default\.", metadata["returned_metadata"]["output_hint"]).group(1))
    local = ROOT / metadata["raw_copy"]
    identical = generated.read_bytes() == local.read_bytes()
    attempt_copies.append({"metadata": relative(path), "raw_copy": relative(local),
                           "sha256": digest(local), "byte_identical_to_builtin_output": identical})
    if not identical:
        errors.append("Raw built-in output copy differs: " + local.name)

print(json.dumps({"creature_id": "skeleton", "scope": "ten-pose attack/turn pilot only",
                  "source_plan_sha256": digest(ROOT / "docs/art/remasters/necropolis-v01/generation-plan.json"),
                  "shared_helper_sha256_at_check": digest(ROOT / "tools/art/necropolis_remaster.py"),
                  "coverage": manifest["coverage"], "pose_checks": checks, "groups": groups,
                  "immutable_references": immutable, "tool_requests": tool_requests, "attempt_copies": attempt_copies,
                  "comparison_outputs": outputs, "errors": errors,
                  "engine_or_browser_run": False, "human_animation_acceptance": False,
                  "original_timing_verified": False, "full_creature_complete": False}, indent=2))
