# Source of Truth: RoomEngine

**File:** `Core/RoomEngine.lua`  
**Last updated:** v1.1.0

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
| `Engine.ExportEHH()` | Exports routes to EndlessHallsHelper format |
| `Engine.DumpMap()` | Writes CSV to editbox |
| `Engine.ImportMap()` | Reads CSV from editbox and loads map |
| `Engine.SetTracking(enabled)` | Enables/disables position tracking |
| `Engine.CenterCamera()` | Scrolls map to center on current room |
| `Engine.JumpOver()` | Severs pending collision link, jumps to new room |
| `Engine.KeepLinked()` | Accepts pending collision link |
| `Engine.GetSelectedRoom()` | Returns selected room or nil |
| `Engine.SetPlayerToSelected()` | Moves player to selected room |
| `Engine.GetCurrentRoom()` | Returns current room |
| `Engine.GetRooms()` | Returns rooms table |
| `Engine.GetPoiRooms()` | Returns poirooms table |
| `Engine.GetTrapRoom()` | Returns trapRoom |
| `Engine.GetNavTarget()` | Returns navtarget index |
| `Engine.UpdatePOIButtonText()` | Refreshes POI button tints |
| `Engine.UpdateNavButtonText()` | Refreshes nav button labels |

## Private state

| Variable | Description |
|----------|-------------|
| `rooms[]` | All rooms indexed by `room.index` |
| `map[]` | Starting rooms (map[1] = room 1) |
| `poirooms[]` | POI index → room |
| `trapRoom` | The trap room, or nil |
| `current_room` | Room the player is in |
| `selected_btn` | Currently selected cell Button frame |
| `pool[]` | Recycled button frames |

## Room schema

```lua
room = {
  index      = number,        -- 1-based, unique
  cx         = number,        -- grid column (signed)
  cy         = number,        -- grid row (signed)
  neighbors  = {[1..4]=room}, -- N=1 E=2 S=3 W=4
  walls      = {[1..4]=bool},
  visited    = bool,          -- scratch flag for BFS
  poi_index  = number,        -- 0=none, 1-5=rune, 6-10=orb, 11=unexplored, 12=trap
  POI_c      = number,        -- color index (1-5)
  POI_t      = string,        -- "rune" or "orb"
  is_trap    = bool,
  button     = Frame,         -- visual cell
}
```

## CSV serialization format

```
index,poi,north_neighbor,east_neighbor,south_neighbor,west_neighbor,n_wall,e_wall,s_wall,w_wall,cx,cy,current,trap,-
```
One row per room. `current` field is the literal string `"current"` for the current room. `trap` field is `"T"` for trap rooms. Neighbor fields are room indices or empty.
