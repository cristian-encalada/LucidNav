# Changelog

All notable changes to this project will be documented in this file.

---

## [1.5.0] - 2026-07-05

### Added
- **Rune & orb icons on the map.** POI rooms now show the actual rune glyph or
  orb icon (tinted to the POI colour) in the corner of the cell — on both the
  main canvas and the 8×8 Grid Map — instead of just a coloured cell / "R"/"O"
  text prefix.
- **Live step counts on navigation targets.** Each rune/orb/trap button shows
  its distance from your current room (`(N)`), updated on every move, with
  `(here)` when you're standing on it. Wall-aware and trap-aware, so the count
  always matches the actual guidance route.
- **Match tracker.** A per-colour ✓ toggle marks a rune+orb pair as matched;
  matched pairs dim out and their nav buttons grey out, so you can see at a
  glance what's left. State persists across `/reload` and resets with New Map.
- **Unreachable-POI warning.** If a wall toggle accidentally seals off a known
  rune or orb, LucidNav warns you in chat the moment it happens instead of
  silently losing the route.
- **Player arrow on the Grid Map.** Your current cell is marked with the same
  facing arrow used on the main map, oriented to your heading.
- **Current-room reference panel.** A 5-cell cross at the top-right with
  **N/E/S/W buttons** to toggle the selected room's walls directly — no more
  fiddly edge-clicking.
- **Edge-hover wall highlight.** Hovering a cell edge highlights exactly which
  wall you're about to toggle.
- **Grid edge-wrap hints.** Hover a border cell in the Grid Map to light up the
  exact cell you'd emerge in after the maze's ±4 wrap, with a tooltip naming it
  (e.g. `South -> A7`) — Pac-Man-tunnel style.

### Changed
- **Overlapping / cross rooms now use an amber tint** instead of dashed walls,
  so intentional maze crosses no longer look like broken/unresolved walls
  (dashes were confusing right after a Jump Over).
- **Clearer 8×8 Grid Map.** Dropped the cyan cross-cell borders and the dashed
  wall segments (visual noise); blocked edges now draw as a single bold solid
  bar so the grid reads plainly as a map of the maze walls.
- Navigation detection messages dropped the `Hello, user!` prefix for a cleaner
  readout on each room change.

### Fixed
- **Step counts no longer route through trap rooms.** `bfsDistances` now honours
  the same "never traverse a trap" rule as navigation, so displayed counts match
  the real guidance length (previously a count could be short by the steps saved
  by cutting through the trap, dropping the final direction from the guidance).

### Docs
- Documented the new features in the README and corrected the maze-reset
  explanation: the Endless Halls are regenerated per character from
  `playerGUID + realm date` at ~realm midnight, **not** the instance lockout.

---

## [1.4.0] - 2026-06-25

### Changed
- **Paper-style map.** Blocked walls are now drawn as lines along the cell edges
  (open sides are gaps), replacing the old X / mute icon — both on the main map
  canvas and the 8×8 Grid Map. Cells sit closer together so the map reads like a
  hand-drawn maze.
- **Overlapping / non-intersecting-cross rooms use dashed lines** to set them
  apart from normal rooms (rooms sharing a maze cell or the same canvas position).
- The teleport-trap room is now marked with the **skull icon** in the 8×8 Grid
  Map (matching the main canvas), replacing the old "T" label.

### Added
- **Grid Map wrap markers.** The 8×8 Grid Map now shows the maze's edge wrap
  (opposite side with a fixed +4-cell offset): directional arrows on each edge
  plus offset labels on the right (wrapped row) and bottom (wrapped column).

---

## [1.3.0] - 2026-06-25

### Added
- **Delete room** — right-click any room → *Delete room* to remove it (with its
  POI/trap and all links). Orphaned rooms left by *Unlink* / *Detach* can now be
  cleaned up instead of cluttering the map and triggering phantom merge prompts.
- **Disconnected-room indicator** — rooms with no remaining links are drawn with
  a red border so orphans are easy to spot.
- **Clear trap** — right-click a teleport-trap room → *Clear trap* to un-mark a
  mis-flagged trap room.
- **Map checkpoints** — *Save* / *Restore* buttons (and `/ln save <name>`,
  `/ln restore <name>`, `/ln checkpoints`) persist named map snapshots to
  SavedVariables. They survive `/reload` — an in-game replacement for
  screenshotting the map at each milestone. New module `Core/Checkpoints.lua`.

### Fixed
- **Undo now refreshes the Grid Map.** The 8×8 Grid Map (and connector lines)
  used to keep showing the stale "re-drawn" state after an Undo because the
  import path never refreshed it; `Engine.ImportMap` now refreshes all auxiliary
  views, so Undo, checkpoint restore, and login load all stay in sync.

### Changed
- **Cleaner map layout.** New rooms that can't sit in their ideal cell now use a
  nearest-free-cell spiral search instead of sliding down one axis, so the map
  no longer scatters. Linked rooms that don't end up physically adjacent are now
  joined by a connector line so a link is never invisible.
- **Overlapping cells stay clickable.** The current and selected rooms are raised
  above their neighbors so abutting/overlapping cells can still be clicked.
- **Lower memory usage.** The per-frame `OnUpdate` no longer rebuilds the X/Y
  coordinate label strings every frame; updates are throttled to ~10/sec and
  skipped when the value is unchanged, removing the addon's main source of
  garbage-collection churn.

---

## [1.2.0] - 2026-06-16

### Added
- **Undo** — in-memory history stack (up to 20 steps). Each new room mapped, dedup, trap mark, jump-over, and full reset can be reverted. Trigger via the new toolbar Undo button or `/ln undo`.
- **Right-click room menu** — right-click any room cell for: *Set as current room*, *Unlink neighbor* (per-direction submenu), *Detach (unlink all neighbors)*, and *Undo last action*. Lets you correct mis-marked rooms or wrong neighbor links without resetting the whole map (requested by skyrunner1833).
- New modules `Core/History.lua` and `Core/RoomMenu.lua`.
- WoW 12.0.7 interface version (`120007`) added to TOC.

### Fixed
- **Map deduplication no longer leaves orphan rooms.** The "WOAH WOAH WOAH" POI dedup is now a two-phase pass (gather, then apply) with a global neighbor-pointer rebind, so collapsing a loop never strands rooms or leaves stale links on the grid map.

### Changed
- Refactored serialization/import/erase into public `Engine` API; added `Engine.UnlinkNeighbor`, `Engine.DetachRoom`, `Engine.SetSelectedByIndex`.
- Right-click menu uses the modern `MenuUtil` API (with an `EasyMenu` fallback for older clients).
- Project now tracks design intent under `openspec/` (OpenSpec change proposal, tasks, and source-of-truth specs).

---

## [1.1.0] - 2026-06-15

### Changed
- Refactored the addon into a modular `Core/` architecture with UI enhancements.
- Shrank the player arrow and polished the map UI; updated README with new screenshot and UI credits.
- Clarified logout/crash respawn behavior in the help dialog and added a daily-reset warning.

### Fixed
- Save/load: rooms with negative coordinates were lost on reload.

---

## [1.0.1] - 2026-04-21

### Changed
- Added WoW 12.0.5 interface version (`120005`) to TOC for compatibility with the April 21 patch

---

## [1.0.0] - 2026-03-13

### Initial Release — LucidNav

This release marks the first independent version of the addon, forked and significantly
enhanced from [LucidNightmareNavigator](https://github.com/Debuggernaut/LucidNightmareNavigator)
by Wonderpants of Thrall.

### Added
- **8×8 grid map** — live visual overview of explored rooms with wall indicators and colored POI markers
- **Grid map auto-refresh** — updates automatically when a new orb or rune is marked
- **Teleport trap detection** — trap room is flagged with a persistent orange marker; navigation routes around it
- **"I just got ported!" button** — immediately marks the trap room and recalculates navigation
- **Map persistence** — progress saved to `SavedVariablesPerCharacter` and reloaded on login
- **Colored POI navigation buttons** — visual found/unfound state for each rune and orb
- **WoW 12.x (The War Within) compatibility** — TOC updated for interface versions 120000/120001
- **MIT License**

### Changed
- Renamed addon from `LucidNightmareNavigator` to `LucidNav`
- Updated TOC: title, author, email, BattleTag, and SavedVariables key
- Rewrote README with full feature list, usage guide, controls, notes, and credits
- Updated `release.sh` to use the new addon name

### Fixed
- Teleport trap handling no longer corrupts the map state
- Removed obsolete XML tag that caused Lua warnings on load

---

## Prior History (Upstream)

For changes prior to this fork, see the original repository:
[github.com/Debuggernaut/LucidNightmareNavigator](https://github.com/Debuggernaut/LucidNightmareNavigator)
