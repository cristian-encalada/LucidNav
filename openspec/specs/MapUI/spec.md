# Source of Truth: MapUI

**File:** `Core/MapUI.lua`  
**Last updated:** v1.1.0

## Public API (MapUI.*)

| Function | Description |
|----------|-------------|
| `MapUI.Initialize()` | Builds all frames; called on first Toggle |
| `MapUI.Toggle()` | Show/hide the main frame |

## Frame structure

- `ns.maze` — main `BasicFrameTemplateWithInset` frame (730×580)
- `ns.scrollframe` — map canvas scroll frame (anchored inside maze)
- `ns.container` — scroll child, `C.containerW × C.containerH`
- `ns.playerNav` — player arrow frame
- `maze.selMarker` — selection ring texture

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
| Close | Hides maze frame |

## Toolbar icon buttons (top-right of scrollframe)

| Button | Action |
|--------|--------|
| Center (crosshairs) | `Engine.CenterCamera()` |
| Reset (muted icon) | Shows reset dialog |
| Help (info icon) | Shows help dialog |
