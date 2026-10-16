# Cross-machine pickup — complete active-thread audit

This schema 4 checkpoint follows 2026-10-16-game-feel (b98eba3). The project-scoped unarchived metadata listing was exhausted, and recent actual dialogue was read for all ten current tasks. Older dialogue remains partial except Random notes: feedback, whose three rounds were all read. No full conversation transcript is stored.

## Current tasks

| Independent task | Department or position | Recovery note |
| --- | --- | --- |
| Production Manager | Standalone position | [production-manager.md](production-manager.md) |
| Combat | Combat | [combat.md](combat.md) |
| RAE dead cell | Combat | [dead-cells-attack-styles.md](dead-cells-attack-styles.md) |
| Random notes: feedback | Combat | [feedback-notes.md](feedback-notes.md) |
| Art | Art | [art.md](art.md) |
| Laema Audio | Audio | [audio.md](audio.md) |
| Design overseer | Design Overseer | [design-overseer.md](design-overseer.md) |
| Marketing | Marketing | [marketing.md](marketing.md) |
| Town Design | Town Design | [town-design.md](town-design.md) |
| Narrative Room | Narrative | [narrative-room.md](narrative-room.md) |

Combat, RAE dead cell and Production Manager advanced since the preceding save. Other progress UIDs were verified unchanged. Departments have independent content UIDs, so a matching task UID alone does not justify skipping changed shared context.

## Archived and external context

DUM.E, HMM3 and Improve Laema iteration tools are now archived. Their preceding notes are retained through manifest reference entries, along with all prior bindings and confirmed assignments. Do not recreate them or substitute them for current same-department chats. Earlier archived and unavailable references remain in the manifest/history.

The generated Art sprite and native comparison PNG are in the depot. The full original HMM3 extraction and reported ZIP are not; do not assume Git transfers those external assets. Presentation preparation remains closed, and dormant narrative/town/audio work is not restarted by a save.

## On the other computer

Use load checkpoint from a clean Laema checkout. Resolve tasks using stable task keys, confirmed aliases and binding history; read the frozen departments and task notes, compare actual local UIDs and verify responses from restored tasks. Missing bindings remain unresolved rather than silently creating new chats. Local changes block load and must not be discarded automatically.

The initial b98eba3 save carries the complete source/configuration/scenes/assets/output candidate scope. This follow-up adds the verified complete active-task census, newer explanations and portable Art comparison. Neither save establishes new gameplay approval, publishes a live build, or proves the other computer has loaded it.
