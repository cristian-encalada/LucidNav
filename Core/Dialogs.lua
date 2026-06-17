local addonName, ns = ...

ns.Dialogs = ns.Dialogs or {}
local Dialogs = ns.Dialogs

local DIALOG_BACKDROP = {
    bgFile   = "Interface\\DialogFrame\\UI-DialogBox-Background",
    edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
    tile     = true, tileSize = 32, edgeSize = 32,
    insets   = {left=11, right=12, top=12, bottom=11},
}

local function makeDialog(name, parent, w, h)
    local dlg = CreateFrame("Frame", name, parent, "BackdropTemplate")
    dlg:SetSize(w, h)
    dlg:SetFrameStrata("DIALOG")
    dlg:SetMovable(true)
    dlg:EnableMouse(true)
    dlg:RegisterForDrag("LeftButton")
    dlg:SetScript("OnDragStart", dlg.StartMoving)
    dlg:SetScript("OnDragStop",  dlg.StopMovingOrSizing)
    dlg:SetBackdrop(DIALOG_BACKDROP)
    return dlg
end

local function makeTitle(dlg, text)
    local t = dlg:CreateFontString(nil,"OVERLAY","GameFontNormalLarge")
    t:SetPoint("TOP", dlg, "TOP", 0, -14)
    t:SetText(text)
end

local function makeBody(dlg, text)
    local f = dlg:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    f:SetPoint("TOPLEFT",     dlg, "TOPLEFT",     16, -40)
    f:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -16,  42)
    f:SetWordWrap(true)
    f:SetText(text)
    return f
end

local function makeDialogButton(parent, text, w, h)
    local btn = CreateFrame("Button", nil, parent, "GameMenuButtonTemplate")
    btn:SetSize(w or 120, h or 22)
    btn:SetText(text)
    return btn
end

------------------------------------------------------------
-- Jump dialog
------------------------------------------------------------
local function buildJumpDialog(mazeFrame)
    local dlg = makeDialog(addonName.."JumpDialog", mazeFrame, 330, 160)
    dlg:SetPoint("CENTER", UIParent, "CENTER")
    makeTitle(dlg, "Lucid Nightmare Navigator")

    local body = makeBody(dlg,
        "You have encountered an existing room on the map.\nIs this the same room you expected to enter?")
    body:SetJustifyH("CENTER")
    body:SetJustifyV("MIDDLE")

    local btnYes = makeDialogButton(dlg, "Yes, keep it linked", 130, 22)
    btnYes:SetPoint("BOTTOMLEFT", dlg, "BOTTOMLEFT", 14, 14)
    btnYes:SetScript("OnClick", function()
        ns.Engine.KeepLinked()
        dlg:Hide()
    end)

    local btnNo = makeDialogButton(dlg, "No, jump over", 110, 22)
    btnNo:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -14, 14)
    btnNo:SetScript("OnClick", function()
        if ns.History then ns.History.Snapshot("Jump over") end
        ns.Engine.JumpOver()
        dlg:Hide()
    end)

    dlg:Hide()
    mazeFrame.jumpDialog = dlg
end

------------------------------------------------------------
-- Reset confirm dialog
------------------------------------------------------------
local function buildResetDialog(mazeFrame)
    local dlg = makeDialog(addonName.."ResetDialog", mazeFrame, 300, 150)
    dlg:SetPoint("CENTER", UIParent, "CENTER")
    makeTitle(dlg, "Erase Map?")

    local body = makeBody(dlg, "This will permanently erase your entire map.\nAre you sure?")
    body:SetJustifyH("CENTER")
    body:SetJustifyV("MIDDLE")

    local btnYes = makeDialogButton(dlg, "Yes, erase it", 110, 22)
    btnYes:SetPoint("BOTTOMLEFT", dlg, "BOTTOMLEFT", 14, 14)
    btnYes:SetScript("OnClick", function()
        ns.Engine.ResetMap()
        dlg:Hide()
    end)

    local btnNo = makeDialogButton(dlg, "Cancel", 80, 22)
    btnNo:SetPoint("BOTTOMRIGHT", dlg, "BOTTOMRIGHT", -14, 14)
    btnNo:SetScript("OnClick", function() dlg:Hide() end)

    dlg:Hide()
    mazeFrame.resetDialog = dlg
end

------------------------------------------------------------
-- Help dialog
------------------------------------------------------------
local function buildHelpDialog(mazeFrame)
    local dlg = makeDialog(addonName.."HelpDialog", mazeFrame, 500, 410)
    dlg:SetPoint("CENTER", UIParent, "CENTER")
    makeTitle(dlg, "Lucid Nightmare Navigator — Help")

    local body = makeBody(dlg,
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
        "• The teleport trap is marked in orange — navigation avoids routing through it.|r"
    )
    body:SetJustifyH("LEFT")
    body:SetJustifyV("TOP")

    local btnClose = makeDialogButton(dlg, CLOSE, 80, 22)
    btnClose:SetPoint("BOTTOM", dlg, "BOTTOM", 0, 14)
    btnClose:SetScript("OnClick", function() dlg:Hide() end)

    dlg:Hide()
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
