local addonName, ns = ...
local C = ns.C

ns.Engine = ns.Engine or {}
local Engine = ns.Engine

------------------------------------------------------------
-- Private state
------------------------------------------------------------
local pool         = {}
local rooms        = {}
local map          = {}
local poirooms     = {}
local trapRoom     = nil
local current_room = nil
local last_dir     = nil
local last_room_number = 0
local tracking_disabled = false
local selected_btn = nil   -- currently selected cell Button frame
local poi_warned   = 0

local pendingJump  = nil   -- set when jump dialog is open

-- Frame levels so overlapping/abutting cells stay clickable: base cells sit
-- low, the current room is raised, and the selected room is raised highest.
local FL_BASE, FL_CURRENT, FL_SELECTED = 2, 5, 8

local Exporting_To_EHH = false
local EHH_Directions   = ""

local navtarget = 11  -- 11=unexplored, 12=trap, 1-5=rune, 6-10=orb

local lx, ly = 0, 0

------------------------------------------------------------
-- Direction helpers
------------------------------------------------------------
local function getOppositeDir(dir)
    return C.oppositeDir[dir]
end

local function detectDir(x, y)
    if     y > -1410 then return C.north
    elseif y < -1440 then return C.south
    elseif x <   660 then return C.east
    elseif x >   720 then return C.west
    end
end

local function getRotation(dir)
    if     dir == C.west  then return 90
    elseif dir == C.south then return 180
    elseif dir == C.east  then return 270
    else                       return 0
    end
end

------------------------------------------------------------
-- Camera
------------------------------------------------------------
local function centerCam(cx, cy)
    local x = C.containerW / 2 + C.cellStep * cx
    local y = C.containerH / 2 + C.cellStep * cy
    ns.scrollframe:SetHorizontalScroll(x - 250 + C.buttonW / 2)
    ns.scrollframe:SetVerticalScroll(y - 250 + C.buttonH / 2)
end

------------------------------------------------------------
-- Visit tracking (used by navigation BFS/DFS)
------------------------------------------------------------
local function resetVisited()
    for _, v in pairs(rooms) do v.visited = false end
end

------------------------------------------------------------
-- Selection ring
------------------------------------------------------------
local function setSelectedBtn(btn, force)
    if not force and selected_btn == btn then
        ns.maze.selMarker:Hide()
        -- Drop the de-selected cell back down (current room keeps its level).
        btn:SetFrameLevel(btn == (current_room and current_room.button) and FL_CURRENT or FL_BASE)
        selected_btn = nil
    else
        selected_btn = btn
        btn:SetFrameLevel(FL_SELECTED)
        ns.maze.selMarker:ClearAllPoints()
        ns.maze.selMarker:SetPoint("CENTER", btn, "CENTER")
        ns.maze.selMarker:Show()
    end
    local label = selected_btn and selected_btn.room.index or "None"
    ns.maze.selected_room_label:SetText("Selected: |cff00ff00" .. label .. "|r")
end

------------------------------------------------------------
-- Cell factory (35x35 with edge-click wall toggle)
------------------------------------------------------------
local function createCell()
    local btn = CreateFrame("Button", nil, ns.container)
    btn:SetSize(C.buttonW, C.buttonH)

    local borderTex = btn:CreateTexture(nil, "BACKGROUND", nil, 0)
    borderTex:SetAllPoints()
    borderTex:SetColorTexture(unpack(C.cellColor.border))
    btn.borderTex = borderTex

    local midTex = btn:CreateTexture(nil, "BACKGROUND", nil, 1)
    midTex:SetSize(C.buttonW - 8, C.buttonH - 8)
    midTex:SetColorTexture(unpack(C.cellColor.default))
    midTex:SetPoint("CENTER")
    btn.midTex = midTex

    btn.text = btn:CreateFontString(nil, "OVERLAY")
    btn.text:SetAllPoints()
    btn.text:SetFont("Fonts\\FRIZQT__.TTF", 10, "")

    local skull = btn:CreateTexture(nil, "OVERLAY")
    skull:SetTexture("interface\\targetingframe\\UI-RaidTargetingIcon_8")
    skull:SetSize(18, 18)
    skull:SetPoint("CENTER")
    skull:Hide()
    btn.skullTex = skull

    -- Paper-style walls: each blocked edge is drawn as a line spanning the cell
    -- side. Each edge holds one full-length solid bar plus a set of short dash
    -- segments (shown for overlapped / cross rooms). Anchors are static; only
    -- visibility toggles per render (see renderRoomWalls).
    btn.walls = {}
    local bw, bh, th = C.buttonW, C.buttonH, C.wallThickness
    local nseg, gap = C.dashSegments, C.dashGap
    for dir = 1, 4 do
        local horizontal = (dir == C.north or dir == C.south)
        local len    = horizontal and bw or bh
        local segLen = (len - (nseg - 1) * gap) / nseg
        local edge   = { dashes = {} }

        local s = btn:CreateTexture(nil, "OVERLAY")
        s:SetColorTexture(unpack(C.wallColor))
        s:Hide()
        edge.solid = s
        if     dir == C.north then s:SetSize(bw, th); s:SetPoint("TOPLEFT",     btn, "TOPLEFT",     0, 0)
        elseif dir == C.south then s:SetSize(bw, th); s:SetPoint("BOTTOMLEFT",  btn, "BOTTOMLEFT",  0, 0)
        elseif dir == C.east  then s:SetSize(th, bh); s:SetPoint("TOPRIGHT",    btn, "TOPRIGHT",    0, 0)
        else                       s:SetSize(th, bh); s:SetPoint("TOPLEFT",     btn, "TOPLEFT",     0, 0)
        end

        for k = 1, nseg do
            local d = btn:CreateTexture(nil, "OVERLAY")
            d:SetColorTexture(unpack(C.wallColor))
            d:Hide()
            local off = (k - 1) * (segLen + gap)
            if horizontal then d:SetSize(segLen, th) else d:SetSize(th, segLen) end
            if     dir == C.north then d:SetPoint("TOPLEFT",    btn, "TOPLEFT",    off,  0)
            elseif dir == C.south then d:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", off,  0)
            elseif dir == C.east  then d:SetPoint("TOPRIGHT",   btn, "TOPRIGHT",   0,   -off)
            else                       d:SetPoint("TOPLEFT",    btn, "TOPLEFT",    0,   -off)
            end
            edge.dashes[k] = d
        end
        btn.walls[dir] = edge
    end

    btn:RegisterForClicks("LeftButtonUp", "RightButtonUp")
    btn:SetScript("OnClick", function(self, button, isDown)
        if button == "RightButton" then
            if self.room and ns.RoomMenu then ns.RoomMenu.Show(self.room) end
            return
        end
        if button ~= "LeftButton" or isDown then return end
        local cx, cy = GetCursorPosition()
        local es = ns.maze:GetEffectiveScale()
        cx, cy = cx / es, cy / es
        local bl = self:GetLeft(); local br = self:GetRight()
        local bt = self:GetTop();  local bb = self:GetBottom()
        if     cx <= bl + C.borderW then Engine.ToggleWall(self, C.west)
        elseif cx >= br - C.borderW then Engine.ToggleWall(self, C.east)
        elseif cy >= bt - C.borderH then Engine.ToggleWall(self, C.north)
        elseif cy <= bb + C.borderH then Engine.ToggleWall(self, C.south)
        else                             setSelectedBtn(self)
        end
    end)

    return btn
end

local function getUnusedButton()
    if #pool > 0 then return tremove(pool, 1) end
    return createCell()
end

------------------------------------------------------------
-- Room visual state
------------------------------------------------------------
local function setRoomNumber(r)
    r.button.text:SetFont("Fonts\\FRIZQT__.TTF", r.index < 100 and 10 or 8, "")
    r.button.text:SetText("|cffeeeeee" .. r.index .. "|r")
end

-- Draw each blocked edge as a paper-style line: solid for a normal room,
-- dashed for an overlapped / non-intersecting-cross room (r.isOverlap).
local function renderRoomWalls(r)
    if not r.button then return end
    local edges = r.button.walls
    for dir = 1, 4 do
        local e = edges[dir]
        if not r.walls[dir] then
            e.solid:Hide()
            for k = 1, #e.dashes do e.dashes[k]:Hide() end
        elseif r.isOverlap then
            e.solid:Hide()
            for k = 1, #e.dashes do e.dashes[k]:Show() end
        else
            e.solid:Show()
            for k = 1, #e.dashes do e.dashes[k]:Hide() end
        end
    end
end

local function recolorRoom(r)
    if not r.button then return end
    local btn = r.button
    btn.skullTex:SetShown(r.is_trap == true)
    if r.is_trap then
        btn.midTex:SetColorTexture(unpack(C.cellColor.trap))
        btn.borderTex:SetColorTexture(unpack(C.cellColor.trapBorder))
    elseif r.POI_c then
        local rgb = C.poi_rgb[r.POI_c]
        if r.POI_t == "rune" then
            btn.midTex:SetColorTexture(rgb[1], rgb[2], rgb[3], 1)
            btn.borderTex:SetColorTexture(unpack(C.cellColor.borderVisited))
        else
            btn.midTex:SetColorTexture(unpack(C.cellColor.visited))
            btn.borderTex:SetColorTexture(rgb[1], rgb[2], rgb[3], 1)
        end
    else
        btn.midTex:SetColorTexture(unpack(C.cellColor.visited))
        btn.borderTex:SetColorTexture(unpack(C.cellColor.borderVisited))
    end
    -- Flag disconnected (orphaned) rooms so they are easy to spot and delete.
    -- The current room is exempt so a fresh single-room map is not flagged.
    if not r.is_trap and r ~= current_room then
        local connected = false
        for i = 1, 4 do if r.neighbors[i] then connected = true; break end end
        if not connected then
            btn.borderTex:SetColorTexture(unpack(C.cellColor.orphanBorder))
        end
    end
    renderRoomWalls(r)
end

------------------------------------------------------------
-- Room placement helpers
------------------------------------------------------------
local function getMapXY(cx, cy)
    return C.containerW / 2 + C.cellStep * cx,
           C.containerH / 2 + C.cellStep * cy
end

local function createButton(r)
    local btn = getUnusedButton()
    local x, y = getMapXY(r.cx, r.cy)
    btn:SetPoint("TOPLEFT", ns.container, "TOPLEFT", x, -y)
    btn:SetFrameLevel(FL_BASE)
    btn.midTex:SetColorTexture(unpack(C.cellColor.default))
    btn.borderTex:SetColorTexture(unpack(C.cellColor.border))
    for i = 1, 4 do
        local e = btn.walls[i]
        e.solid:Hide()
        for k = 1, #e.dashes do e.dashes[k]:Hide() end
    end
    btn.room = r
    btn:EnableMouse(true)
    btn:Show()
    r.button = btn
end

------------------------------------------------------------
-- Connector lines: when two linked rooms do not end up in physically
-- adjacent cells (dead-reckoning drift / spiral displacement), draw a line
-- between them so the logical link is never invisible.
------------------------------------------------------------
local connectorPool   = {}
local activeConnectors = {}

local function refreshConnectors()
    if not ns.container then return end
    for _, line in ipairs(activeConnectors) do
        line:Hide()
        connectorPool[#connectorPool + 1] = line
    end
    wipe(activeConnectors)

    for _, r in pairs(rooms) do
        if r.button then
            for dir = 1, 4 do
                local n = r.neighbors[dir]
                -- Draw each pair once (r.index < n.index).
                if n and n.button and r.index < n.index then
                    local off = C.coord_offset[dir]
                    local adjacent = (n.cx == r.cx + off[1]) and (n.cy == r.cy + off[2])
                    if not adjacent then
                        local line = tremove(connectorPool)
                            or ns.container:CreateLine(nil, "ARTWORK", nil, -1)
                        line:SetThickness(2)
                        line:SetColorTexture(0.40, 0.75, 1.0, 0.6)
                        line:SetStartPoint("CENTER", r.button)
                        line:SetEndPoint("CENTER", n.button)
                        line:Show()
                        activeConnectors[#activeConnectors + 1] = line
                    end
                end
            end
        end
    end
end

-- Mark rooms that share a maze cell (non-intersecting cross, via gcol/grow) or a
-- canvas position (overlapping button, via cx/cy) so their walls render dashed.
local function computeOverlapFlags()
    local byGrid, byPos = {}, {}
    for _, r in pairs(rooms) do
        r.isOverlap = false
        if r.gcol and r.grow then
            local k = r.gcol .. "," .. r.grow
            if byGrid[k] then byGrid[k].isOverlap = true; r.isOverlap = true
            else byGrid[k] = r end
        end
        local pk = r.cx .. "," .. r.cy
        if byPos[pk] then byPos[pk].isOverlap = true; r.isOverlap = true
        else byPos[pk] = r end
    end
end

-- Single entry point for redrawing the auxiliary views after any map mutation.
local function refreshMapViews()
    -- Refresh wrap-aware grid positions so cross detection works even when the
    -- Grid Map window is closed, then re-render walls (solid vs dashed).
    if ns.GridMap and ns.GridMap.ComputePositions then ns.GridMap.ComputePositions() end
    computeOverlapFlags()
    for _, r in pairs(rooms) do renderRoomWalls(r) end
    refreshConnectors()
    if ns.GridMap then ns.GridMap.Refresh() end
end

function Engine.RefreshConnectors() refreshConnectors() end

local function newRoom()
    local r = {}
    r.neighbors  = {}
    r.walls      = {false, false, false, false}
    r.visited    = false
    r.index      = #rooms + 1
    r.poi_index  = 0
    r.cx         = 0
    r.cy         = 0
    rooms[r.index] = r
    return r
end

------------------------------------------------------------
-- Current room + visited dimming
------------------------------------------------------------
local function setCurrentRoom(r)
    if r == nil then return end
    current_room = r

    for _, v in pairs(rooms) do
        if v.button then v.button:SetAlpha(0.65); v.button:SetFrameLevel(FL_BASE) end
    end
    r.button:SetAlpha(1)
    r.button:SetFrameLevel(FL_CURRENT)
    for _, n in pairs(r.neighbors) do
        if n and n.button then n.button:SetAlpha(1) end
    end

    centerCam(r.cx, r.cy)
    ns.playerNav:SetParent(r.button)
    ns.playerNav:ClearAllPoints()
    ns.playerNav:SetSize(20, 20)
    ns.playerNav:SetPoint("CENTER", r.button, "CENTER")
    ns.playerNav.tex:SetRotation(math.rad(getRotation(last_dir or C.north)))

    ns.maze.current_room_label:SetText("Current: |cff00ff00" .. r.index .. "|r")
    setSelectedBtn(r.button, true)

    refreshMapViews()
end

------------------------------------------------------------
-- Jump / room offset helpers
------------------------------------------------------------
local function cellIsFree(cx, cy)
    for _, v in pairs(rooms) do
        if v.cx == cx and v.cy == cy then return false end
    end
    return true
end

-- Find a free cell as close as possible to the ideal cell (one step in the
-- walked direction). Spiral outward in Chebyshev rings and pick the nearest
-- free cell, so a displaced room lands near where it belongs instead of
-- scattering down a single axis. Returns the offset relative to (baseCX,baseCY).
local function getRoomJumpOffset(baseCX, baseCY, dcx, dcy)
    local idealX, idealY = baseCX + dcx, baseCY + dcy
    if cellIsFree(idealX, idealY) then return dcx, dcy end

    for ring = 1, 64 do
        local bestX, bestY, bestD
        for ox = -ring, ring do
            for oy = -ring, ring do
                if math.max(math.abs(ox), math.abs(oy)) == ring then
                    local cx, cy = idealX + ox, idealY + oy
                    if cellIsFree(cx, cy) then
                        local d = ox * ox + oy * oy
                        if bestD == nil or d < bestD then
                            bestD, bestX, bestY = d, cx, cy
                        end
                    end
                end
            end
        end
        if bestX then return bestX - baseCX, bestY - baseCY end
    end

    -- Fallback: linear slide (should never be reached on a sane-sized map).
    local oX, oY = dcx, dcy
    while not cellIsFree(baseCX + oX, baseCY + oY) do oX = oX + dcx; oY = oY + dcy end
    return oX, oY
end

local function addRoom(dir, forceJump)
    local offset = C.coord_offset[dir]
    local dcx, dcy = offset[1], offset[2]

    -- Snapshot before any mapping mutation so Undo reverts this single step.
    -- (forceJump comes from JumpOver, which already snapshotted "Jump over".)
    if not forceJump and ns.History then ns.History.Snapshot("Map room") end

    if not forceJump then
        local targetCX = current_room.cx + dcx
        local targetCY = current_room.cy + dcy
        for _, v in pairs(rooms) do
            if v.cx == targetCX and v.cy == targetCY then
                current_room.neighbors[dir]              = v
                v.neighbors[getOppositeDir(dir)]         = current_room
                pendingJump = {dir = dir, existing = v, prev = current_room}
                if ns.maze and ns.maze.jumpDialog then ns.maze.jumpDialog:Show() end
                return v
            end
        end
    end

    local r = newRoom()
    local oX, oY = getRoomJumpOffset(current_room.cx, current_room.cy, dcx, dcy)
    r.cx = current_room.cx + oX
    r.cy = current_room.cy + oY
    r.neighbors[getOppositeDir(dir)] = current_room
    current_room.neighbors[dir]      = r
    createButton(r)
    setRoomNumber(r)
    return r
end

------------------------------------------------------------
-- Erase / Reset
------------------------------------------------------------
local function eraseRooms()
    for _, v in pairs(rooms) do
        if v.button then
            v.button:Hide()
            pool[#pool + 1] = v.button
        end
    end
    wipe(rooms); wipe(map); wipe(poirooms)
    trapRoom    = nil
    last_dir    = C.north
    selected_btn = nil
    if ns.maze and ns.maze.selMarker then ns.maze.selMarker:Hide() end
    if ns.maze and ns.maze.selected_room_label then
        ns.maze.selected_room_label:SetText("Selected: |cff00ff00None|r")
    end
end

local function resetMap()
    eraseRooms()
    map[1] = newRoom()
    map[1].cx = 0; map[1].cy = 0
    last_room_number = 0
    createButton(map[1])
    setRoomNumber(map[1])
    setCurrentRoom(map[1])
    Engine.UpdatePOIButtonText()
    Engine.UpdateNavButtonText()
end

------------------------------------------------------------
-- BFS queue helpers
------------------------------------------------------------
local function qPush(q, min, max, v) q[max+1]=v; return min, max+1 end
local function qPop(q, min, max)
    if min>max then return min,max,nil end
    return min+1, max, q[min]
end
local function qEmpty(q, min, max) return min>max end

------------------------------------------------------------
-- Map deduplication
------------------------------------------------------------
local function deDuplicateMap(orig, dupe)
    if orig == dupe then return end
    if (orig and orig.is_trap) or (dupe and dupe.is_trap) then
        print("Skipping map deduplication: one of the rooms is the teleport trap room.")
        return
    end
    if ns.History then ns.History.Snapshot("Dedup") end

    ----------------------------------------------------------
    -- Phase 1 — gather (walk in parallel, mutate nothing)
    ----------------------------------------------------------
    local visitedOrig, visitedDupe = {}, {}
    local grafts  = {}   -- {cur, dir, newNeighbor}
    local dupeMap = {}   -- dupeRoom -> origRoom

    local rQ, dQ = {}, {}
    local r1,r2 = 1,0
    local d1,d2 = 1,0
    r1,r2 = qPush(rQ,r1,r2,orig)
    d1,d2 = qPush(dQ,d1,d2,dupe)

    while not qEmpty(rQ,r1,r2) do
        local cur, dcur
        r1,r2,cur  = qPop(rQ,r1,r2)
        d1,d2,dcur = qPop(dQ,d1,d2)

        -- Skip if we've already processed this pairing on either side
        if not visitedOrig[cur] and not (dcur and visitedDupe[dcur]) then
            visitedOrig[cur] = true
            if dcur then
                visitedDupe[dcur] = true
                dupeMap[dcur] = cur
            end
            for i = 1,4 do
                local n  = cur.neighbors[i]
                local n2 = dcur and dcur.neighbors[i] or nil
                if n == nil then
                    if n2 ~= nil then
                        grafts[#grafts+1] = {cur, i, n2}
                        r1,r2 = qPush(rQ,r1,r2,n2)
                        d1,d2 = qPush(dQ,d1,d2,nil)
                    end
                else
                    r1,r2 = qPush(rQ,r1,r2,n)
                    d1,d2 = qPush(dQ,d1,d2,n2)
                end
            end
        end
    end

    ----------------------------------------------------------
    -- Phase 2 — apply (mutate everything)
    ----------------------------------------------------------
    -- 2a. Apply grafts (link orig-tree gaps to surviving dupe-tree branches)
    for _, g in ipairs(grafts) do
        local cur, i, n2 = g[1], g[2], g[3]
        cur.neighbors[i] = n2
        n2.neighbors[getOppositeDir(i)] = cur
    end

    -- 2b. Global pointer rebind: kill any pointer that still aims at a dupe
    for _, v in pairs(rooms) do
        for i = 1,4 do
            local target = v.neighbors[i]
            if target and dupeMap[target] then
                v.neighbors[i] = dupeMap[target]
            end
        end
    end

    -- 2c. Transfer POIs (cur wins on conflict)
    for dcur, cur in pairs(dupeMap) do
        if dcur.poi_index ~= 0 then
            if cur.poi_index == 0 then
                cur.poi_index = dcur.poi_index
                cur.POI_c     = dcur.POI_c
                cur.POI_t     = dcur.POI_t
                poirooms[cur.poi_index] = cur
                recolorRoom(cur)
            else
                -- conflict: cur already has a POI; drop the dupe's
                if poirooms[dcur.poi_index] == dcur then
                    poirooms[dcur.poi_index] = nil
                end
            end
        end
    end

    -- 2d. Remove dupes from the map
    for dcur in pairs(dupeMap) do
        wipe(dcur.neighbors); wipe(dcur.walls)
        rooms[dcur.index] = nil
        if dcur.button then
            dcur.button:Hide()
            dcur.button.room = nil
            pool[#pool+1] = dcur.button
            dcur.button = nil
        end
    end

    -- 2e. Reassign current_room if it was a dupe
    if dupeMap[current_room] then
        current_room = dupeMap[current_room]
    end
    if current_room then setCurrentRoom(current_room) end

    -- 2f. Clear selection if it pointed at a wiped room
    if selected_btn and selected_btn.room == nil then
        selected_btn = nil
        if ns.maze and ns.maze.selMarker then ns.maze.selMarker:Hide() end
        if ns.maze and ns.maze.selected_room_label then
            ns.maze.selected_room_label:SetText("Selected: |cff00ff00None|r")
        end
    end

    -- 2g. Refresh grid + connector views
    refreshMapViews()
end

------------------------------------------------------------
-- Navigation guidance output
------------------------------------------------------------
local function outputGuidance(directions)
    local steps = #directions - 1
    local navString = ""
    if navtarget == 11 then
        if steps ~= 1 then
            print("Hello, user! I have detected an unexplored room " .. steps .. " steps from here!")
        else
            navString = "Unexplored room: "
        end
    else
        if steps ~= 1 then
            local destStr = ""
            if navtarget > 5 then
                destStr = C.color_strings[navtarget-5] .. " Orb"
            elseif navtarget > 0 then
                destStr = C.color_strings[navtarget] .. " Rune"
            end
            print("Hello, user! I have detected your destination (" .. destStr .. ") " .. steps .. " steps from here!")
        end
    end
    for i = 2, 4 do
        if directions[i] == nil then
            navString = navString .. "You will have arrived at your destination!"
            break
        end
        navString = navString .. "Go " .. C.direction_strings[directions[i]] .. ", then "
        if i == 4 then navString = navString .. "..." end
    end
    print(navString)
end

local function outputGuidanceToEHH(directions, POIs, targetRoom, startingRoom)
    local dirLetters = {"N","E","S","W"}
    if targetRoom.poi_index == 11 then
        print("Error, EHH does not care about unexplored rooms"); return
    end
    local navString = "" .. C.EHHPOIStrings[startingRoom.poi_index]
    for i = 2, #directions do
        navString = navString .. dirLetters[directions[i]]
        if POIs[i] ~= 0 then navString = navString .. C.EHHPOIStrings[POIs[i]] end
    end
    print(navString)
    EHH_Directions = EHH_Directions .. navString .. "\n"
end

local function navigateToTarget(targetRoom, startingRoom)
    if targetRoom == nil or startingRoom == nil then return end
    local rQ, dQ, pQ = {},{},{}
    local r1,r2 = 1,0; local d1,d2=1,0; local p1,p2=1,0
    resetVisited()
    r1,r2 = qPush(rQ,r1,r2,startingRoom)
    d1,d2 = qPush(dQ,d1,d2,{0})
    p1,p2 = qPush(pQ,p1,p2,{0})

    while not qEmpty(rQ,r1,r2) do
        local cur, tDir, tPOI
        r1,r2,cur  = qPop(rQ,r1,r2)
        d1,d2,tDir = qPop(dQ,d1,d2)
        p1,p2,tPOI = qPop(pQ,p1,p2)
        if not cur.visited then
            cur.visited = true
            for i = 1,4 do
                local n = cur.neighbors[i]
                if n ~= nil and cur.walls[i] == false and (not n.is_trap or n == targetRoom) then
                    local nDir, nPOI = {}, {}
                    for k,v in pairs(tDir) do nDir[k]=v end; nDir[#nDir+1]=i
                    for k,v in pairs(tPOI) do nPOI[k]=v end; nPOI[#nPOI+1]=n.poi_index
                    if n == targetRoom then
                        if Exporting_To_EHH then outputGuidanceToEHH(nDir,nPOI,targetRoom,startingRoom)
                        else outputGuidance(nDir) end
                        return
                    end
                    r1,r2 = qPush(rQ,r1,r2,n)
                    d1,d2 = qPush(dQ,d1,d2,nDir)
                    p1,p2 = qPush(pQ,p1,p2,nPOI)
                end
            end
        end
    end
    print("No route from current room to target found, keep wandering until you hit a known POI so you can reattach to the rest of the map")
end

local function navigateToUnexplored()
    local stack, dstack, sz = {}, {}, 0
    resetVisited()
    table.insert(stack,current_room); sz=sz+1
    table.insert(dstack,{0})

    while sz > 0 do
        local cur = table.remove(stack,1); sz=sz-1
        cur.visited = true
        local td   = table.remove(dstack,1)
        for i = 1,4 do
            if not cur.walls[i] then
                local nd = {}; for k,v in pairs(td) do nd[k]=v end; nd[#nd+1]=i
                local n = cur.neighbors[i]
                if n == nil then outputGuidance(nd); return
                elseif not n.visited and not n.is_trap then
                    table.insert(stack,n); sz=sz+1
                    table.insert(dstack,nd)
                end
            end
        end
    end
    print("Hmm, that's odd, according to this you have no unexplored territory..")
end

local function navigate()
    if navtarget == 12 then
        if trapRoom ~= nil then navigateToTarget(trapRoom, current_room)
        else print("Teleport trap has not been identified yet.") end
    elseif navtarget ~= 11 then
        navigateToTarget(poirooms[navtarget], current_room)
    else
        navigateToUnexplored()
    end
end

------------------------------------------------------------
-- Serialization
------------------------------------------------------------
function Engine.SerializeMap()
    local out = "index,poi,north_neighbor,east_neighbor,south_neighbor,west_neighbor,n_wall,e_wall,s_wall,w_wall,cx,cy,current,trap,-\n"
    for _, v in pairs(rooms) do
        out = out .. v.index .. "," .. v.poi_index
        local sN, sW = "", ""
        for i = 1,4 do
            sN = sN .. (v.neighbors[i] and ("," .. v.neighbors[i].index) or ", ")
            sW = sW .. (v.walls[i] and ",W" or ", ")
        end
        out = out .. sN .. sW
        out = out .. "," .. v.cx .. "," .. v.cy .. ","
        out = out .. (current_room == v and "current," or ",")
        out = out .. (v.is_trap and "T," or ",")
        out = out .. "-\n"
    end
    return out
end

function Engine.ImportMap(t)
    eraseRooms()
    local l = string.len(t)
    local i = 1
    while i <= l do
        local _,l2 = string.find(t,"\n",i,true)
        if l2 == nil then l2 = l+1 end
        local line = string.sub(t,i,l2-1)
        i = l2

        local sub, j = {}, 1
        local ll = string.len(line)
        while j <= ll do
            local _,t2 = string.find(line,",",j,true)
            if t2 == nil then t2 = ll+1 end
            sub[#sub+1] = string.sub(line,j,t2-1)
            j = t2 + 1
        end

        local room = {}
        room.index = tonumber(sub[1])
        if room.index ~= nil then
            room.poi_index = tonumber(sub[2]) or 0
            room.neighbor_indices = {}
            for nb = 1,4 do room.neighbor_indices[nb] = tonumber(sub[2+nb]) end
            room.walls = {false,false,false,false}
            for w = 1,4 do room.walls[w] = (sub[6+w]=="W") end
            room.visited   = false
            room.neighbors = {}
            room.is_trap   = (sub[14]=="T")

            local rawCX = tonumber(sub[11])
            local rawCY = tonumber(sub[12])
            -- Detect old pixel-based format (|value| > 1000 means old 50k container)
            if rawCX ~= nil and math.abs(rawCX) > 1000 then
                room.cx = math.floor((rawCX - C.oldContainerW/2) / C.oldButtonStep + 0.5)
                room.cy = math.floor((rawCY - C.oldContainerW/2) / C.oldButtonStep + 0.5)
            else
                room.cx = rawCX or 0
                room.cy = rawCY or 0
            end

            rooms[room.index] = room
            if sub[13] == "current" then current_room = room end
        end
        i = i + 1
    end

    for _, v in pairs(rooms) do
        for nb = 1,4 do
            local ni = v.neighbor_indices[nb]
            if ni ~= nil then
                if rooms[ni] == nil then
                    print("Error: room", v.index, "references missing room", ni)
                else
                    v.neighbors[nb] = rooms[ni]
                end
            end
        end
        if v.poi_index > 5 then
            v.POI_c = v.poi_index - 5; v.POI_t = "orb"
            poirooms[v.poi_index] = v
        elseif v.poi_index > 0 then
            v.POI_c = v.poi_index; v.POI_t = "rune"
            poirooms[v.poi_index] = v
        end
        if v.is_trap then trapRoom = v end
        createButton(v)
        recolorRoom(v)
        setRoomNumber(v)
        if v == current_room then setCurrentRoom(v) end
    end
    Engine.UpdatePOIButtonText()
    Engine.UpdateNavButtonText()
    -- Keep the Grid Map (and connector lines) in sync for every import path:
    -- Undo, checkpoint restore, login load, and editbox import.
    refreshMapViews()
end

local logoutFrame = CreateFrame("Frame")
logoutFrame:RegisterEvent("PLAYER_LOGOUT")
logoutFrame:SetScript("OnEvent", function(self, event)
    if event ~= "PLAYER_LOGOUT" then return end
    if rooms == nil then return end
    if LucidNavDB == nil then LucidNavDB = {} end
    LucidNavDB.mapData   = Engine.SerializeMap()
    LucidNavDB.last_saved = os.date("%Y-%m-%d %H:%M")
end)

------------------------------------------------------------
-- EHH export
------------------------------------------------------------
local function exportEHH()
    Exporting_To_EHH = true
    EHH_Directions = ""
    local foundPOIs = {}
    for i = 1,10 do if poirooms[i] ~= nil then foundPOIs[#foundPOIs+1]=i end end
    if #foundPOIs < 2 then
        print("Error: need at least 2 POIs marked to export to EndlessHallsHelper")
        Exporting_To_EHH = false; return
    end
    for i = 1, #foundPOIs-1 do
        for j = i+1, #foundPOIs do
            navigateToTarget(poirooms[foundPOIs[j]], poirooms[foundPOIs[i]])
        end
    end
    print("Routes exported. CTRL+A, CTRL+C to copy, then paste at nightswimmer.github.io/EndlessHalls")
    if ns.eb then ns.eb:SetText(EHH_Directions) end
    Exporting_To_EHH = false
end

------------------------------------------------------------
-- POI click (operates on selected room or current room)
------------------------------------------------------------
local function getTargetRoom()
    return (selected_btn and selected_btn.room) or current_room
end

local function setPOIClick(self)
    local target = getTargetRoom()
    if not target then return end

    if self.poi_index == nil then
        -- Clear button
        if poirooms[target.poi_index] ~= nil then poirooms[target.poi_index] = nil end
        target.POI_t = nil; target.POI_c = nil; target.poi_index = 0
        recolorRoom(target)
        Engine.UpdatePOIButtonText()
        return
    end

    if poirooms[self.poi_index] == target then return end

    if poirooms[self.poi_index] ~= nil and poi_warned ~= self.poi_index then
        print("WOAH WOAH WOAH, this point of interest was already defined as room " ..
              poirooms[self.poi_index].index ..
              "! Click again to confirm a loop in the map and de-duplicate nodes")
        poi_warned = self.poi_index; return
    end
    poi_warned = 0

    if poirooms[self.poi_index] ~= nil then
        deDuplicateMap(poirooms[self.poi_index], target)
    else
        if poirooms[target.poi_index] ~= nil then poirooms[target.poi_index] = nil end
        poirooms[self.poi_index] = target
        target.poi_index = self.poi_index
        target.POI_t     = self.t
        target.POI_c     = self.c
        recolorRoom(target)
    end

    local found = 0
    for i=1,10 do if poirooms[i] ~= nil then found=found+1 end end
    if found == 10 then
        print("|cff00ff00All 5 runes and 5 orbs have been marked!|r You can now start matching orbs to runes.")
    end
    Engine.UpdatePOIButtonText()
    if ns.GridMap then ns.GridMap.Refresh() end
end

------------------------------------------------------------
-- Main OnUpdate
------------------------------------------------------------
local labelAccum   = 0
local lastShownX, lastShownY  -- last integer coords pushed to the labels

local function onUpdate(self, elapsed)
    local y, x = UnitPosition("player")
    ns.playerNav.tex:SetRotation(GetPlayerFacing())

    if not tracking_disabled and current_room and (math.abs(x-lx) > 70 or math.abs(y-ly) > 70) then
        local dir = detectDir(lx, ly)
        if dir then
            last_dir = dir
            setCurrentRoom(current_room.neighbors[dir] or addRoom(dir))
            navigate()
        end
    end
    lx = x; ly = y

    -- Throttle coordinate labels to ~10/sec and skip unchanged values, so we
    -- don't allocate two new strings every frame (the main source of GC churn).
    labelAccum = labelAccum + (elapsed or 0)
    if labelAccum >= 0.1 and ns.maze.x_label then
        labelAccum = 0
        local fx, fy = math.floor(x), math.floor(y)
        if fx ~= lastShownX then
            lastShownX = fx
            ns.maze.x_label:SetText("X: |cff00ff00" .. fx .. "|r")
        end
        if fy ~= lastShownY then
            lastShownY = fy
            ns.maze.y_label:SetText("Y: |cff00ff00" .. fy .. "|r")
        end
    end

    -- Right-click pan: read drag state set by scrollframe's OnMouseDown
    local sf = ns.scrollframe
    if sf and sf.dragging_camera then
        local cur_x, cur_y = GetCursorPosition()
        if cur_x ~= sf.cursor_x then
            sf:SetHorizontalScroll(sf.last_horiz + sf.cursor_x - cur_x)
        end
        if cur_y ~= sf.cursor_y then
            sf:SetVerticalScroll(sf.last_vert + cur_y - sf.cursor_y)
        end
    end
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function Engine.Init()
    tracking_disabled = false
    resetMap()
    ly, lx = UnitPosition("player")
    ns.maze:SetScript("OnUpdate", onUpdate)
end

function Engine.LoadSavedMap()
    if LucidNavDB and LucidNavDB.mapData then
        local saved = LucidNavDB.last_saved or "unknown time"
        print("|cff00ff00LucidNav:|r Found a saved map from " .. saved .. ". Loading it...")
        Engine.ImportMap(LucidNavDB.mapData)
        if rooms[1] then last_dir = C.north; setCurrentRoom(rooms[1]) end
    else
        resetMap()
        print("No saved map found. Starting fresh.")
    end
    print("Right-click drag to pan the map. Click a room center to select it. Click an edge to toggle a wall.")
end

function Engine.ResetMap()
    -- Snapshot the pre-wipe map so a full reset stays undoable.
    if ns.History then ns.History.Snapshot("Reset") end
    LucidNavDB = {}
    resetMap()
    print("Map cleared. Starting fresh.")
end

function Engine.SetCurrentRoom(room)
    setCurrentRoom(room)
end

function Engine.ToggleWall(btn, dir)
    local r = btn.room
    r.walls[dir] = not r.walls[dir]
    recolorRoom(r)
end

function Engine.SetPOI(self)
    setPOIClick(self)
end

function Engine.SetGuidance(self)
    if self.target == 11 then
        navtarget = 11
        Engine.UpdateNavButtonText(); navigate(); return
    end
    if self.target == 12 then
        if trapRoom == nil then
            print("Teleport trap has not been identified yet."); return
        end
        navtarget = 12
        Engine.UpdateNavButtonText(); navigate(); return
    end
    if poirooms[self.target] == nil then
        print("That target has not been discovered yet. Navigating to the nearest unexplored territory")
        navtarget = 11
    else
        navtarget = self.target
    end
    Engine.UpdateNavButtonText(); navigate()
end

function Engine.HitTheTrap()
    if not last_dir then
        print("Cannot process trap: no movement recorded yet. Walk somewhere first."); return
    end
    if ns.History then ns.History.Snapshot("Trap") end
    local prevRoom = current_room.neighbors[getOppositeDir(last_dir)]
    if prevRoom then
        current_room.is_trap = true; trapRoom = current_room
        recolorRoom(current_room)
        print("Room " .. current_room.index .. " marked as the teleport trap room (orange on map).")
        prevRoom.neighbors[last_dir] = nil; prevRoom.walls[last_dir] = true
        print("Room " .. prevRoom.index .. "'s " .. C.direction_strings[last_dir] .. " exit walled off.")
        recolorRoom(prevRoom)
        current_room.neighbors[getOppositeDir(last_dir)] = nil
    else
        print("Warning: could not identify the trap room entrance. Creating new room for current position.")
    end
    local r = newRoom()
    local oX, oY = getRoomJumpOffset(current_room.cx, current_room.cy, 0, 1)
    r.cx = current_room.cx + oX; r.cy = current_room.cy + oY
    createButton(r); setRoomNumber(r); setCurrentRoom(r)
    Engine.UpdateNavButtonText()
end

function Engine.ExportEHH()   exportEHH() end
function Engine.DumpMap()
    if ns.eb then ns.eb:SetText(Engine.SerializeMap()) end
end
function Engine.ImportMapFromEditbox()
    if not ns.eb then return end
    print("WARNING! You must load the map from the same room as you were when you saved the map")
    local t = ns.eb:GetText()
    print("Loading this map:"); print(t)
    Engine.ImportMap(t)
end

function Engine.EraseRooms() eraseRooms() end

function Engine.SetSelectedByIndex(idx)
    if idx == nil then return end
    local r = rooms[idx]
    if r and r.button then setSelectedBtn(r.button, true) end
end

function Engine.UnlinkNeighbor(room, dir)
    if not room then return end
    local n = room.neighbors[dir]
    room.neighbors[dir] = nil
    if n then n.neighbors[getOppositeDir(dir)] = nil end
    recolorRoom(room)
    if n then recolorRoom(n) end
    refreshMapViews()
end

function Engine.DetachRoom(room)
    if not room then return end
    for i = 1,4 do
        local n = room.neighbors[i]
        room.neighbors[i] = nil
        if n then n.neighbors[getOppositeDir(i)] = nil; recolorRoom(n) end
    end
    recolorRoom(room)
    refreshMapViews()
end

function Engine.ClearTrap(room)
    if not room or not room.is_trap then return end
    if ns.History then ns.History.Snapshot("Clear trap") end
    room.is_trap = false
    if trapRoom == room then trapRoom = nil end
    recolorRoom(room)
    Engine.UpdateNavButtonText()
    refreshMapViews()
end

function Engine.DeleteRoom(room)
    if not room then return end
    -- Room 1 is the maze entrance: it anchors the Grid Map layout and the
    -- respawn-to-entrance logic, so it must never be deleted.
    if room == rooms[1] then
        print("|cff00ff00LucidNav:|r Cannot delete the entrance room (Room 1).")
        return
    end
    local total = 0
    for _ in pairs(rooms) do total = total + 1 end
    if total <= 1 then
        print("|cff00ff00LucidNav:|r Cannot delete the only room on the map.")
        return
    end
    if ns.History then ns.History.Snapshot("Delete room") end

    -- Pick a replacement current room (prefer a neighbor) before severing links.
    local replacement
    if current_room == room then
        for i = 1, 4 do
            if room.neighbors[i] then replacement = room.neighbors[i]; break end
        end
        if not replacement then
            for _, v in pairs(rooms) do
                if v ~= room then replacement = v; break end
            end
        end
    end

    -- Sever neighbor back-links and recolor former neighbors (may now be orphans).
    for i = 1, 4 do
        local n = room.neighbors[i]
        if n then n.neighbors[getOppositeDir(i)] = nil end
        room.neighbors[i] = nil
        if n then recolorRoom(n) end
    end

    -- Clear POI / trap registries.
    if room.poi_index and poirooms[room.poi_index] == room then
        poirooms[room.poi_index] = nil
    end
    if trapRoom == room then trapRoom = nil end

    -- Clear selection if it pointed here.
    if selected_btn and selected_btn.room == room then
        selected_btn = nil
        if ns.maze and ns.maze.selMarker then ns.maze.selMarker:Hide() end
        if ns.maze and ns.maze.selected_room_label then
            ns.maze.selected_room_label:SetText("Selected: |cff00ff00None|r")
        end
    end

    -- Recycle the button and drop the room from the map.
    if room.button then
        room.button:Hide()
        room.button.room = nil
        pool[#pool + 1] = room.button
        room.button = nil
    end
    rooms[room.index] = nil

    -- Re-point the current room if we just deleted it.
    if replacement then
        setCurrentRoom(replacement)
        recolorRoom(replacement)  -- refresh orphan-flag now that it is current
    elseif current_room == room then
        current_room = nil
    end

    Engine.UpdatePOIButtonText()
    Engine.UpdateNavButtonText()
    refreshMapViews()
end

function Engine.SetTracking(enabled) tracking_disabled = not enabled end
function Engine.CenterCamera()
    if current_room then centerCam(current_room.cx, current_room.cy) end
end

function Engine.JumpOver()
    if not pendingJump then return end
    local dir = pendingJump.dir
    pendingJump.prev.neighbors[dir] = nil
    pendingJump.existing.neighbors[getOppositeDir(dir)] = nil
    current_room = pendingJump.prev
    pendingJump  = nil
    setCurrentRoom(addRoom(dir, true))
end

function Engine.KeepLinked()
    pendingJump = nil
end

function Engine.GetSelectedRoom()
    return selected_btn and selected_btn.room or nil
end

function Engine.SetPlayerToSelected()
    local r = Engine.GetSelectedRoom()
    if r then setCurrentRoom(r) end
end

function Engine.GetCurrentRoom()  return current_room end
function Engine.GetRooms()        return rooms end
function Engine.GetPoiRooms()     return poirooms end
function Engine.GetTrapRoom()     return trapRoom end
function Engine.GetNavTarget()    return navtarget end

function Engine.UpdatePOIButtonText()
    if not (ns.maze and ns.maze.poi_buttons) then return end
    local poi_buttons = ns.maze.poi_buttons
    for i = 1, 5 do
        local runeTex = poi_buttons[i]
        local orbTex  = poi_buttons[i+5]
        local rgb = C.poi_rgb[i]
        if runeTex then
            if poirooms[i] ~= nil then
                runeTex:SetVertexColor(rgb[1]*0.4, rgb[2]*0.4, rgb[3]*0.4)
            else
                runeTex:SetVertexColor(rgb[1], rgb[2], rgb[3])
            end
        end
        if orbTex then
            if poirooms[i+5] ~= nil then
                orbTex:SetVertexColor(rgb[1]*0.4, rgb[2]*0.4, rgb[3]*0.4)
            else
                orbTex:SetVertexColor(rgb[1], rgb[2], rgb[3])
            end
        end
    end
end

function Engine.UpdateNavButtonText()
    if not (ns.maze and ns.maze.guidance_buttons) then return end
    local guidance_buttons = ns.maze.guidance_buttons
    for i = 1, 12 do
        local btn = guidance_buttons[i]
        if not btn then break end
        local text
        if i == 11 then
            text = "Unexplored Territory"
        elseif i == 12 then
            text = "Teleport Trap"
        elseif i > 5 then
            text = "|cff" .. C.poi_hex_colors[i-5] .. C.color_strings[i-5] .. " Orb|r"
        else
            text = "|cff" .. C.poi_hex_colors[i] .. C.color_strings[i] .. " Rune|r"
        end
        if i == navtarget then text = "[" .. text .. "]" end
        btn:SetText(text)
    end
end
