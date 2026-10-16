"""Validate the portal in an isolated Godot copy; never run against the user's tree.

Usage: python tools/test-dev-portal.py --godot <Godot executable>
"""
from __future__ import annotations

import argparse
import os
from pathlib import Path
import shutil
import subprocess
import tempfile


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--godot", required=True, type=Path)
    parser.add_argument("--work-root", type=Path, help="Optional writable parent for isolated copies")
    parser.add_argument("--keep-work", action="store_true", help="Keep successful isolated copies for inspection")
    parser.add_argument("--script", type=Path, help="Alternative project test script to run in isolation")
    parser.add_argument("--frame-limit", type=int, default=600, help="Maximum process frames before forced exit")
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[1]
    if args.work_root:
        args.work_root.mkdir(parents=True, exist_ok=True)
    work = Path(tempfile.mkdtemp(prefix="laema-dev-portal-", dir=args.work_root)).resolve()
    (work / ".gdignore").touch()
    project = work / "project"
    project.mkdir()
    for name in ("scripts", "scenes", "config", "ai", "assets", "addons"):
        if (source / name).is_dir():
            shutil.copytree(source / name, project / name,
                            ignore=shutil.ignore_patterns("~*", ".git", ".godot"))
    for name in ("project.godot", "icon.svg"):
        shutil.copy2(source / name, project / name)
    test_script = args.script or source / "tools/tests/dev_portal_test.gd"
    shutil.copy2(test_script, project / "dev_portal_test.gd")
    # Portable editor data prevents writes to the user's Godot settings/profile.
    binary_dir = work / "engine"
    binary_dir.mkdir()
    engine = binary_dir / args.godot.name
    shutil.copy2(args.godot, engine)
    (binary_dir / "_sc_").touch()
    profile = work / "profile"
    (profile / "Godot/app_userdata/Laema").mkdir(parents=True)
    environment = os.environ.copy()
    environment.update(APPDATA=str(profile), LOCALAPPDATA=str(profile))
    print(f"Isolated validation project: {project}", flush=True)
    runs = [
        ["--headless", "--path", str(project), "--editor", "--quit"],
        ["--headless", "--path", str(project), "--script", "res://dev_portal_test.gd", "--quit-after", str(args.frame_limit)],
    ]
    failed = False
    for index, arguments in enumerate(runs):
        log_path = work / f"check-{index}.log"
        arguments += ["--log-file", str(work / f"engine-{index}.log")]
        with log_path.open("w", encoding="utf-8") as log:
            result = subprocess.run([str(engine), *arguments], stdout=log,
                                    stderr=subprocess.STDOUT, env=environment, timeout=120)
        output = log_path.read_text(encoding="utf-8", errors="replace")
        relevant = [line for line in output.splitlines()
                    if any(tag in line for tag in ("ERROR", "Error", "PASSED", "FAILED", " at:", "GDScript backtrace", "[0]", "[1]"))]
        print("\n".join(relevant), flush=True)
        failed |= result.returncode != 0 or "SCRIPT ERROR" in output or "ERROR:" in output
        if index == 1:
            failed |= "PASSED:" not in output
    if not failed and not args.keep_work:
        parent = (args.work_root or Path(tempfile.gettempdir())).resolve()
        if work.parent != parent or not work.name.startswith("laema-dev-portal-"):
            raise RuntimeError(f"Refusing to remove unexpected validation path: {work}")
        if not (work / ".gdignore").is_file() or not (project / "project.godot").is_file():
            raise RuntimeError(f"Validation directory markers missing: {work}")
        print(f"Removing successful isolated copy: {work}", flush=True)
        shutil.rmtree(work)
        print("Validation PASSED. Isolated copy removed.", flush=True)
    else:
        print(f"Validation {'FAILED' if failed else 'PASSED'}. Logs: {work}", flush=True)
    return 1 if failed else 0


if __name__ == "__main__":
    raise SystemExit(main())
