# Spec: RoomMenu module — v1.2.0

## ADDED

### `Core/RoomMenu.lua` (new file)

Module exposed as `ns.RoomMenu`.

Uses the modern Blizzard menu API `MenuUtil.CreateContextMenu(UIParent, generator)` (Retail 11.0+ / 12.x), which anchors at the cursor automatically. A legacy `EasyMenu` + `UIDropDownMenuTemplate` path is kept as a fallback for older clients.

> **Note:** The original plan called for `EasyMenu`, but it was removed in Retail 12.x — calling it failed silently and no menu appeared. Ported to `MenuUtil` during testing.

---

#### `RoomMenu.Show(room)`

Builds and opens a dropdown menu scoped to `room`. Menu items:

| Item | Enabled when | Action |
|------|-------------|--------|
| Set as current room | always | `Engine.SetCurrentRoom(room)` |
| Unlink neighbor ▶ | room has ≥1 neighbor | Submenu: one entry per present direction (N/E/S/W); selecting one calls `History.Snapshot("Unlink " .. dirName)` then `Engine.UnlinkNeighbor(room, dir)` |
| Detach (unlink all) | room has ≥1 neighbor | `History.Snapshot("Detach")` then `Engine.DetachRoom(room)` |
| Undo last action | `History.HasEntries()` | `History.Undo()` |

Direction names for submenu labels: North, East, South, West.
