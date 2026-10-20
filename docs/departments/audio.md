# Audio

Persistent department context, reconciled 2026-10-20. Tasks belong to this department without becoming its identity.

## Decisions and carried context

- Audio supports the fight; background music is not an external timing rail and does not change input, animation or gameplay rules.
- Preserve source/license provenance and distinguish external audition candidates from curated project imports. Historical library counts and local library locations are not a fresh inventory or an automatic import list.
- The approved prototype audio pass covered school attacks/common swings, orb generation/Charging, normal/empowered/failed Casts, projectile travel/impact, wind ambience and provisional Fairy Battles music.
- **Accepted historical handoff:** a shared Kenney Impact Sounds `impactPunch_medium_002.ogg` cue for nonzero Player, practice-target and Final Enemy hit reactions, routed through SFX with provenance. Source presence is not an audible mix check.
- The user rejected a linear pitch ramp and required a recognisable discrete Do–Re–Mi–Fa–Sol charging scale. The later accepted target extends it to eight notes, Do–Re–Mi–Fa–Sol–La–Ti–Do, with fixed cue volume.
- **Proposal:** In compound Casting, the primary spell is the melodic cue and the free secondary spell harmonises rather than competes with it. **Open:** release-only harmony versus harmony continuing through projectile flight. No accepted harmony timing or implementation is established.

## Current source and provenance

- Ambient, SFX and BGM buses route to Master; persisted Portal controls provide category enable/volume. Wind and Fairy Battles remain temporary prototype selections, not final mix/music approval.
- Player owns attack/Cast/orb/guard feedback; projectile and arena paths own travel, impact and world beds. Player and Enemy scene/handler paths provide hit-reaction audio. These are source observations, not playback proof.
- `guard_warning.ogg` is documented as Kenney Interface Sounds `error_008.ogg` (CC0); `mark_orb_scale.ogg` as Kenney `pluck_001.ogg` (CC0); the hit-reaction cue as Kenney Impact Sounds (CC0). Original archives/licenses remain external; Craftpix entitlement is separate and does not permit unrestricted source redistribution.
- **Reconciled:** The old five-versus-eight configuration/pitch-table mismatch is historical. At inspected committed revision `056a4a6`, Player settings use capacity eight, the loader enforces eight with ten storage slots, and Player has eight ratios: `1, 9/8, 5/4, 4/3, 3/2, 5/3, 15/8, 2`.
- Player queues crossed charge levels for sequential playback and clears pending cues on reset/teardown. The active stream remains `mark_orb_scale.ogg`; the asset README's five-note description is stale relative to the source/GDD. This reconciliation does not edit that README.
- The compound-harmony proposal is not made implemented by existing primary-school Cast cues or generic audio assets.

## Unfinished evaluation and validation

- Historical static analysis described the active scale cue as a short bright approximately 102 ms pluck; at double pitch it would be approximately 51 ms. The older `mark_orb.ogg` was a longer/lower audition candidate. Those are dated analysis reports, not a fresh measurement or human listening judgment.
- Whether the upper octave reads clearly, overlap/mix balance, guard-warning audibility under ordinary combat, pause/control behavior and cue-level current-runtime acceptance remain unestablished here.
- The earlier user complaint that the scale did not sound like Do–Re–Mi–Fa–Sol is retained as feedback, not erased by finding the corrected ratios.
- Existing dated engine-check reports are separate from an audible audition or mix approval. This reconciliation ran no engine, build, compiler, test, playback or mix check.

## Resume point

Remain dormant until explicitly resumed. First settle compound-harmony timing and the intended audible relationship; for a charging-cue request, audition the current eight-note source before replacing it. Preserve buses, provenance and gameplay boundaries; do not repeat a superseded five-capacity fix or import the whole external library.

## Sources and coverage

- [Audio design](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/docs/GAME_DESIGN.md), [Player cue implementation](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/scripts/player/player.gd), [Player settings](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/config/characters/player.tres), [loader invariant](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/scripts/config/prototype_config_loader.gd), [bus layout](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/config/prototype_audio_bus_layout.tres), [Enemy feedback](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/scripts/enemy/enemy.gd) and [asset provenance](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/assets/README.md).
- Source task: `audio`; local title **Audio**, thread `01a02e1a-babc-7200-991f-d48f8f4bf4f2`. All 27 host-returned turns read through the end of available history on 2026-10-20; latest completed round `01a085ff-334e-7892-8adc-d92a00e0858b`.
- [Saved task note](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/docs/checkpoints/2026-10-16-complete-thread-audit/audio.md) and [binding history](https://github.com/czhou2822/Laema/blob/056a4a6a5aa1ba8c66e8bdbe327bbcaa7b8247e5/docs/checkpoints/2026-10-16-complete-thread-audit/manifest.json). Earlier seed: six turns read on 2026-10-12 from other-machine binding `01a07f73-b9b0-75e1-bc7d-6d91e6d5270b`; that dialogue is carried through saved summaries, not claimed re-read.
- Library procurement/provenance above is carried historical development context. No external candidate library was reopened or redistributed.
- The user directed reconciliation and retirement of this source chat on 2026-10-20. Independent task identity, binding history and unresolved audio choices remain preserved.

## Mirrors

- [GitHub Markdown](https://github.com/czhou2822/Laema/blob/main/docs/departments/audio.md)
- [Space counterpart](https://chatgpt.com/space/page_421edb14b2cc8191a9b78dcd2dd1c064)
