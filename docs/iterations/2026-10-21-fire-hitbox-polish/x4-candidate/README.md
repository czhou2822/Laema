# Fire X4 candidate — October 21

Status: bounded supervisor review passed; `AWAITING_USER_VALIDATION`.
Combat independently passed1281 headless checks at the candidate hash below and
inspected all four active holds in both facings in a separate actual renderer.
No detached coverage was observed. Human feel remains open. X5-only is next.

Only position/target key **values** in config/attack_animations/fire_x4.tres
changed. All existing key times, Sprite mappings, UID/length, active0.36–0.8666667,
pacing split0.7, radius3.5, source art, body/floor, AI and combat settings remain
unchanged. Final two geometry keys now repeat the same measured cell2 pose,
matching the repeated artwork rather than inventing another sword angle.

## Independent source truth and native holds

Source cells are distinct from Animation key indices. Native Sprite keys map
to cells0/0/0/1/2/2. Three independently measured physical blades supply four
active hold intervals; the fixture derives intervals from actual native keys
and looks up the displayed source cell, including0. Measurements exclude hands,
crossguards/effects; estimated visual uncertainty2 source pixels. Combat also
reviewed the annotated original pixels before this candidate.

| Cell | Base | Separately observed middle | Tip |
| --- | --- | --- | --- |
| 0 | (228,259) | (264,244) | (300,230) |
| 1 | (286,240) | (319,227) | (354,213) |
| 2 | (228,263) | (260,248) | (291,233.5) |

| Native key | Active interval | Source cell |
| --- | --- | --- |
| 2 | [.36,.5197053) | 0 |
| 3 | [.5197053,.6942831) | 1 |
| 4 | [.6942831,.85266525) | 2 |
| 5 | [.85266525,.8666667] | 2 |

Truth: ../fire_x4-blade-points.json. Annotated source: native keys0/3/4 in
../fire_x4-source-measurements/. Use the engine-derived source origin(224,348),
unchanged radius3.5 and7-source-pixel end-center inset from the
[X2 method](../x2-candidate/README.md), not the feet anchor(224,400).

## Evidence

Godot4.7.1 stable official a13da4feb, isolated portable project/profile; hidden
Compatibility/OpenGL3.3 window, RTX4090, Dummy audio for rendered checks.
Base921fd1ae plus reviewed X1/X2 and this X4 resource.

| Run | Result | Files |
| --- | --- | --- |
| Pristine X4 negative fixture | Expected192/737 failed assertions; exit1; no reported engine errors | baseline-negative-report.json / baseline-negative.log |
| Candidate headless | 1281 checks pass; exit0; no reported errors | headless-report.json / headless.log |
| Candidate rendered | 1136 checks pass; exit0; no reported errors | render-report.json / render.log |
| Source/whitespace invariants | PASS | ../fire_x4-source-measurements/static-checks.json; working diff |

64 manual-fixture samples/448 real point probes check blade base/middle/tip and
outside points for both directions/Heat0/100. All192 old blade-point checks
fail; candidate checks pass. All32 comparable Heat pairs have identical query
geometry and actual Sprite region. Distinct interior and near-key tolerance
samples use the native displayed cell as physical truth. Collector/resolver
fixtures preserve late contact after a miss, once-per-target spending,
invincible rejection/no orb, active bounds and cancellation.

Eight ordinary input/physics cases reach X4 through actual X inputs and live
AI, with baseline/max Heat, both directions and spacing/approach cases. Each
spends at most one target contact. Baseline cases apply10 damage. Max-Heat X4
contacts here are rejected as INVINCIBLE from the preceding combo reaction:
they spend contact but deal0 and must not retry after invincibility ends.
The actual health-result trace records that outcome. This inherited reaction
rule was preserved, not hidden by more reach/armour or described as a geometry
miss. Max Heat is a test precondition seeded through the existing Heat API.

captures/ contains32 original game-scale engine PNGs:12 matched fixture pairs
and8 live-input images. close-ups/ has12 paired native2x crops. All four normal
held-pose pairs were directly inspected in both directions here; max-Heat
samples are also retained. The yellow shape is the actual committed-query
overlay, not a drawing of an expected shape. Manual and ordinary evidence are
labeled separately. tested-fixture.gd is the exact used helper snapshot;
candidate-native.tres preserves the reviewed resource. Future helper changes
must not rewrite this evidence.

SHA256:

- Atlas:b04247fd0c27e030c8aa5485e2aa7f91579cfcf0d384e1daf7b15144dbc07e09
- Pristine X4:237a71023a86c6001dab73775be9f4620161566efd2250633caa9cc5a7450388
- Candidate X4:bfc1ee308ac202b4717b472c1306c3d961a9a557359e31c11d08159fd3cecbad
- Exact helper/point hashes are embedded in the reports.

Residual limits: bounded points/captures and this engine/hardware, not human
feel approval or overall game clearance. Existing high-Heat invincibility can
still suppress later combo damage. No build/export, commit, push, publication,
source-art rewrite or gameplay-rule change occurred.
