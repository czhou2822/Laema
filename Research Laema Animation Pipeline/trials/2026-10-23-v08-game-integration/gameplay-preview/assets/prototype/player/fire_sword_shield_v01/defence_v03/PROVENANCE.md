# Fire Shield Catch v03 runtime presentation

The user requested binding the artwork to the existing defend feature on
2026-10-21. This is the accepted refinement from
`docs/art/explorations/2026-10-21-fire-shield-catch-refined-v03`, copied without pixel changes as `shield_catch.png`.
SHA-256: `59a118996c31e83633291876951e5b6601d793f0dee33ed829e2842feda60333`.

Eight 448px RGBA cells, seven unique drawn poses and an exact repeated opening
endpoint. Foot anchor(224,400), existing Fire offset(0,-124), root2/Sprite0.5,
body profile, material/filter and runtime horizontal facing are retained.

Player presentation reads captured state through DefenceController's new
read-only snapshot. Frames0..3 raise/hold; frame4 contains the contact spark and
is used only after a confirmed Fire PARRIED/BLOCKED HealthResult. Frames5..7
release/recover. A missed tap uses the existing remaining control commitment;
parry success/release contact playback uses one captured early-window duration
without adding any gameplay lock. The source GIF's review cadence is not used.

Attack/hurt interrupts immediately. New attempts, school changes, stage lock,
death and retry clear old presentation. Held block returns to guard after a
contact. Existing defence mechanics and numerical settings remain untouched;
Water/other schools and all attack resources/artwork remain unchanged.

Status: `AWAITING_USER_VALIDATION`. Only source/image inspection and scoped
whitespace checks were performed. No engine import, editor, runtime, build or
tests were run. Check tap miss, hold, front parry/block, rear hit, immediate
attack after success, school switch, interruption and retry in both facings.
Generated fine-detail continuity remains provisional. No commit/push/publication.
