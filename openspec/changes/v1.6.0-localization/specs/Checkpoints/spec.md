# Spec: Checkpoints — v1.6.0

(`Core/Checkpoints.lua` has no prior top-level spec. This delta covers only
the localization-relevant surface; save/restore/list/delete behavior and the
`LucidNavDB.checkpoints` storage format are unchanged.)

## CHANGED

### Print messages
- "Checkpoint saved: `<name>`", "No checkpoint named '`<name>`'.", "Restored
  checkpoint: `<name>`", "Checkpoint deleted: `<name>`" now read from
  `ns.L.MSG_*` via `ns.Print`/`string.format`.

### Default checkpoint name unaffected
- The `date("%H:%M:%S")` fallback name (used when `Checkpoints.Save(name)` is
  called with no name) is a timestamp, not translated text — unchanged.
