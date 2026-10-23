"""Read-only asset/provenance collection; stdout JSON, no engine or network use."""
import json
import re
import sys
from collections import Counter
from hashlib import sha256
from pathlib import Path

from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
DEST = ROOT / "assets/prototype/enemy/wraith/remaster_v01"


def read(path):
    return json.loads(path.read_text(encoding="utf-8"))


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def relative(path):
    return path.relative_to(ROOT).as_posix()


def main():
    manifest = read(DEST / "source_manifest.json")
    provenance = read(REPORT / "generation-attempts.json")
    observations = read(REPORT / "pose-review-notes.json")["observations"]
    validation = read(REPORT / "validation-results.json")
    assert validation["after_spriteframes"]["complete"]
    for attempt in provenance["attempts"]:
        raw = ROOT / attempt["raw_file"]
        assert digest(raw) == attempt["raw_sha256"] == digest(Path(attempt["tool_output_path"]))
        prompt = ROOT / attempt["prompt_file"]
        assert digest(prompt) == attempt["prompt_file_sha256"]
        assert prompt.read_text().rstrip("\r\n") == attempt["exact_submitted_prompt"].rstrip("\r\n")
        for ref in attempt["references"]:
            assert digest(ROOT / ref["file"]) == ref["sha256"]
    poses = []
    for p in manifest["poses"]:
        pid = p["pose_id"]
        assert p["artwork_origin"] == "built-in image-generation artwork"
        assert p["visual_review"]["note"] == observations[pid]
        assert p["visual_review"]["source_sha256_at_review"] == p["registered_pose_sha256"]
        assert p["visual_review"]["mirror_sha256_at_review"] == p["mirror_sha256"]
        for path_key, hash_key in [("raw_source", "raw_sha256"), ("isolated_source", "isolated_sha256"),
                                   ("registered_pose_file", "registered_pose_sha256"), ("mirror_file", "mirror_sha256")]:
            assert digest(ROOT / p[path_key]) == p[hash_key]
        number = int(pid.rsplit("p", 1)[1])
        comparison = REPORT / "review-images" / f"poses-{number // 4:03d}.png"
        rep = p["original_representative"]
        poses.append({"pose_id": pid, "source_group_frame": [rep["group_id"], rep["frame_index"]],
                      "source_occurrences": [[g["group_id"], i] for g in manifest["groups"]
                                             for i, actual in enumerate(g["pose_ids_in_source_order"]) if actual == pid],
                      "registered_sha256": p["registered_pose_sha256"], "mirror_sha256": p["mirror_sha256"],
                      "isolated_source": p["isolated_source"], "raw_source": p["raw_source"],
                      "registered_rect": p["registration"]["registered_rect"],
                      "comparison": relative(comparison), "comparison_sha256": digest(comparison),
                      "worker_observation": observations[pid], "blocking_defects_observed": [],
                      "previous_selections_retained": len(list((DEST / "_source/history" / pid).glob("*.json")))})
    assert len({p["registered_sha256"] for p in poses}) == 57
    groups = []
    frame_pngs = 0
    for g in manifest["groups"]:
        base = f'g{g["group_id"]:02d}_b{g["original_block"]:02d}'
        for i, pid in enumerate(g["pose_ids_in_source_order"]):
            original = Image.open(DEST / "poses" / f"{pid}.png").convert("RGBA")
            for facing in ("source", "mirror"):
                frame = Image.open(DEST / "frames" / facing / base / f"{i:03d}.png").convert("RGBA")
                expected = original if facing == "source" else ImageOps.mirror(original)
                assert frame.tobytes() == expected.tobytes()
                frame_pngs += 1
        gif_data = {}
        for facing, key in (("source", "preview"), ("mirror", "mirror_preview")):
            file = ROOT / g[key]
            gif = Image.open(file)
            durations = []
            for index in range(gif.n_frames):
                gif.seek(index)
                durations.append(gif.info.get("duration", 0))
            assert sum(durations) == g["frame_count"] * 100
            gif_data[facing] = {"file": g[key], "sha256": digest(file), "stored_frames": gif.n_frames,
                                "durations_ms": durations}
        seq = REPORT / "review-images" / f"sequence-{base}.png"
        gif_review = REPORT / "review-images" / f"gif-{base}.png"
        groups.append({"group_id": g["group_id"], "original_block": g["original_block"],
                       "positions": g["frame_count"], "pose_ids_in_source_order": g["pose_ids_in_source_order"],
                       "exact_aliases": g["exact_aliases"], "atlas": g["file"], "atlas_sha256": g["sha256"],
                       "mirror_atlas": g["mirror_file"], "mirror_atlas_sha256": g["mirror_sha256"],
                       "contact": g["contact"], "contact_sha256": digest(ROOT / g["contact"]),
                       "both_facing_frame_review": relative(seq), "frame_review_sha256": digest(seq),
                       "decoded_gif_review": relative(gif_review), "gif_review_sha256": digest(gif_review),
                       "gifs": gif_data, "all_timeline_positions_statically_inspected_both_facings": True,
                       "source_contact_inspected": True, "all_stored_gif_frames_inspected": True,
                       "blocking_defects_observed": []})
    libraries = []
    for name in ("original_groups.tres", "original_groups_mirrored.tres"):
        path = DEST / name
        text = path.read_text()
        assert text.count('"name": &"og_') == 18
        assert text.count('[sub_resource type="AtlasTexture"') == 102
        assert text.count('"loop": true') == 2
        for resource_path in re.findall(r'path="res://([^"]+)"', text):
            assert (ROOT / resource_path).exists()
        libraries.append({"file": relative(path), "sha256": digest(path), "groups": 18, "positions": 102,
                          "static_references_checked": True, "engine_loaded": False})
    data = {"schema_version": 1, "creature_id": "wraith",
                      "status": "COMPLETE_WORKER_ASSET_REVIEW_AWAITING_PARENT_INDEPENDENT_ACCEPTANCE",
                      "source_manifest": relative(DEST / "source_manifest.json"),
                      "source_manifest_sha256": digest(DEST / "source_manifest.json"),
                      "coverage": manifest["coverage"], "validation": validation,
                      "frame_pngs_verified": frame_pngs, "new_drawn_poses_selected": len(poses),
                      "approved_master_reuses": 0, "built_in_artwork_calls": len(provenance["attempts"]),
                      "artwork_origin_counts": dict(Counter(p["artwork_origin"] for p in manifest["poses"])),
                      "poses": poses, "groups": groups, "spriteframes_libraries": libraries,
                      "human_animation_acceptance": False, "original_timing_verified": False,
                      "browser_verified": False, "godot_verified": False, "animated_playback_claimed": False}
    section = sys.argv[1] if len(sys.argv) > 1 else "summary"
    if section.startswith("poses:"):
        offset = int(section.split(":")[1])
        data = poses[offset:offset + 15]
    elif section == "groups":
        data = groups
    elif section == "summary":
        data = {k: v for k, v in data.items() if k not in ("poses", "groups")}
    else:
        raise ValueError("Use summary, groups or poses:<offset>")
    print(json.dumps(data, separators=(",", ":")))


if __name__ == "__main__":
    main()
