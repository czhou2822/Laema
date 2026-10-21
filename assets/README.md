# Assets

Fire Player X1/X4/X5 use transparent overnight R05/R02/R04 derivatives under
`prototype/player/fire_sword_shield_v01/overnight_v04/`: eight, three and seven
448px atlas cells. X4 holds three poses across six existing keys; X5 selects
study poses 1/2/3/4/6/7/9. X2/X3 retain v03. The new manifest/provenance records
hashes, registration and phase mapping. All prior PNGs and active Idle/Walk/Hurt/
Cast remain. Timing/hitboxes are preserved; engine/runtime validation is pending.

Fire defence uses the accepted Shield Catch v03 transparent atlas in
`prototype/player/fire_sword_shield_v01/shield_catch/`. Player's existing sprite
cadence raises into a held guard; only a successful Fire parry shows the spark.
Ordinary block and miss/release skip it. Cosmetic recovery yields to movement,
attacks and Hurt without adding a gameplay lock. The adjacent provenance records
source identity, frame mapping and pending user validation. The earlier concurrent
`defence_v03/` candidate remains preserved; this is the current active binding.

CombatEnemy now uses the original Heroes III Castle Pikeman's idle, walk, front
attack, hurt, and death sheets from the local extraction. See
[Pikeman provenance](prototype/enemy/pikeman/PROVENANCE.md) for source hashes,
group mapping, shared alignment, and prototype-use limits. Practice dummies
retain their artwork; the former medieval fighter sheets remain available.

CombatEnemy's original-game audio is in `prototype/audio/enemy/pikeman/`:
PIKEATTK (committed thrust start), PIKEWNCE (accepted hurt), PIKEKILL (death),
and PIKEMOVE (actual approach movement). These are mono 22,050 Hz PCM16 runtime
decodes of the untouched IMA ADPCM originals in
`docs/art/references/heroes3-original-audio/pikeman/`. The source manifest records
archive offsets/hashes; the runtime `manifest.json` records decoded sample counts,
durations and hashes. RIFF `fact` counts define duration; codec block padding is
excluded. PIKEDFND remains reserved, with no runtime defence mapping.

These Heroes III recordings are copyrighted original-game audio, **not CC0**.
No redistribution license has been established. This local implementation does
not authorize committing/pushing these assets or publishing them in a live build.
Non-Heroes SFX were removed at the user's request on October 20. The accepted
original-game Player and practice-target replacements are now wired through
their existing triggers. See [runtime SFX provenance](prototype/audio/ORIGINAL_HEROES_SFX.md)
and `prototype/audio/heroes3-replacements.json` for mappings, hashes, conversion,
and the single-note Charging FIFO. Source originals/fallbacks remain under
`docs/art/references/heroes3-original-audio/replacements/`. Projectile travel and
impact remain silent. Wind ambience and Fairy Battles BGM remain outside this pass.

`prototype/` contains the user-approved Craftpix prototype subset:

- Pack 6 shared Idle and Walk sheets, plus Pack 2's shared Casting Spell sheet, are the active player locomotion and cast presentation.
- Twenty 128×128 X sheets are active by school: Pack 2 Fire, Pack 6 Water, Pack 3 Air, and Pack 5 Earth. They supply X1–X5 for the current five-position chain.
- Air X5 now uses Pack 3 `Weapon_Summon.png`: eleven full-body 128×128 frames (1408×128), copied byte-for-byte to `prototype/player/animation/air_x5.png`. Its stable import UID/path is retained. The retired eight-frame `Weapon_1.png` effect, pre-change native Animation and source hashes are preserved in [Air X5 history](../docs/history/2026-10-20-air-x5-weapon-summon/README.md).
- Shinobi, Swordsman, Fighter, Saber, and Samurai sheets remain legacy prototype imports.
- `ground_grasss.png` from the membership Grassland archive.
- Fire, Water, and Ice frame sequences from the membership Fantasy Platformer bundle.

The user confirmed membership entitlement for the premium archives. Craftpix source redistribution remains prohibited; do not publish or redistribute the source asset files outside the licensed project context.

The former CC0 combat, casting, projectile, guard-warning and generic hurt SFX
have been removed from the runtime asset tree. Their licensing/source history
remains historical; none should be relabeled as original Heroes III audio.
`audio/ambience/wind.ogg` and `audio/music/fairy_battles.ogg` remain temporary
non-Heroes ambience and BGM, respectively, outside the requested SFX-only removal.

The active presentation is a generic side-view prototype shell, not final Laema art. It shares Pack 6 locomotion, mirrors left-facing presentation, uses the approved school/position X table, and uses the shared cast sheet for the current Cast action. Final art remains deferred.
