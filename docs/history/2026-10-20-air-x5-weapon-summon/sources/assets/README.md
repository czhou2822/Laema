# Assets

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
