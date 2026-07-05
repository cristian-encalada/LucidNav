# LucidNav — Backlog / Future Improvements

## Faster wall marking
**Problem:** Walls are marked one edge at a time by clicking the thin cell border
(~2 clicks/room; a 15-room test session logged **32** wall toggles). It's tedious
and the small edge hit-zone is easy to mis-click.

**Possible directions (not yet decided):**
- A 4-way N/E/S/W wall toggle block in the room right-click menu (`RoomMenu`) —
  far bigger hit targets than edge-clicking.
- A "wall paint" mode where a single click on a cell side toggles that wall
  without changing the selection.
- Auto-infer walls from movement: if a walk attempt in a direction doesn't change
  rooms, mark that side as a wall automatically.
- Keyboard shortcuts acting on the selected room (e.g. modifier + arrow keys).

_Surfaced 2026-06-25 from debug stats (`wallToggles=32` over 15 rooms)._

## Smoother trap-teleport reorientation
**Problem:** When you hit the teleport trap and press "I got ported!", the addon
marks the trap room and creates a new **orphan placeholder room** at your unknown
teleport destination. Since the trap usually drops you back into already-explored
territory, you then have to wander to a known POI and dedup to reattach — or
manually Set Player Loc and delete the orphan. Fiddly.

**Idea:** On "I got ported!", prompt _"Do you recognize where you landed?"_:
- **Yes** → let the user click an existing room and snap the position there in one
  step (no orphan room created, no manual delete).
- **No** → current behavior (create placeholder, reattach later via POI dedup).

Could also auto-offer to delete the orphan placeholder once the player is
relocated. Surfaced 2026-06-25 during trap testing.

## Grid wrap model (±4 twist) — under investigation
The grid uses a fixed ±4 offset (`flipSidesGrid`) when wrapping edges. The wrap
audit (`/ln debug` summary) found a room 6↔7 link off by exactly ±4 on the row
axis after a loop-closing dedup — consistent with EITHER a real twisted-torus
maze (seam is unavoidable on a flat grid) OR a wrong twist value. Needs more
loop-closure data to decide. Map audit stays clean, so navigation is unaffected.

## Dashed lines on overlap rooms are misleading after JumpOver
**Problem:** After any JumpOver the newly created room `R_new` and the
jumped-over room `v` share the same maze-grid cell, so `computeOverlapFlags()`
(`RoomEngine.lua:319`) flags both with `isOverlap = true`. `renderRoomWalls()`
(`RoomEngine.lua:199`) then renders **all** blocked walls of both rooms as
dashed, making them look broken or unresolved to the user — even though the
cross is intentional and the walls are correct.

**Root cause:** BFS in `GridMap.ComputePositions()` assigns
`R_new.gcol = prev.gcol + dcol[dir]`, identical to `v.gcol` (both are "one step
from `prev` in direction `dir`"). This is topologically correct but the visual
treatment is confusing.

**Proposed directions:**
- Replace dashed walls with a **room-level indicator** (subtle diagonal stripe
  or background tint on the room button) so the cross/overlap is communicated at
  the room level instead of repurposing wall aesthetics.
- Only dash the **shared crossing edge** (the edge directly connecting the two
  overlapping rooms), not all four walls — this requires `computeOverlapFlags()`
  to record which direction the partner is in.
- Suppress the dashed treatment until the map has been stable for at least one
  navigation step (debounce), hiding the transient flash right after JumpOver.

_Surfaced 2026-07-05 from screenshot review after JumpOver confirmation._

## Wall-edge hit zones are ambiguous when adjacent rooms share a wall
**Problem:** Each room cell has 8 px click zones on its interior borders
(`borderW/H = 8`, `RoomEngine.lua:164`). With a 1 px inter-cell gap
(`cellStep = 36`), room A's north zone and room B's south zone are nearly
touching. When room B already shows a wall on that side, the user cannot tell
which room's zone is under the cursor and may accidentally double-toggle or
assume they need to click a different room.

`ToggleWall()` (`RoomEngine.lua:1074`) already syncs both sides atomically, so
there is no data inconsistency — the confusion is purely visual.

**Reference:** The Lucid Nightmare Maze addon places wall indicators *between*
cells in the gap, making each shared edge a single unambiguous click target.

**Proposed directions:**
- **Gap-zone approach:** increase `cellStep` from 36 to ~40 px to create a 5 px
  inter-cell gap; place a dedicated transparent hit-frame in each gap
  representing the single shared edge. Clicking it toggles the wall for both
  rooms atomically (no "which room?" ambiguity).
- **Hover-highlight approach:** activate a highlight texture on the specific
  wall edge when the mouse enters that 8 px zone, so the user sees exactly which
  wall is about to be toggled before clicking. No layout change required.
- **Right-click menu** (see "Faster wall marking" above) already addresses the
  hit-target problem with large N/E/S/W buttons — the two items are
  complementary.

_Surfaced 2026-07-05 from screenshot review (reference: Lucid Nightmare Maze
v0.2 wall placement style)._
