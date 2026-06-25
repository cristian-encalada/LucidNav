# Spec: RoomEngine — v1.3.0

## FIXED

### `Engine.ImportMap(text)` now refreshes the Grid Map

After rebuilding rooms and calling `UpdatePOIButtonText` / `UpdateNavButtonText`,
`ImportMap` MUST call `ns.GridMap.Refresh()` (guarded by `if ns.GridMap`).

This makes **every** import path leave the 8×8 Grid Map consistent with the main
canvas: Undo, checkpoint Restore, login load, and editbox import. Previously only
the canvas was rebuilt, so after an Undo the Grid Map showed the stale,
"re-drawn" state (reported by blenderkitten).

## ADDED

### `Engine.ClearTrap(room)`
- Snapshots `"Clear trap"`.
- If `room.is_trap`: clear the flag, set `trapRoom = nil` if it pointed here,
  `recolorRoom(room)`, `GridMap.Refresh()`.
- No-op if `room` is nil or not a trap.

### `Engine.DeleteRoom(room)`
- Snapshots `"Delete room"`.
- Severs all four neighbor back-links
  (`n.neighbors[opposite] = nil` for each present neighbor).
- Clears POI: `poirooms[room.poi_index] = nil`; clears trap if applicable.
- Hides the button and returns it to `pool`; sets `rooms[room.index] = nil`.
- If `current_room == room`: reassign to a surviving neighbor when one exists;
  otherwise refuse (must never leave `current_room == nil`).
- If `selected_btn.room == room`: clear selection + hide selection marker.
- Calls `UpdatePOIButtonText`, `UpdateNavButtonText`, `GridMap.Refresh()`.

## CHANGED

### `getRoomJumpOffset(baseCX, baseCY, dcx, dcy)` — spiral, not linear slide
- Previously walked linearly in the `(dcx,dcy)` direction until a free cell.
- Now searches outward in a **spiral around the ideal cell**
  `(baseCX+dcx, baseCY+dcy)` and returns the offset of the nearest free cell, so
  displaced rooms land as close as possible to where they belong instead of
  scattering down one axis.

### Connector lines for non-adjacent links
- After placement, for any room→neighbor link whose two cells are **not**
  physically adjacent on the canvas, the engine draws a line texture between the
  two button centers, so a logical link is never invisible. Recomputed on map
  mutation and pan.

### Disconnected-room indicator
- `recolorRoom` draws a dim/red border on any room with **zero** neighbors so
  orphaned rooms are visually obvious before the user deletes them.
