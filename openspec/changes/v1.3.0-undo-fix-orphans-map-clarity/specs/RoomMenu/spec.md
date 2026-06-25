# Spec: RoomMenu — v1.3.0

## ADDED

### Right-click menu items

Added to the existing room context menu (`RoomMenu.Show(room)`):

- **"Clear trap"** — shown only when `room.is_trap` is true; calls
  `Engine.ClearTrap(room)`. Lets a user correct a mis-marked teleport-trap room
  (reported: "telling it the wrong spot I had been teleported").
- **"Mark as trap"** *(optional)* — shown when `room` is not a trap and no other
  trap room exists; marks this room as the trap.
- **"Delete room"** — enabled for any non-current room (or the current room only
  after it can be reassigned to a neighbor; see RoomEngine `DeleteRoom`). Calls
  `Engine.DeleteRoom(room)`. This is the missing cleanup path for orphaned rooms
  left by *Detach* / *Unlink*.

## NOTES

Existing items (*Set as current room*, *Unlink neighbor ▶*, *Detach*,
*Undo last action*) are unchanged. Item ordering should keep destructive actions
(*Delete room*) visually separated / last.
