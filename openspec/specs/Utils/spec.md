# Source of Truth: Utils

**File:** `Core/Utils.lua`  
**Last updated:** v1.6.0 (new)

## Public API (ns.*)

| Function | Description |
|----------|-------------|
| `ns.Print(msg)` | Prints `msg` with the green `"LucidNav:"` chat prefix |
| `ns.PrintWarning(msg)` | Prints `msg` with the orange `"LucidNav warning:"` chat prefix |
| `ns.PrintDebug(msg)` | Prints `msg` with the blue `"LucidNav[dbg]:"` chat prefix (used by `Core/Debug.lua`) |
| `ns.ColorText(hex, text)` | Wraps `text` in a `"\|cffRRGGBB...\|r"` hex color code |
| `ns.PoiName(i, withColor)` | Builds the "Yellow Rune"/"Blue Orb"-style POI display name from a `poi_index` (1-5 = rune, 6-10 = orb); `withColor` wraps it in the POI's hex color |

## Purpose

Centralizes small formatting helpers that were previously copy-pasted at
every call site across `Core/*.lua`:

- **Chat prefixes**: `ns.Print`/`ns.PrintWarning`/`ns.PrintDebug` replace 13+
  inline `"|cff00ff00LucidNav:|r " .. msg`-style literals. Callers pass only
  the message body; the color-coded prefix itself is not translated (see the
  `Locales` spec's "Left untouched" section).
- **`ns.PoiName`**: single source of truth for Rune/Orb display-name
  construction (previously re-derived independently at 5+ call sites in
  `Core/RoomEngine.lua`/`Core/MapUI.lua`). Locale-aware since v1.6.0 — see
  the `Locales` spec for why it formats a full-name template rather than
  concatenating a color name with a fixed suffix.

## Load order

Loads immediately after `Core/Constants.lua` and before every
`Locales/*.lua` file. `ns.PoiName`'s body references `ns.L`, but since it's a
function (not evaluated until called), this is safe even though `ns.L` isn't
populated until the `Locales/*.lua` files run later in the same load
sequence — by the time any UI code actually calls `ns.PoiName`, locale
loading has long since completed.
