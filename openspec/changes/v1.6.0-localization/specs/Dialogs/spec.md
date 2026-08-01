# Spec: Dialogs — v1.6.0

## CHANGED

### Jump dialog
- Title, body text, and both button labels ("Yes, keep it linked" / "No,
  jump over") now read from `ns.L.DLG_JUMP_*`.

### Reset dialog
- Title, body text, and both button labels ("Yes, erase it" / "Cancel") now
  read from `ns.L.DLG_RESET_*`.

### Help dialog
- Title, the 5 section headers, and the full body prose now read from
  `ns.L.DLG_HELP_*` — the single largest translation surface in the addon
  (a full multi-paragraph tutorial). The `CLOSE` button is unchanged (already
  locale-aware via the Blizzard global).

### Unaffected
- `makeDialog`/`makeTitle`/`makeBody`/`makeDialogButton`/`makeConfirmButtons`
  helper structure (added in the pre-localization cleanup) is unchanged —
  only the string literals passed into them move to `ns.L`.
