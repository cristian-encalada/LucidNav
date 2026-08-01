# Source of Truth: GridMap

**File:** `Core/GridMap.lua`  
**Last updated:** v1.6.0 (new, incorporates v1.4.0 paper-map-rendering + v1.6.0 localization)

## Public API (GridMap.*)

| Function | Description |
|----------|-------------|
| `GridMap.Initialize()` | Builds the 8×8 grid frame |
| `GridMap.Show()` | Shows the grid frame and refreshes it |
| `GridMap.Refresh(skipCompute)` | Redraws cells; `skipCompute` skips the BFS if the caller already ran it this tick |
| `GridMap.ComputePositions()` | Public wrapper around the internal wrap-aware BFS (`computeGridPositions`), so other modules (`RoomEngine.refreshMapViews`) can refresh `r.gcol`/`r.grow` even when the Grid Map window is hidden — used for cross detection (v1.4.0) |
| `GridMap.DumpCells()` | Returns sorted `"room N = H6"`-style strings for `/ln grid` |
| `GridMap.AuditWrap()` | Compares the ±4 wrap model's predicted neighbor cell against the actual BFS-placed cell; returns mismatch strings |

## Wrap-aware positioning

`computeGridPositions` runs a BFS from room 1, assigning each room a
`(gcol, grow)` grid slot via `flipSidesGrid(p) = p<5 and p+4 or p-4` — the
fixed ±4 twist wrap. The **current room and start room (index 1) are trusted
anchors**: when a cell holds one of them, it defines the cell's identity, so
a mis-wrapped POI room can't bleed a wrong color onto it (e.g. a false rune
on the plain start cell).

## Rendering (v1.4.0 — paper-style)

- Grid cells draw **solid** wall lines per edge where every room occupying
  that cell has a wall there; **cross cells** (`isCross = #rList > 1`) draw
  dashed lines instead.
- The trap cell shows the skull texture (matching the main canvas) instead
  of a "T" label.
- Border **wrap/skip markers**, built once in `createGridMap` (static, no
  per-refresh cost): ASCII arrows (`v ^ < >`) on the four outer edges, and
  offset labels (`flipSidesGrid(col)`/`flipSidesGrid(row)`) showing the
  coordinate you'd arrive at wrapping off that edge.
- Hovering a border cell lights up its wrap partner cell with an
  edge-wrap hover hint (`GameTooltip`), naming the destination (e.g.
  `"South -> A7"`).
- Grid cells use motion-only mouse (`SetMouseMotionEnabled`, with an
  `EnableMouse`+`SetMouseClickEnabled(false)` fallback) so left-click drag
  still pans the grid frame while hover hints work.

## Known open item

The 8×8 grid is a 64-cell torus, but exploration yields ~90-100 room nodes,
so the flat grid collides many rooms onto one cell (the "grid wrap model"
item tracked in `BACKLOG.md`).

## Localization (v1.6.0)

The "Edge wrap" tooltip title and the per-direction hint text now read from
`ns.L.TIP_*`/`ns.L.DIR` — see the `Locales` spec. `AuditWrap()`'s mismatch
format string reads from `ns.L.AUDIT_WRAP_MISMATCH`. Grid coordinate letters
(`A`-`H`), column numbers, and the ASCII wrap-direction arrows are
unaffected — they read as coordinates, not prose, in every language.
