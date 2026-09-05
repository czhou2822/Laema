# Combat checkpoint — 2026-09-05

Task key: combat

## Since last checkpoint

- The current feature slice includes Stage 1–8, Elemental Endurance, a solid Final Enemy, committed-position attacks, a Player 1-HP Floor option, smaller DoT feedback, restored Final Arena practice targets, and HUD telemetry.
- User manually validated smaller DoT numbers, solid Final Enemy collision, pass-through practice targets, committed-position misses, and windup non-interruption.
- The user waived remaining targeted runtime checks for this tuning phase. The waiver is not a passed test.
- The historical Endurance merge-review discussion remains preserved; do not infer deletion authority from earlier safety discussion.

## Carried context

- Decision: the first active Enemy is a school-switching test. It attacks during the test; active-Enemy behavior beyond the current slice remains subject to later tuning.
- Draft: Elemental Endurance details are present in current project records. Preserve unresolved review history where current authority has not settled it.
- Validation: no agent-run Godot, build, compiler, or automated-test evidence exists.

## Resume point

Start game-feel tuning after checkpoint publication.

## Sources

- docs/GAME_DESIGN.md
- docs/TECH_ARCHITECTURE.md
- docs/IMPLEMENTATION_STATUS.md
- Combat turn 01a070f6-6608-7722-8e91-434b3508eea7
