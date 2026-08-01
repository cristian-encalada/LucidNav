# Tasks: v1.6.0 — Localization

## Status legend
- [ ] pending
- [x] done

---

## 1. Locales infrastructure
**Files:** `Locales/enUS.lua`, `Locales/esES.lua`, `Locales/ptBR.lua`, `Locales/deDE.lua`, `Locales/zhCN.lua`, `Locales/Locales.lua`, `LucidNav.toc`

- [x] 1.1 `Locales/enUS.lua` — base `ns.L` table, every key used anywhere in
      the addon defined here.
- [x] 1.2 `Locales/esES.lua` — early-return unless `GetLocale()` is `esES`/`esMX`,
      overrides translated keys only.
- [x] 1.3 `Locales/ptBR.lua` — early-return unless `GetLocale()` is `ptBR`,
      overrides translated keys only.
- [x] 1.3b `Locales/deDE.lua` — early-return unless `GetLocale()` is `deDE`,
      overrides translated keys only.
- [x] 1.3c `Locales/zhCN.lua` — early-return unless `GetLocale()` is `zhCN`,
      overrides translated keys only (`zhTW` out of scope, falls back to English).
- [x] 1.4 `Locales/Locales.lua` — assembles `ns.L.DIR[1..4]` / `ns.L.COLOR[1..5]`
      array forms after all overrides have applied.
- [x] 1.5 `LucidNav.toc` — register the six files right after `Core/Utils.lua`,
      before every consumer; bump `## Version:` to `1.6.0`.

## 2. Constants / Utils
**Files:** `Core/Constants.lua`, `Core/Utils.lua`

- [x] 2.1 Remove `direction_strings`/`color_strings` from `ns.C` (moved to
      `ns.L.DIR`/`ns.L.COLOR`).
- [x] 2.2 `ns.PoiName(i, withColor)` composes from `ns.L.COLOR`/`ns.L.SUFFIX_RUNE`/
      `ns.L.SUFFIX_ORB` instead of `C.color_strings`.

## 3. Core/Debug.lua
- [x] 3.1 `STAT_LABEL` table values → `ns.L.STAT_*` keys.
- [x] 3.2 Report headers, on/off toggle messages, `printList` format strings →
      `ns.L.MSG_*`/`ns.L.AUDIT_*` with `string.format`.

## 4. Core/RoomEngine.lua
- [x] 4.1 Navigation status messages (`outputGuidance`, no-route, unexplored) →
      `ns.L.MSG_*`.
- [x] 4.2 Audit message format strings (`AuditMap`) → `ns.L.AUDIT_*`.
- [x] 4.3 Trap/save/load/delete-room messages → `ns.L.MSG_*`.
- [x] 4.4 Guidance panel button text (`UpdateNavButtonText`) → `ns.L.LBL_*`.
- [x] 4.5 `direction_strings`/`color_strings` call sites → `ns.L.DIR`/`ns.L.COLOR`.

## 5. Core/History.lua, Core/Checkpoints.lua
- [x] 5.1 Undo print messages → `ns.L.MSG_*`.
- [x] 5.2 Checkpoint save/restore/delete print messages → `ns.L.MSG_*`.

## 6. Core/Dialogs.lua
- [x] 6.1 Jump dialog title/body/button labels → `ns.L.DLG_*`.
- [x] 6.2 Reset dialog title/body/button labels → `ns.L.DLG_*`.
- [x] 6.3 Help dialog title + section headers + body prose → `ns.L.DLG_HELP_*`
      (the largest single translation surface).

## 7. Core/RoomMenu.lua
- [x] 7.1 The 6 shared menu-item label constants → `ns.L.MENU_*` (single
      definition already shared between the modern/legacy code paths).
- [x] 7.2 "Context menu API unavailable" message → `ns.L.MSG_*`.

## 8. Core/MapUI.lua
- [x] 8.1 Frame title, panel section headers, "Current:"/"Selected:"/"X:"/"Y:"
      label prefixes → `ns.L.LBL_*`.
- [x] 8.2 Toolbar/button tooltips → `ns.L.TIP_*`.
- [x] 8.3 Button labels (Clear, Track, Set Player Loc, I got ported!, Grid Map,
      New Map, Save, Restore) → `ns.L.BTN_*`.
- [x] 8.4 Slider labels (Opacity/40%/100%) → `ns.L.LBL_*`.
- [x] 8.5 Checkpoint context menu title/no-checkpoints message → `ns.L.MENU_*`/`ns.L.MSG_*`.

## 9. Core/GridMap.lua
- [x] 9.1 "Edge wrap" tooltip title → `ns.L.TIP_*`.
- [x] 9.2 Direction-name usage → `ns.L.DIR` (row letters/compass glyphs stay
      as-is, see `design.md`).

## 10. LucidNav.lua
- [x] 10.1 Checkpoint list print messages → `ns.L.MSG_*`.

## 11. Translations
- [x] 11.1 Spanish (`esES.lua`) — every key in `enUS.lua` reviewed for a
      translation (one neutral table for `esES`/`esMX`).
- [x] 11.2 Portuguese (`ptBR.lua`) — every key in `enUS.lua` reviewed for a
      translation.
- [x] 11.3 German (`deDE.lua`) — every key in `enUS.lua` reviewed for a
      translation.
- [x] 11.4 Simplified Chinese (`zhCN.lua`) — every key in `enUS.lua` reviewed
      for a translation.
- [x] 11.5 Key-count parity check: all four regional files define the exact
      same 149 keys as `enUS.lua` (no partial translations left silently
      falling back mid-file).

## 12. Housekeeping
**Files:** `LucidNav.toc`, `CHANGELOG.md`, `README.md`, `CURSEFORGE.md`

- [x] 12.1 Bumped `## Version:` to `1.6.0`.
- [x] 12.1b Bumped `## Interface:` to add `120100` (patch 12.1.0, launching
      2026-08-11 per Warcraft Wiki's Patch 12.1.0/API changes page).
- [x] 12.2 Added `## [1.6.0]` CHANGELOG entry.
- [x] 12.3 Mentioned enUS/esES/esMX/ptBR/deDE/zhCN support in
      README.md/CURSEFORGE.md.

## 13. Verification
- [x] 13.1 Every `ns.L.KEY` reference across `Core/*.lua`/`LucidNav.lua` has a
      matching definition in `Locales/enUS.lua` (grep cross-check — a missing
      key is a nil `string.format`/concat error at runtime).
- [x] 13.2 `esES.lua`/`ptBR.lua` never reassign `ns.L`, only overwrite keys.
- [x] 13.3 `lua-language-server --check` clean (no new warnings from the
      conversion).
- [ ] 13.4 In-game: `/reload` with client language set to English (baseline
      unaffected), then Spanish, then Portuguese — confirm UI text switches
      and no nil-string errors on the most-used flows (open map, mark POI,
      mark trap, right-click menu, Help dialog, checkpoints). Cannot be run
      from this environment — ask the user to confirm.
