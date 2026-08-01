# Source of Truth: RoomEngine

**File:** `Core/RoomEngine.lua`  
**Last updated:** v1.6.0

## Public API (Engine.*)

| Function | Description |
|----------|-------------|
| `Engine.Init()` | Resets map, starts OnUpdate tracking |
| `Engine.LoadSavedMap()` | Loads from `LucidNavDB.mapData` or starts fresh |
| `Engine.ResetMap()` | Clears DB + resets map to a single room |
| `Engine.SetCurrentRoom(room)` | Moves player marker to room |
| `Engine.ToggleWall(btn, dir)` | Toggles wall on a room edge |
| `Engine.SetPOI(self)` | Marks/clears POI on selected/current room |
| `Engine.SetGuidance(self)` | Sets navigation target and runs BFS |
| `Engine.HitTheTrap()` | Marks current room as teleport trap |
| `Engine.ClearTrap(room)` | Clears the trap flag from a room (v1.3.0) |
| `Engine.DeleteRoom(room)` | Removes a room from the map, pool/serialization-safe (v1.3.0); refuses to delete room 1 or the last remaining room |
| `Engine.ExportEHH()` | Exports routes to EndlessHallsHelper format |
| `Engine.DumpMap()` | Writes CSV to editbox |
| `Engine.ImportMap()` | Reads CSV from editbox and loads map; ends with a `GridMap.Refresh()` (v1.3.0 fix) |
| `Engine.SetTracking(enabled)` | Enables/disables position tracking |
| `Engine.CenterCamera()` | Scrolls map to center on current room |
| `Engine.JumpOver()` | Severs pending collision link, jumps to new room |
| `Engine.KeepLinked()` | Accepts pending collision link |
| `Engine.GetSelectedRoom()` | Returns selected room or nil |
| `Engine.SetSelectedByIndex(idx)` | Selects a room by index (used by Undo) |
| `Engine.SetPlayerToSelected()` | Moves player to selected room |
| `Engine.GetCurrentRoom()` | Returns current room |
| `Engine.GetRooms()` | Returns rooms table |
| `Engine.GetPoiRooms()` | Returns poirooms table |
| `Engine.GetTrapRoom()` | Returns trapRoom |
| `Engine.GetNavTarget()` | Returns navtarget index |
| `Engine.EraseRooms()` | Wipes all rooms (used by Undo before re-importing) |
| `Engine.UpdatePOIButtonText()` | Refreshes POI button tints |
| `Engine.UpdateNavButtonText()` | Refreshes nav button labels |
| `Engine.AuditMap()` | Returns a list of structural issue strings (orphans, asymmetric links, wall mismatches, canvas overlaps) |

## Private state

| Variable | Description |
|----------|-------------|
| `rooms[]` | All rooms indexed by `room.index` |
| `map[]` | Starting rooms (map[1] = room 1) |
| `poirooms[]` | POI index → room |
| `trapRoom` | The trap room, or nil |
| `current_room` | Room the player is in (`Room?`) |
| `selected_btn` | Currently selected cell Button frame |
| `pool[]` | Recycled button frames |

## Room schema

Annotated in code as `---@class Room` (v1.6.0):

```lua
room = {
  index            = number,          -- 1-based, unique (room 1 is the start/anchor)
  cx, cy           = number,          -- dead-reckoned canvas cell (+cx = east, +cy = south)
  neighbors        = {[1..4]=room?},  -- N=1 E=2 S=3 W=4
  walls            = {[1..4]=bool},   -- true = blocked edge
  gcol, grow       = number?,         -- 8x8 grid position from wrap-aware BFS (GridMap.ComputePositions)
  visited          = bool,            -- scratch flag for BFS
  poi_index        = number,          -- 0=none, 1-5=rune, 6-10=orb, 11=unexplored, 12=trap
  POI_c            = number?,         -- color index (1-5)
  POI_t            = string?,         -- "rune" or "orb"
  is_trap          = bool?,
  isOverlap        = bool?,           -- shares a grid/canvas cell with another room (cross)
  neighbor_indices = {[1..4]=number}?,-- transient: raw indices during ImportMap, resolved into `neighbors`
  button           = Frame?,          -- visual cell
}
```

## CSV serialization format

```
index,poi,north_neighbor,east_neighbor,south_neighbor,west_neighbor,n_wall,e_wall,s_wall,w_wall,cx,cy,current,trap,-
```
One row per room. `current` field is the literal string `"current"` for the current room. `trap` field is `"T"` for trap rooms. Neighbor fields are room indices or empty.

## Localization (v1.6.0)

All user-facing strings (navigation guidance, trap/save/load messages,
delete-room guards, the POI-unreachable warning, `AuditMap()`'s diagnostic
messages, the guidance-panel button text) now read from `ns.L.*` keys via
`string.format`, instead of hardcoded English — see the `Locales` spec.
Direction/color lookups (`C.direction_strings`/`C.color_strings`) were
replaced by `ns.L.DIR`/`ns.L.COLOR` — see the `Constants` spec. Algorithm
logic (BFS, dedup, serialization) is unchanged.
