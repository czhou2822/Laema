# Elemental Endurance — merged recovery draft

Status: MERGED_FOR_USER_REVIEW. This document combines the local GDD discussion and the Combat recovery package in 2026-09-05-substantive-cross-machine-recovery.thread-sync.json. The user explained that these represent parallel discussions of the same idea following unreliable recovery.

This merge preserves compatible local detail where the checkpoint merely leaves a question open. An unanswered question is not an opposing rule. Shared content and retained additions below are not promoted to final approval by this merge. Existing GDD and checkpoint history are preserved.

## Common ground

Both versions describe tutorial protection intended to encourage school switching and mixed Casting before a later boss-like test. Same-school hits 1–5 deal full damage; hit 6 deals 50%; later hits decline to 0% at hit 10+. Another school clears the previous streak; a mixed Cast clears the buff and delivers both layers without Endurance reduction. A school-colored icon shows remaining damage percentage.

## Compatible detail retained from the local discussion

- Tutorial final Enemy only; no general rule for all enemies.
- Hits 7–9: 40%, 30%, 20%.
- One player action counts at most once even when it produces multiple damage events.
- Blocked/parried actions do not change the streak.
- A different-school hit becomes hit 1; mixed Casting leaves no active streak.
- Separate mixed-Cast damage numbers; all numbers show final actual Health loss, including zero.
- DoT uses current resistance without changing streaks.
- Partial resistance preserves non-damage effects; full resistance suppresses new same-school effects while existing effects remain.
- At zero damage: no orb generation; Heat Reset Timer refresh and normal Impact/hit reaction remain.
- Enemy AI remains a separate unresolved design subject.

The checkpoint offers no contrary values for these additions. They remain in the combined draft rather than being erased or presented as cross-machine contradictions.

## Decisions needed

### C1 — Single-school defeat versus permanent immunity

Local intent: “The Enemy is intended to remain defeatable through single-school melee.”
Both versions: hit 10+ deals 0% until another school lands.
These cannot guarantee single-school defeat when the Enemy survives the first nine hits. No existing health/damage tuning guarantee is established by these records.

User resolution needed: must single-school melee always remain capable of defeating this Enemy, or may Endurance force a school change after hit 9? Do not invent a damage floor, decay timer, reset, or health tuning to resolve this.

### C2 — Full resistance suppresses effects but retains Impact

The local version suppresses non-damage effects at 0%, yet explicitly preserves normal Impact and hit reaction and Heat Reset Timer refresh.
These can coexist if the named responses are exceptions to suppression. The broad suppression wording does not state that boundary clearly.

Proposed editorial clarification, awaiting user resolution: full resistance suppresses newly applied school/status effects and orb generation, while Impact, hit reaction, and Heat Reset Timer refresh remain explicit exceptions. No new effect behavior is introduced by this proposed wording.

### C3 — “Applied attacks” and fully resisted contact

The local version limits participation to “landed, applied attacks,” but explicitly requires responses for landed zero-damage hits. The documents do not define whether “applied” includes full resistance or means a particular HealthResult outcome.
This is an eligibility ambiguity, not evidence of two opposing decisions.

User resolution needed: confirm whether physically landed, fully resisted same-school attacks still qualify for the explicitly retained responses, without advancing beyond the capped streak. Blocked/parried attacks remain excluded as written.

### Approval status

The checkpoint labels Endurance a candidate; the local GDD writes detailed rules declaratively. Per the user's request to review conflicts, this merged draft remains pending review. Its location or level of detail does not establish approval. No old checkpoint is rewritten.

## Combined source text

The local section below is preserved in full as the more detailed version of the common idea. C1–C3 above flag the wording still awaiting resolution.

### Elemental Endurance — Tutorial-Only Buff

Elemental Endurance is currently a tutorial-only protective buff for the tutorial's final Enemy. It showcases Laema's school-changing and Casting systems without becoming the later boss-like skill test. This buff is not yet a general rule for other enemies or the final game.

The Enemy is intended to remain defeatable through single-school melee, but repeatedly relying on one school becomes increasingly inefficient.

Only landed, applied attacks participate in Elemental Endurance. One player action advances its school streak at most once, regardless of how many direct-damage `HealthEvent`s the action produces. Blocked and parried actions neither advance nor reset the streak.

Consecutive landed actions from the same school use the following damage percentages:

| Same-school hit | Damage dealt |
|---|---:|
| 1–5 | 100% |
| 6 | 50% |
| 7 | 40% |
| 8 | 30% |
| 9 | 20% |
| 10 and later | 0% |

Hit 6 activates the protective buff. The 0% state persists until an action from another school successfully lands.

A landed action from another school:

- deals full damage;
- clears the previous school streak;
- removes the existing protective buff; and
- becomes hit 1 of the new school's streak.

A mixed-school Cast is an exception to ordinary streak replacement. It clears Elemental Endurance, removes the protective buff, deals full damage with both school-damage layers, and leaves no active school streak. The next landed single-school action becomes hit 1. Its primary and secondary layers display separate floating damage numbers, each showing that layer's final Health loss after modifiers.

DoT ticks use the Enemy's current damage percentage for their school, but they never advance, reset, or replace the streak. A landed same-school action at hit 10 or later remains capped at 0% damage until a different school successfully lands.

At `50%`, `40%`, `30%`, or `20%` damage, the action's non-damage effects still apply normally. At `0%` damage, non-damage effects carried by that same-school action are also suppressed. Existing effects are not removed; for example, an already active same-school DoT continues ticking at the current 0% damage percentage without changing the streak.

A same-school direct hit that lands at `0%` damage still refreshes the Heat Reset Timer and resolves its normal Impact and Enemy hit reaction. A same-school X hit at `0%` does not generate an orb. A fully resisted Cast layer still displays its final damage feedback as `0`.

When active, the protective buff displays an icon above the Enemy's head. The icon color identifies the resisted school. A number in the icon's lower-right corner displays the percentage of incoming same-school damage that remains: `50`, `40`, `30`, `20`, or `0`.

Floating damage numbers always display the final Health actually lost after Elemental Endurance, blocking, and every other damage modifier. A final Health loss of zero still displays `0`.


## Evidence and next step

No Endurance runtime validation is established by this merge. No gameplay code was changed. Resolve C1 first, then the narrower C2/C3 wording, then confirm the merged design before canonical synchronization or technical handoff.
