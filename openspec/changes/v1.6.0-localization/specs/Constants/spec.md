# Spec: Constants — v1.6.0

## REMOVED

### `ns.C.direction_strings`, `ns.C.color_strings`
- These were English display arrays masquerading as constants. Replaced by
  the locale-driven `ns.L.DIR[1..4]` / `ns.L.COLOR[1..5]` arrays (see the
  `Locales` spec) — `Constants.lua` loads before any `Locales/*.lua` file, so
  it cannot itself hold locale-resolved values.
- Every prior call site (`Core/RoomEngine.lua`, `Core/MapUI.lua`,
  `Core/RoomMenu.lua`, `Core/GridMap.lua`) now indexes `ns.L.DIR`/`ns.L.COLOR`
  instead.

## CHANGED

### `textColor` table unaffected
- The hex color constants added in the pre-localization cleanup
  (`ns.C.textColor.info/roomIndex/matched/unmatched`) are colors, not text,
  and are unchanged by this pass.
