# Spec: Checkpoints module — v1.3.0

## ADDED

### `Core/Checkpoints.lua` (new file)

Module exposed as `ns.Checkpoints`. Unlike `History` (in-memory, step-granular,
lost on `/reload`), checkpoints are **named, milestone-granular, and persisted**
to `LucidNavDB.checkpoints`. They are the in-game replacement for the
"screenshot every time I make progress" workflow users resorted to.

Storage shape:
```
LucidNavDB.checkpoints = {
  [name] = { csv = <SerializeMap output>, saved = "YYYY-MM-DD HH:MM", name = name },
  ...
}
```
List is capped (e.g. 10 entries); saving over the cap drops the oldest by
timestamp. Saving an existing name overwrites it.

---

#### `Checkpoints.Save(name: string)`
- Defaults `name` to a timestamp if omitted/blank.
- Stores `{csv = Engine.SerializeMap(), saved = date, name}` keyed by `name`.
- Enforces the cap, dropping the oldest.
- Prints confirmation to chat.

#### `Checkpoints.Restore(name: string)`
- Looks up `name`; prints an error and returns if missing.
- Pushes a `History.Snapshot("Pre-restore")` first, so the restore itself is
  undoable.
- Calls `Engine.ImportMap(entry.csv)` (which now refreshes the Grid Map).
- Prints confirmation.

#### `Checkpoints.List() → table`
- Returns the saved checkpoints (name + timestamp) for UI/slash display.

#### `Checkpoints.Delete(name: string)`
- Removes the named checkpoint.

### Registration
- `Core\Checkpoints.lua` added to `LucidNav.toc` after `Core\History.lua`.
