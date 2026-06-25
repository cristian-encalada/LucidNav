# Tasks: v1.4.0 — Paper-style Map Rendering

## Status legend
- [ ] pending
- [x] done

---

## 1. Constants
**File:** `Core/Constants.lua`

- [x] 1.1 Added `cellStep = 36` (`buttonW + 1`) for canvas spacing.
- [x] 1.2 Added `wallColor`, `wallThickness`.
- [x] 1.3 Added `dashSegments`, `dashGap` for dashed edges.

## 2. Improvement A — Canvas walls as edge lines
**File:** `Core/RoomEngine.lua`

- [x] 2.1 Replaced the 4 `voicechat-muted` textures in `createCell` with per-edge
      wall objects: one full-length solid bar + `dashSegments` short bars each.
- [x] 2.2 Added `renderRoomWalls(r)` drawing none/solid/dashed per edge from
      `r.walls[dir]` + `r.isOverlap`.
- [x] 2.3 `recolorRoom` calls `renderRoomWalls(r)`; orphan-border + POI/trap
      coloring kept intact. (Also enlarged room fill `midTex` to `buttonW-8` for
      a blockier paper look.)
- [x] 2.4 `getMapXY` and `centerCam` use `C.cellStep`.
- [ ] 2.5 Verify (in-game) edge-click wall toggle hit zones feel right.

## 3. Improvement B — Dashed for crosses + overlaps
**Files:** `Core/GridMap.lua`, `Core/RoomEngine.lua`

- [x] 3.1 Exposed `GridMap.ComputePositions()` (wrap of `computeGridPositions`).
- [x] 3.2 `refreshMapViews` calls `GridMap.ComputePositions()`, then
      `computeOverlapFlags()` sets `r.isOverlap` (shares `gcol,grow` OR `cx,cy`).
- [x] 3.3 `refreshMapViews` runs `renderRoomWalls` for every room after the pass.

## 4. Improvement C — Grid Map walls + skip markers
**File:** `Core/GridMap.lua`

- [x] 4.1 Grid cells draw solid wall lines per edge (an edge is walled if every
      room in the cell is walled there); dashed when `isCross`. Replaced the old
      `cell.conn` connection stubs with `cell.wall` / `cell.wallDash`.
- [x] 4.2 Added border arrows on the 4 outer edges (ASCII `v ^ < >` for
      guaranteed font rendering; built once). Grid frame margins enlarged.
- [x] 4.3 Added offset labels — `flipSidesGrid(col)` along the bottom and
      `flipSidesGrid(row)` letters along the right (built once).
- [x] 4.4 Kept POI/trap/current/cross cell coloring.

## 5. Housekeeping
**Files:** `LucidNav.toc`, `CHANGELOG.md`

- [x] 5.1 Bumped `## Version:` to `1.4.0`.
- [x] 5.2 Added `## [1.4.0]` CHANGELOG entry.

## 6. Verification
- [x] 6.1 Syntax: luaparser parse of each changed file (all OK).
- [ ] 6.2 In-game: blocked edges = lines, open = gaps; adjacent open rooms read
      connected.
- [ ] 6.3 Cross / overlapping rooms render dashed on canvas and Grid Map.
- [ ] 6.4 Grid Map shows wall lines, border arrows, and offset labels matching the
      +4 wrap (e.g. col 1↔5, row A↔E).
- [ ] 6.5 Perf: `refreshMapViews` still runs only on mutations/room changes; wall
      pass is O(n); no per-frame work added.
