"""R16: bounded cold-import diagnosis; never edits the source or main runner.

One invocation makes one NEW project/engine/profile. Baseline uses read-only
git archive; retained uses the same roots/exclusions as test-dev-portal.py.
No .godot cache is copied. No test/runtime/editor UI is launched after import.
"""
from __future__ import annotations

import argparse
import hashlib
import io
import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import tarfile
import time

ROOTS = ("scripts", "scenes", "config", "ai", "assets", "addons")
FILES = ("project.godot", "icon.svg")
BASELINE = "644587bc9e570aed5d7c78cc00f8f81a6defff67"


def sha(path: Path) -> str:
    return hashlib.sha256(path.read_bytes()).hexdigest()


def diagnostics(text: str) -> list[str]:
    # Asset names such as LimboVarError.svg are progress entries, not errors.
    plain = re.sub(r"\x1b\[[0-9;]*m", "", text)
    return [line for line in plain.splitlines()
            if re.search(r"(?:^|\s)(?:SCRIPT ERROR:|ERROR:|WARNING:|Parse Error:|Compile Error:)", line)]


def inventory(project: Path) -> dict:
    cache = project / ".godot"
    imported = cache / "imported"
    files = sorted(p for p in imported.rglob("*") if p.is_file())
    remaps = []
    missing = []
    # Sidecar remap targets are concrete imported artifacts, not just log markers.
    for sidecar in sorted(project.rglob("*.import")):
        if ".godot" in sidecar.relative_to(project).parts:
            continue
        for target in re.findall(r'^path(?:\.[^=]+)?="(res://[^"\n]+)"',
                                 sidecar.read_text(errors="replace"), re.M):
            remaps.append(target)
            if not (project / target.removeprefix("res://")).is_file():
                missing.append({"sidecar": sidecar.relative_to(project).as_posix(), "target": target})
    return {"cache_exists": cache.exists(), "imported_count": len(files),
            "imported_bytes": sum(p.stat().st_size for p in files),
            "imported_files": {p.relative_to(project).as_posix(): sha(p) for p in files},
            "sidecar_target_count": len(remaps), "missing_sidecar_targets": missing,
            "uid_cache_exists": (cache / "uid_cache.bin").is_file(),
            "filesystem_cache_files": [p.relative_to(project).as_posix()
                                       for p in (cache / "editor").glob("filesystem_cache*")]}


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--godot", type=Path, required=True)
    parser.add_argument("--work-root", type=Path, required=True)
    parser.add_argument("--source", choices=("baseline", "retained"), required=True)
    parser.add_argument("--mode", choices=("first-iteration", "import-complete"), required=True)
    parser.add_argument("--repeat", type=int, choices=(1, 2, 3), required=True)
    parser.add_argument("--warm", action="store_true", help="One same-mode warm retry after this cold run")
    args = parser.parse_args()
    source = Path(__file__).resolve().parents[2]
    work = args.work_root.resolve() / f"{args.source}-{args.mode}-{args.repeat}"
    work.mkdir(parents=True, exist_ok=False)
    (work / ".gdignore").touch()
    project = work / "project"
    project.mkdir()
    if args.source == "baseline":
        archive = subprocess.check_output(["git", "archive", "--format=tar", BASELINE,
                                           "--", *ROOTS, *FILES, "tools/tests/dev_portal_test.gd"], cwd=source)
        with tarfile.open(fileobj=io.BytesIO(archive)) as saved:
            for member in saved.getmembers():
                parts = Path(member.name).parts
                if not member.isfile() or any(p.startswith("~") or p in (".git", ".godot", "..") for p in parts):
                    continue
                relative = Path("dev_portal_test.gd") if member.name == "tools/tests/dev_portal_test.gd" else Path(member.name)
                target = (project / relative).resolve()
                if not target.is_relative_to(project.resolve()):
                    raise RuntimeError(f"Archive path outside project: {relative}")
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(saved.extractfile(member).read())
    else:
        for name in ROOTS:
            if (source / name).is_dir():
                shutil.copytree(source / name, project / name,
                                ignore=shutil.ignore_patterns("~*", ".git", ".godot"))
        for name in FILES:
            shutil.copy2(source / name, project / name)
        shutil.copy2(source / "tools/tests/dev_portal_test.gd", project / "dev_portal_test.gd")
    assert not (project / ".godot").exists()
    inputs = {p.relative_to(project).as_posix(): sha(p)
              for p in sorted(project.rglob("*")) if p.is_file()}
    binary = work / "engine"
    binary.mkdir()
    engine = binary / args.godot.name
    shutil.copy2(args.godot, engine)
    (binary / "_sc_").touch()
    profile = work / "profile"
    (profile / "Godot/app_userdata/Laema").mkdir(parents=True)
    env = os.environ.copy()
    env.update(APPDATA=str(profile), LOCALAPPDATA=str(profile))
    help_result = subprocess.run([str(engine), "--help"], stdout=subprocess.PIPE,
                                 stderr=subprocess.STDOUT, env=env, timeout=15)
    (work / "engine-help.txt").write_bytes(help_result.stdout)
    help_text = re.sub(r"\x1b\[[0-9;]*m", "", help_result.stdout.decode(errors="replace"))
    report = {"source": args.source, "baseline_ref": BASELINE, "mode": args.mode,
              "repeat": args.repeat, "input_hashes": inputs, "engine_sha256": sha(engine),
              "project_godot_sha256_before": sha(project / "project.godot"),
              "copied_cache": False, "help_lines": [s for s in help_text.splitlines()
                if any(flag in s for flag in ("--quit ", "--import ", "--editor "))], "runs": []}
    for phase in (["cold", "warm"] if args.warm else ["cold"]):
        arguments = [str(engine), "--headless", "--path", str(project)]
        arguments += ["--editor", "--quit"] if args.mode == "first-iteration" else ["--import"]
        arguments += ["--log-file", str(work / f"{phase}-engine.log")]
        before = inventory(project)
        started = time.monotonic()
        timed_out = False
        with (work / f"{phase}-output.log").open("wb") as log:
            try:
                result = subprocess.run(arguments, env=env, stdout=log,
                                        stderr=subprocess.STDOUT, timeout=60)
                code = result.returncode
            except subprocess.TimeoutExpired:
                timed_out = True  # subprocess.run kills/waits for its owned child.
                code = None
        text = (work / f"{phase}-output.log").read_text(errors="replace")
        run = {"phase": phase, "command": arguments, "timeout_seconds": 60,
               "timed_out": timed_out, "exit_code": code,
               "exit_hex": f"0x{code & 0xffffffff:08X}" if code is not None else None,
               "wall_seconds": time.monotonic() - started,
               "diagnostics": diagnostics(text),
               "completion_lines": [s for s in text.splitlines() if any(k in s for k in ("reimport", "loading_editor_layout", "first_scan_filesystem"))],
               "before": before, "after": inventory(project),
               "project_godot_sha256_after": sha(project / "project.godot")}
        report["runs"].append(run)
        (work / "report.json").write_text(json.dumps(report, indent=2), encoding="utf-8")
        print(json.dumps({k: run[k] for k in ("phase", "exit_code", "exit_hex", "timed_out", "wall_seconds", "diagnostics")} |
                         {"work": str(work), "imported_count": run["after"]["imported_count"],
                          "missing_remaps": len(run["after"]["missing_sidecar_targets"])}), flush=True)
    # Diagnosis reports preserve failures; never convert engine errors to test success.
    return 0 if all(r["exit_code"] == 0 and not r["timed_out"] and not r["diagnostics"] for r in report["runs"]) else 1


if __name__ == "__main__":
    raise SystemExit(main())
