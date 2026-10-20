# Decisions

This is a dated decision history, not a current-rules summary. Earlier R2 pressure semantics, capacities, offensive-power comparisons, single-contact assumptions and implementation statements retain their original context. Later explicit decisions and the current [GDD](GAME_DESIGN.md) supersede them where stated. Historical pending labels do not reopen completed work.

**Later decisions — October 20:** the user retained the current shorter shared reaction durations and Cast-commitment Heat timer refresh, recorded in the GDD/TDD. October 14 durations below remain historical. The user also confirmed the editor's separate 0.3–0.8-second post-reaction AI wait; it does not extend the component reaction lifetime.

## 2026-10-14 — Longer combat hit-reaction tuning

- **Decision:** Levels 1–5 use durations of 0.6, 0.9, 1.2, 1.5 and 1.8 seconds respectively. This supersedes the earlier starting-duration table below; distances remain 5, 10, 15, 20 and 25 pixels.
- **Implementation:** Both the shared Inspector Resource and Portal JSON mirror carry these values. Gameplay validation of this tuning remains pending.
- **Source:** The user's corrected duration sequence in the Dummy execution task.

## 2026-10-14 — Shared Inspector and Developer Portal tuning

- **Decision:** Expose move Impact, Player/Final Enemy poise and hit-reaction tuning in the Godot Inspector and keep those values synchronized with the Developer Portal.
- **Implementation candidate:** A shared combat tuning Resource provides the Inspector surface and mirrors selected values into the existing validated JSON model. Portal Save Tuning persists both; runtime edits share the existing Arena callback. Combat duration/distance are editable per level, with separate legacy settings.
- **Constraint:** Reaction eligibility, five difference bands, Player-winning ties and failed-Cast vulnerability are preserved. Existing reactions retain the duration and displacement captured at entry.
- **Validation:** Source/grammar and data-consistency checks do not establish Inspector or runtime execution. User validation is pending.


## 2026-10-14 — Poise, attack interruption, and hit-reaction levels

Status: accepted design decisions, recorded before implementation. No new runtime validation is established.

- **Decision:** Poise (韧性) contributes to resistance against hit reactions. During windup/startup and recovery, only the character's poise counts. During active frames—the frames that can trigger a hit event—the current move's Impact is added: `power = poise + move Impact`.
- **Decision:** A hit landing during windup or recovery triggers a reaction when incoming Impact strictly exceeds the target's poise.
- **Decision:** For physical contact while both attacks have overlapping active frames, compare both characters' power. The higher-power side wins; equal power favors the player. The losing attack is cancelled entirely and deals no damage, and its attacker enters hit reaction.
- **Decision:** After hit reaction, the Enemy abandons the cancelled attack and reassesses the situation rather than resuming that attack. A qualifying hit reaction replaces the prior blanket committed-attack non-interruption rule for the intended new design.
- **Decision:** Hit-reaction level increases in bands of power difference, rather than one level per point. In simultaneous clashes, the difference is winning power minus losing power. A player-winning tie applies level 1 to the Enemy. Level 5 is the cap.

| Power difference | Hit-reaction level | Duration | Backward displacement |
|---|---|---|---|
| 0–10 | 1 | 0.3 s | 5 px |
| 11–20 | 2 | 0.6 s | 10 px |
| 21–30 | 3 | 0.9 s | 15 px |
| 31–40 | 4 | 1.2 s | 20 px |
| 41 and above | 5 | 1.5 s | 25 px |

- **Constraint:** The table selects the level only after reaction eligibility is established. Difference 0 does not independently trigger a reaction; it applies to the player-winning simultaneous-contact tie.
- **Decision:** Displacement pushes the whole character, including its collision body, backward and leaves it at the new position. It is not sprite-only recoil followed by a return.
- **Decision:** The entire hit-reaction duration grants invincibility: no further damage or additional hit reactions until it ends.
- **Later clarification:** Ordinary-hit difference is incoming Impact minus target poise. Clash eligibility uses overlapping active intervals with physical contact, without requiring mutual same-update contacts. Failed-Cast self-reactions grant no invincibility. Walls can block whole-body push, which is spread across the full reaction duration.
- **Later decision:** Author active_start and active_end markers in the animations; seed missing active_end at swing completion for later user tuning. Mixed-Cast primary/secondary layers resolve before invincibility starts.
- **Open:** Final poise/move Impact tuning, forward-lunge tuning and additional spell/status interactions remain unresolved. Defence redesign remains deferred.
- **Implementation candidate:** The October 14 execution slice synchronizes the affected GDD, technical/status and Combat records with the hit-reaction candidate. JSON per-move records use individual Impact and animation references, existing damage/duration sources and a null reserved forward-lunge field. Runtime validation remains pending; forward-lunge execution/tuning is not included.
- **Source:** Explicit user decisions in the Combat task on 2026-10-14, including authorization to record the complete design before implementation.

## 2026-10-13 — Per-move Impact and forward lunge requirement

- **Decision:** Each attack/move must have its own data structure containing an Impact level and a forward-lunge setting alongside its existing attack data. “Forwarding level” means forward lunge, not a separate mechanic.
- **Decision:** Attacks should move the attacker forward to maintain range through repeated attacks as Enemy hit reactions move the Enemy backward. This records the intended behavior, not a claim about current physical knockback.
- **Constraint:** Forward-lunge movement does not necessarily need to equal Enemy knockback.
- **Open at recording:** Exact distances, timing, and Impact tiers remained tuning decisions; data representation and sprite-only recoil versus collision-body displacement were unresolved. The 2026-10-14 hit-reaction decisions above now settle the reaction bands, duration, distance and whole-body displacement. Forward-lunge tuning and data representation remain Open.
- **Fact:** The user requested that this requirement be recorded before implementation. This entry does not establish implementation or runtime validation; corresponding GDD/technical synchronization remains pending before an implementation handoff.
- **Source:** Explicit user requirement in the Combat task on 2026-10-13.

## 2026-08-24 — First-draft prototype baseline

- **Decision:** The committed first-draft baseline is `e543a43`, covering the user-verified 2D top-down Fire/Water prototype slice with Air/Earth placeholders and a non-attacking Enemy.
- **Fact:** The user reported `validation passed` in Godot on 2026-08-24 for the exercised scene, controls, school selection, Fire/Water combat, combos, Heat, Enemy refill, statuses, hit reactions, collision, animation readability, and UI.
- **Constraint:** Incoming Enemy attacks, ordinary-play blocking/parrying/guard-break triggering, functional Air/Earth packages, final art, complete enemy content, and final tuning remain outside that validation.
- **Constraint:** The accepted instigator-lifetime waiver and the deferred Enemy/Air/Earth scope remain part of the technical record.
- **Decision:** `docs/TECH_ARCHITECTURE.md` is synchronized to the committed implementation and validation boundary by the current documentation update; future material source changes must keep it synchronized before submission readiness is declared.

## 2026-08-25 — Expanded side-scrolling prototype state

- **Decision:** The active prototype representation is the four-school side-scrolling orb-casting slice with five-position X/Cast chains, seven-second FIFO orb lifetime, R2 DEPLETING/CHARGING/CAST pressure semantics, full-press Casting, shared normalized X/Cast buffering, three non-attacking Enemy targets, and the organized Developer Portal/audio controls recorded in the canonical GDD and technical architecture.
- **Fact:** The user reported the expanded implementation as validated in Godot on 2026-08-25, but did not provide a scenario-by-scenario matrix or engine-version record.
- **Constraint:** Agent-run Godot, build, compiler, and automated-test evidence remains unavailable. Incoming Enemy attacks, ordinary-play defence validation, final art, final tuning, and complete enemy content remain outside the current validation boundary.
- **Decision:** The active summaries and implementation-status record are synchronized to the current implementation.
- **Fact:** The current committed implementation is `358684b` (`feat: add side-scrolling orb casting prototype`). The user-reported validation applies to the expanded implementation, while agent-run runtime/build/test evidence remains unavailable.

## 2026-10-16 — Four school melee styles within the existing chain

Accepted: implement the Broadsword/Earth, Spartan Sandals/Fire, War Spear/Water and Twin Daggers/Air feel references with current animations. Preserve five global X/Cast progression positions and the optional sixth-slot Cast endpoint. Allow independent, tunable timing and movement for all 20 X moves; X3/X4 are variations and X5 is the finishing role. The temporary variable-length-chain proposal was withdrawn. Native contact/active markers and the current input buffer, Cast commitments and orb rules remain in use.

Implementation interpretation: windup/post-contact durations, query reach/radius, forward-body distance/phases and qualifying-reaction push scaling form the initial tunable profile. Heat scales timing once. Stored damage, Impact/Poise and reaction duration/band values are preserved. The new numeric style presets require gameplay validation and are not final balance.
