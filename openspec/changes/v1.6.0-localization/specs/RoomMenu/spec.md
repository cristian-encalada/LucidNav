# Spec: RoomMenu — v1.6.0

## CHANGED

### Menu item labels
- The 6 shared label constants (`LABEL_SET_CURRENT`, `LABEL_UNLINK`,
  `LABEL_DETACH`, `LABEL_CLEAR_TRAP`, `LABEL_UNDO`, `LABEL_DELETE` — already
  defined once and shared between the modern `MenuUtil` and legacy `EasyMenu`
  code paths since the pre-localization cleanup) now read from
  `ns.L.MENU_*` instead of English literals. Because they were already
  deduplicated to one definition each, this is a one-line change per label.
- The per-direction submenu labels (North/East/South/West) read
  `ns.L.DIR[dir]` (see the `Constants`/`Locales` deltas).
- "Context menu API unavailable on this client." now reads from `ns.L.MSG_*`.

### Unaffected
- Modern-vs-legacy branching logic (`RoomMenu.Show`) is unchanged.
