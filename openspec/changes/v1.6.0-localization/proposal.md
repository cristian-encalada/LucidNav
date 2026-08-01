# Change Proposal: v1.6.0 — Localization (enUS / esES-esMX / ptBR / deDE / zhCN)

## Summary

LucidNav has no localization infrastructure today — every user-facing string
(button labels, tooltips, dialogs, print/chat messages, the Help text) is a
hardcoded English literal, mostly built with `..` concatenation, spread across
9 files. This change adds Spanish, Portuguese, German, and Simplified Chinese
support, auto-selected from the WoW client's language (`GetLocale()`),
falling back to English otherwise.

User-confirmed decisions (from the planning discussion):

1. **Full coverage** — translate everything user-facing, including
   `Core/Debug.lua`'s `/ln debug` output and `AuditMap()`/`AuditWrap()`
   diagnostic messages, not just the primary UI.
2. **One neutral Spanish table** covering both the `esES` and `esMX` WoW
   locale codes (avoids `vosotros`, keeps register neutral/Latin-America
   friendly) — not two separate regional variants.
3. **German (`deDE`) and Simplified Chinese (`zhCN`) added** after the
   initial Spanish/Portuguese pass, for the same reason (large WoW
   Chinese- and German-speaking communities) — **Traditional Chinese
   (`zhTW`) is explicitly out of scope** (see below), one Simplified
   Chinese table only.
4. **Translations are Claude-authored** — no existing reference and no
   native-speaker review pass in this change. Treated as a living first draft,
   refinable later via issues/PRs, same as any other addon's localization.

This change ships on top of the `refactor(core)` / `chore` / `fix(engine)`
cleanup already merged to `main` (centralized print helpers, `ns.PoiName`,
`Room` class annotations) — that work was explicitly prep so this pass edits
each string exactly once, through a handful of choke points, instead of once
per copy-pasted call site.

## Intended Outcome

Players running the WoW client in Spanish (`esES`/`esMX`), Portuguese
(`ptBR`), German (`deDE`), or Simplified Chinese (`zhCN`) see LucidNav's UI in
their language automatically; every other locale falls back to English.
Adding a future language is a matter of dropping in one more
`Locales/<locale>.lua` override file — no `Core/*.lua` file needs to change
again.

## Scope

### In scope
- New `Locales/` folder: `enUS.lua` (base, always fully populated),
  `esES.lua` (overrides for `esES`/`esMX`), `ptBR.lua` (overrides for
  `ptBR`), `deDE.lua` (overrides for `deDE`), `zhCN.lua` (overrides for
  `zhCN`), `Locales.lua` (finalizer — assembles the `ns.L.DIR`/`ns.L.COLOR`
  array forms after overrides are applied; see `design.md`).
- Convert every hardcoded user-facing string in `Core/*.lua` and
  `LucidNav.lua` to an `ns.L.KEY` lookup, restructuring `..`-concatenation
  into `string.format(ns.L.KEY, ...)` wherever a value is interpolated (word
  order around a value differs between English/Spanish/Portuguese).
- Remove `ns.C.direction_strings` / `ns.C.color_strings` from
  `Core/Constants.lua` in favor of locale-driven `ns.L.DIR[1..4]` /
  `ns.L.COLOR[1..5]` arrays (see `design.md` for why the array form has to be
  assembled after locale load, not at `Constants.lua` load time).
- `LucidNav.toc` load-order update: the six `Locales/*.lua` files load right
  after `Core/Utils.lua` and before every file that consumes `ns.L`.
- Version bump `1.5.0` → `1.6.0`, `CHANGELOG.md` entry, `README.md` /
  `CURSEFORGE.md` mention of supported locales.

### Out of scope
- **Traditional Chinese (`zhTW`)** — mainland China (`zhCN`, Simplified) is
  the larger WoW Chinese-speaking market and the one requested; adding a
  second Chinese table without native-speaker review for either would double
  the wording risk for a market this addon doesn't yet have signal on. A
  follow-up, not a redesign, per the base+override pattern.
- A 6th language beyond Spanish/Portuguese/German/Chinese (same reasoning).
- Localizing slash-command *keywords* (`debug`, `undo`, `save`, `restore`,
  `checkpoints`) — these are English parsing literals, not display text;
  changing them risks breaking muscle memory/docs for existing users. Only
  the printed *output* of these commands is localized.
- Native-speaker review of the esES/ptBR/deDE/zhCN wording (tracked as a
  known limitation, not a blocker — see Summary point 4).
- Grid coordinate letters (`A`–`H`) and single-letter compass labels
  (`N`/`E`/`S`/`W`) — these read as coordinate/compass glyphs, not prose, in
  all five languages, and stay as-is.

## Affected Files

| File | Status |
|------|--------|
| `Locales/enUS.lua` | Added |
| `Locales/esES.lua` | Added |
| `Locales/ptBR.lua` | Added |
| `Locales/deDE.lua` | Added |
| `Locales/zhCN.lua` | Added |
| `Locales/Locales.lua` | Added |
| `Core/Constants.lua` | Modified (remove `direction_strings`/`color_strings`) |
| `Core/Utils.lua` | Modified (`ns.PoiName` becomes locale-aware) |
| `Core/Debug.lua` | Modified |
| `Core/RoomEngine.lua` | Modified |
| `Core/History.lua` | Modified |
| `Core/Checkpoints.lua` | Modified |
| `Core/Dialogs.lua` | Modified |
| `Core/RoomMenu.lua` | Modified |
| `Core/MapUI.lua` | Modified |
| `Core/GridMap.lua` | Modified |
| `LucidNav.lua` | Modified |
| `LucidNav.toc` | Modified (register `Locales/*.lua`, version bump) |
| `CHANGELOG.md` | Modified |
| `README.md` / `CURSEFORGE.md` | Modified (mention supported locales) |

## Version Bump
`1.5.0` → `1.6.0`
