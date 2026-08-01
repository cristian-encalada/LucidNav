# Source of Truth: Constants

**File:** `Core/Constants.lua`  
**Last updated:** v1.6.0 (new)

## Purpose

`ns.C` — non-localizable constants: sizes, colors, direction/coordinate
tables, POI hex colors, serialization/legacy constants. Loads first (before
`Core/Utils.lua` and every `Locales/*.lua` file), so it cannot hold
locale-resolved display text — see the `Locales` spec for where those live.

## Key fields

| Field | Description |
|-------|-------------|
| `containerW`/`containerH` | Canvas scroll-child size |
| `buttonW`/`buttonH` | Cell size (35×35) |
| `cellStep` | Canvas spacing between cell origins (≈ `buttonW + 1`, v1.4.0) — tight gap so adjacent open rooms read as connected |
| `wallColor`, `wallThickness`, `dashSegments`, `dashGap` | Paper-style wall-line rendering (v1.4.0): solid bar for a blocked edge, short dash segments for cross/overlap rooms |
| `borderW`/`borderH` | Edge hit-zone width for click detection |
| `north`/`east`/`south`/`west` | Direction constants `1..4` |
| `oppositeDir` | `{3,4,1,2}` — mirrored edge per direction |
| `coord_offset` | `{{0,-1},{1,0},{0,1},{-1,0}}` — dx/dy per direction |
| `dir_to_region`/`dir_to_region_opposite` | Frame anchor points per direction (wall click-zone hit testing) |
| `poi_hex_colors`, `poi_hex_colors_found`, `poi_rgb` | Per-color-index (1-5) hex/RGB for rune/orb rendering |
| `EHHPOIStrings` | `#Y/#B/.../$Y/$B/...` export tokens for EndlessHallsHelper (rune=`#`, orb=`$`) |
| `cellColor` | Cell fill colors: default, border, visited, trap, orphan-border, cross/overlap tint |
| `wallHoverColor` | Highlight on the edge zone under the cursor |
| `textColor` | Hex color codes reused across label/print sites (paired with `ns.ColorText`): `info`, `roomIndex`, `matched`, `unmatched` |
| `oldContainerW`/`oldButtonStep` | Legacy save-format constants (backward-compat coordinate conversion) |
| `player_icon` | Player arrow texture path |

## Localization (v1.6.0)

`direction_strings` (`{"North","East","South","West"}`) and `color_strings`
(`{"Yellow","Blue","Red","Green","Purple"}`) were **removed** — they were
English display arrays masquerading as constants. Replaced by
`ns.L.DIR[1..4]`/`ns.L.COLOR[1..5]`, assembled in `Locales/Locales.lua` after
locale load (impossible here, since this file loads before any
`Locales/*.lua` file runs). Every prior call site (`Core/RoomEngine.lua`,
`Core/MapUI.lua`, `Core/RoomMenu.lua`, `Core/GridMap.lua`) now indexes
`ns.L.DIR`/`ns.L.COLOR` instead. `textColor` is unaffected — it's colors, not
text.
