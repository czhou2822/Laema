"""Read-only Wraith source/preparation audit. Run with Python -B; stdout only."""
import importlib.util
import json
from collections import Counter
from hashlib import sha256
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[6]
PLAN = ROOT / "docs/art/remasters/necropolis-v01/generation-plan.json"
MASTER_ROOT = ROOT / "docs/art/production/necropolis-creature-assets-v01"
DEST = ROOT / "assets/prototype/enemy/wraith/remaster_v01"


def load(path):
    return json.loads(path.read_text(encoding="utf-8"))


def digest(path):
    return sha256(path.read_bytes()).hexdigest()


def module(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def main():
    plan = load(PLAN)
    c = next(c for c in plan["creatures"] if c["creature_id"] == "wraith")
    native = load(ROOT / c["original_metadata"])
    job = load(MASTER_ROOT / "wraith/job.json")
    manifest = load(MASTER_ROOT / "wraith/master-manifest.json")
    selected = next(e for e in load(MASTER_ROOT / "selected-masters.json")["entries"]
                    if e["slug"] == "wraith")
    approved = next(e for e in load(PLAN.parent / "master-approval.json")["entries"]
                    if e["creature_id"] == "wraith")
    helper = module("wraith_remaster_readonly", ROOT / "tools/art/necropolis_remaster.py")
    decoder = module("wraith_def_verifier_readonly", ROOT / plan["original_root"] / "verify.py")
    hashes = {}
    for key in ("original_metadata", "original_def", "appearance_reference"):
        actual = digest(ROOT / c[key])
        assert actual == c[key + "_sha256"], key
        hashes[key] = actual
    assert hashes["original_def"] == native["def_sha256"] == job["original_def_sha256"]
    assert hashes["original_metadata"] == job["source_metadata_sha256"]
    assert hashes["appearance_reference"] == manifest["high_res_sha256"]
    assert hashes["appearance_reference"] == selected["master_sha256"] == approved["sha256"]
    assert c["appearance_reference"] == approved["master"]
    assert c["geometry"] == plan["geometry"] == helper.geometry()
    assert [g["original_group_record"] for g in c["groups"]] == native["groups"]
    assert [g["native"] for g in job["groups"]] == native["groups"]
    pm = helper.posemap(c)
    assert len(pm) == c["unique_registered_poses"] == 57
    data = (ROOT / c["original_def"]).read_bytes()
    palette_path = (ROOT / c["original_metadata"]).parent / native["palette"]
    assert palette_path.read_bytes() == data[16:784]
    page_hashes = {}
    actual_occurrences = {pid: [] for pid in pm}
    bounds = []
    total = 0
    for g, ng in zip(c["groups"], native["groups"]):
        assert g["frame_count"] == len(ng["frames"]) == len(g["pose_ids_in_source_order"])
        expected_aliases = [h["group_id"] for h in c["groups"]
                            if h is not g and h["pose_ids_in_source_order"] == g["pose_ids_in_source_order"]]
        assert expected_aliases == g["exact_aliases"]
        for f, pid in zip(ng["frames"], g["pose_ids_in_source_order"]):
            p = pm[pid]
            pg = ng["pages"][f["page"]]
            directory = (ROOT / c["original_metadata"]).parent
            record = {"group_id": g["group_id"], "original_block": g["original_block"],
                      "frame_index": f["index"],
                      "rgba_sheet": (directory / pg["preview"]).relative_to(ROOT).as_posix(),
                      "indexed_sheet": (directory / pg["indexed"]).relative_to(ROOT).as_posix(),
                      "sheet_cell_region": [f["x"], f["y"], ng["cell_width"], ng["cell_height"]],
                      "source_record": f}
            assert helper.signature(f) == p["original_signature"]
            actual_occurrences[pid].append(record)
            decoded = decoder.second_decode(data, f["offset"])
            assert sha256(decoded).hexdigest() == f["index_sha256"]
            with Image.open(ROOT / record["indexed_sheet"]) as indexed:
                assert indexed.mode == "P"
                assert bytes(indexed.getpalette()[:768]) == data[16:784]
                assert indexed.size == (pg["width"], pg["height"])
                x, y = f["x"] + f["left"] - ng["origin_x"], f["y"] + f["top"] - ng["origin_y"]
                assert indexed.crop((x, y, x + f["width"], y + f["height"])).tobytes() == decoded
            with Image.open(ROOT / record["rgba_sheet"]) as rgba:
                assert rgba.mode == "RGBA"
                assert rgba.size == (pg["width"], pg["height"])
            for path in (record["indexed_sheet"], record["rgba_sheet"]):
                if path not in page_hashes:
                    page_hashes[path] = digest(ROOT / path)
            total += 1
    for pid, p in pm.items():
        assert p["occurrences"] == actual_occurrences[pid]
        assert p["representative"] == actual_occurrences[pid][0]
        bb = helper.bbox(helper.original(p), 160)
        assert p["opaque_body_rect"] == [bb[0], bb[1], bb[2] - bb[0], bb[3] - bb[1]]
        bounds.append(bb)
    assert total == c["original_frame_positions"] == native["frame_count"] == 102
    assert len(c["groups"]) == c["original_group_slots"] == 18
    assert c["og_idle_reference_pose_id"] == "wraith_p012"
    x1, y1 = min(b[0] for b in bounds), min(b[1] for b in bounds)
    x2, y2 = max(b[2] for b in bounds), max(b[3] for b in bounds)
    mapped = [512 + (x1 - 196) * helper.SCALE, 512 + (y1 - 268) * helper.SCALE,
              512 + (x2 - 196) * helper.SCALE, 512 + (y2 - 268) * helper.SCALE]
    assert mapped[0] >= 40 and mapped[1] >= 40 and mapped[2] <= 984 and mapped[3] <= 728
    with Image.open(ROOT / c["appearance_reference"]) as master:
        master_info = {"size": list(master.size), "mode": master.mode,
                       "alpha_extrema": list(master.getchannel("A").getextrema()),
                       "bounds_alpha8": helper.bbox(master, 8)}
    prep_info = None
    if (DEST / "_source/preparation.json").exists():
        preparation = load(DEST / "_source/preparation.json")
        ids = [pid for b in preparation["batches"] for pid in b["pose_ids"]]
        assert ids == preparation["pending_pose_ids"] == list(pm)
        assert digest(DEST / "_source/appearance-master.png") == hashes["appearance_reference"]
        for batch in preparation["batches"]:
            with Image.open(ROOT / batch["guide"]) as image:
                assert image.size == (512 * batch["columns"], 512 * batch["rows"])
            assert load((ROOT / batch["guide"]).with_suffix(".json")) == batch
        prep_info = {"pending_poses": len(ids), "batches": len(preparation["batches"]),
                     "batch_sizes": [len(b["pose_ids"]) for b in preparation["batches"]],
                     "guide_sha256": {Path(b["guide"]).name: digest(ROOT / b["guide"])
                                      for b in preparation["batches"]},
                     "preparation_json_sha256": digest(DEST / "_source/preparation.json")}
    report = {"creature_id": "wraith", "checks_passed": True,
              "generation_plan_sha256": digest(PLAN), "hashes": hashes,
              "counts": {"groups": len(c["groups"]), "positions": total, "poses": len(pm),
                         "page_files_checked": len(page_hashes), "decoded_positions_checked": total},
              "pose_occurrence_frequency": dict(sorted(Counter(len(p["occurrences"]) for p in pm.values()).items())),
              "alias_pairs": [[g["group_id"], a] for g in c["groups"] for a in g["exact_aliases"] if g["group_id"] < a],
              "native_opaque_union_xyxy": [x1, y1, x2, y2], "mapped_opaque_union_xyxy": mapped,
              "master": master_info, "preparation": prep_info,
              "registered_pose_records": len(list((DEST / "poses").glob("*.json"))),
              "native_sheet_sha256": page_hashes}
    print(json.dumps(report, indent=2))


if __name__ == "__main__":
    main()
