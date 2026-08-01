# Source of Truth: Checkpoints

**File:** `Core/Checkpoints.lua`  
**Last updated:** v1.6.0 (new, added v1.3.0)

## Public API (Checkpoints.*)

| Function | Description |
|----------|-------------|
| `Checkpoints.Save(name)` | Saves the current map under `name` (default: `date("%H:%M:%S")` timestamp); enforces a 10-checkpoint cap by dropping the oldest |
| `Checkpoints.Restore(name)` | Snapshots to History (`"Pre-restore"`), then imports the named checkpoint's CSV |
| `Checkpoints.List()` | Returns `{name, saved, ts}` entries sorted newest-first |
| `Checkpoints.Delete(name)` | Removes a named checkpoint |

## Storage

Persistent, named map snapshots — the in-game replacement for
"screenshot the map every time I make progress." Unlike `History`
(in-memory, step-granular, lost on `/reload`), checkpoints are stored in
`LucidNavDB.checkpoints` and survive reloads and relogs.

Each entry: `{name=string, csv=string, saved="YYYY-MM-DD HH:MM", ts=number}`.

## Entry points

- Toolbar Save/Restore buttons (`Core/MapUI.lua`).
- `/ln save [name]`, `/ln restore <name>`, `/ln checkpoints` (`LucidNav.lua`).

## Localization (v1.6.0)

The save/restore/delete/not-found print messages now read from `ns.L.MSG_*`
keys via `ns.Print`/`string.format` — see the `Locales` spec. The default
checkpoint name (`date("%H:%M:%S")`) is a timestamp, not translated text, and
is unaffected.
