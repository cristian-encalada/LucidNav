# CLAUDE.md — LucidNav developer guide

Guidance for AI/human contributors working on **LucidNav**, a World of Warcraft
addon that maps and navigates the **Endless Halls** maze (Lucid Nightmare mount).
Read this before making changes.

---

## What this addon is

- Auto-builds a live map of the Endless Halls as the player walks, and gives
  turn-by-turn navigation to runes, orbs, the teleport trap, or unexplored rooms.
- Pure Lua WoW addon. **No build step for the code** — the game loads the `.lua`
  files listed in `LucidNav.toc`. `release.sh` only *packages* a `.zip`.
- Runtime target: **WoW Lua 5.1** (see gotchas). Only active inside the Endless Halls.

---

## Module layout (load order = `LucidNav.toc`)

| File | Responsibility |
|------|----------------|
| `Core/Constants.lua` | `ns.C` — sizes, colors, direction tables, POI colors/textures, serialization constants. |
| `Core/Debug.lua` | `/ln debug` switch: live logging, periodic report, stats, map/wrap audits. |
| `Core/RoomEngine.lua` | **The core.** Rooms graph, walls, POIs, trap, canvas buttons, movement tracking, navigation BFS, dedup, serialize/import, jump/overlap logic. Largest file. |
| `Core/History.lua` | In-memory Undo stack (≤20 steps, lost on `/reload`). |
| `Core/Checkpoints.lua` | Named, timestamped map snapshots in SavedVariables (survive `/reload`, ≤10). |
| `Core/GridMap.lua` | The 8×8 grid overview: wrap-aware BFS positions, rendering, edge-wrap hover hint. |
| `Core/Dialogs.lua` | Confirm/help dialogs (reset, jump-over, etc.). |
| `Core/RoomMenu.lua` | Right-click room menu (set current, unlink, detach, delete, clear trap, undo). |
| `Core/MapUI.lua` | Main window, right panel (markers, match toggles, nav targets, current-room N/E/S/W panel), Save/Restore buttons. |
| `LucidNav.lua` | Slash command handler + entry point. |

Namespace: every file starts `local addonName, ns = ...`. Shared state hangs off
`ns` (`ns.Engine`, `ns.GridMap`, `ns.MapUI`, `ns.Checkpoints`, `ns.History`,
`ns.Debug`, `ns.C`, `ns.maze`, `ns.container`, `ns.scrollframe`, `ns.playerNav`).

Slash: `/ln`, `/lnn`, `/lucid` (toggle UI). Sub-args: `debug`, `undo`, `save [name]`,
`restore <name>`, `checkpoints`.

---

## Core data model

A **room** is a Lua table:
- `index` — 1-based id (room 1 is the start/anchor).
- `neighbors[1..4]` — linked rooms by direction (N=1, E=2, S=3, W=4).
- `walls[1..4]` — `true` = blocked edge. **Mirrored on both rooms** of a shared edge.
- `cx, cy` — canvas cell (dead-reckoned; `+cy` = south, `+cx` = east).
- `gcol, grow` — 8×8 grid slot from wrap-aware BFS (set by `GridMap.ComputePositions`).
- `poi_index` (0 none, 1–5 rune, 6–10 orb), plus `POI_c` (color 1–5) / `POI_t`
  (`"rune"`/`"orb"`). `is_trap` for the teleport trap.
- `isOverlap` — shares a grid/canvas cell with another room (cross).

Direction tables in `ns.C`: `north/east/south/west = 1/2/3/4`, `oppositeDir`,
`coord_offset`, `direction_strings`. Use `getOppositeDir(dir)` for the mirrored edge.

POI rendering: runes use `interface\icons\boss_odunrunes_<suffix>` where
`runeIconSuffixes = {"yellow","blue","orange","green","purple"}`; orbs use
`interface\icons\spell_broker_orb` tinted by `C.poi_rgb`.

---

## Key invariants & gotchas (read before editing)

- **Lua 5.1 runtime.** No `\xHH`/`\u{}` string escapes, no integer division `//`,
  no `goto`. Use `wipe(t)` (WoW global) to clear tables. Embed literal UTF-8 or
  ASCII (`->`, `v`, `^`) rather than escape sequences — several bugs came from this.
- **Wall symmetry.** `Engine.ToggleWall` sets the edge on *both* rooms. Navigation
  (`navigateToTarget`, `bfsDistances`, `navigateToUnexplored`) currently trusts
  `cur.walls[dir]` (single-sided). `reconcileWalls()` heals mismatches only during
  dedup, resolving toward OPEN. `Engine.AuditMap()` reports "Wall mismatch".
- **Trap rooms are never traversed through** by navigation or `bfsDistances`
  (only reachable as a final destination). Keep this rule in any new pathfinding.
- **8×8 grid wrap is a ±4 twist** (`flipSidesGrid`, `gridWrap`). The maze is a
  64-cell torus but exploration yields ~90–100 room nodes, so the flat grid
  **collides** many rooms onto one cell. This is the open "grid wrap model" item
  in `BACKLOG.md`. In `GridMap.lua`, the **current room and start room (index 1)
  are trusted anchors** — when a cell holds one, it defines the cell's identity so
  a mis-wrapped POI room can't bleed a wrong color (e.g. false rune on the start cell).
- **Grid cells use motion-only mouse** (`SetMouseMotionEnabled`, with a
  `EnableMouse`+`SetMouseClickEnabled(false)` fallback) so left-click still pans
  the grid frame while hover hints work.
- **Player arrow** uses `GetPlayerFacing()`; the main map rotates it live in
  `onUpdate`, the grid only on refresh (per room change).
- Movement tracking lives in `RoomEngine.lua`'s `onUpdate` via `UnitPosition` +
  `detectDir` thresholds. Coordinate labels are throttled to ~10/sec to avoid GC churn.

---

## SavedVariables (`LucidNavDB`, per-character)

```
LucidNavDB = {
  mapData        = "<CSV>",        -- SerializeMap(): header + one row per room
  last_saved     = "YYYY-MM-DD HH:MM",
  matched_pairs  = { [1..5] = bool },
  checkpoints    = { [name] = { name, csv, saved, ts } },
  stats          = { ... },        -- Debug counters
  debug          = bool,
}
```

CSV row = `index,poi,N,E,S,W (neighbors), n,e,s,w (walls: "W" or " "), cx,cy,current,trap,-`.

**Editing a save file safely:** WoW writes `LucidNavDB` on logout and reads it on
login/`/reload`. Only hand-edit the save while the character is **logged out**, or
it gets overwritten. See `RoomEngine.lua` `SerializeMap`/`ImportMap` for the format.

---

## Testing (no game/Lua here)

- There is **no Lua interpreter** in the dev environment and **WoW can't run**
  here, so you can't execute the addon directly. Reason about changes carefully.
- **Simulate against real data:** parse a character's `LucidNavDB.mapData` and
  reimplement the algorithm in Python to reproduce/verify (this is how the grid
  A1 collision and the trap step-count bugs were confirmed). Save files live under
  `_retail_/WTF/Account/<id>/<realm>/<char>/SavedVariables/LucidNav.lua`.
- After edits, sanity-check by reading the changed block; there is no linter/CI.

---

## Maze reset (important product fact)

The Endless Halls layout is generated **per character from player ID + the current
date** (roughly `Hash(playerGUID + realmDate)`), changing once per day at ~**realm
midnight**, NOT the weekly/daily instance lockout. A brief relog keeps the same
maze; the next day is a new one. A future feature (see `BACKLOG.md`) could detect
regeneration and **prompt** for a fresh map — never auto-wipe (destructive).

---

## Release / contribution workflow

1. **Branch** off `main` as `vX.Y.Z-short-topic` for a feature set.
2. **Commit** with Conventional Commits (`feat(scope):`, `fix(nav):`, `docs:`,
   `perf:`, `build:`, `chore(release):`). Keep each commit focused; end messages
   with the `Co-Authored-By: Claude ...` trailer used in this repo.
3. **Bump the version** in `LucidNav.toc` (`## Version:`) — `release.sh` reads it.
   Follow SemVer: new features = minor, fixes only = patch.
4. **Update `CHANGELOG.md`** — add a `## [X.Y.Z] - YYYY-MM-DD` section grouped into
   Added / Changed / Fixed (/ Docs). Keep entries user-facing.
5. **Update store docs if user-facing:** `README.md` (GitHub) and `CURSEFORGE.md`
   (the CurseForge page description; images use `raw.githubusercontent.com/.../main/...`
   URLs, so screenshots must be on `main` to resolve).
6. **Package:** `bash release.sh` → `release/LucidNav-<ver>.zip` via `git archive HEAD`.
   `.gitattributes` `export-ignore` keeps `assets/`, `openspec/`, `release/`,
   `release.sh`, `CURSEFORGE.md`, `.gitattributes`, `.gitignore` **out of the zip**
   (screenshots stay in the repo but aren't shipped). Verify the zip after building.
7. **Merge to `main`** (fast-forward when possible) and **push**.
8. **Tag** `git tag -a vX.Y.Z -m "..." && git push origin vX.Y.Z`.
9. Upload the zip to CurseForge; paste `CURSEFORGE.md` into the description; use
   `release/RELEASE_NOTES-<ver>.md` (or the CHANGELOG section) for release notes.

Notes:
- `assets/img/*.png` are kept in the repo (README/CurseForge display) but excluded
  from the addon download — don't re-add them to the zip.
- `openspec/` holds design intent (proposals/specs) for larger changes; update it
  when a change is architecturally significant.
- `git remote origin` uses SSH (`git@github.com:cristian-encalada/LucidNav.git`).

---

## Where to look first

- Navigation / rooms / walls / dedup / serialization → `Core/RoomEngine.lua`.
- Anything about the 8×8 grid (positions, wrap, rendering) → `Core/GridMap.lua`.
- Right-panel UI, markers, match toggles, nav buttons → `Core/MapUI.lua`.
- Open ideas & known issues (incl. the ±4 wrap question, faster wall marking,
  maze-reset auto-detect) → `BACKLOG.md`.
