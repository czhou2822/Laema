# Local integration receipt — October23–24 Fire candidates

Prepared after the07:30 candidate cutoff; no further gameplay candidate introduced.

## Product identity and boundaries

Baseline:f6ccfbe03143b5bf591ee83f5725ddb3919644b3.
Retained product:3200279f4f69f0f9e6fdb5bac0f0674befda5890.

- Feedback/support through1660dd04 and M1's4b715460 were guardedly integrated
  as521a6a6d. M1 changes only shared Level4 motion1.15→0.15s in two Resources;
  distance20/stun1.15 and every other level stay unchanged.
- R1ab284aa7 was integrated alone asd6a74074: detached camera callback guard/
  disconnection and its existing focused regression.
- T15cc98e8e was integrated alone as3200279f: only FireX5 pre-split0.30→0.55,
  recovery1.10 retained. All native pose/geometry/marker/lunge values preserved.
- T2b84b3181 (X5 .45/1.10) and P1cfa94d2d (X1 .28/.44) remain UNMERGED.
  Their Resource-only experiments were actually compared separately. Main X1
  remains .21/.51. Do not switch whole experimental worker branches to recreate
  the final baseline; their ancestry differs. Apply only the exact leaf Resource
  change to current main when the human requests another comparison.

The retained source diff contains13product/support files. No native Scene,
Animation, Sprite/body/collider registration or asset bytes changed. No new AI
policy, art/audio identity, damage/Health/Impact/Poise/eligibility, Heat/orb/input
rule, shared Cast timing, defence/dodge contract, stun/protection duration,
hitstop, time-scale, zoom or rotation change. Independent new cosmetic switches
default off/Precise. No per-attack knockback or duplicate geometry control returns.

## Actual evidence

Windows Godot4.7.1/1280×720/60physicsHz rendered normal bound input; no forced
Health/Heat/orbs/hits/positions/AI/clocks in primary evidence. Final default
PrototypeArena replay117048_729144 completedP80/E0/H28/unexpected0 and visibly
entered free practice. New effects were off/camera0. Normal quit produced no
gameplay script/null-tree error; generic16ObjectDB/9resource exit diagnostics
remain uninvestigated. Earlier reproduced C3/R1 errors and excluded UI01 are
retained honestly in the ledger rather than erased.

Main independently reran the current focused fixture:1,998checks/0failures/no
stderr. Separate dodge fixture512/513, with only the retired-control-count
assertion failing; old unused contact-API tests still parse-fail in Editor.
No full-suite/whole-editor, final art/audio, all-roster, physical-controller or
human-feel acceptance. GDD exact synchronization remains AWAITING_GDD_VERIFICATION.

Final101candidate/configuration files byte-matched main in the isolated runtime.
The earlier12,197-file runtime comparison had only eight provenance-JSON CRLF/LF
differences with equal normalized content; broader demo/export/admin omissions
were outside the original runtime archive roots. The unique-userdata override
is isolation-only, not product source. First preflight's normal log/cache touch
is disclosed in REPORT.md; no normal preferences were saved.

## Preservation and record commit

Before/after source integration and at final check, all6,293 unrelated untracked
draft/department entries retained aggregateSHA256
5D14F289937A882E07005CCF4AD79BB3E6D89D2CB77197A0687A0FC3D84E9C9B.
The index was empty and incoming/dirty paths did not overlap. User department,
research, original-sprite and import drafts remain separate and dirty.

The accompanying LOCAL record commit stages ONLY these six canonical records
and this run folder: GAME_DESIGN.md, TECH_ARCHITECTURE.md, IMPLEMENTATION_STATUS.md,
GYM.md, ATTACK_STYLES.md and ATTACK_FEEL_GUIDELINES.md. The record commit does not
change the product above. Its exact HEAD is reported in the chat after commit.
No stage-all, reset, stash, discard, unrelated cleanup, push, fetch/remote
reconciliation, Web export, checkpoint save/load or chat archive. Retained work
is a morning candidate, not submission clearance.
