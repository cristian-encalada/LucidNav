# Source of Truth: LucidNav (root)

**File:** `LucidNav.lua`  
**Last updated:** v1.6.0 (new)

## Purpose

Slash command entry point. Registers `/lucid`, `/ln`, `/lnn` and dispatches
on the first word of the command.

## Slash sub-commands

| Sub-command | Action |
|--------------|--------|
| (none) | `ns.MapUI.Toggle()` — show/hide the main window |
| `debug` | `ns.Debug.Toggle()` |
| `undo` | `ns.History.Undo()` |
| `save [name]` | `ns.Checkpoints.Save(name)` |
| `restore <name>` | `ns.Checkpoints.Restore(name)` |
| `checkpoints` | Prints the checkpoint list (name + saved timestamp) |

## Localization (v1.6.0)

The `/ln checkpoints` output ("No checkpoints saved." / "LucidNav
checkpoints:" header) now reads from `ns.L.MSG_*` — see the `Locales` spec.
Slash command keywords themselves (`debug`, `undo`, `save`, `restore`,
`checkpoints`) are **not** localized — they're English parsing literals, not
display text; changing them would risk breaking muscle memory and existing
documentation/screenshots for current users.
