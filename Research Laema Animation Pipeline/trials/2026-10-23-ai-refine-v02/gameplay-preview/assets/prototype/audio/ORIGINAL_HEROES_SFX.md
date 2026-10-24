# Accepted original Heroes III SFX replacements — October 20

These 12 runtime WAVs implement the accepted mapping in
`docs/art/references/heroes3-original-audio/replacements/README.md`.
`heroes3-replacements.json` records each prepared source, original/PCM hashes,
decoded frame count, conversion, and event owner. Originals and fallback choices
remain in that source package. Runtime files are byte-identical prepared PCM
copies; import settings add no trim, normalization, loop, resampling, or codec
compression. Godot's imported sample caches are generated on ordinary import.

The recordings are copyrighted original Heroes III audio, **not CC0**. The
PICKUP03 excerpt retains that provenance. No redistribution permission has been
established. This implementation does not commit, push, or publish live assets.

## Active assignments

| Event | Runtime WAV under this directory | Owner / existing trigger |
|---|---|---|
| Common Player X | combat/SWRDATTK.wav | Player AttackSwingAudio, animation start, including misses |
| Player hurt | hit_reaction/SWRDWNCE.wav | Player HitReactionAudio, accepted nonzero reaction |
| Stationary-target response | hit_reaction/SWRDDFND.wav | Base Enemy HitReactionAudio, existing nonzero reaction |
| Fire Cast | casting/SPONTCOMB.wav | Player CastAudio, launch |
| Water Cast | casting/ICERAY.wav | Player CastAudio, launch |
| Air Cast | casting/LIGHTBLT.wav | Player CastAudio, launch |
| Earth Cast | casting/METEOR.wav | Player CastAudio, launch |
| Empowered feedback | casting/BLESS.wav | Player EmpoweredCastAudio, existing empowered event |
| Cast failure | casting/DISPELL.wav | Player CastFailAudio, existing failure event |
| Generated orb | casting/PICKUP04.wav | Player OrbAudio, visible queue size increase |
| Guard near break | guard/PROTECT.wav | Player GuardWarningAudio, existing warning signal |
| Newly charged orb | casting/charging_note_pickup03.wav | Player MarkAudio, visible charged-count increase |

All players use `SFX`, routed to `Master` through the existing bus layout and
mute/volume controls. Ambient/BGM are untouched. CombatEnemy retains PIKEATTK,
PIKEWNCE, PIKEKILL and PIKEMOVE; its inherited hurt override prevents the base
target's SWRDDFND cue from replacing its voice. School-specific melee layers,
projectile flight, and projectile impact remain silent. A mixed Cast plays only
the existing primary-school launch cue; no compound-harmony schedule is added.
DISPELL/PROTECT are the primary choices; MAGICRES/SHIELD remain source-package
fallbacks, not automatic substitutions. No full spell is replayed at impact.

## Charging: actual producer-to-player path

`MagicComponent._advance_marking()` increases capacity, including multiple steps
in one update. `get_snapshot()` limits the marked prefix to generated queue
entries. `queue_changed` passes through Combat and Player's existing signal
connection to `_on_orb_queue_changed()`. Player counts visible `marked` flags,
not banked capacity, and appends every newly reached count to
`_pending_mark_audio_levels`. `_drain_mark_audio_queue()` pops the oldest level;
`_play_mark_audio()` loads the single derived note, assigns its count-indexed
pitch and fixed 0 dB gain, and `_play_audio()` sets MarkAudio.stream and plays it.
MarkAudio is one SFX voice with max_polyphony 1. Its one connected `finished`
callback releases the draining flag and starts the next FIFO note.

| Charged count | Relative pitch |
|---:|---:|
| 1 / Do | 1 |
| 2 / Re | 9/8 |
| 3 / Mi | 5/4 |
| 4 / Fa | 4/3 |
| 5 / Sol | 3/2 |
| 6 / La | 5/3 |
| 7 / Ti | 15/8 |
| 8 / high Do | 2 |

The base is exactly 3,969 PCM16 mono frames at 22,050 Hz (0.18 s), derived
from PICKUP03 with the source package's 44-frame fade-in and 441-frame fade-out.
The preview melody is never copied into runtime assets or loaded by Player.
There is no Heat multiplier on note pitch, no fixed 0.3-second runtime spacing,
and no added gameplay timer. The final/base pitch ratio is exactly one octave.

Source-level examples: `0 -> 3` appends `[1,2,3]`; another snapshot at `3`
appends nothing; `3 -> 5` appends `[4,5]` behind unfinished notes. Banked charging
with no generated orbs appends nothing. A count decrease stops and clears old
notes; subsequent increases use the new visible count rather than replaying the
old prefix. Configure/reset, failed Cast, hit reaction, stage-input lock/death,
and teardown also clear presentation. Snapshots during stage lock/death cannot
enqueue. A missing note stream clears the draining state instead of waiting
forever for a `finished` signal from a voice that never started.

While charging notes drain, CastAudio, EmpoweredCastAudio, and OrbAudio are
temporarily reduced by 12 dB from their captured gains so earlier tails remain
behind the scale. Queue completion, cancellation, and load failure restore those
exact captured values. The note itself always stays at the same 0 dB gain.
No other bus or player is ducked. Actual perceived balance still needs audition.

## Validation boundary

Only source trace, WAV metadata/hash checks, resource-path/import inspection,
and whitespace checks were performed. No sound was played, and no Godot/editor,
build, runtime, or automated test was run or created. The source package's
measured onset peaks are reference evidence, not proof of perceived in-game pitch.

User listening should cover the eight-note ascent, batched/rapid charging,
unchanged-count snapshots, depletion/recharge, generation into banked capacity,
Cast consumption, failed Cast, incoming hurt, death, retry/stage change and pause;
confirm no stale notes, no duplicate spell at impact, and restored background
gains. Check every mapped event plus SFX mute/volume with Ambient/BGM unchanged.
