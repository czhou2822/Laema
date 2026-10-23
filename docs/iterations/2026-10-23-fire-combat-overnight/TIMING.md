# Activity and evidence accounting

The human-authorized window was23:57HKT October23 to08:00HKT October24. That
elapsed window is NOT hours of continuous play. Candidate work froze before
07:30; the remainder is final review, records and local integration.

Closed recorder logs contain31rendered trials, including preflight, UI,
diagnostic and practice trials. They record23distinct combat Enemy instances
reaching0Health; incomplete4HP/partial/probe attempts are not added as victories.
There are9,674captured review frames, not9,674frames individually inspected.
Selected frames and native editor/UI states were actually viewed.

| Activity | Evidence / timing boundary |
| --- | --- |
| Scheduled unpaused game operation | Approximately806.483s (13m26s), sampled from actual adjacent states; includes ordinary movement/setup, combat, diagnostics and post-victory tails. |
| Positive-Health target command time | Approximately690.945s (11m31s), excluding UI/preflight; includes the explicitly labelled training/partial diagnostics, not only live attacking enemies. |
| Post-defeat command time | Approximately111.399s, including genuine practice and scheduled tails; not extra fights. |
| Source and visual review | Interleaved throughout the ledger: source diffs, actual image inspection, native editor/UI, measurements and repeated decisions. No exclusive stopwatch total was recorded; do not infer it by subtracting play from wall time. |
| Implementation | U/Dum-E's isolated commits are identified per iteration. Their elapsed work overlapped Main's play/review; commit/turn timestamps are not exclusive coding-time totals. |
| Waiting | Not separately stopwatch-measured. Main continued independent work during worker preparation and the initial P1 authority block; those intervals are not claimed as active play or as hours of idle waiting. |

TIME_ACCOUNTING.json retains per-trial sampled intervals, process lifetimes,
capture counts, input lateness and completion counts. Intervals are bounded by
adjacent states no more than1.5s apart, with paused time excluded. Process lifetime
includes long review pauses and must never be presented as play time. UI01 is
excluded as a combat comparison; the intentional native preflight input is
labelled separately. Synthetic hardware events are not physical-controller or
human-usability acceptance. Exact exclusive category totals were not captured;
this limitation is explicit rather than retroactively invented.

The per-row legacy key `sampled_live_enemy_command_s` means positive-Health
target time, including the labelled training targets and partial diagnostics;
it must not be read as time spent only fighting an attacking Enemy. The root
aggregate and table above use the clearer positive-Health-target wording.
