# Spec: GridMap — v1.6.0

(`Core/GridMap.lua` has no prior top-level spec in `openspec/specs/` — a
delta for it exists under the unmerged `v1.4.0-paper-map-rendering` change.
This delta covers only the localization-relevant surface.)

## CHANGED

### Edge-wrap hover hint
- The "Edge wrap" `GameTooltip` title now reads from `ns.L.TIP_*`. The
  per-direction hint lines (e.g. `"South -> A7"`) now build their direction
  name from `ns.L.DIR[dir]` instead of the module's own (already-deduplicated,
  post-cleanup) direction table.

### Unaffected — coordinate labels
- Column numbers, row letters (`A`-`H`), and the ASCII wrap-direction arrows
  (`v ^ < >`) are unchanged — these read as grid coordinates, not prose, in
  every language (see `design.md`).
