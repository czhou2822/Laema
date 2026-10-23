# Vampire Lord — static master proposal

Status: **proposal awaiting human master approval**. The scope remains the full creature collection. This delivery establishes one idle master; animation production has not begun.

## Source and treatment

Used Mali and built-in imagegen after reading the worker brief, current project instructions, `ART_DIRECTION.md`, the physical Mali profile and relevant Skill references. Inspected the original idle enlargement, all-groups contact sheet, detailed guides listed in `visual-review.json`, actual CNOSFE metadata and Pikeman rendering benchmark. Source DEF, metadata and idle PNG hashes match `job.json`; all embedded native group metadata matches the actual source. The full inventory remains in `job.json`.

The proposal retains CNOSFE's pale gaunt face, pointed ears, forward hunch, original right-facing idle gesture, high rust-orange/brown collar, torn hanging sleeves, long ivory bony hands and ground-length charcoal-brown robe. Pikeman supplied rendering guidance only. Attempt 01 overemphasized scorched surfaces and hooked nails; one targeted built-in edit softened the cloth treatment and shortened the nails. **Attempt 02 is selected**.

## Deliverables and checks

- `master_rgba.png`: cropped high-resolution RGBA master, 732 × 1448.
- `master_source_1024x768.png` and `master_mirror_1024x768.png`: transparent registered cells; original facing right and exact mechanical mirror left.
- `source-vs-master.png` and `game-size-mattes.png`: inspected enlarged comparison and 1:1 light/dark matte review.
- `master-manifest.json`: registration, source/output hashes and selected provenance. `build-master.cjs` calls the unchanged shared `../tools/lib.cjs`.

Registration uses anchor (512,512), original reference (196,268) and shared scale 180/73 without overrides or stretching. Visible bounds are (453,295), 109 × 215; bottom 510. The 215-pixel height follows CNOSFE's native silhouette. Both facings retain ears, hands, tatters and hem with ample cell margins. Actual alpha is present, mirror pixels match exactly, and no generated floor shadow, scene or props are visible. Original reference panels retain their exported source shadow.

Exact prompts/tool arguments are in `generation-01.request.json` and `generation-02.request.json`; both byte-preserved raw PNGs, tool output records and per-attempt provenance are retained. Selected raw SHA-256: `a93dffd13994558217c00512d38d058daf49cd850ef4846496e8eb81a04973cd`.

## Actual limitations and handoff

The generated silhouette is 109 pixels wide versus the source target's 118, with more pronounced ears and sleeve tatters. The revised robe remains more heavily textured and its rust color more subdued than the original. These are disclosed proposal differences, not approved changes. Fine facial/fabric detail cannot be uniquely recovered from the tiny source. This is static visual and mechanical evidence only; motion, timing and runtime are unverified. No animation, import, game change, engine/test/build run, Git operation or peer message occurred. Collection QA belongs to the parent; await human master approval.
