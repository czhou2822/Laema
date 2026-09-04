# Changelist — 2026-09-04 checkpoint automation

## Intent

Introduce the first deterministic checkpoint script and publish the initial concise task-summary manifest.

## Included scope

- `tools/checkpoint.ps1`
- `tools/README.md`
- `AGENTS.md`
- `README.md`
- `docs/README.md`
- `docs/checkpoints/2026-09-04-checkpoint-automation.thread-sync.json`
- `docs/checkpoints/2026-09-04-checkpoint-automation.md`
- `docs/changelists/2026-09-04-checkpoint-automation.md`

## Behavior added

- Save validates task keys, latest turn IDs, and concise summaries; it stages, commits, pushes, and verifies the remote.
- Load rejects a dirty tree, pulls fast-forward-only, resolves mapped local bindings, and emits one message plan per changed task.
- Agent orchestration owns thread reads, material summaries, and message dispatch. The script never infers conversation meaning or controls Codex sidebar indicators.

## Evidence

- PowerShell syntax parsing passed.
- `git diff --check` passed before publication.
- No Godot, build, compiler, editor, or automated-test command was run.
