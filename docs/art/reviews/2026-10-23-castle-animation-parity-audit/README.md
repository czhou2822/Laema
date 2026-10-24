# Castle creatures — original HoMM3 animation and remaster parity audit

**Later generation:** [All 225 Castle group counterparts, actual-enemy integration and validation](../../remasters/castle-v01/README.md).
The user subsequently authorized drawing missing high-resolution artwork from OG
flipbooks. This audit remains the earlier inventory snapshot.

**Subsequent work:** [Phase 2 specification research and Phase 5 playback repair](phase-2-and-5-progress.md).
This audit and its CSV/JSON retain the pre-repair snapshot; the follow-up records
new evidence, the Hurt reclassification and the actual live-resource correction.

**Audit date:** 23 October 2026, Hong Kong time. **Source tree:** `a41c900de771cea55e3c1819f1c77ff16d8101b5`. This report and its companion evidence are new, uncommitted audit records. No animation artwork, live resource, gameplay code, collision, combat setting or balance value was changed.

## Findings and completion status

The full original Castle roster is present: **14 creatures, 225 populated animation-group slots and 1,324 frame positions**. There are **188 distinct ordered registered sequences within individual creatures**; original aliases still count as separate group identities. Existing high-resolution artwork consists of **37 converted character sheets / 270 frame positions**, bound to the seven base enemies. All seven upgraded variants are absent from the current gameplay catalog and have no local remastered character sheets.

The separate approved static masters, independent generated frame sources and full source collection were not located. Existing atlas cells are available artwork and must not be confused with a located independent master package. No group meets the full **Complete** criterion: original timing, frame-to-pose fidelity and original-to-remaster registration have not been established. Matching counts and checksums alone are insufficient.

| Status | Group slots | Audit interpretation |
|---|---:|---|
| Complete | 0 | Full original specification, including timing and fidelity, has not been verified for any remaster. |
| Partial | 0 | No selected atlas has a missing or blank declared frame; fidelity differences are explicitly flagged as Needs verification. |
| Not converted | 0 | No independently verified complete hi-res source without a usable atlas was located. |
| Missing source | 187 | No suitable hi-res artwork or exact-original-alias candidate located in the accessible project. |
| Needs verification | 38 | 37 existing atlas-backed groups plus Angel G15, an exact-original-alias reuse candidate from its G12 atlas. |
| **Total** | **225** | Every actual original group appears exactly once below. |

**This corrects a simple sheet-count gap calculation:** 225 minus 37 is 188 unbound original slots, but Angel G15 has an exact source alias to already-atlased G12. Thus 187 slots lack located source artwork; one additional slot needs reuse/binding verification. This is a source candidate, not a newly completed conversion. The 187 missing-source slots reduce to **151 distinct required source sequences** after exact within-creature aliases are accounted for: **56 for the seven base creatures, 95 for upgrades**. No cross-creature artwork substitution is implied.

The two Pikeman sequence discrepancies remain **Needs verification** because this audit has not established whether required artwork is absent or existing cells need correction/reassignment. This status does not mean those sequences are correct. If a verified pose map confirms missing required frames or elements, they must be reclassified **Partial**; they are not counted as Complete merely because the declared cells are populated.

**Stop point:** audit complete; bulk conversion, artwork correction and gameplay integration have not started. The plan below is for review, not a claim that remastering is approved or completed.

## Deliverables and evidence boundaries

- This Markdown report contains all 225 groups and the per-creature coverage summary.
- [inventory.csv](inventory.csv) provides the same inventory in sortable form, including purpose, source frame order, source locations, current binding and status notes.
- [evidence.json](evidence.json) retains every original frame name/index/order/offset/canvas/margin/pixel hash, exact sequence aliases, fresh source and PNG checks, and current resource paths/key times/rectangles/import settings. `original_group_specifications` is the per-frame source specification; `live_enemy_bindings` is the current Laema behavior.
- `.gdignore` excludes this audit-data folder from Godot asset importing, following the project reference/archive convention.

The audit covers the current workspace, available ignored/untracked files, cached Git history/branches, existing archive contents and project Art/checkpoint records. Earlier discovery in this session found no larger creature source package in these scopes. The pixel audit also checked 2,650 non-native project PNG/JPG/WebP files for the recorded Swordsman master hash, without a match. This does not establish absence from another computer or an external chat output. Fresh remote branch inspection was unavailable because the environment network/proxy request failed; the cached tree and history were available. Connected-source searches did not locate a replacement master package and are not treated as proof of global absence.

## Original-source authority, semantics and timing

The current original reference is the fresh Ubisoft-installation extraction, not the earlier external extraction with different totals. Exact source locations: [collection overview](../../references/heroes3-original-flipbooks/README.md), [format/provenance/timing limits](../../references/heroes3-original-flipbooks/README.txt), [manifest](../../references/heroes3-original-flipbooks/manifest.json), [archive inventory](../../references/heroes3-original-flipbooks/archive-inventory.json), [extractor](../../references/heroes3-original-flipbooks/extract.py), and [historical full-collection verification](../../references/heroes3-original-flipbooks/verification.json).

**Timing is unknown, not 10 fps.** The preserved DEFs encode ordered frame references without playback durations, loop flags, battle-speed multipliers or gameplay event markers. The adjustable 10 fps viewer is illustrative. `CrAnim.txt` is listed in `H3ab_bmp` at offset 6,645,963 (16,231 bytes unpacked, 1,958 packed), and `CRANIM.TXT` in `H3bitmap` at 19,049,525 (same sizes); neither the table bytes nor source LOD archives are present here. Pikeman provenance historically reports a 1.00-second base attack duration from both tables, but that value was not freshly re-read and cannot establish all original frame dwell or battle-speed behavior. The current Laema one-second clips and 8/9 fps state clocks are separate implementation evidence.

**Frame order and placement:** every original Castle group has a 450×400 exported canvas, origin `(0,0)`, and zero-based ordered positions `0…N−1`. Original PCX names, repeated DEF offsets, stored image dimensions and signed `left/top` margins are retained per frame in `evidence.json`; frames must not be independently trimmed/recentered. These records describe raster registration, not an authored semantic foot pivot or original engine placement. Original recoloring, palette behavior and engine-generated mirroring are outside the baked PNG sequence. The lossless indexed PNGs and DEFs remain the preservation authority; RGBA transparency/shadows are the extraction's documented preview interpretation.

Names and purposes below use [VCMI’s creature animation-group documentation](https://vcmi.eu/modders/Animation_Format/#creature-animation-groups) as a separate interpretation layer. Actual IDs, presence and frame arrays come from the original files. Group 1 is hover/random idle; 4 is the defensive hit response; 7/8 are turning phases; 9/10 retain unlabelled H3 slots; 11–13 are up/front/down melee; 14–16 conventional ranged slots; 17–19 special slots; 20/21 movement entry/exit. A conventional slot name does not prove a creature ability: Angel/Archangel 14–16 contain exact melee aliases, not evidence of a distinct ranged mechanic. No generic group is invented when absent: Pikeman has neither 20 nor 21; Monk has 20 but no 21.

### Exact original aliases and special sequence behavior

Equality was checked within each creature using ordered indexed-pixel hashes **and** frame registration (`left/top`, stored and full sizes). Every class below also shares ordered original DEF frame offsets. These are stored source aliases, not an inference from similar-looking art. Reuse may preserve a distinct group identity/timeline; it does not remove that identity from the 225-slot target.

| Creature scope | Exact original alias groups | Consequence |
|---|---|---|
| All 14 Castle creatures | 7=9; 8=10 | Turning/legacy slots can share verified artwork while retaining IDs. |
| Monk | 13=16 | Downward melee/ranged-slot drawings are the same stored sequence. |
| Zealot | 17=18=19 | Three special-slot IDs share one stored sequence. |
| Angel and Archangel | 11=14; 12=15; 13=16 | Corresponding melee/ranged slots share the same stored drawings. Angel G15 can potentially reuse its existing G12 atlas. |

## Per-creature original and high-resolution coverage

“Atlas groups” counts physical existing remastered sequences assigned to the current game. “Source candidates” also includes the one exact-alias reuse candidate. Independent approved master/frame-source files were not located for any of the 14 creatures; the counts below describe available atlas artwork, not recovered master packages.

| Creature | DEF ID | OG groups | OG frames | Distinct OG sequences | Atlas groups / frames | Source candidate groups | Missing-source groups |
|---|---|---:|---:|---:|---:|---:|---:|
| Pikeman | `CPKMAN` | 13 | 80 | 11 | 5 / 34 | 5 | 8 |
| Halberdier | `chalbd` | 13 | 67 | 11 | 0 / 0 | 0 | 13 |
| Archer | `CLCBOW` | 18 | 100 | 16 | 6 / 42 | 6 | 12 |
| Marksman | `CHCBOW` | 18 | 101 | 16 | 0 / 0 | 0 | 18 |
| Griffin | `CGRIFF` | 15 | 91 | 13 | 5 / 37 | 5 | 10 |
| Royal Griffin | `Crgrif` | 15 | 91 | 13 | 0 / 0 | 0 | 15 |
| Swordsman | `Csword` | 15 | 80 | 13 | 5 / 35 | 5 | 10 |
| Crusader | `Ccrusd` | 15 | 80 | 13 | 0 / 0 | 0 | 15 |
| Monk | `Cmonkk` | 17 | 113 | 14 | 6 / 49 | 6 | 11 |
| Zealot | `Czealt` | 20 | 154 | 16 | 0 / 0 | 0 | 20 |
| Cavalier | `CCAVLR` | 15 | 87 | 13 | 5 / 38 | 5 | 10 |
| Champion | `CCHAMP` | 15 | 87 | 13 | 0 / 0 | 0 | 15 |
| Angel | `cangel` | 18 | 98 | 13 | 5 / 35 | 6 | 12 |
| Archangel | `CRANGL` | 18 | 95 | 13 | 0 / 0 | 0 | 18 |
| **Total** | | **225** | **1,324** | **188** | **37 / 270** | **38** | **187** |

### Located hi-res files and missing master packages

- Pikeman: [repaint_v02/](../../../../assets/prototype/enemy/pikeman/repaint_v02) contains the five right-facing converted atlases; [provenance](../../../../assets/prototype/enemy/pikeman/repaint_v02/PROVENANCE.md) references external `pikeman-flipbook-assets-v02`, `HANDOFF.md`, `manifest.json` and `motion-review.json`. Those independent source files and left/frame masters are not here.
- Archer, Griffin, Swordsman, Monk, Cavalier and Angel: each has `assets/prototype/enemy/<creature>/highres_v01/` and `source-manifest.json`, linked individually below. These reference `castle-creature-assets-v01/animations` and source index SHA-256 `56a4bc391a035c785d833a62b906a57b5301461dd6235c4682f1a7374d731321`; that collection index and full package are absent.
- Swordsman’s recorded approved static-master SHA-256 is `74e41bddc05ec8efab31e85fe6ed86b9d1b08552d25948162ce8d624303f92f0`; no matching standalone file was located. A hash in a manifest is evidence of a reference, not proof that the referenced master is locally accessible.
- No local master/frame set or remastered character atlas was found for Halberdier, Marksman, Royal Griffin, Crusader, Zealot, Champion or Archangel. Similar base-creature artwork is not silently substituted for an upgraded variant.

## Existing real-enemy bindings and current animation specification

The shared [creature catalog](../../../../scripts/config/creature_catalog.gd) registers only seven base Castle IDs. [PrototypeArena](../../../../scripts/prototype/prototype_arena.gd) loads the selected scene into the actual encounter/final-enemy slot; these are live game resources, not a demonstration collection. [CombatEnemy](../../../../scripts/enemy/combat_enemy.gd) selects the state visuals; [Archer’s shared ranged subclass](../../../../scripts/enemy/archer.gd) supplies the Monk/Archer ranged branch. The seven upgraded variants have no registered scenes or current state bindings.

| Actual gameplay state | Current selected source group | Current playback |
|---|---|---|
| DORMANT / IDLE | 2 | Loop at 8 fps |
| APPROACH | 0 | Loop at 9 fps |
| WINDUP / ACTIVE / RECOVERY | 12 melee; Archer/Monk additionally 15 shooting | Native clip with committed selection and facing; baseline 1.0 s |
| HIT_REACTING | 3 | All selected frames normalized across captured reaction duration |
| DEAD | 5 | 8 fps, clamp to last frame; encounter/lifecycle may stop visible playback |
| Original hover/defence/turn/angled/special/start/end slots | No dedicated current bindings | No original trigger/transition parity established |

**Current timing, not recovered OG timing:** every native attack lasts 1.0 simulated second. Melee markers span 0.5–1.0 seconds; Archer/Monk shooting launches at 0.5 and reaches the active boundary at 0.625. Enemy attack clocks explicitly use speed scale 1.0 and advance through the shared physics/contact owner; Player Heat scaling is separate. Pause, interruption and encounter lifecycle still affect visible completion. The exact tracks, keys and source evidence are in `evidence.json → live_enemy_bindings`.

| Creature | Original group | Native live resource | Key times (s) | Atlas indexes at those keys |
|---|---|---|---|---|
| Pikeman | G12 | [melee_swing.tres](../../../../config/attack_animations/melee_swing.tres) | `0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1` | `0,1,2,3,4,5,6,7,8,9,0` |
| Archer | G12 | [archer_melee.tres](../../../../config/attack_animations/archer_melee.tres) | `0,0.166667,0.333333,0.5,0.666667,0.833333,1` | `0,1,2,3,4,5,0` |
| Archer | G15 | [archer_shoot.tres](../../../../config/attack_animations/archer_shoot.tres) | `0,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1` | `0,1,2,3,4,5,6,7,0` |
| Griffin | G12 | [griffin_melee.tres](../../../../config/attack_animations/griffin_melee.tres) | `0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1` | `0,1,2,3,4,4,5,6,7,8,0` |
| Swordsman | G12 | [swordsman_melee.tres](../../../../config/attack_animations/swordsman_melee.tres) | `0,0.142857,0.285714,0.428571,0.571429,0.714286,0.857143,1` | `0,1,2,3,4,5,6,0` |
| Monk | G12 | [monk_melee.tres](../../../../config/attack_animations/monk_melee.tres) | `0,0.125,0.25,0.375,0.5,0.625,0.75,0.875,1` | `0,1,2,3,4,5,6,7,0` |
| Monk | G15 | [monk_shoot.tres](../../../../config/attack_animations/monk_shoot.tres) | `0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1` | `0,1,2,3,4,5,6,7,8,9,0` |
| Cavalier | G12 | [cavalier_melee.tres](../../../../config/attack_animations/cavalier_melee.tres) | `0,0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8,0.9,1` | `0,1,2,3,4,5,6,7,8,9,0` |
| Angel | G12 | [angel_melee.tres](../../../../config/attack_animations/angel_melee.tres) | `0,0.166667,0.333333,0.5,0.666667,0.833333,1` | `0,1,2,3,4,5,0` |

The terminal index-0 key at 1.0 s is a resource reset, not an additional original source pose. Griffin deliberately repeats index 4 across two 0.1-second key intervals, yielding a 0.2-second dwell; the other selected indexes occur in source-index order. All selected atlas indexes are sampled, but numerical index order cannot establish that generated drawing i recreates original pose i.

**Current registration/import convention:** Pikeman has 768×512 cells and centered offset `(0,-192)`; the other six have 768×640 cells and `(0,-128)`. All use four columns, scale 1 and cell anchor `(384,448)` mapped to BodyVisual/capsule bottom `(-11,31)`. Facing uses `Sprite2D.flip_h` rather than original turn groups. The inherited texture filter is linear; all 37 import descriptors use compression mode 0, no mipmaps, alpha-border fix enabled, premultiplied alpha disabled and no size limit. These descriptors were read, not executed by Godot. Original reference margins and current anchors are different coordinate systems; one has not been proven a faithful transformation of the other.

## Identified discrepancies and verification gaps

1. **F1 — Pikeman G12 recovery/repeated-pose composition differs.** Original ordered frames have exact repeats `1=9` and `2=8`; the remaster instead has `0=9` and `1=8`. Other pairs `3=7` and `4=6` remain identical. Direct original/remaster sheet inspection confirms that the remaster’s last populated frame returns to its initial ready drawing, whereas the original ends on source frame 1. This is an observed sequence-composition difference, not a frame-count mismatch. A future correction needs explicit pose mapping; do not silently reorder or generate art during this audit.
2. **F2 — Pikeman G03 collapses a source distinction.** Original indexed frames 0 and 5 differ; remastered RGBA cells 0 and 5 are exactly identical. The visual/source-frame correspondence requires review before this sequence can be certified as a 1:1 remaster.
3. **F3 — Original playback timing is unavailable for all groups.** Current 8/9 fps state rates, one-second attacks, Griffin’s extra dwell and normalized hurt timing cannot be certified against absent original frame-dwell/engine evidence. No specific original timing delta is invented.
4. **F4 — Registration and original behavior remain unverified.** Correct atlas arithmetic, transparent padding and stable shared anchors do not prove foot/weapon/muzzle alignment, original silhouette scale or in-game playback. Griffin/Angel airborne drawings under current grounded physics are documented prototype behavior, not an automatically diagnosed pivot error. Pikeman provenance also records an existing drawing/query mismatch; no collision change is included.
5. **F5 — Pikeman provenance contains stale collider dimensions.** Its repaint prose describes height 68.7 at `(-11,-3.35)`, while the current scene has height 180 at `(-11,-59)`. Both bottoms are `(-11,31)`, so the registration bottom still agrees. The report uses the current scene and records the stale prose without editing it.
6. **F6 — Full master lineage cannot be freshly checked.** The atlas PNG hashes match recorded manifests, but missing independent frame/master packages prevent rerunning the historical source-copy comparisons or validating master approval/pose lineage from the original deliverables.
7. **F7 — Gameplay state coverage is narrower than the original group inventory.** Current enemies bind only groups 0/2/3/5/12 (+15 for Archer/Monk); upgrades and original turn/angled/special/transition triggers have no present integration. Visual completeness and behavior parity require separate evidence. A slot name must not create an unapproved flying/ranged/special mechanic.

No selected-sheet frame-count mismatch, blank declared cell, nontransparent padding or cell-edge clipping was found. No additional wrong pose order or pivot is certified merely from filenames or bounding boxes. The remaining 35 sheets also require fidelity review; absence of a detected repeat mismatch is not approval.

## Complete original-group inventory

Each row is an actually present original group. **Hi-res source frames** means available populated cells in an existing atlas, not a located independent master. “None located” means source artwork was not found here, not that an external package cannot contain it. **Needs verification** applies to all existing atlas-backed groups and the Angel alias candidate. Full frame order is the original metadata array `0…N−1`, including repeated stored frames; exact names, hashes, margins and offsets are retained in `evidence.json`. There are no recovered per-frame OG times or explicit semantic pivots for these rows.

### Pikeman — `CPKMAN`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CPKMAN/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CPKMAN.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CPKMAN).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/pikeman/repaint_v02/PROVENANCE.md); actual runtime scene: [enemy scene](../../../../scenes/enemy/combat_enemy.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Pikeman | G00 — Movement | 6 | 6/6 in atlas; master absent | [walk_right_sheet.png](../../../../assets/prototype/enemy/pikeman/repaint_v02/walk_right_sheet.png); live-bound | Needs verification |
| Pikeman | G01 — Idle variation / hover | 4 | None located | None located | Missing source |
| Pikeman | G02 — Idle | 7 | 7/7 in atlas; master absent | [idle_right_sheet.png](../../../../assets/prototype/enemy/pikeman/repaint_v02/idle_right_sheet.png); live-bound | Needs verification |
| Pikeman | G03 — Hit reaction | 6 | 6/6 in atlas; master absent | [hurt_right_sheet.png](../../../../assets/prototype/enemy/pikeman/repaint_v02/hurt_right_sheet.png); live-bound; F2 | Needs verification |
| Pikeman | G04 — Defensive reaction | 13 | None located | None located | Missing source |
| Pikeman | G05 — Death | 5 | 5/5 in atlas; master absent | [death_right_sheet.png](../../../../assets/prototype/enemy/pikeman/repaint_v02/death_right_sheet.png); live-bound | Needs verification |
| Pikeman | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Pikeman | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Pikeman | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Pikeman | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Pikeman | G11 — Melee up | 10 | None located | None located | Missing source |
| Pikeman | G12 — Melee front | 10 | 10/10 in atlas; master absent | [attack_right_sheet.png](../../../../assets/prototype/enemy/pikeman/repaint_v02/attack_right_sheet.png); live-bound; F1 | Needs verification |
| Pikeman | G13 — Melee down | 11 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13. All other rows remain unverified; none is certified Complete.

### Halberdier — `chalbd`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/chalbd/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/chalbd.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/chalbd).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Halberdier | G00 — Movement | 6 | None located | None located | Missing source |
| Halberdier | G01 — Idle variation / hover | 4 | None located | None located | Missing source |
| Halberdier | G02 — Idle | 8 | None located | None located | Missing source |
| Halberdier | G03 — Hit reaction | 6 | None located | None located | Missing source |
| Halberdier | G04 — Defensive reaction | 12 | None located | None located | Missing source |
| Halberdier | G05 — Death | 4 | None located | None located | Missing source |
| Halberdier | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Halberdier | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Halberdier | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Halberdier | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Halberdier | G11 — Melee up | 6 | None located | None located | Missing source |
| Halberdier | G12 — Melee front | 6 | None located | None located | Missing source |
| Halberdier | G13 — Melee down | 7 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13. All other rows remain unverified; none is certified Complete.

### Archer — `CLCBOW`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CLCBOW/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CLCBOW.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CLCBOW).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/archer/highres_v01/source-manifest.json); actual runtime scene: [enemy scene](../../../../scenes/enemy/archer.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Archer | G00 — Movement | 8 | 8/8 in atlas; master absent | [Walk.png](../../../../assets/prototype/enemy/archer/highres_v01/Walk.png); live-bound | Needs verification |
| Archer | G01 — Idle variation / hover | 9 | None located | None located | Missing source |
| Archer | G02 — Idle | 8 | 8/8 in atlas; master absent | [Idle.png](../../../../assets/prototype/enemy/archer/highres_v01/Idle.png); live-bound | Needs verification |
| Archer | G03 — Hit reaction | 6 | 6/6 in atlas; master absent | [Hurt.png](../../../../assets/prototype/enemy/archer/highres_v01/Hurt.png); live-bound | Needs verification |
| Archer | G04 — Defensive reaction | 9 | None located | None located | Missing source |
| Archer | G05 — Death | 6 | 6/6 in atlas; master absent | [Dead.png](../../../../assets/prototype/enemy/archer/highres_v01/Dead.png); live-bound | Needs verification |
| Archer | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Archer | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Archer | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Archer | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Archer | G11 — Melee up | 6 | None located | None located | Missing source |
| Archer | G12 — Melee front | 6 | 6/6 in atlas; master absent | [Melee.png](../../../../assets/prototype/enemy/archer/highres_v01/Melee.png); live-bound | Needs verification |
| Archer | G13 — Melee down | 6 | None located | None located | Missing source |
| Archer | G14 — Ranged up slot | 8 | None located | None located | Missing source |
| Archer | G15 — Ranged front slot | 8 | 8/8 in atlas; master absent | [Shoot.png](../../../../assets/prototype/enemy/archer/highres_v01/Shoot.png); live-bound | Needs verification |
| Archer | G16 — Ranged down slot | 8 | None located | None located | Missing source |
| Archer | G20 — Movement start | 2 | None located | None located | Missing source |
| Archer | G21 — Movement end | 2 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13, G14, G16, G20, G21. All other rows remain unverified; none is certified Complete.

### Marksman — `CHCBOW`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CHCBOW/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CHCBOW.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CHCBOW).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Marksman | G00 — Movement | 8 | None located | None located | Missing source |
| Marksman | G01 — Idle variation / hover | 9 | None located | None located | Missing source |
| Marksman | G02 — Idle | 8 | None located | None located | Missing source |
| Marksman | G03 — Hit reaction | 6 | None located | None located | Missing source |
| Marksman | G04 — Defensive reaction | 10 | None located | None located | Missing source |
| Marksman | G05 — Death | 6 | None located | None located | Missing source |
| Marksman | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Marksman | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Marksman | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Marksman | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Marksman | G11 — Melee up | 6 | None located | None located | Missing source |
| Marksman | G12 — Melee front | 6 | None located | None located | Missing source |
| Marksman | G13 — Melee down | 6 | None located | None located | Missing source |
| Marksman | G14 — Ranged up slot | 8 | None located | None located | Missing source |
| Marksman | G15 — Ranged front slot | 8 | None located | None located | Missing source |
| Marksman | G16 — Ranged down slot | 8 | None located | None located | Missing source |
| Marksman | G20 — Movement start | 2 | None located | None located | Missing source |
| Marksman | G21 — Movement end | 2 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13, G14, G15, G16, G20, G21. All other rows remain unverified; none is certified Complete.

### Griffin — `CGRIFF`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CGRIFF/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CGRIFF.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CGRIFF).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/griffin/highres_v01/source-manifest.json); actual runtime scene: [enemy scene](../../../../scenes/enemy/griffin.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Griffin | G00 — Movement | 4 | 4/4 in atlas; master absent | [Walk.png](../../../../assets/prototype/enemy/griffin/highres_v01/Walk.png); live-bound | Needs verification |
| Griffin | G01 — Idle variation / hover | 8 | None located | None located | Missing source |
| Griffin | G02 — Idle | 8 | 8/8 in atlas; master absent | [Idle.png](../../../../assets/prototype/enemy/griffin/highres_v01/Idle.png); live-bound | Needs verification |
| Griffin | G03 — Hit reaction | 7 | 7/7 in atlas; master absent | [Hurt.png](../../../../assets/prototype/enemy/griffin/highres_v01/Hurt.png); live-bound | Needs verification |
| Griffin | G04 — Defensive reaction | 8 | None located | None located | Missing source |
| Griffin | G05 — Death | 9 | 9/9 in atlas; master absent | [Dead.png](../../../../assets/prototype/enemy/griffin/highres_v01/Dead.png); live-bound | Needs verification |
| Griffin | G07 — Turning phase 1 (OG = G09) | 3 | None located | None located | Missing source |
| Griffin | G08 — Turning phase 2 (OG = G10) | 3 | None located | None located | Missing source |
| Griffin | G09 — Legacy H3 slot (OG = G07) | 3 | None located | None located | Missing source |
| Griffin | G10 — Legacy H3 slot (OG = G08) | 3 | None located | None located | Missing source |
| Griffin | G11 — Melee up | 9 | None located | None located | Missing source |
| Griffin | G12 — Melee front | 9 | 9/9 in atlas; master absent | [Attack.png](../../../../assets/prototype/enemy/griffin/highres_v01/Attack.png); live-bound | Needs verification |
| Griffin | G13 — Melee down | 9 | None located | None located | Missing source |
| Griffin | G20 — Movement start | 4 | None located | None located | Missing source |
| Griffin | G21 — Movement end | 4 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13, G20, G21. All other rows remain unverified; none is certified Complete.

### Royal Griffin — `Crgrif`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/Crgrif/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/Crgrif.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/Crgrif).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Royal Griffin | G00 — Movement | 4 | None located | None located | Missing source |
| Royal Griffin | G01 — Idle variation / hover | 8 | None located | None located | Missing source |
| Royal Griffin | G02 — Idle | 8 | None located | None located | Missing source |
| Royal Griffin | G03 — Hit reaction | 7 | None located | None located | Missing source |
| Royal Griffin | G04 — Defensive reaction | 8 | None located | None located | Missing source |
| Royal Griffin | G05 — Death | 9 | None located | None located | Missing source |
| Royal Griffin | G07 — Turning phase 1 (OG = G09) | 3 | None located | None located | Missing source |
| Royal Griffin | G08 — Turning phase 2 (OG = G10) | 3 | None located | None located | Missing source |
| Royal Griffin | G09 — Legacy H3 slot (OG = G07) | 3 | None located | None located | Missing source |
| Royal Griffin | G10 — Legacy H3 slot (OG = G08) | 3 | None located | None located | Missing source |
| Royal Griffin | G11 — Melee up | 9 | None located | None located | Missing source |
| Royal Griffin | G12 — Melee front | 9 | None located | None located | Missing source |
| Royal Griffin | G13 — Melee down | 9 | None located | None located | Missing source |
| Royal Griffin | G20 — Movement start | 4 | None located | None located | Missing source |
| Royal Griffin | G21 — Movement end | 4 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13, G20, G21. All other rows remain unverified; none is certified Complete.

### Swordsman — `Csword`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/Csword/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/Csword.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/Csword).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/swordsman/highres_v01/source-manifest.json); actual runtime scene: [enemy scene](../../../../scenes/enemy/swordsman.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Swordsman | G00 — Movement | 8 | 8/8 in atlas; master absent | [Walk.png](../../../../assets/prototype/enemy/swordsman/highres_v01/Walk.png); live-bound | Needs verification |
| Swordsman | G01 — Idle variation / hover | 8 | None located | None located | Missing source |
| Swordsman | G02 — Idle | 8 | 8/8 in atlas; master absent | [Idle.png](../../../../assets/prototype/enemy/swordsman/highres_v01/Idle.png); live-bound | Needs verification |
| Swordsman | G03 — Hit reaction | 6 | 6/6 in atlas; master absent | [Hurt.png](../../../../assets/prototype/enemy/swordsman/highres_v01/Hurt.png); live-bound | Needs verification |
| Swordsman | G04 — Defensive reaction | 11 | None located | None located | Missing source |
| Swordsman | G05 — Death | 6 | 6/6 in atlas; master absent | [Dead.png](../../../../assets/prototype/enemy/swordsman/highres_v01/Dead.png); live-bound | Needs verification |
| Swordsman | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Swordsman | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Swordsman | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Swordsman | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Swordsman | G11 — Melee up | 7 | None located | None located | Missing source |
| Swordsman | G12 — Melee front | 7 | 7/7 in atlas; master absent | [Attack.png](../../../../assets/prototype/enemy/swordsman/highres_v01/Attack.png); live-bound | Needs verification |
| Swordsman | G13 — Melee down | 7 | None located | None located | Missing source |
| Swordsman | G20 — Movement start | 2 | None located | None located | Missing source |
| Swordsman | G21 — Movement end | 2 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13, G20, G21. All other rows remain unverified; none is certified Complete.

### Crusader — `Ccrusd`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/Ccrusd/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/Ccrusd.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/Ccrusd).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Crusader | G00 — Movement | 8 | None located | None located | Missing source |
| Crusader | G01 — Idle variation / hover | 8 | None located | None located | Missing source |
| Crusader | G02 — Idle | 8 | None located | None located | Missing source |
| Crusader | G03 — Hit reaction | 6 | None located | None located | Missing source |
| Crusader | G04 — Defensive reaction | 11 | None located | None located | Missing source |
| Crusader | G05 — Death | 6 | None located | None located | Missing source |
| Crusader | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Crusader | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Crusader | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Crusader | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Crusader | G11 — Melee up | 7 | None located | None located | Missing source |
| Crusader | G12 — Melee front | 7 | None located | None located | Missing source |
| Crusader | G13 — Melee down | 7 | None located | None located | Missing source |
| Crusader | G20 — Movement start | 2 | None located | None located | Missing source |
| Crusader | G21 — Movement end | 2 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13, G20, G21. All other rows remain unverified; none is certified Complete.

### Monk — `Cmonkk`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/Cmonkk/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/Cmonkk.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/Cmonkk).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/monk/highres_v01/source-manifest.json); actual runtime scene: [enemy scene](../../../../scenes/enemy/monk.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Monk | G00 — Movement | 6 | 6/6 in atlas; master absent | [Walk.png](../../../../assets/prototype/enemy/monk/highres_v01/Walk.png); live-bound | Needs verification |
| Monk | G01 — Idle variation / hover | 10 | None located | None located | Missing source |
| Monk | G02 — Idle | 6 | 6/6 in atlas; master absent | [Idle.png](../../../../assets/prototype/enemy/monk/highres_v01/Idle.png); live-bound | Needs verification |
| Monk | G03 — Hit reaction | 8 | 8/8 in atlas; master absent | [Hurt.png](../../../../assets/prototype/enemy/monk/highres_v01/Hurt.png); live-bound | Needs verification |
| Monk | G04 — Defensive reaction | 7 | None located | None located | Missing source |
| Monk | G05 — Death | 11 | 11/11 in atlas; master absent | [Dead.png](../../../../assets/prototype/enemy/monk/highres_v01/Dead.png); live-bound | Needs verification |
| Monk | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Monk | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Monk | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Monk | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Monk | G11 — Melee up | 9 | None located | None located | Missing source |
| Monk | G12 — Melee front | 8 | 8/8 in atlas; master absent | [Melee.png](../../../../assets/prototype/enemy/monk/highres_v01/Melee.png); live-bound | Needs verification |
| Monk | G13 — Melee down (OG = G16) | 9 | None located | None located | Missing source |
| Monk | G14 — Ranged up slot | 10 | None located | None located | Missing source |
| Monk | G15 — Ranged front slot | 10 | 10/10 in atlas; master absent | [Shoot.png](../../../../assets/prototype/enemy/monk/highres_v01/Shoot.png); live-bound | Needs verification |
| Monk | G16 — Ranged down slot (OG = G13) | 9 | None located | None located | Missing source |
| Monk | G20 — Movement start | 2 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13, G14, G16, G20. All other rows remain unverified; none is certified Complete.

### Zealot — `Czealt`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/Czealt/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/Czealt.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/Czealt).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Zealot | G00 — Movement | 6 | None located | None located | Missing source |
| Zealot | G01 — Idle variation / hover | 10 | None located | None located | Missing source |
| Zealot | G02 — Idle | 6 | None located | None located | Missing source |
| Zealot | G03 — Hit reaction | 8 | None located | None located | Missing source |
| Zealot | G04 — Defensive reaction | 7 | None located | None located | Missing source |
| Zealot | G05 — Death | 11 | None located | None located | Missing source |
| Zealot | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Zealot | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Zealot | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Zealot | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Zealot | G11 — Melee up | 9 | None located | None located | Missing source |
| Zealot | G12 — Melee front | 8 | None located | None located | Missing source |
| Zealot | G13 — Melee down | 9 | None located | None located | Missing source |
| Zealot | G14 — Ranged up slot | 13 | None located | None located | Missing source |
| Zealot | G15 — Ranged front slot | 14 | None located | None located | Missing source |
| Zealot | G16 — Ranged down slot | 13 | None located | None located | Missing source |
| Zealot | G17 — Special up slot (OG = G18,G19) | 10 | None located | None located | Missing source |
| Zealot | G18 — Special front slot (OG = G17,G19) | 10 | None located | None located | Missing source |
| Zealot | G19 — Special down slot (OG = G17,G18) | 10 | None located | None located | Missing source |
| Zealot | G20 — Movement start | 2 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13, G14, G15, G16, G17, G18, G19, G20. All other rows remain unverified; none is certified Complete.

### Cavalier — `CCAVLR`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CCAVLR/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CCAVLR.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CCAVLR).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/cavalier/highres_v01/source-manifest.json); actual runtime scene: [enemy scene](../../../../scenes/enemy/cavalier.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Cavalier | G00 — Movement | 8 | 8/8 in atlas; master absent | [Walk.png](../../../../assets/prototype/enemy/cavalier/highres_v01/Walk.png); live-bound | Needs verification |
| Cavalier | G01 — Idle variation / hover | 5 | None located | None located | Missing source |
| Cavalier | G02 — Idle | 4 | 4/4 in atlas; master absent | [Idle.png](../../../../assets/prototype/enemy/cavalier/highres_v01/Idle.png); live-bound | Needs verification |
| Cavalier | G03 — Hit reaction | 8 | 8/8 in atlas; master absent | [Hurt.png](../../../../assets/prototype/enemy/cavalier/highres_v01/Hurt.png); live-bound | Needs verification |
| Cavalier | G04 — Defensive reaction | 6 | None located | None located | Missing source |
| Cavalier | G05 — Death | 8 | 8/8 in atlas; master absent | [Dead.png](../../../../assets/prototype/enemy/cavalier/highres_v01/Dead.png); live-bound | Needs verification |
| Cavalier | G07 — Turning phase 1 (OG = G09) | 3 | None located | None located | Missing source |
| Cavalier | G08 — Turning phase 2 (OG = G10) | 3 | None located | None located | Missing source |
| Cavalier | G09 — Legacy H3 slot (OG = G07) | 3 | None located | None located | Missing source |
| Cavalier | G10 — Legacy H3 slot (OG = G08) | 3 | None located | None located | Missing source |
| Cavalier | G11 — Melee up | 10 | None located | None located | Missing source |
| Cavalier | G12 — Melee front | 10 | 10/10 in atlas; master absent | [Attack.png](../../../../assets/prototype/enemy/cavalier/highres_v01/Attack.png); live-bound | Needs verification |
| Cavalier | G13 — Melee down | 9 | None located | None located | Missing source |
| Cavalier | G20 — Movement start | 3 | None located | None located | Missing source |
| Cavalier | G21 — Movement end | 4 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13, G20, G21. All other rows remain unverified; none is certified Complete.

### Champion — `CCHAMP`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CCHAMP/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CCHAMP.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CCHAMP).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Champion | G00 — Movement | 8 | None located | None located | Missing source |
| Champion | G01 — Idle variation / hover | 5 | None located | None located | Missing source |
| Champion | G02 — Idle | 4 | None located | None located | Missing source |
| Champion | G03 — Hit reaction | 8 | None located | None located | Missing source |
| Champion | G04 — Defensive reaction | 6 | None located | None located | Missing source |
| Champion | G05 — Death | 8 | None located | None located | Missing source |
| Champion | G07 — Turning phase 1 (OG = G09) | 3 | None located | None located | Missing source |
| Champion | G08 — Turning phase 2 (OG = G10) | 3 | None located | None located | Missing source |
| Champion | G09 — Legacy H3 slot (OG = G07) | 3 | None located | None located | Missing source |
| Champion | G10 — Legacy H3 slot (OG = G08) | 3 | None located | None located | Missing source |
| Champion | G11 — Melee up | 10 | None located | None located | Missing source |
| Champion | G12 — Melee front | 10 | None located | None located | Missing source |
| Champion | G13 — Melee down | 9 | None located | None located | Missing source |
| Champion | G20 — Movement start | 3 | None located | None located | Missing source |
| Champion | G21 — Movement end | 4 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13, G20, G21. All other rows remain unverified; none is certified Complete.

### Angel — `cangel`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/cangel/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/cangel.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/cangel).

Hi-res evidence: [manifest/provenance](../../../../assets/prototype/enemy/angel/highres_v01/source-manifest.json); actual runtime scene: [enemy scene](../../../../scenes/enemy/angel.tscn). Independent master/frame files were not located.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Angel | G00 — Movement | 7 | 7/7 in atlas; master absent | [Walk.png](../../../../assets/prototype/enemy/angel/highres_v01/Walk.png); live-bound | Needs verification |
| Angel | G01 — Idle variation / hover | 10 | None located | None located | Missing source |
| Angel | G02 — Idle | 8 | 8/8 in atlas; master absent | [Idle.png](../../../../assets/prototype/enemy/angel/highres_v01/Idle.png); live-bound | Needs verification |
| Angel | G03 — Hit reaction | 6 | 6/6 in atlas; master absent | [Hurt.png](../../../../assets/prototype/enemy/angel/highres_v01/Hurt.png); live-bound | Needs verification |
| Angel | G04 — Defensive reaction | 10 | None located | None located | Missing source |
| Angel | G05 — Death | 8 | 8/8 in atlas; master absent | [Dead.png](../../../../assets/prototype/enemy/angel/highres_v01/Dead.png); live-bound | Needs verification |
| Angel | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Angel | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Angel | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Angel | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Angel | G11 — Melee up (OG = G14) | 6 | None located | None located | Missing source |
| Angel | G12 — Melee front (OG = G15) | 6 | 6/6 in atlas; master absent | [Attack.png](../../../../assets/prototype/enemy/angel/highres_v01/Attack.png); live-bound | Needs verification |
| Angel | G13 — Melee down (OG = G16) | 6 | None located | None located | Missing source |
| Angel | G14 — Ranged up slot (OG = G11) | 6 | None located | None located | Missing source |
| Angel | G15 — Ranged front slot (OG = G12) | 6 | 6/6 via exact OG G12 alias; unverified | No dedicated G15 binding; [G12 atlas reuse candidate](../../../../assets/prototype/enemy/angel/highres_v01/Attack.png) | Needs verification |
| Angel | G16 — Ranged down slot (OG = G13) | 6 | None located | None located | Missing source |
| Angel | G20 — Movement start | 2 | None located | None located | Missing source |
| Angel | G21 — Movement end | 3 | None located | None located | Missing source |

Missing-source slots: G01, G04, G07, G08, G09, G10, G11, G13, G14, G16, G20, G21. All other rows remain unverified; none is certified Complete.

### Archangel — `CRANGL`

Original evidence: [ordered metadata](../../references/heroes3-original-flipbooks/sprites/H3sprite/CRANGL/metadata.json), [preserved DEF](../../references/heroes3-original-flipbooks/originals/H3sprite/CRANGL.def), [indexed/RGBA group sheets and palette](../../references/heroes3-original-flipbooks/sprites/H3sprite/CRANGL).

No local hi-res master, remastered character sheet or registered live enemy scene was located for this upgraded variant.

| Creature | Original group | OG frame count | Hi-res source frames | Converted flipbook | Status |
|---|---|---:|---|---|---|
| Archangel | G00 — Movement | 7 | None located | None located | Missing source |
| Archangel | G01 — Idle variation / hover | 7 | None located | None located | Missing source |
| Archangel | G02 — Idle | 8 | None located | None located | Missing source |
| Archangel | G03 — Hit reaction | 6 | None located | None located | Missing source |
| Archangel | G04 — Defensive reaction | 10 | None located | None located | Missing source |
| Archangel | G05 — Death | 8 | None located | None located | Missing source |
| Archangel | G07 — Turning phase 1 (OG = G09) | 2 | None located | None located | Missing source |
| Archangel | G08 — Turning phase 2 (OG = G10) | 2 | None located | None located | Missing source |
| Archangel | G09 — Legacy H3 slot (OG = G07) | 2 | None located | None located | Missing source |
| Archangel | G10 — Legacy H3 slot (OG = G08) | 2 | None located | None located | Missing source |
| Archangel | G11 — Melee up (OG = G14) | 6 | None located | None located | Missing source |
| Archangel | G12 — Melee front (OG = G15) | 6 | None located | None located | Missing source |
| Archangel | G13 — Melee down (OG = G16) | 6 | None located | None located | Missing source |
| Archangel | G14 — Ranged up slot (OG = G11) | 6 | None located | None located | Missing source |
| Archangel | G15 — Ranged front slot (OG = G12) | 6 | None located | None located | Missing source |
| Archangel | G16 — Ranged down slot (OG = G13) | 6 | None located | None located | Missing source |
| Archangel | G20 — Movement start | 2 | None located | None located | Missing source |
| Archangel | G21 — Movement end | 3 | None located | None located | Missing source |

Missing-source slots: G00, G01, G02, G03, G04, G05, G07, G08, G09, G10, G11, G12, G13, G14, G15, G16, G20, G21. All other rows remain unverified; none is certified Complete.

## Prioritized plan to reach verified 100% parity

1. **P0 — Recover source and timing authority.** Locate the full approved Castle master/frame collection, its collection index/QA/motion records, and Pikeman v02 source package. Recover the original creature timing table bytes and original-engine timing/transition evidence at an explicitly recorded battle-speed setting. Preserve all original IDs, ordered references, margins and exact aliases. Until these inputs are available, source absence and timing uncertainty remain explicit blockers.
2. **P1 — Verify and repair the existing 37 sequences before expanding.** Compare each of the 270 existing cells to its original pose, in order and at the same registered scale. Resolve Pikeman F1/F2, establish all frame dwells and loop/hold policies, review feet/weapons/muzzles and document any accepted deviation. Verify Angel G15 reuse from G12 against its exact-original alias; maintain separate original group identity/binding even if the same art is reused. Record approval and fresh evidence rather than promoting matching counts to Complete.
3. **P2 — Complete base-creature artwork coverage.** Supply the 56 distinct ordered sequences corresponding to the 73 still-missing base-creature group slots. Group 1/4, original turn/legacy slots and angled/entry/exit sequences must remain independently accounted for; deduplicate only the proven within-creature aliases. Use actual approved high-resolution source frames, with matching source pose coverage. If source artwork does not exist, record an explicit art-production requirement; do not stretch native pixels or fill with unrelated poses.
4. **P3 — Complete upgraded variants.** Supply the 95 distinct required sequences for the 114 upgrade slots, with each variant’s actual identity, source counts and margins. Base characters are not substitute upgrade masters. Preserve special aliases such as Zealot 17=18=19 and Archangel melee/ranged-slot aliases while retaining all source IDs.
5. **P4 — Review behavior/state ownership before integration.** Map every original group’s actual trigger, direction, start/end transition and interruption/death policy to an approved gameplay representation. The current side-view grounded prototype does not already implement original HoMM3 state orchestration. Agree how archival group coverage and real encounter triggers will coexist; do not infer abilities from slot names or alter combat balance to make a missing group play. Reuse the established catalog/inherited scene/native-Animation pipeline where that mapping is settled.
6. **P5 — Verify real encounters and close only on evidence.** After reviewed conversion/integration, run import/resource checks and inspect every creature, group, direction, loop seam and transition at recorded timings. Check actual enemy encounters, both facings, alignment, interruptions, death/terminal hold, reset/retry and gameplay invariants. Finish only with one verified high-resolution equivalent and an appropriate integration/reference binding for each of the 225 original slots; retain per-group evidence and unresolved deviations.

## Checks performed and limits

- Fresh source-integrity inspection: 14 DEF hashes, 225 indexed sheets, 14 palettes and 1,324 registered indexed frame crops match their recorded source evidence; zero errors.
- Fresh remaster file inspection: 37 PNG hashes match provenance; 270 declared cells contain artwork; all 42 padding cells are transparent; declared layouts/counts fit; no populated frame touches a cell edge. Pixel-repeat differences F1/F2 are retained.
- Static live-resource tracing: all 37 selected groups are referenced by actual enemy resources; all nine native attack clips sample their expected atlas indexes; exact track times, repeats/reset keys, registration and import descriptors were inspected. No upgraded actor is registered.
- This audit does not rerun the historical independent DEF decoder and does not establish historical retail-byte authenticity. It does not certify all remastered drawings or original game playback.
- No Godot import/editor/runtime, build, gameplay test, asset generation, animation correction or balance change ran. The audit-only request stops before those implementation stages. No commit, push or publication is included.

**Result:** a complete and source-grounded audit is available for review. Original data coverage is verified; full remaster parity remains unverified. Artwork generation and game integration remain untouched.
