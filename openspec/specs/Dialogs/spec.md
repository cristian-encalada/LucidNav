# Source of Truth: Dialogs

**File:** `Core/Dialogs.lua`  
**Last updated:** v1.1.0

## Public API (Dialogs.*)

| Function | Description |
|----------|-------------|
| `Dialogs.Build(mazeFrame)` | Creates all dialogs as children of mazeFrame |

## Dialogs

### Jump dialog (`mazeFrame.jumpDialog`)
Shown when movement enters an already-mapped cell (collision). Two choices:
- **Yes, keep it linked** → `Engine.KeepLinked()`
- **No, jump over** → `Engine.JumpOver()`

### Reset dialog (`mazeFrame.resetDialog`)
Confirmation before erasing the full map.
- **Yes, erase it** → `Engine.ResetMap()`
- **Cancel** → hides dialog

### Help dialog (`mazeFrame.helpDialog`)
Static help text explaining controls, POI marking, trap handling, logout behavior.
