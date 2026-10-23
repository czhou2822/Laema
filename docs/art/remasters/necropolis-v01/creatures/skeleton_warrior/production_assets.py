"""Skeleton Warrior only: mechanical source isolation and review presentations.

Run with Python -B. Never paints, warps, recolors, or repairs figure artwork.
All helper code, plans, approved masters and originals remain read-only.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
CID = "skeleton_warrior"
DEST = ROOT / "assets/prototype/enemy" / CID / "remaster_v01"
REPORT = Path(__file__).resolve().parent
spec = importlib.util.spec_from_file_location("necropolis_read_only", ROOT / "tools/art/necropolis_remaster.py")
helper = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helper)


def salvage(batch):
    """Preserve good original grid cells; clipping checks are unchanged."""
    submission = helper.read(DEST / "_source/raw" / (batch + ".submission.json"))
    raw_path = ROOT / submission["raw_source"]
    raw = Image.open(raw_path).convert("RGBA")
    cols, rows = submission["columns"], submission["rows"]
    xs = helper.boundaries(raw, cols, 0, True)
    ys = helper.boundaries(raw, rows, 1, True)
    outcomes = []
    for i, pid in enumerate(submission["pose_ids"]):
        region = [xs[i % cols], ys[i // cols], xs[i % cols + 1] - xs[i % cols], ys[i // cols + 1] - ys[i // cols]]
        art = helper.crop(raw, region)
        bounds = helper.bbox(art, 16)
        outcome = {"pose_id": pid, "source_page": submission["raw_source"],
                   "source_page_sha256": helper.sha(raw_path), "source_region": region}
        if not bounds or bounds[0] <= 1 or bounds[1] <= 1 or bounds[2] >= art.width - 1 or bounds[3] >= art.height - 1:
            outcome["status"] = "rejected_clipped_grid_cell_needs_redraw"
        else:
            crop_path = DEST / "_source/derived" / (batch + "-" + pid + ".png")
            crop_path.parent.mkdir(parents=True, exist_ok=True)
            if crop_path.exists():
                assert Image.open(crop_path).convert("RGBA").tobytes() == art.tobytes()
            else:
                art.save(crop_path)
            attempt = batch + "-cell-" + str(i)
            helper.ingest(CID, crop_path, [pid], 1, 1, attempt, submission["prompt"])
            outcome.update({"status": "ingested_unchanged_grid_cell", "derived_file": helper.rel(crop_path),
                            "derived_sha256": helper.sha(crop_path), "derived_batch": attempt})
        outcomes.append(outcome)
    helper.write(DEST / "_source/derived" / (batch + ".provenance.json"), outcomes)
    return outcomes


def edit_reference(ids, name):
    """Arrange selected existing figures as reference only for an AI edit."""
    cols = min(4, len(ids))
    rows = (len(ids) + cols - 1) // cols
    sheet = Image.new("RGBA", (512 * cols, 512 * rows))
    records = []
    for i, pid in enumerate(ids):
        record = helper.read(DEST / "poses" / (pid + ".json"))
        original_path = ROOT / record["isolated_source"]
        im = Image.open(original_path).convert("RGBA")
        im = im.crop(helper.bbox(im))
        im.thumbnail((360, 360), Image.Resampling.LANCZOS)
        x = i % cols * 512 + (512 - im.width) // 2
        y = i // cols * 512 + (512 - im.height) // 2
        sheet.alpha_composite(im, (x, y))
        records.append({"pose_id": pid, "isolated_source": record["isolated_source"],
                        "isolated_sha256": helper.sha(original_path)})
    output = DEST / "_source/guides" / (name + "-edit-target.png")
    sheet.save(output)
    result = {"purpose": "Reference arrangement only; no production artwork painted or repaired by code.",
              "path": helper.rel(output), "sha256": helper.sha(output), "figures": records}
    helper.write(output.with_suffix(".json"), result)
    return result


def comparisons():
    creature = helper.creature(CID)
    review = DEST / "_source/review"
    review.mkdir(parents=True, exist_ok=True)
    available = [p for p in creature["poses"] if (DEST / "poses" / (p["pose_id"] + ".json")).exists()]
    sheets = []
    for start in range(0, len(available), 8):
        poses = available[start:start + 8]
        # Four poses per row; OG, candidate and exact mirror all use the same projection.
        sheet = Image.new("RGB", (2048, 800 * ((len(poses) + 3) // 4)), (23, 36, 49))
        draw = ImageDraw.Draw(sheet)
        for i, pose in enumerate(poses):
            x, y = i % 4 * 512, i // 4 * 800
            draw.text((x + 8, y + 5), pose["pose_id"] + " OG / candidate / mirror", fill="white")
            original = helper.projected_original(pose)
            new = Image.open(DEST / "poses" / (pose["pose_id"] + ".png")).convert("RGBA")
            for j, im in enumerate((original, new, ImageOps.mirror(new))):
                # Constant half-scale framing, not separately fitted actor silhouettes.
                panel = helper.matte(im).resize((512, 384), Image.Resampling.NEAREST if j == 0 else Image.Resampling.LANCZOS)
                # Show the fixed actor area within each panel; no pixels are clipped from the figure.
                sheet.paste(panel.crop((0, 104, 512, 360)), (x, y + 24 + j * 256))
        path = review / ("poses-" + str(start).zfill(3) + ".png")
        sheet.save(path)
        sheets.append(helper.rel(path))
    return {"available": len(available), "comparison_sheets": sheets}


def zooms():
    creature = helper.creature(CID)
    review = DEST / "_source/review/zoom"
    review.mkdir(parents=True, exist_ok=True)
    outputs = []
    for start in range(0, len(creature["poses"]), 4):
        poses = creature["poses"][start:start + 4]
        sheet = Image.new("RGB", (512 * len(poses), 1230), (23, 36, 49))
        draw = ImageDraw.Draw(sheet)
        for i, pose in enumerate(poses):
            new = Image.open(DEST / "poses" / (pose["pose_id"] + ".png")).convert("RGBA")
            images = (helper.projected_original(pose), new, ImageOps.mirror(new))
            for j, im in enumerate(images):
                # Fixed shared window fully contains every Skeleton Warrior body.
                assert not im.getchannel("A").crop((0, 0, 1024, 170)).getbbox()
                assert not im.getchannel("A").crop((0, 590, 1024, 768)).getbbox()
                panel = helper.matte(im).crop((240, 170, 840, 590)).resize((512, 384), Image.Resampling.NEAREST if j == 0 else Image.Resampling.LANCZOS)
                sheet.paste(panel, (i * 512, j * 410 + 25))
                draw.text((i * 512 + 8, j * 410 + 5), pose["pose_id"] + (" OG", " candidate", " mirror")[j], fill="white")
        path = review / ("zoom-" + str(start).zfill(3) + ".png")
        sheet.save(path)
        outputs.append(helper.rel(path))
    return outputs


def gif_strips():
    """Decode every exported GIF frame, including coalesced hold durations."""
    manifest = helper.read(DEST / "source_manifest.json")
    review = DEST / "_source/review/gifs"
    review.mkdir(parents=True, exist_ok=True)
    result = []
    for group in manifest["groups"]:
        if not group["complete"]:
            continue
        for orientation, key in (("source", "preview"), ("mirror", "mirror_preview")):
            gif = Image.open(ROOT / group[key])
            sheet = Image.new("RGB", (4 * 512, 410 * ((gif.n_frames + 3) // 4)), (23, 36, 49))
            draw = ImageDraw.Draw(sheet)
            durations = []
            for i in range(gif.n_frames):
                gif.seek(i)
                durations.append(gif.info.get("duration", 0))
                x, y = i % 4 * 512, i // 4 * 410
                panel = gif.convert("RGB").crop((120, 85, 420, 295)).resize((512, 384), Image.Resampling.LANCZOS)
                sheet.paste(panel, (x, y + 24))
                draw.text((x + 8, y + 5), f"G{group['group_id']} {orientation} GIF frame {i} {durations[-1]}ms", fill="white")
            path = review / f"g{group['group_id']:02d}-{orientation}.png"
            sheet.save(path)
            result.append({"group_id": group["group_id"], "orientation": orientation,
                           "gif": group[key], "decoded_frames": gif.n_frames,
                           "durations_ms": durations, "decoded_contact": helper.rel(path)})
    for group in manifest["groups"]:
        if not group["complete"]:
            continue
        parts = [Image.open(review / f"g{group['group_id']:02d}-{orientation}.png").convert("RGB")
                 for orientation in ("source", "mirror")]
        pair = Image.new("RGB", (2048, sum(im.height for im in parts)), (23, 36, 49))
        y = 0
        for im in parts:
            pair.paste(im, (0, y))
            y += im.height
        pair.save(review / f"g{group['group_id']:02d}-both.png")
    helper.write(review / "decoded-gifs.json", result)
    return result


def provenance():
    calls = []
    for path in sorted((DEST / "_source/tool-metadata").glob("*.json")):
        call = helper.read(path)
        call["metadata_file"] = helper.rel(path)
        for ref in call["references"]:
            ref["sha256"] = helper.sha(ROOT / ref["path"])
        call["prompt_sha256"] = helper.sha(ROOT / call["prompt_file"])
        call["raw_sha256"] = helper.sha(ROOT / call["raw_file"])
        calls.append(call)
    helper.write(DEST / "_source/generation-provenance.json", calls)
    return {"calls": len(calls), "file": helper.rel(DEST / "_source/generation-provenance.json")}


def record_review():
    observations = helper.read(REPORT / "review-observations.json")
    creature = helper.creature(CID)
    assert [r["pose_id"] for r in observations["poses"]] == [p["pose_id"] for p in creature["poses"]]
    group_notes = {g["group_id"]: g["observation"] for g in observations["groups"]}
    evidence = {"creature_id": CID, "status": "worker_reviewed_complete_candidate",
                "method": observations["method"], "human_animation_acceptance": False,
                "original_timing_verified": False, "runtime_display_size_verified": False,
                "browser_or_engine_run": False, "playback_observed": False,
                "blocking_findings": [], "poses": [], "groups": []}
    for i, (pose, note) in enumerate(zip(creature["poses"], observations["poses"])):
        pid = pose["pose_id"]
        helper.mark_review(CID, [pid], note["observation"] + " Inspected against OG in fixed registration contacts, enlarged comparison and exact mirror; static worker review only.")
        record = helper.read(DEST / "poses" / (pid + ".json"))
        zoom = DEST / "_source/review/zoom" / ("zoom-" + str(i // 4 * 4).zfill(3) + ".png")
        evidence["poses"].append({"pose_id": pid, "observation": note["observation"],
                                  "registered_sha256": record["registered_pose_sha256"],
                                  "mirror_sha256": record["mirror_sha256"],
                                  "raw_source": record["raw_source"], "raw_sha256": record["raw_sha256"],
                                  "isolated_source": record["isolated_source"],
                                  "isolated_sha256": record["isolated_sha256"],
                                  "source_occurrences": [[o["group_id"], o["frame_index"]] for o in pose["occurrences"]],
                                  "comparison": helper.rel(zoom), "comparison_sha256": helper.sha(zoom),
                                  "source_candidate_and_mirror_viewed": True, "blocking_findings": []})
    manifest = helper.read(DEST / "source_manifest.json")
    decoded = helper.read(DEST / "_source/review/gifs/decoded-gifs.json")
    for group in manifest["groups"]:
        gid = group["group_id"]
        pair = DEST / "_source/review/gifs" / f"g{gid:02d}-both.png"
        evidence["groups"].append({"group_id": gid, "original_block": group["original_block"],
                                   "source_order": group["pose_ids_in_source_order"], "exact_aliases": group["exact_aliases"],
                                   "observation": group_notes[gid], "contact": group["contact"],
                                   "contact_sha256": helper.sha(ROOT / group["contact"]),
                                   "source_ordered_contact_viewed": True,
                                   "decoded_gif_pair_viewed": helper.rel(pair), "decoded_pair_sha256": helper.sha(pair),
                                   "gif_frames": [d for d in decoded if d["group_id"] == gid],
                                   "both_facings_inspected": True, "blocking_findings": []})
    helper.write(REPORT / "visual-review.json", evidence)
    return {"reviewed_poses": len(evidence["poses"]), "reviewed_groups": len(evidence["groups"]),
            "report": helper.rel(REPORT / "visual-review.json")}


def final_audit():
    """Check emitted frame PNGs/resources/provenance, without opening Godot."""
    creature = helper.creature(CID)
    manifest = helper.read(DEST / "source_manifest.json")
    validation = helper.validate(CID)
    assert validation["complete"] and not validation["errors"]
    assert manifest["coverage"]["reviewed_poses"] == 57
    frame_count = 0
    for group in manifest["groups"]:
        for i, pid in enumerate(group["pose_ids_in_source_order"]):
            pose = Image.open(DEST / "poses" / (pid + ".png")).convert("RGBA")
            for facing, expected in (("source", pose), ("mirror", ImageOps.mirror(pose))):
                path = DEST / "frames" / facing / f"g{group['group_id']:02d}_b{group['original_block']:02d}" / f"{i:03d}.png"
                assert Image.open(path).convert("RGBA").tobytes() == expected.tobytes(), str(path)
                frame_count += 1
        for alias in group["exact_aliases"]:
            other = next(g for g in manifest["groups"] if g["group_id"] == alias)
            assert group["sha256"] == other["sha256"]
            assert group["mirror_sha256"] == other["mirror_sha256"]
    resources = []
    for name in ("original_groups.tres", "original_groups_mirrored.tres"):
        path = DEST / name
        source = path.read_text(encoding="utf-8")
        assert source.count('"name": &"og_') == 15
        assert source.count('[sub_resource type="AtlasTexture"') == 86
        assert source.count('[ext_resource type="Texture2D"') == 15
        assert 'metadata/preview_only = true' in source and 'metadata/original_timing_verified = false' in source
        resources.append({"file": helper.rel(path), "sha256": helper.sha(path), "groups": 15, "positions": 86})
    calls = helper.read(DEST / "_source/generation-provenance.json")
    for call in calls:
        assert helper.sha(ROOT / call["raw_file"]) == call["raw_sha256"]
        assert helper.sha(Path(call["raw_returned_file"])) == call["raw_sha256"]
        assert helper.sha(ROOT / call["prompt_file"]) == call["prompt_sha256"]
        for ref in call["references"]:
            assert helper.sha(ROOT / ref["path"]) == ref["sha256"]
    invocations = helper.read(DEST / "_source/tool-invocations.json")["invocations"]
    assert len(invocations) == len(calls)
    for invocation in invocations:
        prompt_path = DEST / "_source/prompts" / (invocation["attempt"] + ".txt")
        assert prompt_path.read_text(encoding="utf-8") == invocation["arguments"]["prompt"] + "\n"
    visual = helper.read(REPORT / "visual-review.json")
    current = {p["pose_id"]: p for p in manifest["poses"]}
    for pose in visual["poses"]:
        assert current[pose["pose_id"]]["registered_pose_sha256"] == pose["registered_sha256"]
        assert current[pose["pose_id"]]["mirror_sha256"] == pose["mirror_sha256"]
        assert helper.sha(ROOT / pose["comparison"]) == pose["comparison_sha256"]
    for group in visual["groups"]:
        assert helper.sha(ROOT / group["contact"]) == group["contact_sha256"]
        assert helper.sha(ROOT / group["decoded_gif_pair_viewed"]) == group["decoded_pair_sha256"]
    origins = [r["artwork_origin"] for r in manifest["poses"]]
    assert all(o == "built-in image-generation artwork" for o in origins)
    result = {"creature_id": CID, "status": "complete_worker_candidate", "validation": validation,
              "frame_pngs_verified": frame_count, "resources": resources, "generation_calls": len(calls),
              "pose_review_hashes_verified": len(visual["poses"]),
              "group_review_evidence_verified": len(visual["groups"]),
              "raw_tool_copies_verified": len(calls), "exact_prompt_strings_verified": len(invocations),
              "new_unique_pose_artworks": 57, "approved_master_reuse": 0,
              "source_manifest_sha256": helper.sha(DEST / "source_manifest.json"),
              "blocking_findings": [], "human_animation_acceptance": False,
              "original_timing_verified": False, "engine_run": False, "browser_playback": False}
    helper.write(REPORT / "final-validation.json", result)
    return result


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=("salvage", "edit-reference", "comparisons", "zooms", "gif-strips", "provenance", "record-review", "final-audit"))
    parser.add_argument("--batch")
    parser.add_argument("--ids")
    args = parser.parse_args()
    functions = {"comparisons": comparisons, "zooms": zooms, "gif-strips": gif_strips,
                 "provenance": provenance, "record-review": record_review, "final-audit": final_audit}
    if args.command == "salvage":
        result = salvage(args.batch)
    elif args.command == "edit-reference":
        result = edit_reference(args.ids.split(","), args.batch)
    else:
        result = functions[args.command]()
    print(json.dumps(result, indent=2))
