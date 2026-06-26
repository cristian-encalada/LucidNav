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
