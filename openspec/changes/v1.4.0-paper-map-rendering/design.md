# Design Note: Paper-style Map Rendering

## Maze topology (the constraints we draw against)

- The Endless Halls is an **8×8 grid** (≤64 cells; up to 128 logical rooms via
  non-intersecting crosses).
- **Non-intersecting crosses**: "2 rooms with 2 direct passages, geographically
  occupying one and the same coordinate" (reference: *lucid-nightmare-maze*).
  On a paper map these are the rooms drawn with dashed lines.
- **Edge wrap with a fixed +4-cell offset**: "the edges of the matrix are circled
  to the opposite edge with an offset of 4 cells." This is exactly the
  `flipSidesGrid(p) = p<5 and p+4 or p-4` model already in `Core/GridMap.lua`.

References:
- warcraft-secrets.com/guides/lucid-nightmare
- curseforge.com/wow/addons/lucid-nightmare-maze (description)
- nightswimmer.github.io/EndlessHalls

## Rendering approach

### Walls as lines (A)
Each cell edge is drawn in one of three states: `none` (open — nothing drawn),
`solid`, or `dashed`. A blocked wall (`r.walls[dir] == true`) draws a line
spanning the full edge; an open side draws nothing, so adjacent open rooms read
as connected.

**Dashes without art assets:** WoW color textures can't tile a dashed pattern, so
dashed edges are drawn as a few short segment textures (`dashSegments` bars with
`dashGap` gaps) along the edge. Solid edges use a single `WHITE8X8` /
`SetColorTexture` bar. Both reuse textures held on the (pooled) cell button, so
no per-render allocation and no new files.

**Cell spacing:** the current canvas leaves a 6px gap between cells
(`buttonW + 6`). For walls/openings to read correctly the gap is reduced to a
single shared `C.cellStep` (≈ `buttonW + 1`), used by `getMapXY` and `centerCam`.

### Overlap / cross detection (B)
A room draws dashed walls when it shares a cell with another room:
- **Cross**: shares `(gcol, grow)` — reuses the wrap-aware positions from
  `computeGridPositions` (already sets `r.gcol/grow`).
- **Overlap**: shares `(cx, cy)` on the canvas.

`computeGridPositions` is exposed as `GridMap.ComputePositions()` and called from
`refreshMapViews` so positions/flags are current even when the Grid Map window is
closed. The overlap pass is a single O(n) bucketing by `gcol,grow` and `cx,cy`.

### Grid Map walls + skip markers (C)
- Grid cells draw solid wall lines per edge (aggregated over the rooms in the
  cell); cross cells (`isCross`, already computed in `refreshGridMap`) draw dashed.
- Border **arrows** (`▲ ▼ ◀ ▶` FontStrings) and **offset labels**
  (`flipSidesGrid(c)` / `flipSidesGrid(r)`) are built once in `createGridMap` —
  the +4 model is constant, so they carry no per-refresh cost.

## Why not alternatives
- *Light "paper" theme*: would force re-tuning all POI/trap colors for contrast;
  deferred (out of scope) per user decision to keep the dark theme.
- *Dynamic wrap-offset detection*: the offset is a fixed +4; learning it per
  instance adds complexity with no benefit here.
