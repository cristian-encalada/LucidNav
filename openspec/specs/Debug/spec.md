# Source of Truth: Debug

**File:** `Core/Debug.lua`  
**Last updated:** v1.6.0 (new)

## Public API (Debug.*)

| Function | Description |
|----------|-------------|
| `Debug.Toggle()` | `/ln debug` — toggles live logging + periodic reporting; prints a full summary on stop |
| `Debug.SetEnabled(on)` | Explicit on/off |
| `Debug.IsEnabled()` | Returns current state |
| `Debug.Stat(key, n)` | Increments a persistent session stat (always tracked, independent of debug mode) |
| `Debug.GetStat(key)` | Reads a stat value |
| `Debug.Count(key, n)` | Increments a debug-mode-only counter (no-op while disabled) |
| `Debug.Log(fmt, ...)` | printf-style log line, gated on debug mode |
| `Debug.Report(tag)` | Prints a memory (and CPU, if `scriptProfile` is on) snapshot |
| `Debug.PrintStats()` | Prints all session stats |
| `Debug.ResetStats()` | Clears stats (called on New Map) |
| `Debug.FullReport(tag)` | Report + PrintStats + `Engine.AuditMap()` + `GridMap.AuditWrap()`, all in one place |
| `Debug.Initialize()` | Restores persisted stats/enabled-state from `LucidNavDB` on login |

## Behavior

- Off by default; zero overhead when disabled (every entry point
  early-returns on the `enabled` flag).
- Session stats (rooms discovered, POIs set, dedups, jumps, wall toggles,
  etc.) are **always** tracked regardless of debug mode — cheap, user-paced
  events — and persisted to `LucidNavDB.stats` on logout/reload.
- A periodic profiler frame reports memory every `PROFILE_INTERVAL` (5s)
  seconds while debug mode is on. CPU profiling requires the `scriptProfile`
  CVar to be `"1"` (reported as unavailable otherwise, rather than showing
  zeros).
- `Debug.FullReport` prints on both enable (baseline) and disable (final
  summary), including a map-structure audit (`Engine.AuditMap()`) and a grid
  wrap-model audit (`GridMap.AuditWrap()`).

## Localization (v1.6.0)

The 12 session-stat display names (`STAT_LABEL` table), the report headers
("session stats:", debug ON/OFF toggle messages), and the audit-summary
format strings ("`<title>`: clean" / "`<title>`: N issue(s)") now read from
`ns.L.STAT_*`/`ns.L.MSG_*`/`ns.L.AUDIT_*` keys via `string.format` — see the
`Locales` spec. The `ns.PrintDebug` (`"LucidNav[dbg]:"`) prefix itself stays
literal English in every locale (a technical marker, not translated).
