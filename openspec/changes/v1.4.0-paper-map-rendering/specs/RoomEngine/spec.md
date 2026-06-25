# Spec: RoomEngine — v1.4.0

## CHANGED

### Walls rendered as edge lines (not X icons)
- `createCell` no longer creates the four `interface\common\voicechat-muted`
  textures. Each cell edge instead holds reusable wall textures: one full-length
  **solid** bar plus `C.dashSegments` short **dash** bars, parented to the
  (pooled) cell button.
- New `local function renderRoomWalls(r)` sets each edge to one of:
  - `none` — `r.walls[dir]` false → nothing shown (open passage / gap);
  - `solid` — wall present and the room is not overlapped;
  - `dashed` — wall present and `r.isOverlap` is true (cross / overlapping room).
- `recolorRoom` calls `renderRoomWalls(r)` in place of the old
  `btn.walls[i]:SetShown(...)` loop. Orphan-border (v1.3.0) and POI/trap coloring
  are unchanged.

### Tighter cell spacing
- Canvas spacing uses a single `C.cellStep` (≈ `buttonW + 1`) in `getMapXY` and
  `centerCam`, replacing the hard-coded `buttonW + 6`, so adjacent open rooms read
  as connected and shared walls align.

## ADDED

### Overlap / cross detection in `refreshMapViews`
- `refreshMapViews` now calls `GridMap.ComputePositions()` (so `r.gcol/grow` are
  current even when the Grid Map is closed), then performs one O(n) pass setting
  `r.isOverlap = true` for any room that shares `(gcol, grow)` **or** `(cx, cy)`
  with another room, and re-renders walls for all rooms.
- Edge-click wall toggling (`createCell` OnClick) is unchanged.
