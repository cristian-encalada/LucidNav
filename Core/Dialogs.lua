local addonName, ns = ...

ns.Dialogs = ns.Dialogs or {}
local Dialogs = ns.Dialogs

local function hideTooltip() GameTooltip:Hide() end
local function tip(btn, text)
    btn:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
        GameTooltip:ClearLines()
        GameTooltip:AddLine(text)
        GameTooltip:Show()
    end)
    btn:SetScript("OnLeave", hideTooltip)
end

local DIALOG_BACKDROP = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true, tileSize = 32, edgeSize = 32,
    insets   = {left=11, right=12, top=12, bottom=11},
}

-- `justifyH`/`justifyV` default to the FontString's own defaults (LEFT/TOP)
-- when omitted, so the Help dialog's body doesn't need to pass them.
local function makeDialog(name, parent, w, h)
    local dlg = CreateFrame("Frame", name, parent, "BackdropTemplate")
    dlg:SetSize(w, h)
    dlg:SetPoint("CENTER", UIParent, "CENTER")
    dlg:SetFrameStrata("DIALOG")
    dlg:SetMovable(true)
    dlg:EnableMouse(true)
    dlg:RegisterForDrag("LeftButton")
    dlg:SetScript("OnDragStart", dlg.StartMoving)
    dlg:SetScript("OnDragStop",  dlg.StopMovingOrSizing)
    dlg:SetBackdrop(DIALOG_BACKDROP)
    dlg:Hide()
    return dlg
end

local function makeTitle(dlg, text)
    local t = dlg:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    t:SetPoint("TOP", dlg, "TOP", 0, -14)
    t:SetText(text)
end

local function makeBody(dlg, text, justifyH, justifyV, bottomOffset)
    local f = dlg:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    f:SetPoint("TOPLEFT",     dlg, "TOPLEFT",     16, -40)
    f:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -16,  bottomOffset or 42)
    f:SetWordWrap(true)
    f:SetText(text)
    if justifyH then f:SetJustifyH(justifyH) end
    if justifyV then f:SetJustifyV(justifyV) end
    return f
end

-- Localized button labels (esES/deDE/ptBR) commonly run longer than the
-- English text these pixel widths were sized for, so widen the button to
-- fit its label rather than let the text spill past the button edges.
local function makeDialogButton(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    local minW = w or 120
    btn:SetSize(minW, h or 22)
    btn:SetText(text)
    local fs = btn:GetFontString()
    if fs then
        local tw = fs:GetStringWidth() + 16
        if tw > minW then btn:SetWidth(tw) end
    end
    return btn
end

-- Shared Yes/No confirmation button pair (bottom-left "Yes"/bottom-right
-- "No"), each hiding the dialog after running its handler.
local function makeConfirmButtons(dlg, yesText, yesW, noText, noW, onYes, onNo)
    local btnYes = makeDialogButton(dlg, yesText, yesW, 22)
    btnYes:SetPoint("BOTTOMLEFT", dlg, "BOTTOMLEFT", 14, 14)
    btnYes:SetScript("OnClick", function()
        onYes()
        dlg:Hide()
    end)

    local btnNo = makeDialogButton(dlg, noText, noW, 22)
    btnNo:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -14, 14)
    btnNo:SetScript("OnClick", function()
        if onNo then onNo() end
        dlg:Hide()
    end)

    return btnYes, btnNo
end

------------------------------------------------------------
-- Jump dialog
------------------------------------------------------------
local function buildJumpDialog(mazeFrame)
    local dlg = makeDialog(addonName.."JumpDialog", mazeFrame, 330, 184)
    -- This one fires far more often than the other dialogs (once per
    -- loop-closure, which is most steps late-game), so unlike Reset/Help it
    -- doesn't get screen-center: that would blank out the map underneath
    -- right when the player wants to see the room they just walked into.
    -- Anchored to the top instead, clear of the map window below it.
    dlg:ClearAllPoints()
    dlg:SetPoint("TOP", UIParent, "TOP", 0, -60)
    makeTitle(dlg, addonName)

    makeBody(dlg, ns.L.DLG_JUMP_BODY, "CENTER", "MIDDLE", 66)

    -- Late-game, nearly every step re-enters already-mapped territory, so
    -- this dialog can fire on almost every move. Letting the player opt in
    -- to skipping it (instead of the addon silently guessing) keeps that
    -- flow uninterrupted without risking a wrong auto-link corrupting the
    -- map -- "No, jump over" is still reachable by unchecking this.
    local cb = CreateFrame("CheckButton", nil, dlg, "UICheckButtonTemplate")
    cb:SetSize(20, 20)
    cb:SetPoint("BOTTOM", dlg, "BOTTOM", -70, 40)
    cb:SetChecked(false)
    cb:SetScript("OnClick", function(self) ns.jumpAutoKeepLinked = (self:GetChecked() == true) end)
    local cbLabel = dlg:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
    cbLabel:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    cbLabel:SetText(ns.L.CHK_AUTO_KEEP_LINKED)
    tip(cb, ns.L.TIP_AUTO_KEEP_LINKED)

    makeConfirmButtons(dlg, ns.L.DLG_JUMP_YES, 130, ns.L.DLG_JUMP_NO, 110,
        function() ns.Engine.KeepLinked() end,
        function()
            if ns.History then ns.History.Snapshot(ns.L.MSG_LABEL_JUMP_OVER) end
            ns.Engine.JumpOver()
        end)

    mazeFrame.jumpDialog = dlg
end

------------------------------------------------------------
-- Reset confirm dialog
------------------------------------------------------------
local function buildResetDialog(mazeFrame)
    local dlg = makeDialog(addonName.."ResetDialog", mazeFrame, 300, 150)
    makeTitle(dlg, ns.L.DLG_RESET_TITLE)

    makeBody(dlg, ns.L.DLG_RESET_BODY, "CENTER", "MIDDLE")

    makeConfirmButtons(dlg, ns.L.DLG_RESET_YES, 110, ns.L.DLG_RESET_NO, 80,
        function() ns.Engine.ResetMap() end)

    mazeFrame.resetDialog = dlg
end

------------------------------------------------------------
-- Help dialog
------------------------------------------------------------
local function buildHelpDialog(mazeFrame)
    local dlg = makeDialog(addonName.."HelpDialog", mazeFrame, 500, 410)
    makeTitle(dlg, addonName .. " " .. ns.L.DLG_HELP_TITLE)

    makeBody(dlg,
        "|cffffff00" .. ns.L.DLG_HELP_H_NAVIGATE .. "|r\n" ..
        "|cffeeeeff" .. ns.L.DLG_HELP_B_NAVIGATE .. "|r\n\n" ..
        "|cffffff00" .. ns.L.DLG_HELP_H_MARKING .. "|r\n" ..
        "|cffeeeeff" .. ns.L.DLG_HELP_B_MARKING .. "|r\n\n" ..
        "|cffffff00" .. ns.L.DLG_HELP_H_TRAP .. "|r\n" ..
        "|cffeeeeff" .. ns.L.DLG_HELP_B_TRAP .. "|r\n\n" ..
        "|cffffff00" .. ns.L.DLG_HELP_H_LOGOUT .. "|r\n" ..
        "|cffeeeeff" .. ns.L.DLG_HELP_B_LOGOUT .. "|r\n\n" ..
        "|cffffff00" .. ns.L.DLG_HELP_H_TIPS .. "|r\n" ..
        "|cffeeeeff" .. ns.L.DLG_HELP_B_TIPS .. "|r",
        "LEFT", "TOP"
    )

    local btnClose = makeDialogButton(dlg, CLOSE, 80, 22)
    btnClose:SetPoint("BOTTOM", dlg, "BOTTOM", 0, 14)
    btnClose:SetScript("OnClick", function() dlg:Hide() end)

    mazeFrame.helpDialog = dlg
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function Dialogs.Build(mazeFrame)
    buildJumpDialog(mazeFrame)
    buildResetDialog(mazeFrame)
    buildHelpDialog(mazeFrame)
end
