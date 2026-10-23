# Walking Dead — proposed static master

Status: **static master awaiting human approval; animation not begun; runtime unverified**.

The selected proposal is `generated-attempt-02.png`, produced through the built-in Imagegen tool. Mali reviewed native identity first and used Pikeman only for fine modeled-volume shading, texture and concentrated highlights. This is newly generated artwork, not enlarged native pixels.

## Review files

- [Source versus master](source-vs-master.png): native reference and generated master at the shared 202px visible height, plus enlarged inspection.
- [Light-background alpha and scale review](alpha-and-scale-review.png): registered artwork at actual size and enlarged.
- [High-resolution trimmed master](master_rgba.png): 721 × 1467 RGBA.
- [Registered native-facing master](master_source_1024x768.png) and [exact horizontal mirror](master_mirror_1024x768.png): 1024 × 768 transparent cells.
- [Registration manifest](master-manifest.json) and [structured visual review](visual-review.json).

## Native evidence and sampled coverage

The original is `H3sprite/CZOMBI.def`, with metadata at `docs/art/references/heroes3-original-flipbooks/sprites/H3sprite/CZOMBI/metadata.json`. Original DEF, metadata and extracted idle PNG hashes were read and matched the job. The native cell is 450 × 400. Idle G2 F0 is `Czombi01.pcx`; its actual alpha>64 bounds are (180,184), 37 × 82.

The complete job.json was read. It records **15 groups, 86 timeline frames and 60 distinct indexed drawings across the collection**. Shared drawings recur in several timelines; distinct counts per group must not be added to infer collection uniqueness.

| Group | Source-format role | Frames | Distinct in group |
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

Visually inspected: native-idle-6x.png; native-all-groups-contact.png (one representative still from every group); native-g00-guide.png F0/F5/F9; native-g02-guide.png F0/F4/F7; native-g04-guide.png F0/F4/F7; native-g07-guide.png F0/F1/F2; native-g12-guide.png F0/F3/F6; native-g13-guide.png F0/F3/F6. The Pikeman rendering master was inspected before generation.

These are static samples. No complete motion sequence or timing was reviewed, and the role labels remain format mappings. The unupgraded CZOMBI was the identity source; no separate Zombie upgrade comparison was inspected.

## Observed identity and material treatment

The source shows a bald, sunken-eyed corpse with pale mint-gray exposed chest/shoulders, cooler lavender-gray limbs/rib shading, dark olive-brown ragged knee trousers and bare feet. The viewer-left torso/upper arm carries red/ochre damage. The empty rear hand has yellowed skeletal fingers, and the bent rear calf has a recognizable red wound with protruding yellowed bone. There is one short brown-handled broad gray cleaver in the viewer-right front hand.

The proposal keeps that single cleaver, exposed torso, ragged trousers, bare feet and damaged calf. It keeps the right-facing head, three-quarter torso, gently slouched bent-knee idle and lower rear foot. Fine modeled flesh and mottling, matte cloth, worn wood and small localized steel highlights follow the rendering reference. No Castle costume, helmet, heraldry or colors were borrowed.

Attempt 1's head read too small and its torso too athletic against the native game-size comparison. One targeted built-in edit enlarged the head and requested less heroic chest definition. Attempt 2 is selected for the human gate; attempt 1 remains preserved as rejected ancestry. There were **two built-in calls total: one generation and one targeted edit**.

## Registration and actual visual review

The common scale remains **180/73** source pixels, native reference (196,268), cell 1024 × 768, anchor (512,512). Native idle bounds yield target (473,305), 91 × 202. The parent helper's default uniform height scale was used, with no registration override or intentional nonuniform artwork stretch.

The selected registered alpha>64 bounds are **(469,305), 99 × 202**, bottom 507. Native silhouette center x=518.5 and bottom 507 are preserved. The generated silhouette is 8px (8.79%) wider than the target; forcing 91px width would distort its anatomy and cleaver, so this remains a disclosed proposal difference.

The selected source-vs-master plate was viewed at shared game size and enlarged; the selected high-resolution master and flat light-background plate were also inspected. Whole body, bare feet and single cleaver are visible. No floor, ground shadow, VFX, text, checkerboard or matte is visible in the reviewed composites. Genuine alpha is present: the selected raw has 1,066,828 zero-alpha pixels. It uses partial alpha even in the near-opaque core and has a faint low-alpha fringe; those generated pixels were retained. The helper mechanically checked the exact mirror. Those are export observations, not art approval or runtime evidence.

## Generation provenance

Exact prompts are preserved verbatim in [attempt 1 prompt](prompt-attempt-01.txt) and [attempt 2 prompt](prompt-attempt-02.txt), and embedded with input hashes in generation-attempt-01.json and generation-attempt-02.json. Tool-return metadata is preserved in generation-tool-output-01.json and generation-tool-output-02.json.

Selected raw:
`C:/Users/zhouc/.codex/generated_images/01a16383-559b-7091-8a4e-08a93aea92b7/exec-a3135e26-2324-42a5-ae0d-d8fda8b67a87.png`
Local preserved copy: `generated-attempt-02.png`.
SHA-256: `e45a5ff33085d292e88a309176ae63739843a00614fc5d13cb8697c1f15708af`.

Rejected first raw:
`C:/Users/zhouc/.codex/generated_images/01a16383-559b-7091-8a4e-08a93aea92b7/exec-ee169896-fc80-4cfe-aadf-e04d3221bdab.png`
Local preserved copy: `generated-attempt-01.png`.
SHA-256: `c8fb52727210e7a2a98b898728a48493a305423a7150100d0b358860be9d67c9`.

Mechanical export is recoverable in register-master.cjs, calling the read-only parent helper's registerMaster. The selected high-resolution master hash is `c7c876d8b59106f422408e72c6570fc7260e3b8bd5d95fb21e2407c0531f3cd5`; registered source hash is `4f4bfad4fa945330e3f0974fbf0b5ca600f428cc6b56d5cc81ea05947625461c`. Other hashes are in the manifest.

## Remaining risks and gate

Human approval is outstanding. The wider silhouette, still pronounced torso anatomy, skeletal finger interpretation, mouth and trouser tearing need human judgment. Wounds and mottled decay are more explicit than in the tiny native original. Flat light/dark plate review does not establish behavior against every background. Static samples do not establish full animation continuity or source timing.

Only this creature directory was written. Source originals, shared tools, other creatures, canonical documents, game files and Git state were not modified. No animation frames, engine import, build, automated tests, runtime run, commit, push or peer messages were performed.

The next dependent action is human approval of this static master. Animation has not begun.

