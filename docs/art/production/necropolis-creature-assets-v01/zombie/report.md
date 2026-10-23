# Zombie — static master proposal

Status: static master awaiting human approval. Animation has not begun; runtime is unverified.

## Deliverable and review

[Source comparison](source-vs-master.png) shows the native reference and generated proposal at the same source-relative scale, plus an enlarged inspection. [Registered master](master_source_1024x768.png) is the right-facing 1024×768 transparent cell; [exact mirror](master_mirror_1024x768.png) is a mechanical horizontal reflection, not another generated pose. [High-resolution master](master_rgba.png) is the tight 665×1330 alpha crop.

Mali's review retained the original cold grey-violet skin, muted olive-brown sleeveless clothing, rusty red accents, brass-colored fittings, asymmetric bare rear foot/dark front boot, and single low-held wooden-shaft tool with a compact pale transverse head. The body remains gaunt, in a narrow right-facing idle arrangement. Pikeman informed only fine modeled volume, surface texture and concentrated highlights.

At the shared 212px visible height, the pale head, hands, asymmetric feet and tool remain legible. The [dark/light matte review](alpha-edge-review.png) shows genuine alpha without a baked floor, shadow, checkerboard or visible glow. Full body and tool have generous margins in the registered cell. This is visual inspection of exported static images, not engine or gameplay evidence.

## Original evidence and sampling

The complete job was read. Source `CZOMLO.def` has **15 groups, 86 timeline frames and 60 distinct indexed drawings**. Original DEF, source metadata and idle PNG hashes match job.json; [source-evidence.json](source-evidence.json) records the exact paths, hashes and frame names.

| Group | Format mapping only | Frames | Distinct within group |
| --- | --- | ---: | ---: |
| 0 | movement | 10 | 10 |
| 1 | gesture / mouse-over | 9 | 5 |
| 2 | idle | 8 | 4 |
| 3 | hit reaction | 7 | 7 |
| 4 | defence | 8 | 7 |
| 5 | death | 9 | 9 |
| 7 | turn | 3 | 3 |
| 8 | turn | 3 | 3 |
| 9 | turn | 3 | 3 |
| 10 | turn | 3 | 3 |
| 11 | melee upper | 7 | 7 |
| 12 | melee front | 7 | 7 |
| 13 | melee lower | 7 | 7 |
| 20 | movement start | 1 | 1 |
| 21 | movement end | 1 | 1 |

These are inherited DEF-format action mappings, not runtime-confirmed roles or timing. Drawings repeat across groups; group counts must not be summed as global unique art.

Viewed native-idle-6x.png and native-all-groups-contact.png (overview of all 15 groups). Individually inspected guides G0 F0/5/9, G2 F0/4/7, G4 F0/4/7, G5 F0/4/8, G7 F0/1/2, and G11/G12/G13 F0/3/6. Also inspected a nearest-neighbor head-detail crop. G1/G3/G8/G9/G10/G20/G21 received contact-sheet overview only. Continuous motion and every native drawing were not reviewed. No paired upgrade source was inspected.

## Generation provenance

One built-in `image_gen.imagegen` call; no edits or fallback API/CLI calls. Selected [attempt-01-raw.png](attempt-01-raw.png) is copied byte-for-byte from:

`C:/Users/zhouc/.codex/generated_images/01a16383-567f-7311-8fea-87f05485d7f9/exec-009cef1e-bd47-4d60-9668-bcd0e99970e6.png`

Generated SHA-256: `a238885d0ffa45111d1358c45e07878e1b20e1e38002b76d319fddabb22fce51`.

The exact prompt is preserved verbatim in [attempt-01-prompt.txt](attempt-01-prompt.txt), [generation-provenance.json](generation-provenance.json), and visual-review.json. Inputs were native-idle-6x.png (subject/idle authority), native-g12-guide.png (original materials/tool evidence), and ../references/pikeman-rendering-master.png (rendering style only). Their hashes are recorded. No rejected raw exists because no second attempt was made. The new master is generated artwork, not enlarged original pixels.

## Registration

[register-master.cjs](register-master.cjs) calls the supplied read-only shared helper. It performs only copying, metadata capture, crop, uniform scaling, registration, exact reflection and review export.

- Cell: 1024×768; anchor: (512,512); native reference: (196,268).
- Shared source-relative scale: 180/73, approximately 2.46575.
- Native idle alpha64: (177,182), 39×86, bottom 268.
- Job target: (465,300), 96×212.
- Actual proposal alpha64: (460,300), **106×212**, bottom 512.
- Default height/center/bottom registration; no override and no nonuniform stretch.
- Helper verified the mirror byte-for-byte in RGBA space. Manifest contains exported PNG hashes.

The 10px extra width (10.4%) is an artwork difference. It was not hidden by stretching to native bounds.

## Remaining review limits

The native head pixels leave hair versus a close head covering ambiguous. The proposal interprets the dark crown as brown hair. Individual fasteners, wrist fittings, torn hems, skin wear and corrosion contain generated fine detail beyond what the source pixels prove. Cloth tears and brass fittings are more explicit than in the native sprite. Those choices, the slightly wider silhouette and consistency with the paired upgrade require human judgment.

No animation frames, timing, engine imports, builds, tests or runtime runs were produced. No original source, other creature, shared tool, canonical record, game file or Git state was changed.

**Gate:** approve or revise this static Zombie master before any animation production.

