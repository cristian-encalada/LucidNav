# AGENTS.md — LucidNav

WoW addon (pure Lua, **no build step, no test runner**) that maps and navigates
the Endless Halls maze. `CLAUDE.md` is the full developer guide (module layout,
room data model, SavedVariables schema, release workflow) — read it for anything
non-trivial. This file is the short list of what agents get wrong.

## Runtime & verification

- **WoW Lua 5.1**: no `\xHH`/`\u{}` string escapes, no `//` integer division, no
  `goto`. Use `wipe(t)` to clear tables. Embed literal UTF-8 or ASCII (`->`)
  instead of escape sequences — several past bugs came from this.
- **You cannot run or test changes here**: no Lua interpreter, no game, no
  linter/CI. Verify by re-reading the changed block. For algorithm questions,
  simulate in Python against a character's `LucidNavDB.mapData` (save files at
  `_retail_/WTF/Account/<id>/<realm>/<char>/SavedVariables/LucidNav.lua`) — this
  is how past bugs were confirmed.

## Load model

- **Only files listed in `LucidNav.toc` are loaded** by WoW, in .toc order.
  Adding a module = adding a line to the .toc.
- `libs/NyxGUI-1.0/` is vendored from the upstream fork but **not loaded** (not
  in the .toc, unused by `Core/`) — don't treat it as a dependency.
- Every module starts `local addonName, ns = ...`; all shared state hangs off
  `ns` (`ns.Engine`, `ns.GridMap`, `ns.maze`, ...).

## Invariants that bite (details in CLAUDE.md)

- Walls are mirrored on **both** rooms of a shared edge (`Engine.ToggleWall`),
  but navigation reads single-sided `walls[dir]` — keep them symmetric.
- Trap rooms are never routed *through* (only reached as a final destination) —
  preserve this in any pathfinding change.
- The 8×8 grid wraps with a ±4 twist and collides multiple rooms per cell; the
  current room and room 1 are trusted anchors in `GridMap` rendering.
- Hand-edit SavedVariables only while the character is **logged out**, or WoW
  overwrites your edit.

## Workflow

- Conventional Commits (`feat(nav):`, `fix(grid):`, `docs:`, ...) with the
  repo's `Co-Authored-By: Claude ...` trailer. User-facing changes: bump
  `## Version:` in the .toc, update `CHANGELOG.md`, `README.md` and
  `CURSEFORGE.md`.
- Package with `bash release.sh`, which runs `git archive HEAD` — **commit
  first**, uncommitted work won't be in the zip. Dev-only files must be added to
  `.gitattributes` `export-ignore` (this file already is) or they ship in the
  addon download.
- Commits/merges/tags/pushes are part of the documented release flow, but only
  run them when the user explicitly asks.
- Known issues & open ideas: `BACKLOG.md`. Architecturally significant changes:
  update `openspec/`.
