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

local function refreshGridMap()
    if gridFrame == nil or not gridFrame:IsShown() then return end
    computeGridPositions()

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
            cell:SetBackdropColor(0.1, 0.1, 0.1, 1)
            cell:SetBackdropBorderColor(0.22, 0.22, 0.22, 1)
            for d = 1, 4 do cell.conn[d]:Hide() end
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

                for _, r in ipairs(rList) do
                    if r == current_room then isCurrentHere = true end
                    if r.is_trap then hasTrap = true end
                    local poiC, poiT = getRoomPOI(r)
                    if poiC ~= nil and bestPoiC == nil then bestPoiC, bestPoiT = poiC, poiT end
                    local prefix = ""
                    if poiC ~= nil then prefix = (poiT == "rune") and "R" or "O" end
                    labelParts[#labelParts+1] = prefix .. r.index
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
                    cell.label:SetText("T")
                elseif isCross then
                    if bestPoiC ~= nil then
                        cell.label:SetText(labelParts[1] .. "+")
                    else
                        local joined = table.concat(labelParts, "/")
                        cell.label:SetText(#joined > 6 and labelParts[1] .. "+" or joined)
                    end
                else
                    cell.label:SetText(labelParts[1] or "")
                end

                for _, r in ipairs(rList) do
                    for dir = 1, 4 do
                        if not r.walls[dir] and r.neighbors[dir] ~= nil then
                            cell.conn[dir]:Show()
                        end
                    end
                end

                if isCurrentHere then
                    cell:SetBackdropBorderColor(1, 1, 0, 1)
                elseif isCross then
                    cell:SetBackdropBorderColor(0, 0.85, 0.85, 1)
                end
            end
        end
    end

    gridFrame:Show()
end

local function createGridMap()
    local frameW = GCOFF_X + 8*GCELL + 7*GCPAD + 10
    local frameH = GCOFF_Y + 8*GCELL + 7*GCPAD + 10

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

    local rowLabels = {"A","B","C","D","E","F","G","H"}

    for col = 1, 8 do
        local t = gridFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        t:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", GCOFF_X+(col-1)*(GCELL+GCPAD)+GCELL/2-3, -3)
        t:SetText(tostring(col))
        t:SetTextColor(0.65,0.65,0.65,1)
    end
    for row = 1, 8 do
        local t = gridFrame:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
        t:SetPoint("TOPLEFT", gridFrame, "TOPLEFT", 3, -(GCOFF_Y+(row-1)*(GCELL+GCPAD)+GCELL/2-4))
        t:SetText(rowLabels[row])
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

            cell.label = cell:CreateFontString(nil,"OVERLAY","GameFontNormalSmall")
            cell.label:SetPoint("CENTER")
            cell.label:SetTextColor(0.88,0.88,0.88,1)

            local cs = math.floor(GCELL/3)
            cell.conn = {}

            local function makeConnTex(anchor, w, h)
                local c = cell:CreateTexture(nil,"OVERLAY")
                c:SetSize(w,h); c:SetPoint(anchor,cell,anchor,0,0)
                c:SetColorTexture(0.75,0.75,0.75,1); c:Hide()
                return c
            end
            cell.conn[C.north] = makeConnTex("TOP",    cs, 4)
            cell.conn[C.south] = makeConnTex("BOTTOM", cs, 4)
            cell.conn[C.east]  = makeConnTex("RIGHT",  4, cs)
            cell.conn[C.west]  = makeConnTex("LEFT",   4, cs)

            gridCells[col][row] = cell
        end
    end

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

function GridMap.Show()
    if gridFrame then gridFrame:Show() end
    refreshGridMap()
end

function GridMap.Refresh()
    refreshGridMap()
end
