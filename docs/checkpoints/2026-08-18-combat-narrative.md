# Laema end-of-day checkpoint — 2026-08-18

## Purpose and status

This is a cross-thread working checkpoint for the current state of the Combat and NarrativeRoom discussions. It is not an approved Game Design Document, Technical Design Report, or implementation specification.

The checkpoint preserves the distinction between:

- decisions and directions explicitly expressed by the user;
- candidate ideas and working interpretations;
- unresolved questions that remain open.

No product code was changed and no Godot runtime validation was performed.

## Sources read

- **Combat** — Codex thread `01a0150a-3101-7611-910e-4e9dc6d55728`
- **NarrativeRoom** — Codex thread `01a014f2-6363-7c20-b67e-1d80689ff86e`
- Narrative ideas were also read from the referenced Miro board: <https://miro.com/app/board/uXjVIprxqks=/>

## Combat

### Current direction / decisions expressed by the user

- Combat should recreate the self-growth experience of learning a musical instrument: material initially feels overwhelming, the player isolates and practises difficult parts, recombines them, increases fluency, and eventually takes on harder material.
- An enemy is analogous to a piece of music.
- An enemy attack is analogous to a passage in that piece.
- Practice and the formal fight are separate contexts.
- Practice is player-directed and can continue for as long as the player wishes.
- The player should be able to use diagnostic and practice methods to understand an enemy rather than being forced through one prescribed learning method.
- Isolation is recursive: enemy → move → smaller actionable unit, potentially down to bars or beats.
- The formal fight acts as a test. The player returns to demonstrate integrated understanding under continuous pressure; defeating the enemy demonstrates sufficient mastery to advance.
- Progression is cumulative rather than a sequence of wholly unrelated replacements:
  - an introductory minion may have one or two moves;
  - familiar minions may later appear together in groups of two or three;
  - later versions of an existing minion may add moves or complexity;
  - new enemies appear periodically while older enemies remain available.
- Combat should not become a rhythm game. There is no external background baseline or beat to synchronise against.
- The combat should be anchored by exactly three pillars, rather than a growing list of equally fundamental ideas.

### Current status

The earlier Stage 1–2 foundation was explicitly reopened because it did not yet feel solid enough. The three pillars have not been named. The current state is therefore a **provisional design direction**, not a completed combat foundation.

### Open combat questions

- What are the three pillars, stated as player experiences rather than mechanics?
- What is the smallest practicable combat unit?
- What does the player actually do during one enemy move or passage?
- Which diagnostic and practice tools are essential?
- How does formal-fight pressure work without an external beat?
- What distinguishes a level-two minion from multiple level-one minions?
- How do combinations of familiar enemies create new learning rather than only numerical difficulty?
- How do damage, defence, failure, recovery, feedback, and balance work?
- How should the board's earlier candidates—four schools, counter windows, an air-like damage-nullification state, spell chanting, resources, and defeat states—relate to the three pillars, if they survive at all?

The board mechanics remain candidates. They have not been promoted to combat rules.

## Narrative

### Purpose and reference material

The NarrativeRoom thread is being used to develop a pitch set in the world and continuity of *Heroes of Might and Magic III* and its two expansions. A broad chronology was researched, but no historical period was selected as the canonical setting for the pitch.

The chronology is reference material, not a design decision.

### Candidate pitch material found on the board

These ideas were present in the Miro material, but were not all explicitly selected as the final pitch:

- The player delivers a message while holding the ground.
- Failure leads into the original *Heroes III* opening.
- Success creates an alternate “if” timeline.
- The ending may bridge directly into the *Heroes III* opening cinematic.
- The alternate line may continue toward the darker *Might and Magic VII* storyline and the Forge faction.
- The player repeatedly returns to a castle, acts as a faction champion, and can advise its development.
- Castle construction becomes visible over time; major creature side quests can cause creatures to inhabit the settlement.
- The wider structure may be a semi-open world.
- A demo may centre on one polished boss encounter while establishing a reusable framework for the wider universe.

Additional Sandro-era material was recorded as possible pitch expansion, including the Falorel/Vayarad replacement, Gelu's investigation and atonement, the Shandar frontier, mass undead conversion, and links among Gelu, Gem, Sandro, and the other campaign heroes. These are also candidates, not approved canon changes for this project.

### Open narrative questions

- Is the heart of the pitch the doomed canonical bridge, or the possibility of breaking history and opening the alternate timeline?
- Which historical window is the present-day setting: the Sandro-era prequel, the Restoration War, or the later Armageddon's Blade period?
- What is the player's precise role, identity, and reason for carrying the message?
- Which board material is the actual pitch and which is background-lore research?
- Is the castle the central home and narrative anchor, and what does “advising” it mean in play?
- Are death transformation, money recovery, castle growth, creature side quests, and the demo boss part of the pitch or merely parked ideas?

No final narrative premise, setting period, or ending choice was explicitly confirmed in the thread.

## Cross-thread relationships

- Both threads remain upstream design exploration. Neither currently authorises implementation.
- **Possible relationship, not a decision:** the combat practice/test loop could provide the gameplay vehicle for a narrative about delivering a message and holding ground.
- The canonical-versus-alternate-history choice may affect what combat failure and victory mean, but that relationship is unresolved.
- The combat foundation is currently less settled than the list of mechanics on the board; the narrative thread likewise contains more candidate material than selected pitch decisions.
- Proposals, board research, and working interpretations should remain separate from canonical project documents until explicitly accepted.

## Next actions

1. In Combat, define the first of the three pillars as a player experience. Do not add more mechanics before the pillars earn confidence.
2. In Narrative, choose the central pitch heart and the historical window before treating the surrounding board material as canonical.
3. Keep the Miro lore/research inventory separate from accepted project decisions.
4. When a decision is deliberately accepted, promote it explicitly into the appropriate project document; do not treat this checkpoint itself as approval.

