# Spec: Debug — v1.6.0

(`Core/Debug.lua` has no prior top-level spec. This delta covers only the
localization-relevant surface; the module's debug/profiling behavior itself
is unchanged and out of scope for a general spec here.)

## CHANGED

### `/ln debug` output is localized
- `STAT_LABEL` values (the 12 session-stat display names: "Rooms discovered",
  "POIs set", etc.) now read from `ns.L.STAT_*`.
- Report headers ("session stats:", memory/CPU snapshot lines), the on/off
  toggle messages, and `printList`'s "clean" / "N issue(s)" summary lines now
  read from `ns.L.MSG_*`/`ns.L.AUDIT_*` via `string.format`.
- `Debug.Log`/`Debug.Report`/`Debug.FullReport` continue to print through
  `p()` (now `ns.PrintDebug`, per the pre-localization cleanup) — only the
  message bodies passed in are localized, not the debug-blue prefix itself
  (a developer-facing marker, left as `LucidNav[dbg]:` in all locales).
