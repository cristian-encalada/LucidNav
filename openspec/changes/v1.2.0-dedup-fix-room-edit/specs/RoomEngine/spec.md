# Spec: RoomEngine changes — v1.2.0

## MODIFIED

### `deDuplicateMap(orig, dupe)` (lines 337–391)

**Before:** Single-pass BFS. The `dcur` cleanup (hide button, nil from `rooms[]`) is nested inside `if not cur.visited`. When BFS visits the same orig-tree node twice via different dupe-tree paths, the second dupe room is never wiped — leaving it in `rooms[]` with intact neighbor pointers (orphan).

**After:** Two-phase algorithm.

**Phase 1 — gather (no mutations):**
- Maintain `visitedOrig` and `visitedDupe` sets (keyed by room reference, not the `.visited` field).
- BFS from `(orig, dupe)` pairs in two parallel queues.
- For each `(cur, dcur)` pair dequeued:
  - For each direction `i` (1–4):
    - If `cur.neighbors[i] == nil` and `dcur.neighbors[i] ~= nil`: record graft `{cur, i, dcur.neighbors[i]}`; enqueue `(dcur.neighbors[i], nil)`.
    - If both non-nil: enqueue `(cur.neighbors[i], dcur.neighbors[i])`.
  - Record `dupeMap[dcur] = cur` if `dcur ~= nil`.
  - Skip pair if already in the respective visited set.

**Phase 2 — apply:**
- 2a. Apply grafts: `cur.neighbors[i] = n2`; `n2.neighbors[getOppositeDir(i)] = cur`.
- 2b. Global pointer rebind: iterate every room in `rooms[]`; for each neighbor pointer whose target is a key in `dupeMap`, redirect to `dupeMap[target]`.
- 2c. Transfer POIs: for each `dcur` in `dupeMap`, if `dcur.poi_index ~= 0`, copy to `cur` and update `poirooms[]`. Conflict: `cur`'s POI wins; clear `poirooms[dcur.poi_index]`.
- 2d. Remove dupes: `wipe(dcur.neighbors)`; `wipe(dcur.walls)`; nil `rooms[dcur.index]`; hide button + return to pool.
- 2e. If `current_room` is in `dupeMap`, reassign and call `setCurrentRoom`.
- 2f. If `selected_btn.room` is in `dupeMap`, clear `selected_btn` and hide `selMarker`.
- 2g. Call `ns.GridMap.Refresh()`.

**Dropped:** `dcur.dupedTo = cur` line (dead code; nothing reads `dupedTo`).

---

### New public Engine API functions

#### `Engine.EraseRooms()`
Promotes private `eraseRooms()`. Called by History.Undo.

#### `Engine.SerializeMap() → string`
Extracts CSV serialization from the logout handler. Returns the CSV string. Used by `History.Snapshot` and `Engine.DumpMap`.

#### `Engine.ImportMap(text: string)`
Refactors `importMapFromString` to accept a string arg directly. The existing `Engine.ImportMap()` editbox wrapper is updated to call `Engine.ImportMap(ns.eb:GetText())`.

#### `Engine.SetSelectedByIndex(idx: number)`
Finds `rooms[idx]` and calls `setSelectedBtn(rooms[idx].button, true)`. No-ops if room not found.

#### `Engine.UnlinkNeighbor(room, dir: number)`
Clears `room.neighbors[dir]` and the back-link on the neighbor. Calls `ns.GridMap.Refresh()`.

#### `Engine.DetachRoom(room)`
Calls `Engine.UnlinkNeighbor(room, i)` for all 4 directions. Calls `ns.GridMap.Refresh()`.

---

### Snapshot hook points added

| Location | Label |
|----------|-------|
| Start of `addRoom` (when `not forceJump`) | `"Map room"` |
| Start of `deDuplicateMap` | `"Dedup"` |
| Start of `Engine.HitTheTrap` | `"Trap"` |
| `Engine.ResetMap` (user-facing reset) | `"Reset"` |

**Note:** The per-step `"Map room"` snapshot in `addRoom` is what makes Undo
revert one mapping step at a time (the headline user expectation).

The `"Reset"` snapshot lives in the public `Engine.ResetMap`, **not** the
internal `resetMap`. The internal `resetMap` runs at addon startup
(`Engine.Init`), so snapshotting there would poison the undo stack with an
empty-map "Reset" entry that wipes the map on first Undo. `resetMap` no longer
touches History at all.
