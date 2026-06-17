# Source of Truth: RoomMenu

**File:** `Core/RoomMenu.lua`  
**Last updated:** v1.2.0 (new)

## Public API (RoomMenu.*)

| Function | Description |
|----------|-------------|
| `RoomMenu.Show(room)` | Open right-click context menu for room at cursor |

## Menu items

| Item | Enabled when | Action |
|------|-------------|--------|
| Set as current room | always | `Engine.SetCurrentRoom(room)` |
| Unlink neighbor ▶ | room has ≥1 neighbor | Submenu per direction; snapshots + unlinks |
| Detach (unlink all) | room has ≥1 neighbor | Snapshot + `Engine.DetachRoom(room)` |
| Undo last action | `History.HasEntries()` | `History.Undo()` |

## Implementation notes

- Uses `MenuUtil.CreateContextMenu(UIParent, generator)` (Retail 11.0+ / 12.x), anchored at cursor.
- Legacy `EasyMenu` fallback (frame `LucidNavRoomMenu`) for older clients.
