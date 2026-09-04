# Laema Art Direction

## Prototype Combat HUD Layout

Status: Approved visual direction for the prototype HUD layout.

### Player-facing HUD

- Upper-right: current stage objective.
- Above the target: target Health and Cast-result feedback.
- Bottom-left: persistent Heat and attack speed.
- Bottom-center: ten generated-orb slots and Charging progress.
- Player-facing terminology uses **generated**, **Charging**, and **charged** rather than `MARK`.

### Optional developer overlay

- Upper-left: Player and Enemy Health, Heat, speed, and Defence diagnostics.
- Top-middle: active school and chain state.
- Upper-right: raw R2 pressure and semantic pressure state.
- Diagnostics form one orderly top rail or aligned diagnostic group.
- Enabling the overlay must not obscure the objective or core combat HUD.
- Disabling the overlay leaves no empty diagnostic frames behind.

#### Live-combat priority

- The overlay prioritizes glanceable live telemetry while combat continues.
- It uses a fixed top rail with stable geometry and compact label-value pairs.
- Left: Player and Enemy Health, Heat, speed, and Defence state.
- Center: active school, five attack positions, and Cast endpoint; the current position receives the strongest emphasis.
- Right: raw R2 pressure and its semantic state.
- The objective moves below the rail while the overlay is enabled.
- Developer and player-facing HUD panels must not overlap or clip at supported display widths.

#### Event confirmations

- A fixed lane beneath the live telemetry shows recent system events.
- The newest event is prominent for approximately one second; up to two older events remain briefly at reduced emphasis.
- Repeated high-frequency results are aggregated where practical.
- Events include orb generation, Charging completion, Cast commitment, chain advancement or break, and applied or blocked damage.
- Normal events remain neutral, school actions receive the school accent, warnings use amber, and failures use red.
- Meaning is always reinforced with text and shape rather than color alone.
- Event activity never changes the rail’s dimensions.

### Open visual work

- Final visual styling, typography, icons, materials, motion, and polish.
- Final Laema art and final UI assets.
