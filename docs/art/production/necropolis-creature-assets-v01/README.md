# Necropolis creature collection — v01

Status: **14 proposed static masters delivered; awaiting user approval before animation production**.

- [Shared-scale master lineup](master-comparison-shared-scale.png).
- [Individual master review](review.html), with links to full-resolution cutouts,
  source comparisons and per-creature provenance.
- [Original roster at the same scale](original-roster-shared-scale.png).
- [Selected master manifest](selected-masters.json), [parent visual review](parent-review.json),
  [mechanical checks](master-validation.json), and [original preservation checks](source-verification.json).

The **full collection is not finished**: this delivery contains 14 static poses
and their exact mirrors, not the 228 new animation sequences. Approval of these
masters is the next gate, following the Castle workflow. The built-in image
workflow produced the artwork; source identity and Pikeman-derived rendering
guided the pass. Targeted repairs and rejected raw attempts remain in each folder.
All 14 dedicated creature workers have finished and are closed.

The user requested the complete Necropolis creature collection on a separate
branch, not a defence-only pass. Work is isolated on
`codex/necropolis-creature-assets`, based on `7e9dff463efb61473133a2c313a93a46b744fb71`.
The original asset-production request did not authorize publication. On
**2026-10-23**, the user separately authorized uploading this review package:
commit and push it to the same dedicated branch. This does not approve the
masters, animation production, a merge into main, engine imports or implementation.
Git history and the verified remote branch record the actual publication result.

## Scope and review gates

All seven base creatures and their seven upgrades: Skeleton / Skeleton Warrior,
Walking Dead / Zombie, Wight / Wraith, Vampire / Vampire Lord, Lich / Power Lich,
Black Knight / Dread Knight, and Bone Dragon / Ghost Dragon.

1. Inspect the actual local original frames and complete metadata. Inventory every
   group, including directional and special attacks, turns, gestures and flight.
2. Produce one source-faithful character master per form, plus comparable views at
   the shared Pikeman-derived scale, for user approval.
3. Only after that approval, produce every original animation group, retaining
   source order, repeated positions, offsets and exact mirrored versions.
4. Deliver sheets, individual frames, GIF previews, contact sheets, manifests,
   prompts and provenance. Preserve rejected attempts separately.

Standalone projectiles, separate spell VFX and audio are excluded, as in the
Castle collection. Effects already drawn inside a creature sequence remain part
of that sequence. Preserving an original flight/ranged/special drawing does not
authorize adding its gameplay behavior to Laema.

## Verified original coverage

One original DEF per form; a "sequence" below means an original animation group,
not a separate character pack. Frame positions include original repeats/holds.

| Base creature | DEF | Groups / positions | Upgrade | DEF | Groups / positions |
|---|---|---:|---|---|---:|
| Skeleton | CSKELE | 15 / 86 | Skeleton Warrior | CWSKEL | 15 / 86 |
| Walking Dead | CZOMBI | 15 / 86 | Zombie | CZOMLO | 15 / 86 |
| Wight | CWIGHT | 18 / 102 | Wraith | CWRAIT | 18 / 102 |
| Vampire | CVAMP | 15 / 90 | Vampire Lord | CNOSFE | 18 / 111 |
| Lich | CLICH | 18 / 120 | Power Lich | CPLICH | 18 / 120 |
| Black Knight | CBKNIG | 15 / 92 | Dread Knight | CBLORD | 18 / 125 |
| Bone Dragon | CNDRGN | 15 / 84 | Ghost Dragon | CHDRGN | 15 / 88 |

**14 creatures, 228 original groups, 1,378 original frame positions.** Identity/DEF
mapping was cross-checked against actual local artwork and the
[VCMI Necropolis configuration](https://github.com/vcmi/vcmi/blob/develop/config/creatures/necropolis.json).
Group role descriptions follow the
[VCMI animation format](https://vcmi.eu/modders/Animation_Format/#creature-animation-groups),
not guessed filenames. Original local metadata supplies the counts and offsets.
An initial unpublished working inventory included two unrelated dragon DEFs;
visual inspection caught this before generation, and the inventory and derived
guides were corrected to CNDRGN / CHDRGN. The earlier preliminary count of 234 /
1,440 is superseded, not additional Necropolis coverage.

## Art and geometry

The actual Heroes III originals govern identity, costume, weapons, anatomy,
materials and upgrade distinctions. The approved generated Pikeman supplies the
modeled-volume rendering benchmark; its colors and armor are not imposed on the
Necropolis roster. These reinterpretations are not original-game preservation
masters or final Laema identity decisions.

Shared source-relative scale: **180 / 73 pixels per original pixel**. Do not
normalize individual creatures, action poses, weapons, crouches or flight to a
common visible height. A common **1024 × 768 transparent review cell**, registration
reference **(512, 512)** corresponding to original reference **(196, 268)**, leaves
room for the original dragons' complete sequence bounds. This changes padding,
not creature size. Four-column animation sheets are planned after master approval.

## Provenance and limits

Original references remain unchanged in
`../../references/heroes3-original-flipbooks/`. Exact DEF and metadata hashes,
all groups and source records are retained in `source-inventory.json` and each
creature's `job.json`. Native preview transparency/shadows are extraction
interpretations; original DEFs and indexed PNGs remain the preservation masters.

Artwork is generated using the built-in image workflow. Cropping, registration,
comparison layout and export checks are mechanical operations. Generated artwork
does not remove underlying third-party character rights; no redistribution or
commercial-use entitlement has been established. The source is the user's
installed Heroes III Complete Edition extraction, not a newly licensed art pack.

Preview playback, when produced, uses 10 fps only for review. Original metadata
does not establish gameplay timing. This collection changes no gameplay, AI,
collision, ranged/flight mechanics, engine code, scenes or APIs. No runtime result
is claimed. The `.gdignore` prevents Godot from importing this production folder.

