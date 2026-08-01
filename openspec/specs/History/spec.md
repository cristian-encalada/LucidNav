# Source of Truth: History

**File:** `Core/History.lua`  
**Last updated:** v1.6.0

## Public API (History.*)

| Function | Description |
|----------|-------------|
| `History.Snapshot(label)` | Push current map state onto undo stack (cap 20) |
| `History.Undo()` | Pop and restore last snapshot; prints label to chat |
| `History.Clear()` | Wipe the stack (called on full map reset) |
| `History.HasEntries()` | Returns true if stack is non-empty |
| `History.LabelUnlink(dirName)` | Builds the "Unlink `<dir>`" snapshot label (v1.6.0; single source shared by `RoomMenu.lua`'s modern/legacy paths) |

## Storage

In-memory only. Not persisted to `SavedVariables`. Stack is a plain Lua table (LIFO).

Each entry: `{csv=string, currentIdx=number, selectedIdx=number|nil, label=string}`.

## Localization (v1.6.0)

`History.Undo()`'s "Nothing to undo."/"Undid: `<label>`" messages now read
from `ns.L.MSG_UNDO_NONE`/`ns.L.MSG_UNDO_DID`. Snapshot labels passed in by
callers (`"Dedup"`, `"Reset"`, `"Trap"`, etc.) are now sourced from
`ns.L.MSG_LABEL_*` keys, so the label echoed back in "Undid: ..." is
localized too, not just the surrounding sentence.
