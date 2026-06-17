# Changelog

All notable changes to this project will be documented in this file.

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
