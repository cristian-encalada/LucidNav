# Change Proposal: v1.3.0 — Undo Fix, Orphan/Delete, Checkpoints, Map Clarity

## Summary

Post-v1.2.0 user feedback (CurseForge comments, 2026-06-21/22) on the freshly
shipped Undo feature surfaced one confirmed bug and several UX gaps that all
point at the same theme: **the map is the product**. LucidNav exists to replace
paper mapping, so anything that makes the on-screen map drift, overlap, or
silently get out of sync undermines the core value.

Five converging work items:

1. **Undo does not refresh the Grid Map (confirmed bug).** User *blenderkitten*:
   "the only issue was the 'undo' button — it didn't actually reset a re-drawn
   grid." Root cause: `History.Undo()` (`Core/History.lua:32-42`) calls
   `Engine.EraseRooms()` → `Engine.ImportMap()` → `Engine.SetSelectedByIndex()`,
   and **none of those call `ns.GridMap.Refresh()`**. Every other map mutation
   (`setPOIClick`, `UnlinkNeighbor`, `DetachRoom`, `deDuplicateMap`,
   `addRoom`/`createButton`) ends with a grid refresh — the undo path is the
   one mutation that forgot it. The main canvas rebuilds (ImportMap recreates
   buttons), so the 8×8 Grid Map window keeps showing the stale, "re-drawn"
   state, which is exactly what the user described.

2. **Orphan / detached rooms have no cleanup path.** v1.2.0 added
   *Unlink neighbor* and *Detach* but no *Delete*. A detached room stays in
   `rooms[]`: it keeps its `cx/cy` cell, still serializes to SavedVariables,
   still renders a button, and is unreachable by navigation BFS. Worse, because
   `addRoom` scans `rooms[]` for any room at the target cell
   (`Core/RoomEngine.lua:279-287`), a leftover orphan sitting on a cell triggers
   a phantom "jump over / merge" dialog when the player later walks into that
   space. So orphans are **not** harmless — they clutter the map and corrupt
   future mapping. They need an explicit delete and a visible "disconnected"
   indicator.

3. **No persistent checkpoints (the screenshot-replacement).** *blenderkitten*:
   "I saved screenshots of all of the navigator maps every time I made
   progress… when I messed it up I could navigate back to a point of reference,
   wipe the map, and use my most recent screenshots." The in-memory Undo stack
   (20 steps) is lost on `/reload` and is step-granular, not milestone-granular.
   Users want named restore points that survive reloads — an in-game
   replacement for the screenshot habit.

4. **Overlapping rooms break click targets and readability (core value).**
   *blenderkitten*: "failed to click overlapping button." The main canvas places
   each new room at `current_room.(cx,cy) + direction_offset`
   (`Core/RoomEngine.lua:268-298`) — pure dead-reckoning. The Endless Halls maze
   is an **8×8 grid that wraps toroidally with an unpredictable offset** (see
   `design.md`), so dead-reckoning inevitably drifts and loops back on itself.
   When the target cell is occupied, `getRoomJumpOffset` (lines 256-266) slides
   linearly in one direction until it finds a free cell, which scatters rooms and
   crams unrelated cells against each other. The result: overlapping/abutting
   buttons that are hard to click and a map that no longer reads cleanly.

5. **Trap mis-marks can't be cleared from the menu.** *blenderkitten*: "telling
   it the wrong spot I had been teleported." The "I got ported!" flow marks a
   trap room but there is no quick un-mark. Add *Clear trap* to the right-click
   menu.

## Intended Outcome

- Undo always leaves the Grid Map and canvas consistent with the restored state.
- Orphaned rooms can be deleted and are visually flagged while they exist.
- Players can save and restore named map checkpoints that survive `/reload`.
- The map no longer scatters or overlaps rooms; every room cell is clickable.
- A mis-marked trap room can be corrected in one click.

## Scope

### In scope (MVP)
- **Item 1 — Undo refresh fix:** add `ns.GridMap.Refresh()` to the end of
  `Engine.ImportMap` (covers undo + every other import path).
- **Item 5 — Clear trap menu item** + `Engine.ClearTrap(room)`.
- **Item 2 — Delete room:** `Engine.DeleteRoom(room)` (pool/serialization-safe)
  + *Delete room* menu item + a dim/red "disconnected" border on rooms with zero
  neighbors.
- **Item 3 — Checkpoints:** `Core/Checkpoints.lua` — save/restore named snapshots
  to `LucidNavDB.checkpoints`; toolbar Save/Restore buttons + `/ln save <name>` /
  `/ln restore <name>` / `/ln checkpoints`.
- **Item 4 — Map clarity, Phase 1 (incremental):**
  - Replace the linear slide in `getRoomJumpOffset` with a nearest-free-cell
    spiral search around the ideal cell.
  - Draw explicit connector lines between linked rooms that are not physically
    adjacent on the canvas (so a logical link is never invisible).
  - Raise z-order (frame level) of the selected and current room so overlapping
    cells stay clickable.
- **Item 6 — Memory/perf:** stop the per-frame `OnUpdate` from re-allocating the
  X/Y coordinate label strings every frame (throttle to ~10/sec + dirty-check).
  This was the addon's dominant GC-churn source.

### Out of scope (deferred to v1.4.0)
- **Item 4 — Map clarity, Phase 2:** full incremental grid-snapped
  constraint/force-directed relayout of the room graph (see `design.md`). Larger
  effort; Phase 1 must prove the connector-line + spiral approach first.
- Toroidal-offset auto-detection / true 8×8 torus embedding.
- Auto-pruning of orphans on detach (data-loss risk — explicit delete only).

## Affected Files

| File | Status |
|------|--------|
| `Core/RoomEngine.lua` | Modified (ImportMap refresh, ClearTrap, DeleteRoom, spiral search, connector lines) |
| `Core/History.lua` | Unchanged logic (fixed transitively via ImportMap) |
| `Core/RoomMenu.lua` | Modified (Clear trap, Delete room items) |
| `Core/MapUI.lua` | Modified (Save/Restore toolbar buttons, disconnected border) |
| `Core/GridMap.lua` | Possibly modified (reflect deleted rooms) |
| `Core/Checkpoints.lua` | Added |
| `LucidNav.lua` | Modified (save/restore/checkpoints slash args) |
| `LucidNav.toc` | Modified (register Checkpoints.lua, bump version) |

## Version Bump
`1.2.0` → `1.3.0`
