# Source of Truth: History

**File:** `Core/History.lua`  
**Last updated:** v1.2.0 (new)

## Public API (History.*)

| Function | Description |
|----------|-------------|
| `History.Snapshot(label)` | Push current map state onto undo stack (cap 20) |
| `History.Undo()` | Pop and restore last snapshot; prints label to chat |
| `History.Clear()` | Wipe the stack (called on full map reset) |
| `History.HasEntries()` | Returns true if stack is non-empty |

## Storage

In-memory only. Not persisted to `SavedVariables`. Stack is a plain Lua table (LIFO).

Each entry: `{csv=string, currentIdx=number, selectedIdx=number|nil, label=string}`.
