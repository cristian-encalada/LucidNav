# Source of Truth: RoomMenu

**File:** `Core/RoomMenu.lua`  
**Last updated:** v1.6.0

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
| Clear trap | room is the trap room | `Engine.ClearTrap(room)` (v1.3.0) |
| Undo last action | `History.HasEntries()` | `History.Undo()` |
| Delete room | always (divider above) | `Engine.DeleteRoom(room)` (v1.3.0) |

## Implementation notes

- Uses `MenuUtil.CreateContextMenu(UIParent, generator)` (Retail 11.0+ / 12.x), anchored at cursor.
- Legacy `EasyMenu` fallback (frame `LucidNavRoomMenu`) for older clients.
- The 6 menu-item labels are defined once as local constants and shared by
  both the modern and legacy code paths (v1.6.0 pre-localization cleanup),
  rather than hardcoded twice.

## Localization (v1.6.0)

All 6 menu-item labels, the per-direction submenu labels (via `ns.L.DIR`),
the "Room `<N>`" title, and the "Context menu API unavailable" message now
read from `ns.L.MENU_*`/`ns.L.MSG_*` keys — see the `Locales` spec.
