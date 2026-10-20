# Original Heroes III Pikeman audio — October 20, 2026

Extracted byte-for-byte from the user's installed Heroes III Complete Edition
`en/Data/Heroes3.snd`. See `manifest.json` for the source archive hash, offsets,
per-file hashes, format and duration. No external audio download was used.

The five roles match the Pikeman entry in the primary VCMI source:
https://github.com/vcmi/vcmi/blob/develop/config/creatures/castle.json

These are copyrighted original-game recordings, not CC0. Installation ownership
and extraction do not grant a redistribution license. Keep that provenance
distinct from Laema's CC0 audio subset; public/live publication needs a separate
rights decision. No source publication is performed by this extraction.

## Mapping handed to U

Scope is the original-Pikeman CombatEnemy used in Gym and Final Arena only.
Player and permanent practice-target sound assignments remain as they are.

| Original file | Duration | Laema playback assignment |
|---|---:|---|
| PIKEATTK.wav | 1.0420 s | Once when the Pikeman begins its committed thrust animation in `ai_begin_windup`; audible on attacks that miss too. Stop the attack cue when the action is cancelled. |
| PIKEWNCE.wav | 0.5340 s | Accepted nonzero hurt reaction in CombatEnemy `_on_reaction_started`; replace its inherited generic hit-reaction stream, without double playback. |
| PIKEKILL.wav | 0.9259 s | Once on the transition into DEAD; terminate movement/attack playback. Reset the once-only state on encounter reset. |
| PIKEMOVE.wav | 0.9563 s | Repeat while actually walking in APPROACH; stop on idle, windup, hurt, death, deactivation, reset and teardown. |
| PIKEDFND.wav | 1.4420 s | Reserved source reference. No current CombatEnemy defence action exists; do not attach it to invincibility, clash or ordinary hurt. |

All originals are mono 22,050 Hz, format tag 17 (IMA ADPCM). Preserve the original
WAV bytes here. U should decode selected runtime copies to PCM WAV for Godot,
verify sample rate/count and preserve full duration, then route them through the
existing SFX bus. Do not alter pitch, action duration, animation markers,
hitboxes, damage, Poise, Impact or reaction lifetime to fit the sounds.

Current attachment owners are `scripts/enemy/combat_enemy.gd` and its inherited
`scenes/enemy/combat_enemy.tscn`. Use the existing attack/state/reaction/death
boundaries. Avoid edits to shared Player/practice-target sound behavior.

The concurrent active-window melee design in `docs/TECH_ARCHITECTURE.md` is under
review and its implementation handoff is held. This audio handoff does not
authorize that migration or depend on the legacy contact marker.

Validation performed: archive bounds/signatures, RIFF headers, original-file
identity and source role mapping. No playback, Godot, build or runtime validation
is claimed. User audition must confirm cue timing, movement repetition, overlap,
cancellation and SFX volume/mute behavior.
