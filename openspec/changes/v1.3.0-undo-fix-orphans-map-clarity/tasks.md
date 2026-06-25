# Tasks: v1.3.0 — Undo Fix, Orphan/Delete, Checkpoints, Map Clarity

## Status legend
- [ ] pending
- [x] done

---

## 1. Fix Undo not refreshing the Grid Map (Item 1 — confirmed bug)
**File:** `Core/RoomEngine.lua`

- [x] 1.1 Added `refreshMapViews()` (Grid Map + connectors) at the end of
      `Engine.ImportMap`, so every import path — Undo, checkpoint restore, login
      load, editbox import — leaves the Grid Map in sync.
- [x] 1.2 `History.Undo` left untouched; fixed transitively via ImportMap.
- [ ] 1.3 Verify current-room marker + selection marker are correct after undo
      (in-game).

## 2. Clear trap from menu (Item 5)
**Files:** `Core/RoomEngine.lua`, `Core/RoomMenu.lua`

- [x] 2.1 Added `Engine.ClearTrap(room)` — snapshot "Clear trap"; clear
      `room.is_trap`; nil `trapRoom` if it was this room; `recolorRoom`;
      `UpdateNavButtonText`; `refreshMapViews`.
- [x] 2.2 Added menu item "Clear trap" — shown only when `room.is_trap` is true
      (modern + legacy menus).
- [ ] 2.3 (Optional, deferred) "Mark as trap" — skipped; trap marking is tied to
      `last_dir` wall logic in `HitTheTrap` and doesn't generalize to an
      arbitrary room cleanly. Out of scope for v1.3.0.

## 3. Delete room + orphan handling (Item 2)
**Files:** `Core/RoomEngine.lua`, `Core/RoomMenu.lua`, `Core/MapUI.lua`

- [x] 3.1 Added `Engine.DeleteRoom(room)` — snapshot "Delete room"; sever all 4
      neighbor back-links; clear POI; clear trap; hide button + return to `pool`;
      `rooms[room.index] = nil`; fix `current_room`/`selected_btn`;
      `UpdatePOIButtonText`/`UpdateNavButtonText`/`refreshMapViews`.
- [x] 3.2 Guard: refuses to delete the only room; reassigns current to a former
      neighbor (else any surviving room) before removal; never leaves
      `current_room == nil` while rooms remain.
- [x] 3.3 Menu item "Delete room" added (modern + legacy).
- [x] 3.4 Disconnected flag — `recolorRoom` draws a red border
      (`cellColor.orphanBorder`) on any zero-neighbor room except the current
      room; unlink/detach/delete recolor affected rooms. (Grid Map mirror
      deferred — canvas indicator is sufficient.)
- [ ] 3.5 Verify (in-game) a deleted room no longer triggers the phantom
      jump-over dialog when re-entering its cell.

## 4. Persistent checkpoints (Item 3)
**Files:** `Core/Checkpoints.lua` (new), `Core/MapUI.lua`, `LucidNav.lua`,
`LucidNav.toc`

- [x] 4.1 Created `Core/Checkpoints.lua` exposing `ns.Checkpoints`.
- [x] 4.2 `Checkpoints.Save(name)` — stores `{name, csv, saved, ts}` in
      `LucidNavDB.checkpoints`; overwrites same name; caps at 10 dropping oldest
      by `ts`.
- [x] 4.3 `Checkpoints.Restore(name)` — `History.Snapshot("Pre-restore")` then
      `Engine.ImportMap(csv)`.
- [x] 4.4 `Checkpoints.List()` (sorted newest-first) / `Checkpoints.Delete(name)`.
- [x] 4.5 Toolbar "Save" + "Restore" buttons (Restore opens a MenuUtil list with
      timestamps and a per-entry Delete submenu).
- [x] 4.6 Slash args: `save <name>`, `restore <name>`, `checkpoints`.
- [x] 4.7 Registered `Core\Checkpoints.lua` in `.toc` after History.lua.

## 5. Map clarity — Phase 1 (Item 4)
**File:** `Core/RoomEngine.lua` (+ `Core/MapUI.lua` for z-order)

- [x] 5.1 Replaced the linear slide in `getRoomJumpOffset` with a
      nearest-free-cell **Chebyshev-ring spiral search** around the ideal cell;
      extracted `cellIsFree(cx,cy)`.
- [x] 5.2 Connector lines via `ns.container:CreateLine` (`refreshConnectors`):
      for every linked pair not in physically adjacent cells, draws a line
      between button centers; pooled and recomputed by `refreshMapViews` on every
      map mutation.
- [x] 5.3 Z-order: `FL_BASE/FL_CURRENT/FL_SELECTED` frame levels — current and
      selected rooms raised above neighbors.
- [ ] 5.4 Verify (in-game): loop-heavy walk has no unclickable overlaps and
      connector lines render correctly.

## 5b. Performance — OnUpdate allocation churn (memory)
**File:** `Core/RoomEngine.lua`

Root cause: `onUpdate` runs every frame and rebuilt the X/Y coordinate label
strings (`"X: ..." .. math.floor(x) .. "|r"`) on **every frame**, allocating two
new strings ~60×/sec even while standing still — the dominant source of the
addon's GC churn / elevated memory.

- [x] 5b.1 Accept `(self, elapsed)` in `onUpdate`; accumulate `elapsed`.
- [x] 5b.2 Throttle the X/Y label updates to ~10/sec (0.1s).
- [x] 5b.3 Dirty-check: only `SetText` when the integer coordinate changed
      (cache `lastShownX/Y`) — near-zero allocation when stationary.
- [ ] 5b.4 Verify (in-game) with `/run UpdateAddOnMemoryUsage()` +
      `GetAddOnMemoryUsage("LucidNav")` before/after that memory growth/sec drops.

## 6. Version + housekeeping
**Files:** `LucidNav.toc`, `CHANGELOG.md`

- [x] 6.1 Bumped `## Version:` to `1.3.0`.
- [x] 6.2 Added `## [1.3.0]` CHANGELOG entry.
- [ ] 6.3 Update `openspec/specs/*` source-of-truth specs to fold in v1.3.0
      (do at archive time, after in-game verification).

## 7. Verification
- [ ] 7.1 Undo after any mutation → Grid Map matches canvas (the reported bug).
- [ ] 7.2 Detach then Delete a room → gone from canvas, grid, and CSV; no phantom
      jump-over when re-entering that cell.
- [ ] 7.3 Orphan (0 neighbors) shows disconnected border on canvas + grid.
- [ ] 7.4 Save checkpoint → `/reload` → Restore brings it back; restore is
      undoable.
- [ ] 7.5 Clear trap removes orange marker and re-enables routing through it.
- [ ] 7.6 Heavy loop walk: rooms land near ideal cells; non-adjacent links show
      connector lines; no unclickable overlaps.
- [ ] 7.7 Load a pre-1.3.0 saved map → parses cleanly; no checkpoints key crash.
