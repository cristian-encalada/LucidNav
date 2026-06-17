# Spec: History module — v1.2.0

## ADDED

### `Core/History.lua` (new file)

Module exposed as `ns.History`.

Snapshot encoding reuses the existing CSV format from `Engine.SerializeMap()`. Snapshots are in-memory only — never persisted to `SavedVariables`.

---

#### `History.Snapshot(label: string)`

- Calls `Engine.SerializeMap()` to get the current CSV.
- Records `current_room.index` and `selected_btn.room.index` (if any).
- Pushes `{csv, currentIdx, selectedIdx, label}` onto an internal stack.
- If stack size exceeds 20, silently drops the oldest entry.

#### `History.Undo()`

- Pops the top entry from the stack.
- If stack is empty, prints `"Nothing to undo."` and returns.
- Calls `Engine.EraseRooms()`.
- Calls `Engine.ImportMap(entry.csv)`.
- Calls `Engine.SetSelectedByIndex(entry.selectedIdx)`.
- Prints `"|cff00ff00LucidNav:|r Undid: <label>"` to chat.

#### `History.Clear()`

- Wipes the internal stack.
- Called by `resetMap` after pushing its own snapshot.

#### `History.HasEntries() → bool`

- Returns `#stack > 0`.
- Used by `RoomMenu` to enable/disable the Undo menu item.
