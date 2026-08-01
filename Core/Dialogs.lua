local addonName, ns = ...

ns.Dialogs = ns.Dialogs or {}
local Dialogs = ns.Dialogs

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

local function makeBody(dlg, text, justifyH, justifyV)
    local f = dlg:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    f:SetPoint("TOPLEFT",     dlg, "TOPLEFT",     16, -40)
    f:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -16,  42)
    f:SetWordWrap(true)
    f:SetText(text)
    if justifyH then f:SetJustifyH(justifyH) end
    if justifyV then f:SetJustifyV(justifyV) end
    return f
end

local function makeDialogButton(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    btn:SetSize(w or 120, h or 22)
    btn:SetText(text)
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
    local dlg = makeDialog(addonName.."JumpDialog", mazeFrame, 330, 160)
    makeTitle(dlg, "Lucid Nightmare Navigator")

    makeBody(dlg,
        "You have encountered an existing room on the map.\nIs this the same room you expected to enter?",
        "CENTER", "MIDDLE")

    makeConfirmButtons(dlg, "Yes, keep it linked", 130, "No, jump over", 110,
        function() ns.Engine.KeepLinked() end,
        function()
            if ns.History then ns.History.Snapshot("Jump over") end
            ns.Engine.JumpOver()
        end)

    mazeFrame.jumpDialog = dlg
end

------------------------------------------------------------
-- Reset confirm dialog
------------------------------------------------------------
local function buildResetDialog(mazeFrame)
    local dlg = makeDialog(addonName.."ResetDialog", mazeFrame, 300, 150)
    makeTitle(dlg, "Erase Map?")

    makeBody(dlg, "This will permanently erase your entire map.\nAre you sure?",
        "CENTER", "MIDDLE")

    makeConfirmButtons(dlg, "Yes, erase it", 110, "Cancel", 80,
        function() ns.Engine.ResetMap() end)

    mazeFrame.resetDialog = dlg
end

------------------------------------------------------------
-- Help dialog
------------------------------------------------------------
local function buildHelpDialog(mazeFrame)
    local dlg = makeDialog(addonName.."HelpDialog", mazeFrame, 500, 410)
    makeTitle(dlg, "Lucid Nightmare Navigator — Help")

    makeBody(dlg,
        "|cffffff00How do I navigate the map?|r\n" ..
        "|cffeeeeffRight-click drag anywhere on the map to pan the view.|r\n\n" ..
        "|cffffff00How do I mark walls and points of interest?|r\n" ..
        "|cffeeeeffClick the CENTER of a room to select it (a ring appears).\n" ..
        "Click an EDGE of a room to toggle that wall.\n" ..
        "Click a colored Rune/Orb button on the right panel to mark the selected (or current) room as that POI.|r\n\n" ..
        "|cffffff00How do I mark the teleport trap?|r\n" ..
        "|cffeeeeffWhen you get ported, immediately click 'I got ported!'. The trap room turns orange.|r\n\n" ..
        "|cffffff00What happens after a logout or crash?|r\n" ..
        "|cffeeeeffProper logout (20-second timer): you respawn at Room 1. The addon resets your position automatically.\n" ..
        "Force-close / crash / DC: you return to your last room in the maze. Walk back to a known room and use 'Set Player Loc' to correct your position.\n" ..
        "The maze resets every daily reset — finish before the server reset!|r\n\n" ..
        "|cffffff00Tips for solving the maze|r\n" ..
        "|cffeeeeff• Do NOT extinguish runes early — they are essential navigation landmarks.\n" ..
        "• Use navigation to reach unexplored rooms first.\n" ..
        "• The teleport trap is marked in orange — navigation avoids routing through it.|r",
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
