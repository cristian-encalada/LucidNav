# Spec: GridMap — v1.4.0

## ADDED

### `GridMap.ComputePositions()`
- Public wrapper around the existing `computeGridPositions` local, so other
  modules (RoomEngine `refreshMapViews`) can refresh `r.gcol/r.grow` even when the
  Grid Map window is hidden. Used for cross detection.

### Border wrap/skip markers (built once in `createGridMap`)
- **Arrows**: `▲ ▼ ◀ ▶` FontStrings on the four outer edges of the grid,
  indicating the edge-wrap direction (matches the reference 8×8 image).
- **Offset labels**: a small dim label outside each column showing
  `flipSidesGrid(col)` and outside each row showing `flipSidesGrid(row)` — the
  coordinate you arrive at when wrapping off that edge (the fixed +4 offset).
- These are static (the +4 model is constant) and carry no per-refresh cost.

## CHANGED

### Cell wall lines
- `refreshGridMap` draws solid wall lines on each grid cell edge where the room(s)
  occupying that cell have a wall (aggregated over `rList`). Cross cells
  (`isCross = #rList > 1`, already computed) draw **dashed** wall lines.
- Existing POI / trap / current-room / cross cell coloring is preserved. The prior
  `cell.conn[dir]` connection stubs are repurposed/extended into full-edge wall
  lines.

### Trap cell uses the skull icon
- The teleport-trap cell shows the skull texture
  (`interface\targetingframe\UI-RaidTargetingIcon_8`, per-cell `cell.skull`)
  instead of the "T" label, matching the main canvas.
