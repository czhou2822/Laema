"""Freeze Wight-only production provenance and actual reviewed-file identities."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("wight_final_helper", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)
dest = h.dest("wight")
plan = h.creature("wight")
manifest = h.read(dest / "source_manifest.json")
log = h.read(dest / "_source/generation-log.json")
pose_notes = h.read(REPORT / "pose-review-observations.json")
group_notes = h.read(REPORT / "group-review-observations.json")
validation = h.read(REPORT / "final-validate.json")
assert validation["complete"] and not validation["errors"]
assert manifest["coverage"] == validation["coverage"]
assert len(log["attempts"]) == 14 and len(log["pose_generation_bindings"]) == 57
pose_map = {p["pose_id"]: p for p in manifest["poses"]}
source_map = {p["pose_id"]: p for p in plan["poses"]}
bindings = {p["pose_id"]: p["generation_attempt"] for p in log["pose_generation_bindings"]}
for attempt in log["attempts"]:
    raw = ROOT / attempt["saved_raw"]
    attempt["raw_sha256"] = h.sha(raw)
    assert h.sha(attempt["original_tool_path"]) == attempt["raw_sha256"]
    attempt["original_tool_copy_byte_identical"] = True
    attempt["prompt_sha256"] = h.sha(ROOT / attempt["saved_prompt"])
    attempt["reference_images"] = [{"path": p, "sha256": h.sha(ROOT / p)} for p in attempt["reference_images"]]
    with Image.open(raw) as im:
        attempt["raw_image"] = {"mode": im.mode, "size": list(im.size), "alpha_extrema": list(im.getchannel("A").getextrema())}
log["source_plan"] = {"path": "docs/art/remasters/necropolis-v01/generation-plan.json", "sha256": h.sha(ROOT / "docs/art/remasters/necropolis-v01/generation-plan.json")}
log["helper"] = {"path": "tools/art/necropolis_remaster.py", "sha256": h.sha(ROOT / "tools/art/necropolis_remaster.py")}
h.write(dest / "_source/generation-provenance.json", log)

poses = []
for note in pose_notes["poses"]:
    pid = note["pose_id"]
    p = pose_map[pid]
    assert p["artwork_origin"] == "built-in image-generation artwork"
    assert p["original_signature"] == source_map[pid]["original_signature"]
    assert p["geometry"] == plan["geometry"]
    assert p["visual_review"]["source_sha256_at_review"] == p["registered_pose_sha256"] == h.sha(ROOT / p["registered_pose_file"])
    assert p["visual_review"]["mirror_sha256_at_review"] == p["mirror_sha256"] == h.sha(ROOT / p["mirror_file"])
    poses.append({**note, "generation_attempt": bindings[pid], "registered_pose": p["registered_pose_file"], "registered_sha256": p["registered_pose_sha256"], "mirror_pose": p["mirror_file"], "mirror_sha256": p["mirror_sha256"], "registration": p["registration"], "evidence_1x_sha256": h.sha(ROOT / note["evidence_1x"]), "evidence_2x_sha256": h.sha(ROOT / note["evidence_2x"])})

groups = []
group_map = {g["group_id"]: g for g in manifest["groups"]}
for note in group_notes["groups"]:
    g = group_map[note["group_id"]]
    for alias in g["exact_aliases"]:
        other = group_map[alias]
        assert g["pose_ids_in_source_order"] == other["pose_ids_in_source_order"]
        assert g["sha256"] == other["sha256"] and g["mirror_sha256"] == other["mirror_sha256"]
    gif_contact = f"assets/prototype/enemy/wight/remaster_v01/_source/review/group_{g['group_id']:02d}_block_{g['original_block']:02d}-gif-frames.png"
    groups.append({**note, "original_block": g["original_block"], "pose_ids_in_source_order": g["pose_ids_in_source_order"], "exact_aliases": g["exact_aliases"], "contact": g["contact"], "contact_sha256": h.sha(ROOT / g["contact"]), "decoded_gif_contact": gif_contact, "decoded_gif_contact_sha256": h.sha(ROOT / gif_contact), "source_gif": g["preview"], "source_gif_sha256": h.sha(ROOT / g["preview"]), "mirror_gif": g["mirror_preview"], "mirror_gif_sha256": h.sha(ROOT / g["mirror_preview"]), "source_atlas_sha256": g["sha256"], "mirror_atlas_sha256": g["mirror_sha256"]})

resources = []
for filename in ["original_groups.tres", "original_groups_mirrored.tres"]:
    fp = dest / filename
    text = fp.read_text(encoding="utf-8")
    assert len(re.findall(r'\[sub_resource type="AtlasTexture"', text)) == 102
    assert len(re.findall(r'"name": &"og_', text)) == 18
    references = re.findall(r'path="res://([^\"]+)"', text)
    assert len(references) == 18 and all((ROOT / p).is_file() for p in references)
    assert "metadata/preview_only = true" in text and "metadata/original_timing_verified = false" in text
    resources.append({"file": h.rel(fp), "sha256": h.sha(fp), "animations": 18, "atlas_textures": 102, "all_18_local_atlas_paths_exist": True, "static_text_check_only": True})

counts = {"group_atlases_source_and_mirror": len(list(dest.glob("group_*.png"))), "frame_pngs_source_and_mirror": len(list((dest / "frames").rglob("*.png"))), "pose_pngs_source_and_mirror": len(list((dest / "poses").glob("*.png"))), "gif_previews_source_and_mirror": len(list((dest / "previews").glob("*.gif"))), "source_candidate_group_contacts": len(list((dest / "contacts").glob("*.png"))), "new_artwork_calls": 14, "current_source_generation_pages": len(set(bindings.values())), "newly_drawn_final_poses": 57, "approved_master_reuse": 0, "missing_poses": 0}
assert counts["group_atlases_source_and_mirror"] == 36
assert counts["frame_pngs_source_and_mirror"] == 204
assert counts["pose_pngs_source_and_mirror"] == 114
assert counts["gif_previews_source_and_mirror"] == 36
assert counts["source_candidate_group_contacts"] == 18
result = {"schema_version": 1, "creature_id": "wight", "status": "complete_worker_candidate_pending_parent_and_human_motion_review", "coverage": manifest["coverage"], "counts": counts, "final_validate": validation, "source_manifest_sha256": h.sha(dest / "source_manifest.json"), "provenance": h.rel(dest / "_source/generation-provenance.json"), "poses": poses, "groups": groups, "spriteframes_static_checks": resources, "unresolved_blocking_worker_findings": [], "review_limits": ["Source/candidate and GIF frames inspected as stills, not continuous timed playback", "Original timing unknown; 10fps preview only", "No browser, Godot import/editor/runtime, gameplay test or human animation acceptance", "New drawings interpret native silhouette and bone/cloth detail; not pixel-identical or motion-capture pose measurements", "Uniform aspect-fit can leave a smaller visible silhouette inside native target bounds; no per-action scaling override or stretching", "Fine fold/hand/skull variation and motion smoothness remain for parent/human judgement"]}
h.write(REPORT / "visual-review.json", result)
print(json.dumps({"status": result["status"], "coverage": result["coverage"], "counts": counts, "source_manifest_sha256": result["source_manifest_sha256"], "provenance_raw_copies_verified": len(log["attempts"]), "reviewed_groups": len(groups), "reviewed_poses": len(poses)}, indent=2))
