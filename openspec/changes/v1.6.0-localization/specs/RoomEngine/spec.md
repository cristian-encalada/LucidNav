# Spec: RoomEngine — v1.6.0

## CHANGED

### User-facing strings sourced from `ns.L`
- All navigation status messages (`outputGuidance`: unexplored-room /
  destination-detected / no-route-found / step-by-step directions), the
  trap-marking flow (`Engine.HitTheTrap`), save/load messages
  (`Engine.LoadSavedMap`, the `PLAYER_LOGOUT` handler), delete-room guard
  messages (`Engine.DeleteRoom`), and the reachability warning
  (`Engine.UpdateNavButtonText`) now read their text from `ns.L.MSG_*` keys
  instead of hardcoded English literals.
- Every message that interpolates a value (room index, step count, direction
  name) is now built with `string.format(ns.L.MSG_KEY, ...)` instead of `..`
  concatenation, so word order can differ per language.
- `AuditMap()`'s diagnostic format strings (orphaned room, missing neighbor,
  asymmetric link, wall mismatch, canvas overlap) now read from `ns.L.AUDIT_*`.
- The guidance panel button text (`UpdateNavButtonText`: "Unexplored
  Territory" / "Teleport Trap" / `(here)`) now reads from `ns.L.LBL_*`.

### Direction/color array lookups
- `C.direction_strings[dir]` / `C.color_strings[i]` call sites now read
  `ns.L.DIR[dir]` / `ns.L.COLOR[i]` (see the `Constants` and `Locales` deltas).

### Unaffected
- The `Room` class shape, BFS/navigation algorithms, dedup logic, and
  serialization format are unchanged — this is a display-layer-only change.
