"""Wight-only mechanical recovery/comparison evidence; never paints artwork."""
import argparse
import importlib.util
import json
import math
from pathlib import Path
import sys

from PIL import Image, ImageDraw, ImageOps

ROOT = Path(__file__).resolve().parents[6]
REPORT = Path(__file__).resolve().parent
DEST = ROOT / "assets/prototype/enemy/wight/remaster_v01"
spec = importlib.util.spec_from_file_location("wight_parent_helper", ROOT / "tools/art/necropolis_remaster.py")
h = importlib.util.module_from_spec(spec)
spec.loader.exec_module(h)


def recover(page, ids, keep, name, prompt):
    """Keep explicitly selected unclipped figures, rejecting all same count/assignment ambiguities.

    Reuses Castle component rules. Unlike full-page ingest, an unselected damaged
    figure is recorded rather than preventing recovery of its intact neighbours.
    Every exported figure still passes the unchanged global-edge check.
    """
    sys.path.insert(0, "C:/Users/zhouc/.codex/visualizations/2026/09/08/01a07f41-7159-70f1-ac7d-e6217941c130/necropolis-validation-v01/python-deps")
    import numpy as np
    from scipy import ndimage
    from scipy.optimize import linear_sum_assignment
    raw = Image.open(ROOT / page).convert("RGBA")
    a = np.asarray(raw)
    alpha = a[:, :, 3]
    labels, _ = ndimage.label(alpha > 8, structure=np.ones((3, 3)))
    sizes = np.bincount(labels.ravel())
    ordered = np.argsort(sizes[1:])[::-1] + 1
    count = len(ids)
    if len(ordered) < count:
        raise ValueError("Too few independent foreground figures")
    primary = ordered[:count]
    if sizes[primary[-1]] < max(300, raw.width * raw.height * .0006):
        raise ValueError("Missing figure or ambiguous primary component")
    if len(ordered) > count and sizes[ordered[count]] > sizes[primary[-1]] * .20:
        raise ValueError("Ambiguous extra large component")
    centers = []
    for label in primary:
        yy, xx = np.where(labels == label)
        centers.append(((xx.min() + xx.max() + 1) / 2 / raw.width * 4, (yy.min() + yy.max() + 1) / 2 / raw.height * 2))
    targets = [(i % 4 + .5, i // 4 + .5) for i in range(count)]
    costs = np.array([[(x - tx) ** 2 + (y - ty) ** 2 for tx, ty in targets] for x, y in centers])
    rr, cc = linear_sum_assignment(costs)
    if any(costs[r, c] > .60 for r, c in zip(rr, cc)):
        raise ValueError("Figure too far from requested row-major slot")
    seeds = np.zeros(labels.shape, dtype=np.int32)
    for r, c in zip(rr, cc):
        seeds[labels == primary[r]] = int(c) + 1
    nearest = ndimage.distance_transform_edt(seeds == 0, return_distances=False, return_indices=True)
    owner = seeds[nearest[0], nearest[1]]
    records = []
    for i, pid in enumerate(ids):
        retained = a.copy()
        retained[:, :, 3] = np.where(owner == i + 1, alpha, 0)
        im = Image.fromarray(retained)
        bb = h.bbox(im, 16)
        clipped = not bb or bb[0] <= 0 or bb[1] <= 0 or bb[2] >= raw.width or bb[3] >= raw.height
        record = {"pose_id": pid, "selected_for_recovery": pid in keep, "global_edge_clipping": bool(clipped), "source_bbox_ltrb": list(bb) if bb else None}
        if pid in keep:
            if clipped:
                raise ValueError("Selected figure is globally clipped: " + pid)
            piece = im.crop(bb)
            padded = Image.new("RGBA", (piece.width + 4, piece.height + 4))
            padded.paste(piece, (2, 2))
            fp = DEST / "_source/recovered" / f"{name}-{pid}.png"
            fp.parent.mkdir(parents=True, exist_ok=True)
            if fp.exists():
                previous = Image.open(fp).convert("RGBA")
                if previous.size != padded.size or previous.tobytes() != padded.tobytes():
                    raise ValueError("Recovery output collision")
            else:
                padded.save(fp)
            record.update({"file": h.rel(fp), "sha256": h.sha(fp)})
            h.ingest("wight", h.rel(fp), [pid], 1, 1, f"{name}-{pid}", prompt)
        records.append(record)
    result = {"raw_page": page, "raw_sha256": h.sha(ROOT / page), "all_count_and_assignment_checks_passed": True, "method": "Same Castle alpha component count/assignment/ownership; only explicitly selected individually unclipped figures exported. No drawing, recolouring, scaling, or relaxed count/clipping limits.", "figures": records}
    h.write(REPORT / f"{name}-recovery.json", result)
    print(json.dumps(result, indent=2))


def comparisons():
    c = h.creature("wight")
    available = [p for p in c["poses"] if (DEST / "poses" / (p["pose_id"] + ".json")).is_file()]
    out = DEST / "_source/review"
    out.mkdir(parents=True, exist_ok=True)
    area = (340, 210, 684, 554)
    paths = []
    for start in range(0, len(available), 4):
        batch = available[start:start + 4]
        contact = Image.new("RGB", (344 * 4, 364 * len(batch)), (23, 36, 49))
        draw = ImageDraw.Draw(contact)
        for row, p in enumerate(batch):
            original = h.projected_original(p)
            candidate = Image.open(DEST / "poses" / (p["pose_id"] + ".png")).convert("RGBA")
            images = [original, candidate, ImageOps.mirror(original), ImageOps.mirror(candidate)]
            for col, (im, label) in enumerate(zip(images, ["OG", "candidate", "OG mirror", "candidate mirror"])):
                x, y = col * 344, row * 364
                draw.text((x + 5, y + 4), p["pose_id"] + " " + label, fill="white")
                contact.paste(h.matte(im).crop(area), (x, y + 20))
        fp = out / f"poses-{start:03d}-1x.png"
        contact.save(fp)
        enlarged = contact.resize((contact.width * 2, contact.height * 2), Image.Resampling.NEAREST)
        enlarged.save(out / f"poses-{start:03d}-2x.png")
        for row in range(0, len(batch), 2):
            enlarged.crop((0, row * 728, 1376, min(len(batch), row + 2) * 728)).save(out / f"detail-{start + row:03d}-source-2x.png")
        paths.append(h.rel(fp))
    print(json.dumps({"available_poses": len(available), "source_candidate_both_facings_contacts": paths}, indent=2))


def gif_frames():
    manifest = h.read(DEST / "source_manifest.json")
    records = []
    for group in manifest["groups"]:
        if not group["complete"]:
            continue
        base = f"group_{group['group_id']:02d}_block_{group['original_block']:02d}"
        frames = []
        for suffix in ["source", "mirror"]:
            gif = Image.open(DEST / "previews" / f"{base}_{suffix}.gif")
            sequence = []
            for i in range(gif.n_frames):
                gif.seek(i)
                sequence.append((gif.convert("RGB").crop((170, 105, 342, 277)), gif.info.get("duration")))
            frames.append(sequence)
        if [f[1] for f in frames[0]] != [f[1] for f in frames[1]]:
            raise ValueError("GIF facings differ in sequence timing")
        n = len(frames[0])
        contact = Image.new("RGB", (344 * 4, 192 * math.ceil(n / 4)), (23, 36, 49))
        draw = ImageDraw.Draw(contact)
        for i in range(n):
            x, y = i % 4 * 344, i // 4 * 192
            draw.text((x + 3, y + 4), f"G{group['group_id']} GIF frame{i} {frames[0][i][1]}ms / source,mirror", fill="white")
            contact.paste(frames[0][i][0], (x, y + 20))
            contact.paste(frames[1][i][0], (x + 172, y + 20))
        fp = DEST / "_source/review" / f"{base}-gif-frames.png"
        contact.save(fp)
        records.append({"group_id": group["group_id"], "gif_frames": n, "timeline_positions": group["frame_count"], "duration_ms": sum(f[1] for f in frames[0]), "contact": h.rel(fp)})
    h.write(REPORT / "gif-frame-inspection-index.json", {"status": "decoded GIF frame evidence, visual inspection recorded separately", "groups": records})
    print(json.dumps(records, indent=2))


parser = argparse.ArgumentParser()
parser.add_argument("mode", choices=["recover", "compare", "gif-frames"])
parser.add_argument("--page")
parser.add_argument("--ids")
parser.add_argument("--keep")
parser.add_argument("--name")
parser.add_argument("--prompt")
args = parser.parse_args()
if args.mode == "recover":
    recover(args.page, args.ids.split(","), set(args.keep.split(",")), args.name, args.prompt)
elif args.mode == "compare":
    comparisons()
else:
    gif_frames()
