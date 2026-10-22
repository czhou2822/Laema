"""Read-only comparison of Fire geometry candidates against the agreed base."""
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
BASE = "921fd1ae207c990070cd279587f5a05ee0fb239c"


def saved(path):
    return subprocess.check_output(["git", "show", f"{BASE}:{path}"], cwd=ROOT)


def without_allowed_keys(text):
    for track in (3, 4):
        text, count = re.subn(
            rf"tracks/{track}/keys = \{{.*?\n\}}", f"tracks/{track}/keys = <allowed>",
            text, flags=re.S,
        )
        assert count == 1, f"expected exactly one track{track} key block"
    return text.replace("\r\n", "\n")


results = []
for position in range(1, 6):
    path = f"config/attack_animations/fire_x{position}.tres"
    before = saved(path)
    after = (ROOT / path).read_bytes()
    text = after.decode("utf-8")
    texture = re.search(r'path="res://([^\"]+\.png)"', text).group(1)
    texture_after = (ROOT / texture).read_bytes()
    results.append({
        "move": f"fire_x{position}",
        "changed": before != after,
        "outside_position_target_key_blocks_unchanged":
            without_allowed_keys(before.decode("utf-8")) == without_allowed_keys(text),
        "atlas_unchanged": saved(texture) == texture_after,
        "animation_sha256": hashlib.sha256(after).hexdigest(),
        "atlas_sha256": hashlib.sha256(texture_after).hexdigest(),
    })
paths = subprocess.check_output(["git", "diff", "--name-only", BASE], cwd=ROOT, text=True).splitlines()
product_changes = [p for p in paths if not p.startswith("docs/")]
expected = {f"config/attack_animations/fire_x{i}.tres" for i in range(1, 6)}
unexpected = [p for p in product_changes if p not in expected]
untracked = subprocess.check_output(["git", "ls-files", "--others", "--exclude-standard"], cwd=ROOT, text=True).splitlines()
untracked_product = [p for p in untracked if p.startswith(("scripts/", "scenes/", "config/", "ai/", "assets/", "addons/"))]
ok = not unexpected and not untracked_product and all(r["outside_position_target_key_blocks_unchanged"] and r["atlas_unchanged"] for r in results)
print(json.dumps({"base": BASE, "ok": ok, "unexpected_tracked_product_changes": unexpected,
                  "unexpected_untracked_product_files": untracked_product, "moves": results}, indent=2))
raise SystemExit(0 if ok else 1)
