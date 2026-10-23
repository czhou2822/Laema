"""Vampire-only provenance/export audit and machine-readable review handoff."""

import hashlib
import json
import re
from pathlib import Path

from PIL import Image

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
ASSET = ROOT / "assets/prototype/enemy/vampire/remaster_v01"


def read(path):
    return json.loads(path.read_text(encoding="utf-8-sig"))


def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def relative(path):
    return path.resolve().relative_to(ROOT).as_posix()


def pixels(path):
    with Image.open(path) as image:
        return image.convert("RGBA").tobytes()


def main():
    manifest_path = ASSET / "source_manifest.json"
    manifest = read(manifest_path)
    source_plan = read(ROOT / "docs/art/remasters/necropolis-v01/generation-plan.json")
    source = next(c for c in source_plan["creatures"] if c["creature_id"] == "vampire")
    observations = read(REPORT / "review-observations.json")
    gif_index = {g["group_id"]: g for g in read(REPORT / "gif-sampling-index.json")}
    validations = read(REPORT / "validation-results.json")
    assert validations["initial_validate"]["complete"] and validations["final_validate"]["complete"]
    assert not validations["final_validate"]["errors"]
    for field, hash_field in [("appearance_reference", "appearance_reference_sha256"),
                              ("original_def", "original_def_sha256"),
                              ("original_metadata", "original_metadata_sha256")]:
        assert sha(ROOT / source[field]) == source[hash_field], field
    assert manifest["coverage"] == {"complete_groups": 15, "total_groups": 15, "available_poses": 56,
                                    "total_poses": 56, "missing_pose_ids": [], "frame_positions": 90,
                                    "reviewed_poses": 56}
    poses = []
    source_poses = {p["pose_id"]: p for p in source["poses"]}
    for pose in manifest["poses"]:
        pid = pose["pose_id"]
        review = next(r["note"] for r in observations["pose_ranges"]
                      if r["start"] <= int(pid[-3:]) <= r["end"])
        for path_field, sha_field in [("raw_source", "raw_sha256"), ("isolated_source", "isolated_sha256"),
                                     ("registered_pose_file", "registered_pose_sha256"), ("mirror_file", "mirror_sha256")]:
            assert sha(ROOT / pose[path_field]) == pose[sha_field], (pid, path_field)
        assert isinstance(pose["visual_review"], dict)
        assert pose["visual_review"]["source_sha256_at_review"] == pose["registered_pose_sha256"]
        assert pose["visual_review"]["mirror_sha256_at_review"] == pose["mirror_sha256"]
        assert pose["original_signature"] == source_poses[pid]["original_signature"]
        if pose["prompt"]:
            assert (ROOT / pose["prompt"]).is_file()
        if pid == "vampire_p004":
            assert pose["artwork_origin"] == "approved high-resolution idle master reuse"
            assert pose["raw_sha256"] == source["appearance_reference_sha256"]
        else:
            assert pose["artwork_origin"] == "built-in image-generation artwork"
        start = int(pid[-3:]) // 4 * 4
        end = min(start + 3, 55)
        comparison = REPORT / "review-images" / f'vampire_p{start:03d}-vampire_p{end:03d}-comparison.png'
        if pid == "vampire_p031":
            comparison = REPORT / "review-images/vampire_p031-vampire_p031-comparison.png"
        assert comparison.is_file()
        poses.append({"pose_id": pid, "artwork_origin": pose["artwork_origin"],
                      "raw_source": pose["raw_source"], "raw_sha256": pose["raw_sha256"],
                      "isolated_source": pose["isolated_source"], "isolated_sha256": pose["isolated_sha256"],
                      "prompt": pose["prompt"], "registered_pose_file": pose["registered_pose_file"],
                      "registered_pose_sha256": pose["registered_pose_sha256"],
                      "mirror_file": pose["mirror_file"], "mirror_sha256": pose["mirror_sha256"],
                      "source_occurrence_count": len(source_poses[pid]["occurrences"]),
                      "comparison": relative(comparison), "comparison_sha256": sha(comparison),
                      "worker_observation": review, "worker_review": "candidate reviewed; no blocking defect observed",
                      "human_animation_acceptance": False})
    assert len({p["registered_pose_sha256"] for p in poses}) == 56, "Unexpected identical pose files"
    group_lookup = {g["group_id"]: g for g in manifest["groups"]}
    groups = []
    frame_png_checks = 0
    for group in manifest["groups"]:
        gid = group["group_id"]
        expected = next(g for g in source["groups"] if g["group_id"] == gid)
        assert group["pose_ids_in_source_order"] == expected["pose_ids_in_source_order"]
        assert group["exact_aliases"] == expected["exact_aliases"]
        for alias_id in group["exact_aliases"]:
            alias = group_lookup[alias_id]
            assert group["sha256"] == alias["sha256"]
            assert group["mirror_sha256"] == alias["mirror_sha256"]
            for key in ["preview", "mirror_preview"]:
                assert sha(ROOT / group[key]) == sha(ROOT / alias[key])
        for index, pid in enumerate(group["pose_ids_in_source_order"]):
            for direction in ["source", "mirror"]:
                path = ASSET / "frames" / direction / f'g{gid:02d}_b{group["original_block"]:02d}' / f'{index:03d}.png'
                pose_path = ASSET / "poses" / (pid + ("_mirror" if direction == "mirror" else "") + ".png")
                assert pixels(path) == pixels(pose_path), (gid, index, direction)
                frame_png_checks += 1
        assert len(gif_index[gid]["orientations"]) == 2
        groups.append({"group_id": gid, "original_block": group["original_block"], "frame_count": group["frame_count"],
                       "pose_ids_in_source_order": group["pose_ids_in_source_order"], "exact_aliases": group["exact_aliases"],
                       "file": group["file"], "sha256": group["sha256"], "mirror_file": group["mirror_file"],
                       "mirror_sha256": group["mirror_sha256"], "contact": group["contact"],
                       "contact_sha256": sha(ROOT / group["contact"]), "all_source_positions_contact_inspected": True,
                       "decoded_gif_review": gif_index[gid],
                       "worker_observation": next(g["note"] for g in observations["groups"] if g["group_id"] == gid),
                       "blocking_defects_observed": [], "human_animation_acceptance": False})
    resources = []
    for name in ["original_groups.tres", "original_groups_mirrored.tres"]:
        path = ASSET / name
        text = path.read_text(encoding="utf-8")
        assert len(re.findall(r'^\[ext_resource ', text, re.M)) == 15
        assert len(re.findall(r'^\[sub_resource ', text, re.M)) == 90
        assert len(re.findall(r'^"name": &"og_', text, re.M)) == 15
        for referenced in re.findall(r'path="res://([^"]+)"', text):
            assert (ROOT / referenced).is_file()
        resources.append({"path": relative(path), "sha256": sha(path), "animations": 15,
                          "frame_subresources": 90, "all_texture_paths_exist": True,
                          "engine_parsed": False})
    tool_metadata = []
    for path in sorted((ASSET / "_source/raw").glob("*.tool.json")):
        record = read(path)
        assert record["tool"] == "built-in image_gen" and record["transparent_background"]
        for ref in record["references"]:
            ref_path = Path(ref["path"])
            if not ref_path.is_absolute():
                ref_path = ROOT / ref_path
            assert sha(ref_path) == ref["sha256"], (path.name, ref["path"])
        prompt_path = path.parent / record["prompt_file"]
        assert prompt_path.read_text(encoding="utf-8-sig").rstrip("\n") == record["prompt"].rstrip("\n")
        raw_path = path.with_name(path.name.replace(".tool.json", ".png"))
        if "raw_sha256" in record:
            assert sha(raw_path) == record["raw_sha256"]
        tool_metadata.append({"path": relative(path), "sha256": sha(path),
                              "raw_path": relative(raw_path), "raw_sha256": sha(raw_path),
                              "prompt_path": relative(prompt_path), "prompt_sha256": sha(prompt_path)})
    assert len(tool_metadata) == 15
    output = {"creature_id": "vampire", "status": "worker_complete_parent_acceptance_pending", "coverage": manifest["coverage"],
              "selected_new_artwork_poses": 55, "selected_approved_idle_reuse_poses": 1,
              "built_in_imagegen_calls": 15, "replaced_attempts_preserved": True,
              "worker_method": observations["method"], "poses": poses, "groups": groups,
              "tool_call_provenance": tool_metadata, "spriteframes": resources,
              "frame_pngs_verified": frame_png_checks, "validation": validations,
              "manifest_path": relative(manifest_path), "manifest_sha256": sha(manifest_path),
              "original_timing_verified": False, "human_animation_acceptance": False,
              "browser_run": False, "godot_run": False, "real_time_playback_review": False,
              "blocking_visual_defects_observed_after_repairs": [],
              "limits": ["Static raw/pose/contact/decoded-GIF-frame review, not human motion acceptance.",
                         "Generated surfaces and fine joint/fragment geometry are interpretations, not a pixel-identical original reconstruction.",
                         "15 complete original group slots; absent native slots were not invented. No one-frame Vampire groups exist.",
                         "GIF/SpriteFrames use 10 fps preview only; original timing is unknown.",
                         "Existing isolated artwork can be repacked offline; new built-in cloud artwork is not reproducible offline.",
                         "Parent owns package assembly, browser/Godot checks, publication and acceptance."]}
    (REPORT / "visual-review.json").write_text(json.dumps(output, indent=2) + "\n", encoding="utf-8")
    print(json.dumps({"coverage": manifest["coverage"], "provenance_calls_checked": len(tool_metadata),
                      "frame_pngs_verified": frame_png_checks, "resource_checks": resources,
                      "review": relative(REPORT / "visual-review.json")}, indent=2))


if __name__ == "__main__":
    main()
