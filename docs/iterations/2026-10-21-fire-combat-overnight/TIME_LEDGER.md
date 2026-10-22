# Overnight time accounting

Updated after final replay at 07:49 HKT, October 22, 2026. The approved working window is 23:00–08:00; that window is not nine hours of gameplay. Final review/documentation continues to the cutoff.

## Active rendered gameplay — measured lower bound

The 24 isolated recorded sessions contain 123 commands with movement, melee, Casting, defence or dodge inputs and 5,248 scheduled input edges. Not every command is a complete encounter; some are failed attempts, calibration, practice or cancellation probes. UI-only commands are excluded.

Consecutive recorded samples within the same command, with both actors alive and both samples unpaused, account for **2,128.408 wall seconds (35m 28.4s)** and **2,121.267 physics seconds (35m 21.3s)**. Samples are sorted by their original readback timestamps, not worker-completion append order. Only positive gaps at most 1.5 wall seconds and at most 120 physics ticks are counted. All 24 JSONL logs parsed without error. The earlier 07:22 snapshot was113commands/4,322edges and28m40.6s; final retained-D practice and parry/encounter add ten normal-input commands, not retrospective relabelling of waiting. FINAL_ACTIVITY.json preserves the final counters.

This is a conservative sample-covered exposure measure, not a complete stopwatch and not physical-controller play. Sparse-keyframe gaps longer than 1.5 seconds, setup/native preflight, paused analysis and time outside commands are not counted. Failed practice is included as activity but never reported as a pass. The unattended defeat after an unfinished batch and the final parry-session startup-idle defeat are outside active command exposure and excluded from difficulty comparisons. Known native UI setup inputs are tracked separately; contaminated/stalled trials are retained with their evidential exclusions in PROGRESS.md.

## Visual/source review — separate, not continuously timed

Actual PNG inspection, native-window checks, source/consumer reading, A/B/C/D comparison, replay planning and evidence indexing occurred between bouts. PROGRESS.md records these phases. No per-task stopwatch was running, so an exact review-hours total would be invented. Wall-clock gaps in the ledger must not be relabelled as continuous gameplay or continuous review.

## Implementation — U only, overlaps review/play

U authored the bounded recorder support and five retained product-file deltas, plus rejected/restored timing and cue candidates. Combat supplied observations, bounded hypotheses and exact scopes, reviewed the changes and replayed fresh snapshots. U turn duration includes its reading/checks as well as edits; it overlaps Combat activity and cannot be added to gameplay as a disjoint total. No main-chat product-code edits, commits or pushes occurred.

## Waiting/continuity — explicitly not play

Startup/import, encoder completion, process shutdown, thread coordination and paused continuity gaps are waiting/overhead. In particular, the game remained safely paused between the 06:42 ledger entry and this continuation around 07:15. That interval is not active gameplay. No locked-desktop bypass or invented unattended observation occurred.

## Final verification phase

The final Gym session closed normally at 07:19:05 HKT with exit0 and the existing 13 ObjectDB / 9 resource shutdown warnings. Controlled geometry regressions then ran sequentially07:19–07:22, all7,212checks passed; their durations are test execution, not play. A final retained-D rendered practice replay followed07:25–07:37, including three120second live batches and earned-Heat100 chain/gap/dodge checks. It also closed exit0 with13/9warnings. No heavy regression process ran beside primary play. Candidate freeze took effect07:30; later replay introduced no code or value candidate. Final source review, documentation and handoff continue until08:00.

Sources: each temporary sessions/*/events.jsonl, archived selected session logs, PROGRESS.md, FINAL_SOURCE_IDENTITY.json and recorder-review.md. The evidence folder preserves selected captures and logs; the isolated temporary source/profile remain restorable.

Final07:43–07:47 same-source parry replay adds one visible-windup/pause-assisted PARRIED/0Healthloss and same-encounter70HP victory, then exit0/13ObjectDB9resources. Initial startup idle reached defeat before command1 and was excluded, followed by ordinary Retry; no Health repair. Source review/doc synchronization and subsequent cutoff waiting are not counted as additional gameplay.
