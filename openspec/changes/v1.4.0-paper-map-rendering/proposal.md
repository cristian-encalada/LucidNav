# Change Proposal: v1.4.0 — Paper-style Map Rendering

## Summary

The map is the core value of LucidNav — it exists to replace hand-drawing the
Endless Halls maze on paper. Today blocked walls are drawn as a small X / mute
icon (`interface\common\voicechat-muted`) centered on each cell edge, which is
hard to read and does not resemble the paper maps players are used to (see the
reference addon *lucid-nightmare-maze* and community paper maps). This change
redesigns the map to read like a paper maze.

User-confirmed decisions:

1. **Walls become edge lines, open sides are gaps** (replacing the X icon), on
   **both** the main canvas and the 8×8 Grid Map.
2. **Dashed (non-continuous) lines** mark **both** non-intersecting crosses
   (rooms sharing the same wrapped grid cell) **and** rooms whose canvas buttons
   overlap.
3. The 8×8 Grid Map gains **wrap/skip markers** — **arrows + offset labels** on
   the borders — showing that the maze wraps to the opposite edge with a fixed
   **+4-cell offset** (confirmed by the reference addon; already modelled by
   `flipSidesGrid` in `Core/GridMap.lua`).
4. Keep the **dark theme**; render walls as crisp light lines (no light "paper"
   background).

## Intended Outcome

A clearer, paper-like map where blocked vs. open paths and cross rooms are
obvious at a glance, and the Grid Map shows how the edges wrap.

## Scope

### In scope (A/B/C)
- **A** — Canvas walls rendered as solid edge lines (open = gap); reduced
  inter-cell gap so adjacent open rooms read as connected.
- **B** — Dashed walls for crosses (shared `gcol/grow`) and overlapping canvas
  buttons (shared `cx/cy`).
- **C** — Grid Map cell wall lines (dashed for cross cells) + border wrap markers
  (arrows + offset labels) using the +4 offset.

### Out of scope
- Light "paper" cell background / full theme reskin.
- Dynamic per-instance wrap-offset detection (the +4 model is treated as fixed).

## Affected Files

| File | Status |
|------|--------|
| `Core/RoomEngine.lua` | Modified (wall renderer, `renderRoomWalls`, overlap pass, `cellStep`) |
| `Core/GridMap.lua` | Modified (`ComputePositions`, cell wall lines, skip markers) |
| `Core/Constants.lua` | Modified (wall/dash/step constants) |
| `CHANGELOG.md` | Modified |
| `LucidNav.toc` | Modified (version bump) |

No new art assets — dashes via short segment textures, arrows via Unicode
FontStrings.

## Version Bump
`1.3.0` → `1.4.0`
