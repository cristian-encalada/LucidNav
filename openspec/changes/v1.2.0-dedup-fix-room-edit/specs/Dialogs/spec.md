# Spec: Dialogs changes — v1.2.0

## MODIFIED

### `buildJumpDialog` — "No, jump over" button handler

**Before:**
```lua
btnNo:SetScript("OnClick", function()
    ns.Engine.JumpOver()
    dlg:Hide()
end)
```

**After:**
```lua
btnNo:SetScript("OnClick", function()
    ns.History.Snapshot("Jump over")
    ns.Engine.JumpOver()
    dlg:Hide()
end)
```
