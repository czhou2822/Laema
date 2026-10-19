# Combat

Persistent development context shared by independent tasks. User decisions and the current GDD outrank summaries.

## Direction and constraints

- Target a semi-polished combat/tutorial playtest version by December 31, 2026. Analyze causes before guiding the user's own editor tuning. Presentation preparation remains closed.
- Preserve four schools, five global X/Cast progression positions and the optional sixth Cast endpoint. The proposed variable-length chain was withdrawn.
- October 19 decision: Charging/release Casting uses L2 across the prototype, Gym and Fire benchmark. Defence remains L1; the earlier R1 defence expression is not implemented by this change. Canonical controls, tutorial prompts, pressure HUD and Portal tooltips now use L2. Controller validation remains pending. Historical Heat-timer wording remains an Open documentation seam.

## Current combat decisions

- The October 16 receiver-side formula supersedes earlier offensive-power descriptions: reaction value = incoming Attack Impact minus receiver Poise minus receiver move Impact during its authored hit-capable active interval. Startup, recovery and idle contribute zero move Impact. Attacker Poise adds no offensive power; Impact/Poise tuning is 0–100.
- Physical melee contact with overlapping active intervals captures both receiver-side values. A positive result interrupts its receiver and cancels that attack before damage; Enemy abandons it and reassesses. If neither value is positive, connected damage applies and both attacks continue; reverse damage still requires contact. Only an exact 0/0 active clash favors Player with Level 1. Zero elsewhere does not qualify.
- Level selection follows eligibility. Default bands are 0–10, 11–20, 21–30, 31–40 and 41+, capped at Level 5. Current duration/distance pairs are 0.6 s/5 px, 0.9 s/10 px, 1.2 s/15 px, 1.5 s/20 px and 1.8 s/25 px. Ordered configurable starting values define the ranges; they do not change eligibility.
- Qualifying reactions move the collision body uniformly over the full duration, leave it displaced and grant invincibility for that duration. Walls block movement. Failed-Cast self-reactions remain vulnerable. Mixed-Cast primary/secondary layers resolve before one reaction begins. Existing effects continue advancing; invincible damage is rejected.
- Each move has individual Impact and motion data. Forward lunge maintains reach as targets are pushed away, but need not match their displacement. Animation active_start/contact/active_end markers author phase/contact; provisional active_end is swing completion.
- Practice targets retain non-attacking, pass-through, stationary visual recoil and finite-health refill behavior. Historical ordinary-hit non-interruption reports describe the old comparison baseline, not the new qualifying-reaction rule. Defence redesign, spell-versus-melee clashes and additional school/status interactions remain deferred.

## Implemented candidates

- LimboAI 1.8.1 supplies the Final Enemy tree and a preempting reaction branch; Entity/HealthResolver own snapshots, contact judgment, cancellation and mixed-hit transactions. Existing movement owners consume collision-aware reaction displacement. The independent DUM.E task retains task_key dummy and its earlier parser/refill history.
- Typed combat_tuning.tres and Inspector views share validated JSON with both Dev Portal surfaces. JSON supplies startup values; opening the editor/game does not write settings. Reaction-only tuning preserves an active reaction's captured lifetime; AI decision changes keep their reset behavior.
- Laema Dev Portal provides an offline editor dock, shared field catalog/renderer, guarded draft/save/reload and explicit debugger apply/session commands. Conflicting edits and ambiguous sessions are rejected. Series fill previews changes before updating drafts; level/range/legacy controls remain distinct. Legacy reaction tooltips must say they do not control new combat reactions.
- The standalone Gym reuses Arena/StageDirector without replacing tutorial configuration: Player and one refillable Final Enemy start 160 px apart in a bounded room. Run gym, encounter reload, Start/Esc pause/restart and a Gym formula display support tuning. Developer Overlay Visible/F4 is the single telemetry/formula visibility preference.
- Approved school references use current animations for all 20 X moves: slow Earth/Broadsword, medium Fire/Spartan Sandals, medium Water/War Spear and fast Air/Twin Daggers. X3/X4 vary the opener/follow-up; X5 finishes. Each move tunes windup/recovery, geometry, collision-aware forward motion and qualifying-reaction push scale. Heat scales timing once. Damage, Impact/Poise, reaction eligibility/duration/invincibility and Casting rules remain separate. Styles are captured at action start; provisional numbers need playtesting.
- RAE dead cell is independently identified by task_key dead_cells_attack_styles and directly assigned to Combat; it does not replace Combat or DUM.E.

## Evidence and Open items

- October 16 source/status records and task reports include isolated Godot 4.7.2 checks. The style slice reports 199 style/physics, 179 Portal/config/layout/Gym and 59 clash checks (437 total). Other iteration-tool checks have their own scopes; do not sum overlapping runs or claim this checkpoint reran them.
- Agent engine checks do not establish interactive feel, physical-controller/visual acceptance, ordinary-play coverage, a Web export or submission clearance. Earlier tuning waivers do not validate later candidates.
- Compare school rhythms on practice targets, then reactions/invincibility against the attacking Enemy. Verify marker placement, range, lunge, wall interactions, cancellation, Portal/Inspector persistence, pause/reload and user-visible layout.
- Final numbers, controls reconciliation, deferred defence/spell interactions and final art remain Open. The prior Dummy parser reload confirmation stays historical; no new refill defect is inferred.

## Resume point

User playtests the school presets and the integrated tuning/Gym workflow, reports a specific mismatch, and adjusts one cause at a time. Keep current approved reaction semantics and independently identified task history intact.

## Sources and coverage

- Current docs/GAME_DESIGN.md, DECISIONS.md, TECH_ARCHITECTURE.md, IMPLEMENTATION_STATUS.md, ATTACK_STYLES.md and GYM.md.
- Combat 01a07f71-17fd-7171-9f63-5859c0a9797d, latest round 01a14388-9766-7111-8d73-2831b07a25d4; four recent turns reread October 16. The user senses a change, not final acceptance. Explicit X windup/recovery overrides supersede shared Attack Duration; Fire X1 is 0.14 + 0.34 s before Heat. Diagnose one observed cause before guided tuning.
- DUM.E 01a07f71-ffdf-7160-bb0d-8ff06a78a0af, latest round 01a1396d-5770-7693-a892-c9c6b251112e; three recent turns read. Dummy-to-Combat assignment was confirmed October 12.
- RAE dead cell 01a14283-95da-78a3-9b36-8ed8e0cfb7c1, latest round 01a143a4-89b6-7f90-94ad-af941e928aa7; four recent turns reread. Explained provisional timing/lunges/geometry and Fire X5's 2× qualifying push with Impact 50 retained. Air's real-time input buffer shortens with faster playback. No new tuning or final approval.
- Prior checkpoint 2026-10-12-game-feel-limboai carries older sources/bindings. Earlier dialogue remains partial; preserve independent notes and current authority.

## Additional independent tasks — confirmed October 16

- Random notes: feedback (task_key feedback_notes, chat 01a13833-9b9c-7641-89ff-908a3c391812) records only: desired Cast school/count may not match the FIFO/lifetime orb queue, and representative HoMM spells could be prototyped later. These are notes, not approved new rules. Do not analyze, question or extend this task's notes.
- Improve Laema iteration tools (iteration_tools, 01a13d51-3252-7470-b60f-5d9d1f52c1aa) and DUM.E are now archived. Preserve their preceding checkpoint notes/bindings as references, not active restoration targets. The former's saved round reports the overlay correction and 221 engine checks; interactive validation remains separate.
