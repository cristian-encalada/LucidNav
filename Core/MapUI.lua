local addonName, ns = ...
local C = ns.C

ns.MapUI = ns.MapUI or {}
local MapUI = ns.MapUI

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

------------------------------------------------------------
-- Main frame (BasicFrameTemplateWithInset)
------------------------------------------------------------
local function buildFrame()
    local maze = CreateFrame("Frame", addonName.."Frame", UIParent, "BasicFrameTemplateWithInset")
    maze:SetSize(730, 580)
    maze:SetPoint("CENTER")
    maze:SetFrameStrata("MEDIUM")
    maze:SetToplevel(true)
    maze:SetClampedToScreen(true)
    maze:SetMovable(true)
    maze:EnableMouse(true)
    maze:RegisterForDrag("LeftButton")
    maze:SetScript("OnDragStart", maze.StartMoving)
    maze:SetScript("OnDragStop",  maze.StopMovingOrSizing)

    if maze.TitleText then
        maze.TitleText:SetText("Lucid Nightmare Navigator")
    end
    if maze.CloseButton then
        maze.CloseButton:SetScript("OnClick", function() maze:Hide() end)
    end

    table.insert(UISpecialFrames, addonName.."Frame")  -- ESC closes it

    maze.current_room_label = maze:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    maze.current_room_label:SetPoint("TOPLEFT", maze, "TOPLEFT", 60, -35)
    maze.current_room_label:SetText("Current: |cff00ff00—|r")

    maze.selected_room_label = maze:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    maze.selected_room_label:SetPoint("LEFT", maze.current_room_label, "RIGHT", 20, 0)
    maze.selected_room_label:SetText("Selected: |cff00ff00None|r")

    maze.x_label = maze:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    maze.x_label:SetPoint("LEFT", maze.selected_room_label, "RIGHT", 20, 0)
    maze.x_label:SetText("X: |cff00ff00—|r")

    maze.y_label = maze:CreateFontString(nil,"OVERLAY","GameFontHighlight")
    maze.y_label:SetPoint("LEFT", maze.x_label, "RIGHT", 10, 0)
    maze.y_label:SetText("Y: |cff00ff00—|r")

    return maze
end

------------------------------------------------------------
-- Scrollframe + container (map canvas)
-- IMPORTANT: OnMouseDown/OnMouseUp only SET state on sf.
-- The actual scroll is applied in RoomEngine's OnUpdate on the maze frame.
------------------------------------------------------------
local function buildScrollFrame(maze)
    local sf = CreateFrame("ScrollFrame", nil, maze)
    sf:SetPoint("TOPLEFT",     maze, "TOPLEFT",     10,  -55)
    sf:SetPoint("BOTTOMRIGHT", maze, "BOTTOMRIGHT", -165,  90)

    sf.bg = sf:CreateTexture(nil, "BACKGROUND")
    sf.bg:SetAllPoints()
    sf.bg:SetColorTexture(0, 0, 0, 1)

    local cont = CreateFrame("Frame", nil, sf)
    cont:SetSize(C.containerW, C.containerH)
    sf:SetScrollChild(cont)

    sf:EnableMouse(true)
    sf:SetScript("OnMouseDown", function(self, button)
        if button ~= "RightButton" then return end
        local mx, my = GetCursorPosition()
        self.cursor_x        = mx
        self.cursor_y        = my
        self.last_horiz      = self:GetHorizontalScroll()
        self.last_vert       = self:GetVerticalScroll()
        self.dragging_camera = true
    end)
    sf:SetScript("OnMouseUp", function(self, button)
        if button == "RightButton" then self.dragging_camera = false end
    end)

    return sf, cont
end

------------------------------------------------------------
-- Player nav arrow + selection ring
------------------------------------------------------------
local function buildNavArrow(sf, cont)
    local nav = CreateFrame("Frame", nil, sf)
    nav:SetAllPoints()
    nav.tex = nav:CreateTexture(nil, "OVERLAY")
    nav.tex:SetAllPoints()
    nav.tex:SetTexture(C.player_icon)

    local selMarker = cont:CreateTexture(nil, "OVERLAY")
    selMarker:SetTexture("interface\\minimap\\UI-QuestBlob-MinimapRing")
    selMarker:SetBlendMode("ADD")
    selMarker:SetSize(C.buttonW * 1.6, C.buttonH * 1.6)
    selMarker:Hide()

    return nav, selMarker
end

------------------------------------------------------------
-- Toolbar (icon buttons anchored inside the scrollframe area)
------------------------------------------------------------
local function buildToolbar(maze, sf)
    local function makeIconBtn(parent, texture, size, tooltipText, onClick)
        local btn = CreateFrame("Button", nil, parent)
        local tex = btn:CreateTexture(nil, "ARTWORK")
        tex:SetTexture(texture)
        tex:SetAllPoints()
        btn:SetSize(size, size)
        btn:SetScript("OnClick", onClick)
        tip(btn, tooltipText)
        return btn
    end

    local centerBtn = makeIconBtn(
        sf, "interface\\cursor\\crosshairs", 22,
        "Center camera on current room",
        function() ns.Engine.CenterCamera() end
    )
    centerBtn:SetPoint("TOPRIGHT", sf, "TOPRIGHT", -3, -3)

    local resetBtn = makeIconBtn(
        sf, "interface\\common\\voicechat-muted", 22,
        "Erase map and start over",
        function() if ns.maze.resetDialog then ns.maze.resetDialog:Show() end end
    )
    resetBtn:SetPoint("RIGHT", centerBtn, "LEFT", -4, 0)

    local helpBtn = makeIconBtn(
        sf, "interface\\friendsframe\\informationicon", 22,
        "Help — how to use the addon",
        function() if ns.maze.helpDialog then ns.maze.helpDialog:Show() end end
    )
    helpBtn:SetPoint("RIGHT", resetBtn, "LEFT", -4, 0)
end

------------------------------------------------------------
-- Right panel: Markers (rune/orb icon buttons)
------------------------------------------------------------
local function buildMarkerPanel(maze)
    local panel = CreateFrame("Frame", nil, maze)
    panel:SetPoint("TOPRIGHT",    maze, "TOPRIGHT",    -5,  -55)
    panel:SetPoint("BOTTOMRIGHT", maze, "BOTTOMRIGHT", -5,   90)
    panel:SetWidth(155)

    local title = panel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    title:SetPoint("TOP", panel, "TOP", 0, -4)
    title:SetText("Markers")
    title:SetTextColor(0.8, 0.8, 0.8, 1)

    -- poi_buttons[1..5]  = rune icon textures (for tinting)
    -- poi_buttons[6..10] = orb icon textures
    maze.poi_buttons = {}

    local runeIconSuffixes = {"yellow","blue","orange","green","purple"}
    local ROW_H = 30

    for i = 1, 5 do
        local y = -22 - (i-1) * ROW_H

        -- Rune button
        local rune = CreateFrame("Button", nil, panel)
        rune:SetSize(28, 28)
        rune:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, y)
        local runeTex = rune:CreateTexture(nil,"ARTWORK")
        runeTex:SetAllPoints()
        runeTex:SetTexture("interface\\icons\\boss_odunrunes_" .. runeIconSuffixes[i])
        local rgb = C.poi_rgb[i]
        runeTex:SetVertexColor(rgb[1], rgb[2], rgb[3])
        rune.t = "rune"; rune.c = i; rune.poi_index = i
        rune:SetScript("OnClick", function(self) ns.Engine.SetPOI(self) end)
        tip(rune, C.color_strings[i] .. " Rune")
        maze.poi_buttons[i] = runeTex

        -- Orb button
        local orb = CreateFrame("Button", nil, panel)
        orb:SetSize(28, 28)
        orb:SetPoint("TOPLEFT", panel, "TOPLEFT", 38, y)
        local orbTex = orb:CreateTexture(nil,"ARTWORK")
        orbTex:SetAllPoints()
        orbTex:SetTexture("interface\\icons\\spell_broker_orb")
        orbTex:SetVertexColor(rgb[1], rgb[2], rgb[3])
        orb.t = "orb"; orb.c = i; orb.poi_index = i+5
        orb:SetScript("OnClick", function(self) ns.Engine.SetPOI(self) end)
        tip(orb, C.color_strings[i] .. " Orb")
        maze.poi_buttons[i+5] = orbTex

        -- Color label anchored to the right of the orb button
        local lbl = panel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        lbl:SetPoint("LEFT", orb, "RIGHT", 6, 0)
        lbl:SetText("|cff" .. C.poi_hex_colors[i] .. C.color_strings[i] .. "|r")
        lbl:SetJustifyH("LEFT")
    end

    -- Clear button
    local clearBtn = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
    clearBtn:SetSize(68, 20)
    clearBtn:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -22 - 5*ROW_H - 4)
    clearBtn:SetText("Clear")
    clearBtn.poi_index = nil; clearBtn.t = nil; clearBtn.c = nil
    clearBtn:SetScript("OnClick", function(self) ns.Engine.SetPOI(self) end)
    tip(clearBtn, "Clear POI marker from selected/current room")

    -- Nav target section
    local navTitle = panel:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    navTitle:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -22 - 5*ROW_H - 30)
    navTitle:SetText("Navigation Target:")
    navTitle:SetTextColor(0.8, 0.8, 0.8, 1)

    maze.guidance_buttons = {}
    local BTN_H = 16
    for i = 1, 12 do
        local btn = CreateFrame("Button", nil, panel)
        btn:SetSize(148, BTN_H)
        btn:SetPoint("TOPLEFT", panel, "TOPLEFT", 4, -22 - 5*ROW_H - 46 - (i-1)*(BTN_H+2))
        btn.target = i
        btn:SetScript("OnClick", function(self) ns.Engine.SetGuidance(self) end)
        -- Highlight on hover
        local hl = btn:CreateTexture(nil,"HIGHLIGHT")
        hl:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
        hl:SetBlendMode("ADD"); hl:SetAllPoints()
        -- Font string for SetText support
        local fs = btn:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        fs:SetAllPoints(); fs:SetJustifyH("LEFT")
        btn:SetFontString(fs)
        maze.guidance_buttons[i] = btn
    end
end

------------------------------------------------------------
-- Compass rose (static N/S/E/W overlay on map canvas)
------------------------------------------------------------
local function buildCompass(maze, sf)
    local comp = CreateFrame("Frame", nil, maze)
    comp:SetSize(48, 48)
    comp:SetPoint("BOTTOMLEFT", sf, "BOTTOMLEFT", 4, 4)
    comp:SetFrameLevel((sf:GetFrameLevel() or 0) + 10)

    local bg = comp:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(0, 0, 0, 0.55)

    local function cLabel(text, anchor, ox, oy, r, g, b)
        local fs = comp:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        fs:SetPoint(anchor, comp, anchor, ox, oy)
        fs:SetTextColor(r or 0.75, g or 0.75, b or 0.75, 1)
        fs:SetText(text)
    end

    cLabel("N", "TOP",    0,  -4, 1.0, 0.82, 0.0)   -- gold for north
    cLabel("S", "BOTTOM", 0,   4)
    cLabel("E", "RIGHT",  -4,  0)
    cLabel("W", "LEFT",    4,  0)

    -- Center crosshair dot
    local dot = comp:CreateTexture(nil, "OVERLAY")
    dot:SetSize(4, 4)
    dot:SetPoint("CENTER")
    dot:SetColorTexture(0.6, 0.6, 0.6, 0.8)
end

------------------------------------------------------------
-- Bottom controls row
------------------------------------------------------------
local function buildControls(maze)
    -- Tracking checkbox
    local cb = CreateFrame("CheckButton", nil, maze, "UICheckButtonTemplate")
    cb:SetSize(20, 20)
    cb:SetPoint("BOTTOMLEFT", maze, "BOTTOMLEFT", 10, 68)
    cb:SetChecked(true)
    local cbLabel = maze:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
    cbLabel:SetPoint("LEFT", cb, "RIGHT", 2, 0)
    cbLabel:SetText("Track")
    cb:SetScript("OnClick", function(self)
        ns.Engine.SetTracking(self:GetChecked() == true)
    end)

    -- "Set Player location" button
    local setLocBtn = CreateFrame("Button", nil, maze, "UIPanelButtonTemplate")
    setLocBtn:SetSize(115, 22)
    setLocBtn:SetPoint("BOTTOMLEFT", maze, "BOTTOMLEFT", 90, 66)
    setLocBtn:SetText("Set Player Loc")
    setLocBtn.step = 0
    setLocBtn:SetScript("OnClick", function(self)
        if ns.Engine.GetSelectedRoom() == nil then
            print("Select a room first (click its center)."); return
        end
        if self.step == 0 then
            self.step = 1
            self:SetText("Click again!")
        else
            self.step = 0
            self:SetText("Set Player Loc")
            ns.Engine.SetPlayerToSelected()
        end
    end)
    tip(setLocBtn, "Move the player position to the selected room")

    -- "I got ported!" button
    local trapBtn = CreateFrame("Button", nil, maze, "UIPanelButtonTemplate")
    trapBtn:SetSize(115, 22)
    trapBtn:SetPoint("LEFT", setLocBtn, "RIGHT", 4, 0)
    trapBtn:SetText("I got ported!")
    trapBtn:SetScript("OnClick", function() ns.Engine.HitTheTrap() end)
    tip(trapBtn, "Mark current room as the teleport trap room")

    -- Opacity slider
    local sliderName = addonName .. "OpacitySlider"
    local slider = CreateFrame("Slider", sliderName, maze, "OptionsSliderTemplate")
    slider:SetPoint("BOTTOMRIGHT", maze, "BOTTOMRIGHT", -170, 78)
    slider:SetWidth(110)
    slider:SetMinMaxValues(40, 100)
    slider:SetValue(100)
    slider:SetValueStep(1)
    local sLow  = _G[sliderName.."Low"]
    local sHigh = _G[sliderName.."High"]
    local sText = _G[sliderName.."Text"]
    if sLow  then sLow:SetText("40%")   end
    if sHigh then sHigh:SetText("100%") end
    if sText then sText:SetText("Opacity") end
    slider:SetScript("OnValueChanged", function(self, value)
        maze:SetAlpha(value / 100)
    end)
end

------------------------------------------------------------
-- Bottom button bar + editbox
------------------------------------------------------------
local function buildBottomBar(maze)
    local function makeBtn(text, w, onClick)
        local btn = CreateFrame("Button", nil, maze, "UIPanelButtonTemplate")
        btn:SetSize(w, 20)
        btn:SetText(text)
        btn:SetScript("OnClick", onClick)
        return btn
    end

    local btnGrid = makeBtn("Grid Map", 80, function() ns.GridMap.Show() end)
    btnGrid:SetPoint("BOTTOMLEFT", maze, "BOTTOMLEFT", 10, 14)

    local btnNew = makeBtn("New Map", 80, function()
        if maze.resetDialog then maze.resetDialog:Show() end
    end)
    btnNew:SetPoint("LEFT", btnGrid, "RIGHT", 4, 0)

    local btnClose = CreateFrame("Button", nil, maze, "UIPanelButtonTemplate")
    btnClose:SetSize(60, 20)
    btnClose:SetText(CLOSE)
    btnClose:SetPoint("BOTTOMRIGHT", maze, "BOTTOMRIGHT", -170, 14)
    btnClose:SetScript("OnClick", function() maze:Hide() end)
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function MapUI.Initialize()
    if ns.maze then return end

    local maze         = buildFrame()
    local sf, cont     = buildScrollFrame(maze)
    local nav, selMark = buildNavArrow(sf, cont)

    ns.maze        = maze
    ns.scrollframe = sf
    ns.container   = cont
    ns.playerNav   = nav
    maze.selMarker = selMark

    buildToolbar(maze, sf)
    buildCompass(maze, sf)
    buildMarkerPanel(maze)
    buildControls(maze)
    buildBottomBar(maze)

    ns.Dialogs.Build(maze)
    ns.GridMap.Initialize()

    ns.Engine.Init()
    ns.Engine.LoadSavedMap()
    ns.Engine.UpdateNavButtonText()
    ns.Engine.UpdatePOIButtonText()

    maze:Hide()
end

function MapUI.Toggle()
    if not ns.maze then
        MapUI.Initialize()
        ns.maze:Show()
        ns.GridMap.Show()
    else
        local show = not ns.maze:IsShown()
        ns.maze:SetShown(show)
        if show then ns.GridMap.Show() end
    end
end
