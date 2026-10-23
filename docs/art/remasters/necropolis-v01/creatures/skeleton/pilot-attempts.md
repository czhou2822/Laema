# Skeleton pilot attempts

Scope is exactly the ten distinct IDs from pilot-attack-turn-00/01. No other poses are authorized in this pass. Full creature remains incomplete.

- Page 00 a01: raw preserved byte-for-byte. True alpha, 1774 x 887. Helper ingest rejected it: `ValueError: No clear transparent gutter; regenerate individual poses instead of clipping`. No pose records were created. Visual observations: p033 sword slopes upward across pelvis instead of remaining down alongside hip; p034 is a genuine frontal turn. Row 2 sword extents prevent common vertical gutters.
- Page 01 a01: raw preserved byte-for-byte. 1536 x 1024, alpha range 0..254; visible brown background haze, broad overlapping horizontal extents. Rejected visually before ingestion. It is not usable transparent sprite artwork.
- Single-pose repair guides were justified by page gutter rejection and/or visible haze. Five singles (p033, p034, p035, p036, p043) had already generated when parent requested preserving otherwise good page00 artwork. Their raw images and exact requests are retained. Uncalled a02 requests for p044/p045/p046 are preparation only, not generated artwork.
- Parent then supplied a strict task-local SciPy component-isolation path. Re-ingestion of unchanged page00 with `--components` succeeded under batch `pilot-attack-turn-00-a01-components-c01`. This recovered all eight original cell mappings without clipping or drawing changes. The corrected p033 single was re-ingested afterward. The other four generated singles remain retained alternatives, not new pose coverage.
- Active selection: corrected single p033; original page00 p034/p035/p036/p043/p044/p045/p046; clean-alpha single repairs p047/p042. All ten pilot IDs are supplied. See PILOT_REPORT.md and the two machine-readable evidence files for final coverage and review limits.

Exact tool requests and prompt files are under the creature `_source/prompts/`; returned output hints are retained verbatim in `.tool-metadata.json`. No model or seed was returned.
