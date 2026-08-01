# Design Note: Localization

## Base + override pattern (no AceLocale dependency)

LucidNav has no other library dependencies (`libs/NyxGUI-1.0` was removed as
dead weight in the pre-localization cleanup), so pulling in AceLocale-3.0 just
for this would add a vendored library for one feature. Instead:

- `Locales/enUS.lua` always loads and fully populates `ns.L = { KEY = "..." }`
  — every key used anywhere in the addon must exist here, since it's the
  fallback for any key a regional file doesn't override.
- `Locales/esES.lua` / `Locales/ptBR.lua` / `Locales/deDE.lua` /
  `Locales/zhCN.lua` each start with an early return if `GetLocale()` doesn't
  match their locale code(s), then overwrite specific `ns.L[...]` keys on the
  *same* shared table — they never reassign `ns.L` itself (that would drop
  every un-overridden English key).

```lua
-- Locales/esES.lua
local addonName, ns = ...
local loc = GetLocale()
if loc ~= "esES" and loc ~= "esMX" then return end
local L = ns.L
L.MSG_UNDO_NONE = "Nada que deshacer."
-- ...
```

Only one Spanish table serves both `esES` and `esMX` per the user's decision
— no `vosotros`, kept neutral enough to read naturally in Spain or Latin
America.

## Load order (`.toc`)

```
Core\Constants.lua
Core\Utils.lua
Locales\enUS.lua
Locales\esES.lua
Locales\ptBR.lua
Locales\deDE.lua
Locales\zhCN.lua
Locales\Locales.lua
Core\Debug.lua
Core\RoomEngine.lua
Core\History.lua
Core\Checkpoints.lua
Core\GridMap.lua
Core\Dialogs.lua
Core\RoomMenu.lua
Core\MapUI.lua
LucidNav.lua
```

`Locales/enUS.lua` must load after `Core/Utils.lua` (harmless either order,
but keeping it grouped with the other locale files is clearer) and, critically,
**before** every file that reads `ns.L` at load time or call time.

## Why `direction_strings`/`color_strings` can't just become `ns.L` lookups in place

`Core/Constants.lua` loads *first*, before any `Locales/*.lua` file runs, so
`ns.C.direction_strings = {ns.L.DIR_NORTH, ...}` would bake in `nil`s — `ns.L`
doesn't exist yet at that point in the load sequence.

Fix: `Constants.lua` drops `direction_strings`/`color_strings` entirely (they
were display data masquerading as constants anyway). Each `Locales/*.lua`
file defines the scalar keys (`L.DIR_NORTH`, `L.COLOR_YELLOW`, etc.), and a
new tiny finalizer, `Locales/Locales.lua`, runs *last* among the locale files
(after `enUS`/`esES`/`ptBR`/`deDE`/`zhCN` have all applied) and assembles the indexed array
forms other modules already index by direction/color number:

```lua
-- Locales/Locales.lua
local addonName, ns = ...
local L = ns.L
L.DIR   = {L.DIR_NORTH, L.DIR_EAST, L.DIR_SOUTH, L.DIR_WEST}
L.COLOR = {L.COLOR_YELLOW, L.COLOR_BLUE, L.COLOR_RED, L.COLOR_GREEN, L.COLOR_PURPLE}
```

Every call site that did `C.direction_strings[dir]` / `C.color_strings[i]`
(RoomEngine.lua, MapUI.lua, RoomMenu.lua, GridMap.lua) switches to
`ns.L.DIR[dir]` / `ns.L.COLOR[i]`. This also finally unifies GridMap.lua's
long-standing separate copy of the same North/East/South/West table (already
folded into one `C.direction_strings` reference in the pre-localization
cleanup) — now there's exactly one array, owned by the locale layer.

## Key naming convention

Flat `ns.L` table, `SCREAMING_SNAKE_CASE`, grouped by prefix so the base file
reads as documentation of every surface:

| Prefix | Used for |
|--------|----------|
| `DIR_*` / `COLOR_*` | Direction and POI-color names (feed the `DIR`/`COLOR` arrays) |
| `MSG_*` | Chat/print message bodies (passed through `ns.Print`/`ns.PrintWarning`/`ns.PrintDebug`, `string.format`-templated where a value is interpolated) |
| `DLG_*` | Dialog titles/bodies/button labels (`Core/Dialogs.lua`) |
| `MENU_*` | Right-click context menu item labels (`Core/RoomMenu.lua`) |
| `TIP_*` | Tooltip text |
| `BTN_*` | Button labels (`Core/MapUI.lua` toolbar/bottom bar) |
| `LBL_*` | Static FontString labels (panel titles, "Current:"/"Selected:" prefixes) |
| `STAT_*` | `Core/Debug.lua` session-stat labels |
| `AUDIT_*` | `Engine.AuditMap()` / `GridMap.AuditWrap()` diagnostic format strings |

## Interpolation: `string.format`, not concatenation

Every string that embeds a variable is written as a `string.format` template
with positional `%s`/`%d` placeholders, e.g.:

```lua
L.MSG_TRAP_MARKED = "Room %d marked as the teleport trap room (orange on map)."
```
```lua
ns.Print(string.format(ns.L.MSG_TRAP_MARKED, cur.index))
```

This is required (not just tidier) because Spanish/Portuguese word order
around an interpolated value often differs from English — a straight 1:1
string swap of a concatenated English sentence isn't sufficient for
grammatically correct translations. This also matches the `string.format`
style already used consistently in `AuditMap`/`AuditWrap`/`Debug.lua` before
this change (established during the pre-localization cleanup).

## `ns.PoiName` becomes locale-aware for free

`ns.PoiName(i, withColor)` (added in the pre-localization cleanup) is the
single place that builds "Yellow Rune"/"Blue Orb"-style names. It composes
`string.format(isOrb and ns.L.POI_NAME_ORB or ns.L.POI_NAME_RUNE, ns.L.COLOR[colorIdx])`
— a **full name template**, not just a color+suffix concatenation, since
Spanish/Portuguese put the noun before the color adjective ("Runa Amarilla")
where English puts it after ("Yellow Rune"); a fixed concatenation order
would have produced grammatically broken output in those languages. Every one
of its ~7 call sites across `RoomEngine.lua`/`MapUI.lua` is correct in all
five languages without further edits.

## Left untouched (and why)

- **The `ns.Print`/`ns.PrintWarning`/`ns.PrintDebug` prefixes themselves**
  (`"LucidNav:"`, `"LucidNav warning:"`, `"LucidNav[dbg]:"`) stay literal
  English in every locale — `LucidNav` is the addon's proper name (not
  translated by convention, same as `CLOSE` isn't asked to translate a brand),
  and `warning`/`[dbg]` read as short technical markers rather than prose.
  Only the message *body* passed to these functions is sourced from `ns.L`.
- The WoW global `CLOSE` — already locale-aware via Blizzard's own
  `GlobalStrings`.
- Slash command keywords (`debug`, `undo`, `save`, `restore`, `checkpoints`)
  — parsing literals, not display text.
- Hex color codes, the EndlessHallsHelper export URL.
- Grid row letters (`A`–`H`) and single-letter compass labels (`N`/`E`/`S`/`W`)
  — coordinate/compass glyphs, not prose, read the same in all five
  languages.
