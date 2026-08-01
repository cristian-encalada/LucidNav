# Spec: Utils — v1.6.0

(`Core/Utils.lua` has no prior top-level spec — added during the
pre-localization cleanup. This is its first spec entry.)

## ADDED

### `ns.Print(msg)` / `ns.PrintWarning(msg)` / `ns.PrintDebug(msg)`
- Shared chat-output helpers; each prepends its own color-coded
  `LucidNav:`/`LucidNav warning:`/`LucidNav[dbg]:` prefix and calls `print`.
  Callers pass only the already-localized (`ns.L`-sourced) message body.

### `ns.ColorText(hex, text)`
- Wraps `text` in a `|cffRRGGBB...|r` color code. Locale-independent (hex
  colors and markup aren't translated).

## CHANGED

### `ns.PoiName(i, withColor)`
- Builds the "Yellow Rune"/"Blue Orb"-style POI display name from a
  `poi_index` (1-5 = rune, 6-10 = orb). Previously composed from
  `ns.C.color_strings`; now formats a full-name template
  (`ns.L.POI_NAME_RUNE`/`ns.L.POI_NAME_ORB`, e.g. `"%s Rune"`) with
  `ns.L.COLOR[colorIdx]` — a template rather than a fixed
  color-then-suffix concatenation, since Spanish/Portuguese put the color
  adjective after the noun ("Runa Amarilla") where English puts it before
  ("Yellow Rune"). Every call site (7 across `RoomEngine.lua`/`MapUI.lua`)
  is correct in all five languages without further edits.
