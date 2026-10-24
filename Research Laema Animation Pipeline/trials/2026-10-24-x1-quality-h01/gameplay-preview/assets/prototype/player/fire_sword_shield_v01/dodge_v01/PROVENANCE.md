# Approved Fire dodge art — first-slice binding

The human approved this Fire sword-and-shield art for prototype integration and
handoff to U. Source: Art task `01a07f41-7159-70f1-ac7d-e6217941c130`, package
`laema-fire-dodge-v01`. Its README/metadata earlier proposal/awaiting-review labels
predate that approval. This staging does not request duplicate art approval or
claim final production, continuous playback or runtime acceptance.

Four PNGs are byte-identical copies of the selected source atlases. Exact hashes,
frame orders and facing roles are in asset-manifest.json. Each is1792×1344 RGBA:
four columns × three rows of448×448 cells, nominal foot anchor(224,400), about180px
standing body. There is no baked root travel. Do not independently enlarge tucked
or inverted poses. Running exit has10 frames and two transparent padding cells;
idle exit has12 frames. The running exit is an art alternative, not an approved
new state-machine branch. Original sheets plus existing Sprite.flip_h are the
natural current facing path; pre-mirrors are alternatives, never double-flipped.

Art retains13 selected source positions and26 individual source/mirror PNGs.
Positions0 and11 reuse the same existing Fire idle frame. Other poses are selected
from the generated sheet and the corrected folded-knees inversion; rejected/raw
generations and the unused calibration pose are not runtime candidates. Source
README.md, metadata.json, qa-report.json, generation-provenance.json and
source-references.json retain identity, prompts, generation ancestry and research.
No original Dead Cells artwork is copied into these assets.

Art reports26 PNG checks,13 exact mirrors,44 atlas-cell matches, exact existing
idle endpoints and six decoded GIFs. U inspected the stepwise contact sheet and
checked copy hashes, PNG headers and metadata. Those are asset/source checks, not
Godot execution or continuous-motion validation. GIF70/100ms positions and280ms
endpoint holds are review aids, not gameplay duration or cancel windows.

The human-approved first-slice contract is now recorded in GAME_DESIGN.md, and
the user approved its wording and the bounded implementation plan. The TDR owns
the selected technical representation. `config/attack_animations/fire_dodge.tres`
binds the original12-frame idle-exit atlas on the existing Player AnimationPlayer:
four-column region keys, fixed0.4-second whole animation, Sprite.flip_h only.
Might owns state/cooldown; Movement alone moves the body. The runtime does not use
the pre-mirrors or optional running exit. Normal locomotion resumes through the
existing path; no additional idle/run state branch is inferred from the artwork.

Circle starts the available Fire-only dodge. The approved whole-animation
invincibility, locked direction, normal-speed travel, enemy-body pass-through,
wall behavior,0.37-second post-dodge cooldown and X/Charging/Cast cancellation
boundaries come from the accepted contract, not the GIFs or Dead Cells timing.
Current attack clips, other schools, body/hitbox profiles and audio are preserved.
The manifest distinguishes this source binding from still-missing engine/runtime
validation; it is not a claim that the animation has been played successfully.

Minor face/hair/cloth/prop variation, ground contact and center-of-mass continuity
remain Art review limits. Existing idle's ornate sword versus the diagnostic
attack blade is retained reference history, not a newly chosen weapon design.
No Godot/import/editor/build/test/runtime, commit, push or publication was run.
