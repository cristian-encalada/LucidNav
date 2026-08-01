# Source of Truth: Dialogs

**File:** `Core/Dialogs.lua`  
**Last updated:** v1.6.0

## Public API (Dialogs.*)

| Function | Description |
|----------|-------------|
| `Dialogs.Build(mazeFrame)` | Creates all dialogs as children of mazeFrame |

## Shared builders (internal)

`makeDialog`/`makeTitle`/`makeBody`/`makeDialogButton`/`makeConfirmButtons`
(v1.6.0 cleanup) — `makeDialog` centers the frame and starts it hidden;
`makeConfirmButtons(dlg, yesText, yesW, noText, noW, onYes, onNo)` builds the
shared bottom-left Yes / bottom-right No button pair, each hiding the dialog
after its handler runs.

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

## Localization (v1.6.0)

Every dialog title, body paragraph, and button label now reads from an
`ns.L.DLG_*` key (see the `Locales` spec) — the Help dialog's title, 5
section headers, and body prose (`ns.L.DLG_HELP_*`) are the single largest
translation surface in the addon. The `CLOSE` button is unaffected (already
locale-aware via the Blizzard global).
