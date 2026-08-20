# Laema project checkpoint — 2026-08-20

## Purpose and authority

This is the full project checkpoint requested by the user. It reconciles every available, unarchived Laema task at the time of the sweep. It is a durable working record, not an approved Game Design Document, Technical Design Report, or implementation specification.

Status labels retain their usual meaning:

- **Decision** — explicitly accepted working direction.
- **Constraint** — a boundary that governs the work.
- **Assumption** — a working belief not yet established.
- **Proposal** — candidate material not yet accepted.
- **Rejected** — a direction that must not be silently revived.
- **Open** — unresolved work.

No product code, scenes, assets, or Godot runtime behavior changed or were verified during this checkpoint.

## Threads swept

| Task | ID | Status observed | Latest incorporated state |
|---|---|---|---|
| Production Manager | `01a01766-1781-7800-a3cb-fc38aca5bb1e` | Active | Checkpoint save/load workflow and advisory model recommendations |
| Combat | `01a01768-b38f-7480-a74b-70e29cc50fae` | Idle | Decomposition refinement and diagnostic-feedback direction |
| Narrative Room | `01a01768-b391-7c61-b31f-2d4be4310c73` | Not loaded | No new design update since the 2026-08-19 checkpoint |
| Design Overseer | `01a018d6-9097-7d53-8a42-1fe65472ceb1` | Not loaded | Prototype scope, Mirham, combat modes, source inspiration |
| Town Design | `01a018cb-7c14-7fe2-af09-569b2f3faf97` | Not loaded | Existing town-design working state; superseded town identity reconciled below |
| Art | `01a01d0a-ced6-77c0-a98a-e94ec3c5c10e` | Not loaded | Combat-prototype art direction and Craftpix constraint |

“Not loaded” is an app status, not an exclusion: each listed unarchived task was available to this sweep and its readable history was incorporated.

## Checkpoint workflow

**Decision:** “Save checkpoint” sweeps all available, unarchived Laema tasks—including idle tasks—writes a dated Markdown record, commits it, and pushes it to `origin`. It is only complete after a successful push.

**Decision:** “Load checkpoint” fast-forward-pulls the latest checkpoint, reconciles the local repository without promoting proposals, and sends its context to listed unarchived tasks available on the current host. Git transfers repository state, not task history.

This workflow is also recorded in `docs/README.md` and `docs/DECISIONS.md`.

## Immediate project scope

**Decision / constraint:** for the coming months, active development is exclusively a **2D, top-down combat prototype**.

- Narrative, Mirham, and faction creatures supply setting and context only; they are not current feature-development targets.
- HMM3-derived adventure-map activities as points of interest are parked and are **not** part of the current prototype.
- The prototype has not yet committed to which melee, magic, creature, or artifact concepts it must include.

## Combat

### Settled working foundation

- **Decision:** Combat is anchored by **Decomposition** and **Reintegration**. They are the only two currently soundly defined concepts.
- **Decision — Decomposition:** examine an overwhelming challenge and recursively narrow it until reaching the smallest result that provides meaningful, observable evidence about the larger challenge.
- **Decision:** Decomposition should provide diagnostic evidence—such as whether the player rushed or lagged—rather than merely report success or failure.
- **Constraint:** combat must retain the learning-a-musical-instrument ambition: player-directed practice and formal fighting are separate contexts, enemy attacks are learnable passages, and the result must not become a rhythm game governed by an external beat.

### Current open work

- **Open and unplaced:** **Anticipate**, **Explain**, and **Extend**. They remain useful terms but do not currently have an accepted parent, rank, or role in the foundation.
- **Not established:** **Comprehension** as their parent concept.
- **Not established:** **Transformative Mastery** or **Transformative Experience** as a defined shared outcome. Earlier assistant phrasing placed too much authority in these labels; neither is currently settled.
- **Proposal:** Reintegration’s earlier working pool—Fluency, Integration, and Adaptation under pressure—remains unexplored and unconfirmed.
- **Working observation:** the debugging/practice experience that matters is watching a large challenge contract through successive cuts: the player can isolate a smaller task, stop carrying the whole challenge in mind, concentrate attention, and have enough time to process it deeply.
- **Open:** what the player can notice once that attention is concentrated, and how that experience should appear in combat.

### Board material

- **Proposal:** counter-window feedback, spellbook assistance progressing toward play from memory, four-school blending, defensive response families, damage-nullification states, chanting, and combined physical/magic modes may support the learning fantasy.
- None of those board mechanics is a Combat **Decision**. Exact VFX, timing windows, and implementation remain proposals.

### Combat pickup point

Continue from: *What does concentrated attention let the player notice about the smaller challenge that was hidden when facing the whole?*

## World, combat modes, and source inspiration

- **Decision:** Laema has both **melee combat** and **magic combat**.
- **Decision:** magic is heavily inspired by the four existing schools; this does not yet decide mechanics or the relationship between magic and melee.
- **Assumption for exploration:** Laema belongs to the Castle faction. The role of Castle creatures beyond enemies remains **Open**.
- **Decision:** the original game’s artifacts are a major inspiration. Their exact gameplay role remains **Open**; no direct mechanical reproduction is implied.
- **Decision:** the recurring town hub is named **Mirham**. This supersedes the old unresolved hub-identity state; Fair Feather remains merely unused, not a governing alternative for the hub.

## Narrative and town carryover

Narrative Room has no change since [2026-08-19-project.md](2026-08-19-project.md). Its current carryover remains:

- Laema is a local protagonist with no personal court connection.
- She recognizes the king’s poisoning from symptoms previously seen near her town.
- Cloudfire is a prominent recurring place but not the buildable town.
- Nighon overruns Cloudfire; its defenders lose and retreat toward the buildable town.
- The final battle occurs at the buildable town before Catherine later reaches Cloudfire and the *Restoration of Erathia* opening begins.

Town Design’s older proposals remain background-setting material for now: a growing, lived-in action-RPG hub with construction, residents, merchants, and a final defense. Its gameplay authority, resource loop, ownership, player attachment, and exact consequences of growth remain **Open**. Mirham is the current hub name.

## Art and prototype assets

- **Decision / scope constraint:** the 2D top-down combat prototype will be built primarily from `C:\Users\ckzhou\Downloads\Craftpix_2D_Assets\`.
- **Constraint:** asset-library contents are reference material, not automatic game requirements.
- **Proposal:** use one coherent top-down pixel-art Craftpix family as the prototype’s visual baseline; avoid mixing illustrated, vector, cartoon, and pixel-art packs with incompatible proportions and rendering language.
- **Proposal:** reserve custom work for Laema’s distinguishing appearance, combat telegraphs/range indicators, hit/block/diagnostic feedback, and missing animation needs.
- **Proposal:** use a high-angle three-quarter presentation rather than strict overhead when it improves body, weapon, anticipation-pose, and attack-readability clarity.
- **Open:** whether the prototype character must already read as Laema or may use a generic swordsman stand-in; whether the visual target is crisp pixel art or a different treatment constrained by the available prototype assets.

The broader “lived-in heroic romanticism” art direction remains a **Proposal** for the future game, not a prototype requirement. Current visual priority is combat readability: silhouettes, anticipation, motion, impacts, diagnostic feedback, and a consistent distinction between practice and formal fight.

## Operations advisory

The project’s current model/effort recommendations are advisory only; no task settings were changed:

| Task | Suggested default |
|---|---|
| Production Manager | `gpt-5.6-terra`, `medium` |
| Design Overseer | `gpt-5.6-terra`, `high` |
| Combat | `gpt-5.6-sol`, `xhigh` |
| Narrative Room | `gpt-5.6-sol`, `high` |
| Town Design | `gpt-5.6-terra`, `high` |
| Art | `gpt-5.6-terra`, `high` |

For full checkpoint sweeps or difficult cross-thread reconciliation, temporarily use `gpt-5.6-sol` with `xhigh` for Production Manager or Design Overseer. `max` is not a standing recommendation.

## Canonical-document and runtime state

- `docs/GAME_DESIGN.md` remains **Not started**. This checkpoint does not promote working design into the canonical GDD.
- `docs/TECH_ARCHITECTURE.md` remains **Not started**.
- `docs/IMPLEMENTATION_STATUS.md` remains **Repository placeholder only**.
- No technical architecture, code, assets, scenes, runtime validation, or playable prototype has been created.

