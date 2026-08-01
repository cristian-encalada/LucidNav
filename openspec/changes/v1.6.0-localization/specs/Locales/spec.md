# Spec: Locales — v1.6.0

## ADDED

### `Locales/enUS.lua` — base string table
- Populates `ns.L = { KEY = "string", ... }` unconditionally on every client,
  regardless of `GetLocale()`. The single fallback for any key a regional
  file doesn't override.
- Every `ns.L.KEY` referenced anywhere in `Core/*.lua`/`LucidNav.lua` must be
  defined here.

### `Locales/esES.lua` — Spanish overrides
- `if GetLocale() ~= "esES" and GetLocale() ~= "esMX" then return end`, then
  overwrites specific `ns.L[...]` keys on the shared table.
- One neutral table serves both `esES` and `esMX` (no `vosotros`, register
  kept usable in Spain or Latin America).

### `Locales/ptBR.lua` — Portuguese overrides
- `if GetLocale() ~= "ptBR" then return end`, then overwrites specific
  `ns.L[...]` keys on the shared table.

### `Locales/deDE.lua` — German overrides
- `if GetLocale() ~= "deDE" then return end`, then overwrites specific
  `ns.L[...]` keys on the shared table.

### `Locales/zhCN.lua` — Simplified Chinese overrides
- `if GetLocale() ~= "zhCN" then return end`, then overwrites specific
  `ns.L[...]` keys on the shared table. Traditional Chinese (`zhTW`) is out
  of scope (see `proposal.md`) — `zhTW` clients fall back to English.

### `Locales/Locales.lua` — array finalizer
- Loads after `enUS`/`esES`/`ptBR`/`deDE`/`zhCN`. Assembles
  `ns.L.DIR = {DIR_NORTH, DIR_EAST, DIR_SOUTH, DIR_WEST}` and
  `ns.L.COLOR = {COLOR_YELLOW, COLOR_BLUE, COLOR_RED, COLOR_GREEN, COLOR_PURPLE}`
  from the (possibly locale-overridden) scalar keys, so direction/color-indexed
  call sites (`ns.L.DIR[dir]`, `ns.L.COLOR[i]`) see the resolved-language values.

### `.toc` load order
- `Locales/enUS.lua`, `Locales/esES.lua`, `Locales/ptBR.lua`,
  `Locales/deDE.lua`, `Locales/zhCN.lua`, `Locales/Locales.lua` load
  immediately after `Core/Utils.lua` and before every file that reads
  `ns.L` (`Core/Debug.lua` onward).

### Auto-detected language, no user setting
- Language selection is entirely `GetLocale()`-driven; there is no slash
  command or SavedVariable to override it. Unsupported locales fall back to
  English (`enUS.lua`'s values, since nothing overrides them).
