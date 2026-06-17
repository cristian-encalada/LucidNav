# Change Proposal: v1.2.0 — Dedup Fix + Room Edit Affordances

## Summary

Two converging issues drive this change:

1. **Dedup bug** — After the "WOAH WOAH WOAH" POI deduplication fires, the visible map ends up with orphan rooms / scattered GridMap cells. Root cause: `Core/RoomEngine.lua` lines 354–385 — the `dcur` cleanup is nested inside `if not cur.visited`, so when BFS reaches the same orig-tree room twice via different paths, the second dupe room is never wiped (stays in `rooms[]` with intact neighbor pointers).

2. **User feedback** (GitHub user skyrunner1833, 2026-06-07) — After 4+ hours of mapping, mis-marked rooms or wrong neighbor links accumulate. There is no way to correct a mistake short of resetting the whole map. User asked for the ability to modify or add a room after the fact.

## Intended Outcome

- Fix dedup so it never leaves orphan rooms or stale neighbor pointers.
- Give users a "fix mistakes" path through a right-click context menu and an Undo command.

## Scope

### In scope (MVP)
- Two-phase `deDuplicateMap` rewrite (fix orphan bug)
- Snapshot-based Undo (in-memory stack, 20 entries, `/ln undo` + Undo button)
- Right-click room context menu: Set as current, Unlink neighbor, Detach, Undo

### Out of scope (deferred to v1.3.0)
- Delete-room (needs careful pool/serialization treatment)
- Clear-POI from menu (existing left-panel "Clear" button is sufficient)
- Mark/Clear trap from menu (existing flow handles it)

## Affected Files

| File | Status |
|------|--------|
| `Core/RoomEngine.lua` | Modified |
| `Core/MapUI.lua` | Modified |
| `Core/Dialogs.lua` | Modified |
| `LucidNav.lua` | Modified |
| `LucidNav.toc` | Modified |
| `Core/History.lua` | Added |
| `Core/RoomMenu.lua` | Added |

## Version Bump
`1.1.0` → `1.2.0`
