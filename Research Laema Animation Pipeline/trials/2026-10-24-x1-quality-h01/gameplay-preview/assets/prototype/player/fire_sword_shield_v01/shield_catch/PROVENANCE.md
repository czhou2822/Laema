# Fire Shield Catch — parry-only spark binding, October 21

Status: `AWAITING_USER_VALIDATION`. The user approved prototype integration of
the refined Shield Catch v03 atlas, then explicitly selected a held guard pose
for blocking, no spark on misses, and a spark only on successful parry. This is
not final-art acceptance or Godot/runtime evidence.

Source from repository root:
`docs/art/explorations/2026-10-21-fire-shield-catch-refined-v03/shield-catch-8x448.png`.
The source README, metadata, prompts and raw sheet retain Art's provenance.
The installed `shield-catch-8x448.png` is copied byte-for-byte, SHA-256
`59a118996c31e83633291876951e5b6601d793f0dee33ed829e2842feda60333`.
It is a 3584×448 RGBA atlas: eight 448px cells, seven unique poses, with the
opening pose repeated at the end. No image generation, repainting or crop was
performed during this binding.

## Runtime mapping

Player's existing presentation owner selects cells using its existing 10fps
WALK_FPS cadence. Frame numbers here are one-based:

- Frames 1–4 raise into frame 4, held while the Fire controller reports holding
  or an active tap parry. A blocked hit keeps this guard pose without a spark.
- Only a delivered Fire PARRIED HealthResult starts frames 5–8. Frame 5 contains
  the baked orange spark. BLOCKED, a miss, rear hits and DoT never start it.
- Release/missed-parry recovery uses frames 6–8, skipping frame 5 completely.
- Movement after control returns, new attacks/Casts and Hurt interrupt cosmetic
  recovery. School changes, stage lock, death, new attempts and Retry clear it.

These visual clocks neither advance nor modify the defence controller. Existing
press/tap/control/reuse windows, damage absorption, rearm, input and immediate
success control return remain authoritative. The Art GIF's viewing pauses are
not engine timing. The read-only defence snapshot was added by the preceding
concurrent integration and is reused without controller changes here.

The atlas stays under the recognized Fire prefix and uses the existing 448px
cell, foot anchor(224,400), offset, scale, facing and body profile. Actual nonzero
alpha reaches source y403–404; the accepted source pixels and registration are
preserved rather than re-aligned. Fine generated equipment/face/garment continuity
and feet stability remain for user inspection.

The earlier concurrent `defence_v03/` copy and its records remain untouched as
the initial candidate. Its block-spark and captured-window playback descriptions
are superseded by this user-approved binding and the current canonical records.
The active Player preload points to this folder. Native attack resources,
including overnight_v04 X1/X4/X5 and current X2/X3, remain unchanged.

## Evidence and user validation

Source/image inspection verifies PNG mode/dimensions/alpha, source-copy identity,
eight cell bounds, matching first/last pixels and the selected frame routing.
No Godot parser/compiler/import/editor/runtime, build or automated tests ran.
No tests were added, and no commit, push or live publication occurred.

In Godot check held block, tap miss, successful parry, immediate movement/attack
after success, Hurt, school switches and Retry in both facings. Confirm sparks
appear only on successful parry, feet remain stable, and existing attacks, Cast,
Idle/Walk/Hurt and Water defence retain their behavior.
