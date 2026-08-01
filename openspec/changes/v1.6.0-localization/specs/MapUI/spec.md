# Spec: MapUI — v1.6.0

## CHANGED

### Frame title and panel labels
- The main frame's `TitleText`, the "Markers"/"Navigation Target:"/"Current
  Room" section headers, and the "Current:"/"Selected:"/"X:"/"Y:" prefixes
  now read from `ns.L.LBL_*`.

### Toolbar and control tooltips
- Center camera, Erase map, Help, Undo toolbar tooltips; rune/orb button
  tooltips (via `ns.PoiName`); match-toggle tooltip; Clear-POI tooltip;
  wall-toggle tooltips (per direction, via `ns.L.DIR`); Set Player Loc / I got
  ported! tooltips — all now read from `ns.L.TIP_*`.

### Button labels
- Clear, Track, Set Player Loc (+ its "Click again!" confirm step), I got
  ported!, Grid Map, New Map, Save, Restore, and the opacity slider's
  40%/100%/"Opacity" labels now read from `ns.L.BTN_*`/`ns.L.LBL_*`.

### Checkpoint context menu
- The "Checkpoints" menu title, per-checkpoint "Restore"/"Delete" submenu
  items, and the "No checkpoints saved yet. Click Save first." /
  "Select a room first (click its center)." messages now read from
  `ns.L.MENU_*`/`ns.L.MSG_*`.

### Unaffected
- Compass rose single-letter labels (N/S/E/W) stay as literal glyphs (see
  `design.md` — read the same in all five languages). The `CLOSE` button
  is unchanged.
