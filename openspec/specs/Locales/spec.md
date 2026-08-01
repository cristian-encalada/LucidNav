# Source of Truth: Locales

**Files:** `Locales/enUS.lua`, `Locales/esES.lua`, `Locales/ptBR.lua`, `Locales/deDE.lua`, `Locales/zhCN.lua`, `Locales/Locales.lua`  
**Last updated:** v1.6.0 (new)

## Purpose

Base + regional-override localization, no external library (AceLocale)
dependency. Auto-selects English, Spanish (`esES`/`esMX`), Portuguese
(`ptBR`), German (`deDE`), or Simplified Chinese (`zhCN`) from `GetLocale()`;
every other client locale falls back to English. There is no slash command
or SavedVariable to override the detected language.

## Files and load order

Registered in `LucidNav.toc` immediately after `Core/Utils.lua`, before every
file that reads `ns.L`:

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
...
```

- **`enUS.lua`** — base table. Populates `ns.L = { KEY = "string", ... }`
  unconditionally. Every `ns.L.KEY` referenced anywhere in the addon must be
  defined here — it's the fallback for any key a regional file doesn't
  override. Currently defines 149 keys.
- **`esES.lua` / `ptBR.lua` / `deDE.lua` / `zhCN.lua`** — each starts with an
  early return unless `GetLocale()` matches its locale code(s) (`esES.lua`
  matches both `esES` and `esMX`), then overwrites specific `ns.L[...]` keys
  on the shared table. **Never reassign `ns.L` itself** — that would drop
  every un-overridden English key. Each currently overrides all 149 keys
  (full parity with `enUS.lua`), but partial overrides are supported by
  design (an unset key falls through to English).
- **`Locales.lua`** — array finalizer. Must load *last* among the locale
  files. Assembles `ns.L.DIR = {DIR_NORTH, DIR_EAST, DIR_SOUTH, DIR_WEST}`
  and `ns.L.COLOR = {COLOR_YELLOW, COLOR_BLUE, COLOR_RED, COLOR_GREEN,
  COLOR_PURPLE}` from the (possibly locale-overridden) scalar keys, so
  direction/color-indexed call sites (`ns.L.DIR[dir]`, `ns.L.COLOR[i]`) see
  the resolved-language values. `Core/Constants.lua` loads *before* any
  locale file, so it cannot hold these arrays itself.

## Key naming convention

Flat `ns.L` table, `SCREAMING_SNAKE_CASE`, grouped by prefix:

| Prefix | Used for |
|--------|----------|
| `DIR_*` / `COLOR_*` | Direction and POI-color name scalars (feed the `DIR`/`COLOR` arrays) |
| `SUFFIX_*` / `POI_NAME_*` | POI display-name templates — see below |
| `MSG_*` | Chat/print message bodies (`string.format`-templated where a value is interpolated) |
| `DLG_*` | Dialog titles/bodies/button labels (`Core/Dialogs.lua`) |
| `MENU_*` | Right-click context menu item labels (`Core/RoomMenu.lua`, `Core/MapUI.lua` checkpoint menu) |
| `TIP_*` | Tooltip text |
| `BTN_*` | Button labels |
| `LBL_*` | Static FontString labels (panel titles, prefixes) |
| `STAT_*` | `Core/Debug.lua` session-stat labels |
| `AUDIT_*` | `Engine.AuditMap()` / `GridMap.AuditWrap()` diagnostic format strings |

## Interpolation rule: `string.format`, not concatenation

Every string embedding a variable is a `string.format` template with
positional `%s`/`%d` placeholders (e.g. `"Room %d marked as the teleport trap
room (orange on map)."`). Required, not just tidier: word order around an
interpolated value differs by language, so a straight 1:1 swap of a
concatenated English sentence isn't sufficient. **The placeholder type
sequence in a translated string must match the argument type sequence at the
call site** (`string.format` consumes varargs positionally) — translators may
reorder surrounding prose freely, but not the relative order of `%s` vs.
`%d` conversions.

## `ns.PoiName` — locale-aware POI naming

`ns.PoiName(i, withColor)` (`Core/Utils.lua`) builds the "Yellow
Rune"/"Blue Orb"-style POI display name via a **full-name template**, not a
color+suffix concatenation:

```lua
string.format(isOrb and L.POI_NAME_ORB or L.POI_NAME_RUNE, L.COLOR[colorIdx])
```

This exists because Spanish/Portuguese put the color adjective after the
noun ("Runa Amarilla") where English puts it before ("Yellow Rune") — a
fixed concatenation order would produce grammatically broken output in
those languages. German and Chinese sidestep gender/agreement issues
entirely via an apposition pattern (`"Rune der Farbe %s"`, `"%s符文"`)
rather than inflected adjectives.

## Left untouched (and why)

- The `ns.Print`/`ns.PrintWarning`/`ns.PrintDebug` prefixes
  (`"LucidNav:"`/`"LucidNav warning:"`/`"LucidNav[dbg]:"`) — the addon's
  proper name isn't translated, and `warning`/`[dbg]` read as technical
  markers, not prose.
- The WoW global `CLOSE` — already locale-aware via Blizzard's own
  `GlobalStrings`.
- Slash command keywords (`debug`, `undo`, `save`, `restore`, `checkpoints`)
  — parsing literals, not display text.
- Hex color codes, the EndlessHallsHelper export URL.
- Grid row letters (`A`–`H`) and single-letter compass labels (`N`/`E`/`S`/`W`)
  — coordinate/compass glyphs, read the same in every supported language.

## Known limitations

- Translations (esES/ptBR/deDE/zhCN) are Claude-authored with no
  native-speaker review pass — treated as a living first draft, refinable
  via GitHub issues/PRs.
- Traditional Chinese (`zhTW`) is out of scope; `zhTW` clients fall back to
  English.
- A 6th language is a follow-up (drop in one more `Locales/<locale>.lua`
  file), not a redesign, per the base+override pattern.
