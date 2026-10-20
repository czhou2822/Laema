# Research evidence

Roster names/levels/schools come from the installed Complete Edition's `en/Data/H3bitmap.lod` → `SPTRAITS.TXT`, read in memory without modifying the installation. Only the compact roster and its source hash are retained in catalogue.json; the descriptions/stat tables are not copied here.

The `vcmi-*.jsonc` files are research snapshots from the VCMI project's public configuration, fetched20 October2026:

- https://github.com/vcmi/vcmi/tree/develop/config/spells — adventure/offensive/other/timed mappings.
- https://github.com/vcmi/vcmi/blob/develop/config/battleEffects.json — procedural material/filter context.
- https://github.com/vcmi/vcmi/blob/1.1.0/config/spells/timed.json — legacy mapping candidates, not substituted silently for current mapping. Its Bloodlust SP12_ entry is marked uncertain in upstream comments.

These files retain their upstream authorship/licensing; see https://github.com/vcmi/vcmi . They are not used as Laema gameplay code. File hashes are recorded in catalogue metadata. Their spell animation references do not establish original game frame timing. Original extracted artwork and per-resource metadata remain the visual evidence.
