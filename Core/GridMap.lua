local addonName, ns = ...
local C = ns.C

ns.GridMap = ns.GridMap or {}
local GridMap = ns.GridMap

local gridFrame = nil
local gridCells = {}

local GCELL   = 34
local GCPAD   = 1
local GCOFF_X = 18
local GCOFF_Y = 16

local runeIconSuffixes = {"yellow", "blue", "orange", "green", "purple"}

-- Shared A-H row labels (grid coordinate letters), used by the header row,
-- the wrap-offset markers, and the edge-wrap hint tooltip below.
local ROW_LETTERS = {"A","B","C","D","E","F","G","H"}

local function flipSidesGrid(p)
    return p < 5 and p + 4 or p - 4
end

local function gridWrap(col, row)
    if     row == 0 then row = 8; col = flipSidesGrid(col)
    elseif row == 9 then row = 1; col = flipSidesGrid(col) end
    if     col == 0 then col = 8; row = flipSidesGrid(row)
    elseif col == 9 then col = 1; row = flipSidesGrid(row) end
    return col, row
end

local function computeGridPositions()
    local rooms = ns.Engine.GetRooms()
    for _, v in pairs(rooms) do v.gcol = nil; v.grow = nil end

    local startRoom = rooms[1]
    if startRoom == nil then return end

    startRoom.gcol = 1; startRoom.grow = 1

    local dcol = {0, 1, 0, -1}
    local drow = {-1, 0, 1, 0}

    local queue = {}
    local qi, qe = 1, 0
    qe = qe + 1; queue[qe] = startRoom

    while qi <= qe do
        local cur = queue[qi]; qi = qi + 1
        for dir = 1, 4 do
            local n = cur.neighbors[dir]
            if n ~= nil and n.gcol == nil then
                local nc, nr = cur.gcol + dcol[dir], cur.grow + drow[dir]
                nc, nr = gridWrap(nc, nr)
                n.gcol = nc; n.grow = nr
                qe = qe + 1; queue[qe] = n
            end
        end
    end

    -- Fallback for disconnected rooms: use cx/cy relative to rooms[1]
    if startRoom.cx ~= nil and startRoom.cy ~= nil then
        for _, r in pairs(rooms) do
            if r.gcol == nil and r.cx ~= nil and r.cy ~= nil then
                local rawDX = r.cx - startRoom.cx
                local rawDY = r.cy - startRoom.cy
                local col, row = startRoom.gcol, startRoom.grow
                local sx = rawDX >= 0 and 1 or -1
                local sy = rawDY >= 0 and 1 or -1
                for _ = 1, math.abs(rawDX) do col = col + sx; col, row = gridWrap(col, row) end
                for _ = 1, math.abs(rawDY) do row = row + sy; col, row = gridWrap(col, row) end
                r.gcol = col; r.grow = row
            end
        end
    end
end

local function getRoomPOI(r)
    local poiC, poiT = r.POI_c, r.POI_t
    if (poiC == nil or poiT == nil) and r.poi_index and r.poi_index > 0 then
        if r.poi_index > 5 then poiC = r.poi_index-5; poiT = "orb"
        else                     poiC = r.poi_index;   poiT = "rune" end
    end
    return poiC, poiT
end

local function poiToRGB(poiC)
    if poiC == nil then return nil end
    local rgb = C.poi_rgb[poiC]
    return rgb and rgb[1], rgb and rgb[2], rgb and rgb[3]
end

local function refreshGridMap(skipCompute)
    if gridFrame == nil or not gridFrame:IsShown() then return end
    -- The caller (refreshMapViews) may have already computed positions this tick;
    -- skip the redundant BFS in that case.
    if not skipCompute then computeGridPositions() end

    local rooms = ns.Engine.GetRooms()
    local current_room = ns.Engine.GetCurrentRoom()

    local cellRooms = {}
    for col = 1, 8 do
        cellRooms[col] = {}
        for row = 1, 8 do cellRooms[col][row] = {} end
    end
    for _, r in pairs(rooms) do
        if r.gcol ~= nil and r.grow ~= nil then
            local list = cellRooms[r.gcol][r.grow]
            list[#list+1] = r
        end
    end

    -- Reset cells
    for col = 1, 8 do
        for row = 1, 8 do
            local cell = gridCells[col][row]
            cell.label:SetText("")
            cell.skull:Hide()
            cell.poi_icon:Hide()
            cell.playerArrow:Hide()
            cell.wrapGlow:Hide()
            cell:SetBackdropColor(0.1, 0.1, 0.1, 1)
            cell:SetBackdropBorderColor(0.22, 0.22, 0.22, 1)
            for d = 1, 4 do
                cell.wall[d]:Hide()
            end
        end
    end

    for col = 1, 8 do
        for row = 1, 8 do
            local rList = cellRooms[col][row]
            if #rList > 0 then
                local cell = gridCells[col][row]
                local isCross = #rList > 1
                local isCurrentHere = false
                local hasTrap, bestPoiC, bestPoiT = false, nil, nil
                local labelParts = {}

                -- Trusted anchor: the current room and the start room (index 1)
                -- have a known-correct grid placement. When one of them lands in
                -- a cell it defines that cell's identity, so a room that the ±4
                -- edge-wrap misplaced onto it can't bleed a wrong POI colour (e.g.
                -- a rune wrongly stacked on the plain start cell).
                local anchor
                for _, r in ipairs(rList) do
                    if r == current_room then anchor = r; break end
                end
                if not anchor then
                    for _, r in ipairs(rList) do
                        if r.index == 1 then anchor = r; break end
                    end
                end

                for _, r in ipairs(rList) do
                    if r == current_room then isCurrentHere = true end
                    labelParts[#labelParts+1] = r.index
                    if not anchor then
                        if r.is_trap then hasTrap = true end
                        local poiC, poiT = getRoomPOI(r)
                        if poiC ~= nil and bestPoiC == nil then bestPoiC, bestPoiT = poiC, poiT end
                    end
                end
                local primaryIdx = labelParts[1]
                if anchor then
                    hasTrap = (anchor.is_trap == true)
                    bestPoiC, bestPoiT = getRoomPOI(anchor)
                    primaryIdx = anchor.index
                end

                if hasTrap then
                    cell:SetBackdropColor(0.75, 0.35, 0, 1)
                elseif bestPoiC ~= nil then
                    local cr, cg, cb = poiToRGB(bestPoiC)
                    if cr ~= nil then
                        local dim = (bestPoiT == "rune") and 0.50 or 0.30
                        if isCross then dim = dim * 0.80 end
                        cell:SetBackdropColor(cr*dim, cg*dim, cb*dim, 1)
                    end
                else
                    cell:SetBackdropColor(0.28, 0.28, 0.28, 1)
                end

                if hasTrap then
                    cell.skull:Show()
                    cell.label:SetText("")
                elseif isCross then
                    if anchor or bestPoiC ~= nil then
                        cell.label:SetText(primaryIdx .. "+")
                    else
                        local joined = table.concat(labelParts, "/")
                        cell.label:SetText(#joined > 6 and primaryIdx .. "+" or joined)
                    end
                else
                    cell.label:SetText(primaryIdx or "")
                end

                -- POI icon: show rune or orb texture in the bottom-right corner.
                if bestPoiC ~= nil then
                    if bestPoiT == "rune" then
                        cell.poi_icon:SetTexture("interface\\icons\\boss_odunrunes_" .. (runeIconSuffixes[bestPoiC] or "yellow"))
                        cell.poi_icon:SetVertexColor(1, 1, 1, 1)
                    else
                        cell.poi_icon:SetTexture("interface\\icons\\spell_broker_orb")
                        local rgb = C.poi_rgb[bestPoiC]
                        if rgb then cell.poi_icon:SetVertexColor(rgb[1], rgb[2], rgb[3], 1) end
                    end
                    cell.poi_icon:Show()
                end

                -- Wall lines: an edge is walled if every room in the cell is
                -- walled there (any occupying room's passage opens the side).
                -- Always solid so the maze walls read clearly at a glance.
                for dir = 1, 4 do
                    local walled = true
                    for _, r in ipairs(rList) do
                        if not r.walls[dir] then walled = false; break end
                    end
                    if walled then cell.wall[dir]:Show() end
                end

                if isCurrentHere then
                    cell:SetBackdropBorderColor(1, 1, 0, 1)
                    -- Show the same player arrow as the main map, oriented to the
                    -- player's current facing (grid refreshes on each room change).
                    cell.playerArrow:SetRotation(GetPlayerFacing() or 0)
                    cell.playerArrow:Show()
                end
            end
        end
    end

    gridFrame:Show()
end

local GRID_RM = 22  -- right margin for wrap offset labels
local GRID_BM = 22  -- bottom margin for wrap offset labels

------------------------------------------------------------
-- Edge-wrap hint: hovering a cell on the grid border lights up the cell you'd
-- actually reappear in after the ±4 twist wrap (Pac-Man-style tunnel), with a
-- tooltip naming it. Makes the otherwise-invisible wrap offset obvious.
------------------------------------------------------------
local wrapDcol = {0, 1, 0, -1}
local wrapDrow = {-1, 0, 1, 0}
local wrapGlowActive = {}

local function hideWrapHint()
    for _, g in ipairs(wrapGlowActive) do g:Hide() end
    wipe(wrapGlowActive)
    GameTooltip:Hide()
end

local function showWrapHint(cell)
    hideWrapHint()
    local col, row = cell.slotCol, cell.slotRow
    local hints = {}
    for dir = 1, 4 do
        local nc, nr = col + wrapDcol[dir], row + wrapDrow[dir]
        local wc, wr = gridWrap(nc, nr)
        if wc ~= nc or wr ~= nr then  -- this direction leaves the grid and wraps
            local dest = gridCells[wc] and gridCells[wc][wr]
            if dest then
                dest.wrapGlow:SetColorTexture(1, 0.55, 0.1, 0.5)  -- orange: you emerge here
                dest.wrapGlow:Show()
                wrapGlowActive[#wrapGlowActive+1] = dest.wrapGlow
                hints[#hints+1] = C.direction_strings[dir] .. " -> " .. ROW_LETTERS[wr] .. wc
            end
        end
    end
    if #hints == 0 then return end  -- interior cell: nothing to wrap

    cell.wrapGlow:SetColorTexture(1, 1, 1, 0.22)  -- subtle: the cell you're on
    cell.wrapGlow:Show()
    wrapGlowActive[#wrapGlowActive+1] = cell.wrapGlow

    GameTooltip:SetOwner(cell, "ANCHOR_RIGHT")
    GameTooltip:ClearLines()
    GameTooltip:AddLine("Edge wrap")
    for _, h in ipairs(hints) do GameTooltip:AddLine(h, 1, 0.82, 0) end
    GameTooltip:Show()
end

local function createGridMap()
    local frameW = GCOFF_X + 8*GCELL + 7*GCPAD + GRID_RM
    local frameH = GCOFF_Y + 8*GCELL + 7*GCPAD + GRID_BM

    gridFrame = CreateFrame("Frame", nil, UIParent, BackdropTemplateMixin and "BackdropTemplate")
    gridFrame:SetSize(frameW, frameH)
    gridFrame:SetPoint("TOPLEFT", ns.maze, "TOPRIGHT", 8, 0)
    gridFrame:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
    gridFrame:SetBackdropColor(0.05, 0.05, 0.05, 0.97)
    gridFrame:SetBackdropBorderColor(0.45, 0.45, 0.45, 1)
    gridFrame:SetMovable(true)
    gridFrame:EnableMouse(true)
    gridFrame:RegisterForDrag("LeftButton")
    gridFrame:SetScript("OnDragStart", gridFrame.StartMoving)
    gridFrame:SetScript("OnDragStop",  gridFrame.StopMovingOrSizing)
    gridFrame:SetFrameLevel(20)
    gridFrame:Hide()

    for col = 1, 8 do
        local t = gridFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        t:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", GCOFF_X+(col-1)*(GCELL+GCPAD)+GCELL/2-3, -3)
        t:SetText(tostring(col))
        t:SetTextColor(0.65,0.65,0.65,1)
    end
    for row = 1, 8 do
        local t = gridFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        t:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", 3, -(GCOFF_Y+(row-1)*(GCELL+GCPAD)+GCELL/2-4))
        t:SetText(ROW_LETTERS[row])
        t:SetTextColor(0.65,0.65,0.65,1)
    end

    for col = 1, 8 do
        gridCells[col] = {}
        for row = 1, 8 do
            local cx = GCOFF_X + (col-1)*(GCELL+GCPAD)
            local cy = GCOFF_Y + (row-1)*(GCELL+GCPAD)

            local cell = CreateFrame("Frame", nil, gridFrame, BackdropTemplateMixin and "BackdropTemplate")
            cell:SetSize(GCELL, GCELL)
            cell:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", cx, -cy)
            cell:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8", edgeFile="Interface\\Buttons\\WHITE8X8", edgeSize=1})
            cell:SetBackdropColor(0.1,0.1,0.1,1)
            cell:SetBackdropBorderColor(0.22,0.22,0.22,1)
            cell:SetFrameLevel(21)

            -- Translucent fill (above the cell background, below the number) used
            -- to highlight edge-wrap partners on hover.
            cell.wrapGlow = cell:CreateTexture(nil,"ARTWORK")
            cell.wrapGlow:SetAllPoints()
            cell.wrapGlow:Hide()

            -- Grid slot coords + hover hooks for the edge-wrap hint. Motion-only
            -- mouse so left-click drag still pans the grid frame underneath.
            cell.slotCol, cell.slotRow = col, row
            if cell.SetMouseMotionEnabled then
                cell:SetMouseMotionEnabled(true)
            else
                cell:EnableMouse(true)
                if cell.SetMouseClickEnabled then cell:SetMouseClickEnabled(false) end
            end
            cell:SetScript("OnEnter", showWrapHint)
            cell:SetScript("OnLeave", hideWrapHint)

            cell.label = cell:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
            cell.label:SetPoint("CENTER")
            cell.label:SetTextColor(0.88,0.88,0.88,1)

            cell.skull = cell:CreateTexture(nil,"OVERLAY")
            cell.skull:SetTexture("interface\\targetingframe\\UI-RaidTargetingIcon_8")
            cell.skull:SetSize(GCELL-12, GCELL-12)
            cell.skull:SetPoint("CENTER")
            cell.skull:Hide()

            cell.poi_icon = cell:CreateTexture(nil,"OVERLAY")
            cell.poi_icon:SetSize(14, 14)
            cell.poi_icon:SetPoint("BOTTOMRIGHT", cell, "BOTTOMRIGHT", -2, 2)
            cell.poi_icon:Hide()

            -- Current-player arrow (same icon as the main map), drawn above the
            -- label so the player's cell is unmistakable.
            cell.playerArrow = cell:CreateTexture(nil,"OVERLAY",nil,7)
            cell.playerArrow:SetTexture(C.player_icon)
            cell.playerArrow:SetSize(GCELL-14, GCELL-14)
            cell.playerArrow:SetPoint("CENTER")
            cell.playerArrow:Hide()

            -- Wall lines per edge: one bold, full-length bar so blocked passages
            -- read clearly as maze walls. Drawn at OVERLAY sublevel 4 so they sit
            -- above the wrap-glow highlight.
            cell.wall = {}
            local gth = 3
            for dir = 1, 4 do
                local s = cell:CreateTexture(nil, "OVERLAY", nil, 4)
                s:SetColorTexture(unpack(C.wallColor)); s:Hide()
                if     dir == C.north then s:SetSize(GCELL, gth); s:SetPoint("TOPLEFT",    cell, "TOPLEFT",    0, 0)
                elseif dir == C.south then s:SetSize(GCELL, gth); s:SetPoint("BOTTOMLEFT", cell, "BOTTOMLEFT", 0, 0)
                elseif dir == C.east  then s:SetSize(gth, GCELL); s:SetPoint("TOPRIGHT",   cell, "TOPRIGHT",   0, 0)
                else                       s:SetSize(gth, GCELL); s:SetPoint("TOPLEFT",    cell, "TOPLEFT",    0, 0)
                end
                cell.wall[dir] = s
            end

            gridCells[col][row] = cell
        end
    end

    ------------------------------------------------------------
    -- Wrap / skip markers: the maze wraps to the opposite edge with a fixed
    -- +4-cell offset (flipSidesGrid). Show that with offset labels on the right
    -- (wrapped row) and bottom (wrapped column), plus a direction arrow per edge.
    ------------------------------------------------------------
    local function mkMarker(x, y, text, r, g, b)
        local t = gridFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        t:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", x, -y)
        t:SetText(text); t:SetTextColor(r, g, b, 1)
        return t
    end

    local span  = 8*(GCELL+GCPAD)
    local midX  = GCOFF_X + 4*(GCELL+GCPAD) - 4
    local midY  = GCOFF_Y + 4*(GCELL+GCPAD) - 6

    for row = 1, 8 do
        mkMarker(GCOFF_X + span + 4,
                 GCOFF_Y + (row-1)*(GCELL+GCPAD) + GCELL/2 - 6,
                 ROW_LETTERS[flipSidesGrid(row)], 0.55, 0.45, 0.30)
    end
    for col = 1, 8 do
        mkMarker(GCOFF_X + (col-1)*(GCELL+GCPAD) + GCELL/2 - 4,
                 GCOFF_Y + span + 4,
                 tostring(flipSidesGrid(col)), 0.55, 0.45, 0.30)
    end

    -- ASCII arrows (guaranteed to render in the default WoW font) indicating
    -- that each edge wraps to the opposite side.
    mkMarker(midX, 0,                  "v", 0.95, 0.70, 0.25)  -- top edge
    mkMarker(midX, GCOFF_Y + span + 2, "^", 0.95, 0.70, 0.25)  -- bottom edge
    mkMarker(2,    midY,               "<", 0.95, 0.70, 0.25)  -- left edge
    mkMarker(GCOFF_X + span + 7, midY, ">", 0.95, 0.70, 0.25)  -- right edge

    local closeBtn = CreateFrame("Button", nil, gridFrame, "UIPanelCloseButton")
    closeBtn:SetSize(18,18)
    closeBtn:SetPoint("TOPRIGHT", gridFrame, "TOPRIGHT", -1, -1)
    closeBtn:SetScript("OnClick", function() gridFrame:Hide() end)
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function GridMap.Initialize()
    createGridMap()
end

-- Recompute wrap-aware grid positions (r.gcol/r.grow) without requiring the
-- Grid Map window to be open. Used by RoomEngine for cross detection.
function GridMap.ComputePositions()
    computeGridPositions()
end

function GridMap.Show()
    if gridFrame then gridFrame:Show() end
    refreshGridMap()
end

function GridMap.Refresh(skipCompute)
    refreshGridMap(skipCompute)
end

local function cellName(col, row)
    if not (col and row) then return "?" end
    return (ROW_LETTERS[row] or "?") .. col
end

-- Map each room's grid cell to a readable "C6"-style name. Returns a sorted
-- (by room index) list of "room N = H6" strings for `/ln grid`.
function GridMap.DumpCells()
    computeGridPositions()
    local rooms = ns.Engine.GetRooms()
    local out = {}
    for _, r in pairs(rooms) do
        out[#out+1] = { idx = r.index, txt = string.format("room %d = %s", r.index, cellName(r.gcol, r.grow)) }
    end
    table.sort(out, function(a, b) return a.idx < b.idx end)
    local lines = {}
    for _, e in ipairs(out) do lines[#lines+1] = e.txt end
    return lines
end

-- Wrap-model audit: for every neighbor link, compare where the ±4 wrap model
-- (flipSidesGrid) PREDICTS the neighbor sits vs. where BFS ACTUALLY placed it.
-- Mismatches mean the model disagrees with the explored graph along that edge
-- (the classic symptom: physically-adjacent rooms in non-adjacent grid cells).
function GridMap.AuditWrap()
    computeGridPositions()
    local rooms = ns.Engine.GetRooms()
    local dcol = {0, 1, 0, -1}
    local drow = {-1, 0, 1, 0}
    local out = {}
    for _, r in pairs(rooms) do
        if r.gcol and r.grow then
            for dir = 1, 4 do
                local n = r.neighbors[dir]
                if n and n.gcol and n.grow then
                    local pc, pr = gridWrap(r.gcol + dcol[dir], r.grow + drow[dir])
                    if pc ~= n.gcol or pr ~= n.grow then
                        out[#out+1] = string.format(
                            "%s %s-> room %d: model predicts %s, but room %d is at %s.",
                            cellName(r.gcol, r.grow), C.direction_strings[dir]:sub(1,1),
                            n.index, cellName(pc, pr), n.index, cellName(n.gcol, n.grow))
                    end
                end
            end
        end
    end
    return out
end
