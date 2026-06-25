# Design Note: Map Layout & Overlap Elimination (Item 4)

## Why rooms overlap today

LucidNav builds the canvas by **dead-reckoning**: each new room is placed at
`current_room.(cx,cy)` plus the cardinal `coord_offset` of the direction walked
(`Core/RoomEngine.lua:268-298`). When the ideal cell is already taken,
`getRoomJumpOffset` (lines 256-266) walks **linearly in the same direction**
until it finds the first empty cell:

```lua
while not isFree() do oX = oX + dcx; oY = oY + dcy end
```

This has two failure modes that match the user complaints:

1. **Scatter / long gaps** — a room that is logically one step away gets pushed
   several cells away, and the link between the two is drawn as a normal
   wall-less edge with nothing visible spanning the gap.
2. **Crammed / overlapping buttons** — unrelated rooms get packed into adjacent
   cells whose 35×35 buttons (plus 6px step) abut or visually overlap, so the
   user "failed to click overlapping button."

## The underlying topology

The Endless Halls maze is **an 8×8 grid (64 cells, up to 128 logical rooms via
"non-intersecting cross" cells), wrapping toroidally with an unpredictable
per-edge offset** — confirmed by the warcraft-secrets guide and the Endless
Halls Helper. Two consequences:

- A naive fixed 8×8 grid-snap from movement alone is **not** achievable, because
  the offset-wrap breaks dead-reckoning at the edges (exiting one side lands you
  on the opposite side *plus* an offset).
- But the explored maze is always a **finite graph (≤64 cells)**. Cardinal
  fidelity is already approximate in LucidNav (dead-reckoning drifts), so a
  graph-based embedding is an acceptable — arguably more honest — representation.

## Options considered

**A. Incremental: better collision + visible links (chosen for Phase 1).**
Keep dead-reckoning, but:
- replace the linear slide with a **nearest-free-cell spiral search** around the
  ideal cell, so a displaced room lands as close as possible to where it belongs;
- draw an explicit **connector line** for any linked pair that is not physically
  adjacent, so a logical link is never invisible;
- raise the **frame level** of the selected/current room so overlapping cells
  remain individually clickable.
Low risk, no data-model change, directly addresses "failed to click overlapping
button" and the worst of the scatter. Ships this release.

**B. Constraint / force-directed relayout (Phase 2, deferred).**
Treat rooms as nodes and links as edges; run an **incremental grid-snapped
layout with soft stress + hard non-overlap constraints** (IPSEP-COLA /
"node-snap & grid-snap stress" family). Eliminates overlap by construction and
keeps edges short while snapping to a grid. Cost: a real layout engine in Lua,
re-layout triggers, and animation/stability tuning so the map doesn't jump
around mid-run. Deferred to v1.4.0; Phase 1 should validate demand first.

**C. True toroidal 8×8 embedding (rejected for now).**
Learn the wrap offsets and place every room on a real 8×8 torus. Highest
fidelity but requires offset auto-detection that may never converge from partial
exploration; high risk for uncertain payoff.

## Decision

Ship **Option A** in v1.3.0 as Item 4 Phase 1. Record **Option B** as the
v1.4.0 follow-up. Keep **Option C** as a research idea only.

## References

- Endless Halls maze structure (8×8, non-intersecting crosses, toroidal offset):
  warcraft-secrets.com/guides/lucid-nightmare ; nightswimmer.github.io/EndlessHalls
- Incremental grid-like layout with soft/hard constraints: arXiv:1308.6368
- Node overlap removal: arXiv:1608.02653 ; ScienceDirect S0020025507000989
- Force-directed graph drawing survey: arXiv:1201.3011
