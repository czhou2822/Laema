# Original Heroes III replacements — implementation handoff, October 20

User accepted the October 20 SFX replacement proposal and explicitly requested
original replacements be obtained and handed to U to implement. Charging must
clearly sound like Do–Re–Mi–Fa–Sol–La–Ti–Do, not a noisy ascending effect.

## Prepared assets, not active runtime assignments

21 byte-original WAVs were extracted from the user's installed English Complete
Edition `Heroes3.snd`; `manifest.json` records archive hash, offsets, hashes,
format, duration and decoded frame counts. `pcm/` contains corresponding mono
22,050 Hz PCM16 decodes, trimmed only to the original RIFF fact frame count to
remove decoder block padding. Originals are unchanged. Decoder: libsndfile 1.2.2.
The user's installation and external CC0 library were not modified.

All are copyrighted original Heroes III recordings, NOT CC0. Original-derived
edited samples retain that provenance. No redistribution license is established.
No commit, push or live publication is authorized by this handoff.

## Accepted mapping and implementation scope

| Existing event | Prepared source / instruction |
|---|---|
| Player common melee | `pcm/SWRDATTK.wav`: once per existing attack animation start, including misses. No duplicate school spell layer on each X. |
| Player accepted nonzero hurt reaction | `pcm/SWRDWNCE.wav`, retaining separate failure feedback. |
| Practice-target reaction | `pcm/SWRDDFND.wav`, metallic contact candidate. Do not put Pikeman vocals on a stationary target. Audition material fit. |
| Fire / Water / Air / Earth Cast | `pcm/SPONTCOMB.wav` / `pcm/ICERAY.wav` / `pcm/LIGHTBLT.wav` / `pcm/METEOR.wav`: use one school cue on existing launch feedback, not the entire cue again at impact. Original source identity does not enable corresponding Heroes spell mechanics. |
| Empowered Cast | `pcm/BLESS.wav`, candidate at the existing empowered feedback event; audition gain/overlap. |
| Failed Cast | `pcm/DISPELL.wav`; `pcm/MAGICRES.wav` available as the accepted fallback. |
| Generated orb | `pcm/PICKUP04.wav` at existing generation event. |
| Guard near break | `pcm/PROTECT.wav`; `pcm/SHIELD.wav` available as fallback. Preserve existing trigger/cadence. Audition urgency/readability. |
| Charged orb | `derived/charging_note_pickup03.wav` through the existing eight pitch ratios and fixed gain; detailed requirements below. |

`FIREBLST` is the alternate Inferno family; `MAGICBLT` is the generic Cast
alternative, not an automatic extra layer. Remaining pickup files are references
if the derived note fails audition. Preserve four existing original Pikeman
assignments, SFX routing and volume/mute controls. Ambient/BGM remain outside scope.
Continuous projectile flight and distinct impact sources remain unselected;
leave those bindings silent rather than looping or duplicating whole spell cues.
Compound-Cast harmony timing is still Open: do not invent a timing contract here.

Existing owners: `scripts/player/player.gd`, `scenes/player/player.tscn`,
`scenes/enemy/enemy.tscn`; retain CombatEnemy's inherited PIKEWNCE override.
Projectile/Arena empty mappings need no change unless selected sources require it.
Place selected runtime copies under the established `assets/prototype/audio/`
structure, retaining provenance and conversion manifests. Do not change combat,
animation markers, damage, reactions, orb rules or action duration to fit audio.
The unrelated active-window migration remains held under its current design gate.

## Charging acceptance requirement

`PICKUP03` is a better tonal candidate than simply replaying the multi-pitched
pickup cues. The prepared base contains its first 3,969 decoded frames (0.18 s),
with a 44-frame fade-in and 441-frame fade-out. No oscillator, synthetic timbre,
normalization, filtering or gain boost was introduced. Exact processing and hashes
are in `derived/manifest.json`.

Keep the accepted ratios `1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2`, corresponding to
Do, Re, Mi, Fa, Sol, La, Ti, high Do. These are the existing just-intonation major
scale, not eight evenly spaced pitches. Do is relative to the sample's base pitch;
no absolute C requirement was supplied. First/last must be an exact octave.
Measured dominant onset peaks in the reference rendering are approximately
587, 660, 734, 783, 880, 978, 1100 and 1174 Hz. This supports pitch ordering and
octave consistency but does not prove perceived pitch or runtime playback.

`derived/charging_scale_preview.wav` renders the same base at those eight ratios,
one onset every 0.3 s, for a listening reference ONLY. It is not a runtime cue and
does not authorize changing Charging timing. Runtime uses one note per existing
newly charged orb, preserves FIFO order, count-to-note indexing, cancellation and
reset behavior, and fixed per-note gain. Do not play all eight notes per orb or
pitch-shift a pre-rendered eight-note melody. Do not allow earlier long spell
tails or note ordering to hide the scale; resolve audio overlap without changing
gameplay timing. If the timbre still sounds ambiguous, report it rather than
claiming an unconfirmed scale.

## Handoff evidence and remaining validation

Source/PCM hashes, archive bounds, RIFF metadata, durations and spectral inspection
only. No listening, engine, editor, automated test, build or runtime validation
was run. U must retain this distinction and hand user validation back for all
eight notes, rapid Charging, reset/cancel, duplicate Cast playback, cue overlap
and SFX volume/mute. No extra validation authority is implied by this handoff.
Synchronize the accepted selection/current implementation state in GDD, TDR and
implementation status through their normal scoped workflow; older top amendments
still describe removal pending replacement, not completed replacement playback.

Preserve all concurrent dirty work. The user authorized this implementation
handoff, not unrelated combat changes or Git publication. Use the current DUM-E
exact-file scope workflow without repeating already accepted source decisions.
