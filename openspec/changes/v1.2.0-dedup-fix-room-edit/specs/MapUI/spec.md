# Spec: MapUI changes — v1.2.0

## MODIFIED

### `createCell()` — click registration (line ~130)

**Before:**
```lua
btn:SetScript("OnClick", function(self, button, isDown)
    if button ~= "LeftButton" or isDown then return end
    ...
end)
```

**After:**
- Add `btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")` after `btn:SetSize`.
- In `OnClick`: keep existing left-click logic. Add branch:
  ```lua
  elseif button == "RightButton" then
      ns.RoomMenu.Show(self.room)
  end
  ```
  The `isDown` guard on left-click remains; right-click fires on `Up` (already guaranteed by RegisterForClicks).

### Undo button (bottom toolbar, `buildToolbar`)

Add an "Undo" icon button anchored to the left of the existing toolbar buttons (or bottom-left of the scrollframe), calling `ns.History.Undo()`. Tooltip: `"Undo last action"`. Uses same `makeIconBtn` pattern as existing toolbar buttons; icon: `"interface\\buttons\\ui-rotationleft-button"`.
