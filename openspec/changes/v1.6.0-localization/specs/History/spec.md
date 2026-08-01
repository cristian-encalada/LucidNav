# Spec: History — v1.6.0

## CHANGED

### `History.Undo()` print messages
- "Nothing to undo." / "Undid: `<label>`" now read from `ns.L.MSG_*`
  (`string.format` for the interpolated label).

### Snapshot labels stay English internally
- Labels passed to `History.Snapshot(label)` (e.g. `"Dedup"`, `"Reset"`,
  `"Trap"`) are short internal tags echoed back in the "Undid: ..." message —
  these are now also sourced from `ns.L.MSG_LABEL_*` so the echoed text is
  localized too, not just the surrounding sentence.
