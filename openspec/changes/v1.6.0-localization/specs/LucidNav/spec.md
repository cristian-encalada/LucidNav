# Spec: LucidNav (root) — v1.6.0

(`LucidNav.lua` — the slash command entry point — has no prior top-level
spec. This delta covers only the localization-relevant surface.)

## CHANGED

### Checkpoint list print output
- The `/ln checkpoints` output ("No checkpoints saved." / "LucidNav
  checkpoints:" header / per-entry lines) now reads from `ns.L.MSG_*`.

## Unaffected

### Slash command keywords
- `/lucid`, `/ln`, `/lnn` and the sub-argument keywords (`debug`, `undo`,
  `save`, `restore`, `checkpoints`) remain English literals — these are
  parsing tokens, not display text, and localizing them would risk breaking
  muscle memory and existing documentation/screenshots for current users
  (per the proposal's explicit out-of-scope decision).
