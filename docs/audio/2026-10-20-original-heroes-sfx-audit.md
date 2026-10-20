# Original Heroes III SFX audit — October 20, 2026

## Subsequent accepted implementation

The user accepted the source mapping prepared in `replacements/README.md` under
`docs/art/references/heroes3-original-audio/`, then redirected implementation
from U to DUM-E. Runtime assignments now follow that handoff, including the
single derived PICKUP03 note through Player's eight-ratio Charging FIFO.
`assets/prototype/audio/ORIGINAL_HEROES_SFX.md` and `heroes3-replacements.json`
record the current mapping and conversion evidence. MAGICRES/SHIELD remain
fallbacks; projectile flight/impact and compound-harmony timing remain unselected.
The findings/proposals below retain the preceding audit history. No listening
or Godot runtime acceptance is established by the replacement implementation.

## Request and scope

User direction: audit existing game SFX, remove every SFX that is not from the
original Heroes III, and propose replacements. Scope is the editable runtime
game; Ambient and BGM remain separate categories. Generated live builds are
historical snapshots and have not been republished.

## Findings and completed removal

42 non-original SFX were present, plus their 42 Godot import sidecars:

| Category | Files removed | Runtime owner |
|---|---:|---|
| Common swings and four school X1–X5 layers | 23 | Player |
| Four school Cast cues, empowered, failure, orb creation, old beep and scale pluck | 9 | Player |
| Four projectile travel and four impact cues | 8 | SpellProjectile / PrototypeArena |
| Guard-warning cue | 1 | Player |
| Generic punch/hurt cue | 1 | Player / base Enemy |

The old beep was unused; the remaining files had runtime bindings. The exact
path/size/SHA-256 inventory is in `2026-10-20-removed-sfx.json` beside this report.
A recovery ZIP, including import sidecars, was made outside the repository at
`C:\Users\zhouc\.codex\visualizations\2026\08\23\01a02e1a-babc-7200-991f-d48f8f4bf4f2\non-heroes-sfx-before-removal-2026-10-20.zip`.
Historical tracked copies also remain recoverable through Git.

Player school/attack/Cast/orb and projectile source-path entries are deliberately
empty until replacements are selected. Empty paths return null before loading.
Guard-warning and generic hit-reaction scene streams have been cleared; their
handlers tolerate an unassigned stream. No charged-note FIFO entries are queued
while its source is empty. The eight pitch ratios and local routing nodes remain
available for a later original-game cue. All removed categories are currently
silent. No substitute has been silently approved or installed.

## Retained original SFX

CombatEnemy already uses original Pikeman PIKEATTK, PIKEWNCE, PIKEKILL and
PIKEMOVE in `assets/prototype/audio/enemy/pikeman/`. The inherited hurt stream is
overridden only for that character. Attack/hurt/death/walking lifecycle and SFX
routing are preserved. Their PCM file hashes are checked against their existing
runtime manifest. PIKEDFND stays reserved because CombatEnemy has no defence
action.

## Original-game replacement proposals

These are presentation assignments only. Source existence and RIFF metadata were
verified in the user's installed `en/Data/Heroes3.snd`; these are not audition
judgments or new spell-behavior contracts.

| Gap | Proposed original source | Intended use / qualification |
|---|---|---|
| Player melee swing | SWRDATTK.wav (0.335 s) | One common Swordsman attack cue per accepted X animation. Restore identity first; do not duplicate a whole spell sound on each X merely to recolor it. |
| Player hurt | SWRDWNCE.wav (0.487 s) | One Swordsman wince on accepted nonzero reaction; retain separate failure feedback. |
| Practice-target hurt | SWRDDFND.wav (0.773 s) | Candidate metallic contact response; audition against the target's material before selecting. Avoid Pikeman vocals on inanimate targets. |
| Generic Cast launch | MAGICBLT.wav (0.882 s) | Magic Arrow provides one original-game launch sound. An alternative to four school cues, not another layer to stack automatically. |
| Fire Cast / impact | FIREBLST.wav or SPONTCOMB.wav | Original Inferno / Fireball families. Select one launch or impact placement after audition; do not play the same full cue twice per Cast. |
| Water Cast / impact | ICERAY.wav (1.395 s) | Original Ice Bolt family. Sound assignment does not enable deferred freezing or other spell mechanics. |
| Air Cast / impact | LIGHTBLT.wav (1.246 s) | Original Lightning Bolt family; avoid confusing a travel loop with repeated strikes. |
| Earth Cast / impact | METEOR.wav (1.683 s) | Original Meteor Shower family, as audio identity only. |
| Empowered Cast | BLESS.wav (1.920 s) | Optional restrained accent; audition its full envelope before layering under a spell. |
| Failed Cast | DISPELL.wav (1.405 s) or MAGICRES.wav (1.837 s) | Original cancellation/resistance sound family. Candidate only; the longer envelopes may be too busy for frequent failures. |
| Generated orb | PICKUP04.wav (0.563 s) | Shortest inspected pickup candidate; may need a non-destructive onset trim after audition. |
| Eight charged notes | A stable pitched segment from PICKUP01–PICKUP07 | Preserve the accepted Do–Re–Mi–Fa–Sol–La–Ti–Do ratios and fixed gain. No candidate is confirmed tonal enough: inspect/audition first. If none supports a clean octave, leave this open rather than label a noisy pitch ramp as a scale. |
| Guard near break | PROTECT.wav (1.039 s) or SHIELD.wav (1.498 s) | Audition for warning readability; neither file's original identity proves urgency. |
| Projectile flight | No continuous loop selected | Prefer a single original launch sound and distinct impact where appropriate. A sustained flight bed remains open. |
| Compound-Cast harmony | No replacement selected | Release-only versus flight-long harmony is still an unresolved design choice; no implementation is authorized by this audit. |

Original spell-role mapping reference:
https://github.com/vcmi/vcmi/blob/develop/config/spells/offensive.json
The Fireball mapping there is SPONTCOMB, not a guess based on the file FIREBALL.
Creature-role reference:
https://github.com/vcmi/vcmi/blob/develop/config/creatures/castle.json

The source archive contains 1,115 entries. All measured candidates are mono
22,050 Hz IMA ADPCM WAV. Preserve original bytes and archive offsets; make PCM
runtime decodes only after selecting replacements. Match RIFF fact sample counts
and avoid decoder block padding, as already done for Pikeman.

## Remaining non-Heroes audio outside this SFX pass

`assets/prototype/audio/ambience/wind.ogg` and
`assets/prototype/audio/music/fairy_battles.ogg` remain non-original Ambient/BGM.
They are not included in an assertion that the entire game's audio is now Heroes
III. Category buses and volume/mute controls stay in place. The external candidate
library and original archives were not altered.

## Validation and rights

Removal verification is source/static only: inventory, recoverable backup,
resource references and preserved Pikeman identities. No game, editor, build,
playback or automated test was run for this audit. Gameplay state, timers,
animation markers, damage, reactions and hit accounting are not changed.

Original Heroes III recordings remain copyrighted; extraction from the user's
installation does not create a CC0 or redistribution license. This pass does not
commit/push or publish live. Existing live artifacts are not evidence that these
edits have been exported or played.

