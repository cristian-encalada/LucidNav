# Tasks: v1.2.0 — Dedup Fix + Room Edit Affordances

## Status legend
- [ ] pending
- [x] done

---

## 1. Fix `deDuplicateMap` (two-phase rewrite)
**File:** `Core/RoomEngine.lua` (function at lines 337–391)

- [x] 1.1 Phase 1 — gather: BFS with separate `visitedOrig` / `visitedDupe` sets; collect `grafts[]` and `dupeMap[]`; never mutate room state
- [x] 1.2 Phase 2a — apply grafts: set `cur.neighbors[i] = n2` and back-link
- [x] 1.3 Phase 2b — global pointer rebind: walk every room in `rooms[]`; redirect any neighbor pointer whose target is in `dupeMap`
- [x] 1.4 Phase 2c — transfer POIs: copy `poi_index` from dcur → cur; handle conflict (cur wins); update `poirooms[]`
- [x] 1.5 Phase 2d — remove dupes: hide buttons, return to pool, nil `rooms[dcur.index]`
- [x] 1.6 Phase 2e — fix `current_room` if it was a dupe; call `setCurrentRoom`
- [x] 1.7 Phase 2f — clear `selected_btn` if it belonged to a wiped room
- [x] 1.8 Phase 2g — call `ns.GridMap.Refresh()`
- [x] 1.9 Keep trap-room guard; drop dead `dcur.dupedTo` line

## 2. Promote private functions to public Engine API
**File:** `Core/RoomEngine.lua`

- [x] 2.1 `eraseRooms` → `Engine.EraseRooms()`
- [x] 2.2 `importMapFromString(text)` → `Engine.ImportMap(text)` (accept string arg; keep editbox wrapper)
- [x] 2.3 Extract `Engine.SerializeMap()` returning CSV string (used by History + DumpMap)
- [x] 2.4 Add `Engine.SetSelectedByIndex(idx)` so selection survives undo
- [x] 2.5 Add `Engine.UnlinkNeighbor(room, dir)` for menu
- [x] 2.6 Add `Engine.DetachRoom(room)` for menu

## 3. Add snapshot hook points in RoomEngine
**File:** `Core/RoomEngine.lua`

- [x] 3.1 Snapshot at start of `deDuplicateMap`
- [x] 3.2 Snapshot inside `Engine.HitTheTrap`
- [x] 3.3 Snapshot in `Engine.ResetMap` (NOT internal `resetMap` — that runs at startup and would poison the stack)
- [x] 3.4 Snapshot in `addRoom` (when `not forceJump`) so Undo reverts one mapping step at a time

## 4. Create `Core/History.lua`
**File:** `Core/History.lua` (new)

- [x] 4.1 `History.Snapshot(label)` — serialize + push onto stack (cap 20)
- [x] 4.2 `History.Undo()` — pop; call `Engine.EraseRooms` + `Engine.ImportMap` + `Engine.SetSelectedByIndex`; print label
- [x] 4.3 `History.Clear()` — wipe stack (API retained; reset is now undoable so no longer auto-called)
- [x] 4.4 `History.HasEntries()` — returns bool (used by menu to enable/disable Undo item)

## 5. Add snapshot in Dialogs — Jump Over
**File:** `Core/Dialogs.lua`

- [x] 5.1 Call `ns.History.Snapshot("Jump over")` inside the "No, jump over" button handler before `ns.Engine.JumpOver()`

## 6. Create `Core/RoomMenu.lua`
**File:** `Core/RoomMenu.lua` (new)

- [x] 6.1 Use `MenuUtil.CreateContextMenu` (modern API; `EasyMenu` removed in 12.x) with legacy fallback
- [x] 6.2 `RoomMenu.Show(room)` — build and open dropdown at cursor
- [x] 6.3 Menu item: "Set as current room" (always enabled)
- [x] 6.4 Menu item: "Unlink neighbor ▶" submenu (N/E/S/W of present directions; snapshots + clears both sides)
- [x] 6.5 Menu item: "Detach (unlink all)" (enabled when room has ≥1 neighbor; snapshot + clear all 4 pairs)
- [x] 6.6 Menu item: "Undo last action" (enabled when history stack non-empty)

## 7. Wire right-click on room cells
**File:** `Core/MapUI.lua`

- [x] 7.1 Change `createCell` click registration to `RegisterForClicks("LeftButtonUp", "RightButtonUp")`
- [x] 7.2 In `OnClick` handler: if `button == "RightButton"` call `ns.RoomMenu.Show(self.room)`
- [x] 7.3 Add "Undo" button to bottom-left toolbar area

## 8. Slash command dispatch
**File:** `LucidNav.lua`

- [x] 8.1 Parse first arg from slash handler
- [x] 8.2 `"undo"` → `ns.History.Undo()`
- [x] 8.3 default (no arg / toggle keywords) → `ns.MapUI.Toggle()`

## 9. Register new files in .toc + bump version
**File:** `LucidNav.toc`

- [x] 9.1 Add `Core\History.lua` (after RoomEngine, before GridMap)
- [x] 9.2 Add `Core\RoomMenu.lua` (after Dialogs, before MapUI)
- [x] 9.3 Bump `## Version:` to `1.2.0`

## 10. Verification
- [x] 10.1 Dedup: walk loop where same room reachable via two paths; confirm no orphan cell
- [x] 10.2 Dedup edge case: rooms with cycles between subtrees; confirm no stale neighbor pointers
- [x] 10.3 Undo after dedup → both rooms reappear with POIs
- [x] 10.4 Undo after Detach → all 4 neighbor links restored
- [x] 10.5 Undo after Jump-over → severed link comes back
- [x] 10.6 Undo after Reset → full map returns
- [x] 10.7 Undo button in toolbar works same as `/ln undo`
- [x] 10.8 Snapshot stack caps at 20 silently
- [x] 10.9 Right-click menu appears at cursor for any room cell
- [x] 10.10 "Set as current" → player marker jumps
- [x] 10.11 "Unlink neighbor → North" → both cells lose N/S link
- [x] 10.12 "Detach" → room isolated but visible
- [x] 10.13 `/lucid`, `/ln`, `/lnn` with no args still toggle window
- [x] 10.14 `/reload` after dedup → map persists correctly
- [x] 10.15 Load pre-1.2.0 saved map → parses cleanly
- [x] 10.16 Left-click selection still works after RegisterForClicks change
- [x] 10.17 Right-click drag pan on scrollframe still works
