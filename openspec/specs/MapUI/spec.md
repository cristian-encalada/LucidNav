# Source of Truth: MapUI

**File:** `Core/MapUI.lua`  
**Last updated:** v1.6.0

## Public API (MapUI.*)

| Function | Description |
|----------|-------------|
| `MapUI.Initialize()` | Builds all frames; called on first Toggle |
| `MapUI.Toggle()` | Show/hide the main frame |
| `MapUI.UpdateWallButtons()` | Refreshes the current-room reference panel (center text, wall lines, neighbor fill) |
| `MapUI.UpdateMatchButtons()` | Refreshes the per-color matched/unmatched glyph |

## Frame structure

- `ns.maze` — main `BasicFrameTemplateWithInset` frame (730×580)
- `ns.scrollframe` — map canvas scroll frame (anchored inside maze)
- `ns.container` — scroll child, `C.containerW × C.containerH`
- `ns.playerNav` — player arrow frame
- `maze.selMarker` — selection ring texture

## Right panel

- **Current Room reference panel** — 5-cell cross (top), N/E/S/W buttons toggle
  the selected room's walls directly; center cell shows the room index and
  wall-line overlays.
- **Markers panel** — rune/orb icon buttons (`maze.poi_buttons[1..10]`), a
  per-color matched/unmatched toggle (`maze.match_buttons[1..5]`), a Clear
  button, and the Navigation Target section (`maze.guidance_buttons[1..12]`).

## Bottom controls

| Control | Description |
|---------|-------------|
| Track checkbox | Enables/disables position tracking |
| Set Player Loc | Two-step confirm; moves player to selected room |
| I got ported! | Calls `Engine.HitTheTrap()` |
| Opacity slider | 40–100%, adjusts `maze:SetAlpha` |

## Bottom bar buttons

| Button | Action |
|--------|--------|
| Grid Map | `ns.GridMap.Show()` |
| New Map | Shows reset dialog |
| Save | `ns.Checkpoints.Save()` (v1.3.0) |
| Restore | Context menu of saved checkpoints, each with Restore/Delete (v1.3.0) |
| Close | Hides maze frame |

## Toolbar icon buttons (top-right of scrollframe)

| Button | Action |
|--------|--------|
| Center (crosshairs) | `Engine.CenterCamera()` |
| Reset (muted icon) | Shows reset dialog |
| Help (info icon) | Shows help dialog |
| Undo (rotate-left icon) | `History.Undo()` (v1.2.0) |

## Localization (v1.6.0)

Frame title, all panel section headers, the "Current:"/"Selected:"/"X:"/"Y:"
label prefixes, every tooltip, and every button label now read from
`ns.L.LBL_*`/`ns.L.TIP_*`/`ns.L.BTN_*`/`ns.L.MENU_*` keys — see the `Locales`
spec. The compass rose's single-letter N/S/E/W labels are unaffected (read
as compass glyphs, not prose, in every language). The `CLOSE` button is
unaffected (already locale-aware via the Blizzard global).
