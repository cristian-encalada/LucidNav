local addonName, ns = ...
local C = ns.C

ns.RoomMenu = ns.RoomMenu or {}
local RoomMenu = ns.RoomMenu

------------------------------------------------------------
-- Menu item labels, defined once and shared by both the modern (MenuUtil)
-- and legacy (EasyMenu) code paths below instead of being hardcoded twice.
-- Locales/*.lua load before this file, so ns.L is already populated here.
------------------------------------------------------------
local LABEL_SET_CURRENT = ns.L.MENU_SET_CURRENT
local LABEL_UNLINK      = ns.L.MENU_UNLINK
local LABEL_DETACH      = ns.L.MENU_DETACH
local LABEL_CLEAR_TRAP  = ns.L.MENU_CLEAR_TRAP
local LABEL_UNDO        = ns.L.MENU_UNDO
local LABEL_DELETE      = ns.L.MENU_DELETE

------------------------------------------------------------
-- Helper: does this room have at least one neighbor?
------------------------------------------------------------
local function hasAnyNeighbor(room)
    for i = 1, 4 do
        if room.neighbors[i] then return true end
    end
    return false
end

------------------------------------------------------------
-- Modern context menu (Retail 11.0+ / 12.x): MenuUtil
------------------------------------------------------------
local function showModern(room)
    MenuUtil.CreateContextMenu(UIParent, function(owner, root)
        root:CreateTitle(string.format(ns.L.MENU_ROOM_TITLE, room.index))

        root:CreateButton(LABEL_SET_CURRENT, function()
            ns.Engine.SetCurrentRoom(room)
        end)

        if hasAnyNeighbor(room) then
            -- CreateButton(title) with no callback returns a submenu root to
            -- chain further :CreateButton calls off of; the annotation only
            -- models the title+callback overload.
            ---@diagnostic disable-next-line: missing-parameter
            local unlink = root:CreateButton(LABEL_UNLINK)
            for i = 1, 4 do
                if room.neighbors[i] then
                    local dir, dirName = i, ns.L.DIR[i]
                    unlink:CreateButton(dirName, function()
                        if ns.History then ns.History.Snapshot(ns.History.LabelUnlink(dirName)) end
                        ns.Engine.UnlinkNeighbor(room, dir)
                    end)
                end
            end

            root:CreateButton(LABEL_DETACH, function()
                if ns.History then ns.History.Snapshot(ns.L.MSG_LABEL_DETACH) end
                ns.Engine.DetachRoom(room)
            end)
        end

        if room.is_trap then
            root:CreateButton(LABEL_CLEAR_TRAP, function()
                ns.Engine.ClearTrap(room)
            end)
        end

        if ns.History and ns.History.HasEntries() then
            root:CreateButton(LABEL_UNDO, function()
                ns.History.Undo()
            end)
        end

        root:CreateDivider()
        root:CreateButton(LABEL_DELETE, function()
            ns.Engine.DeleteRoom(room)
        end)
    end)
end

------------------------------------------------------------
-- Legacy fallback: EasyMenu (older clients)
------------------------------------------------------------
local legacyFrame
local function showLegacy(room)
    legacyFrame = legacyFrame or
        CreateFrame("Frame", "LucidNavRoomMenu", UIParent, "UIDropDownMenuTemplate")

    local menu = {
        { text = string.format(ns.L.MENU_ROOM_TITLE, room.index), isTitle = true, notCheckable = true },
        {
            text = LABEL_SET_CURRENT, notCheckable = true,
            func = function() ns.Engine.SetCurrentRoom(room) end,
        },
    }

    if hasAnyNeighbor(room) then
        local sub = {}
        for i = 1, 4 do
            if room.neighbors[i] then
                local dir, dirName = i, ns.L.DIR[i]
                sub[#sub+1] = {
                    text = dirName, notCheckable = true,
                    func = function()
                        if ns.History then ns.History.Snapshot(ns.History.LabelUnlink(dirName)) end
                        ns.Engine.UnlinkNeighbor(room, dir)
                    end,
                }
            end
        end
        menu[#menu+1] = { text = LABEL_UNLINK, notCheckable = true, hasArrow = true, menuList = sub }
        menu[#menu+1] = {
            text = LABEL_DETACH, notCheckable = true,
            func = function()
                if ns.History then ns.History.Snapshot(ns.L.MSG_LABEL_DETACH) end
                ns.Engine.DetachRoom(room)
            end,
        }
    end

    if room.is_trap then
        menu[#menu+1] = {
            text = LABEL_CLEAR_TRAP, notCheckable = true,
            func = function() ns.Engine.ClearTrap(room) end,
        }
    end

    menu[#menu+1] = {
        text = LABEL_UNDO, notCheckable = true,
        disabled = not (ns.History and ns.History.HasEntries()),
        func = function() if ns.History then ns.History.Undo() end end,
    }

    menu[#menu+1] = {
        text = LABEL_DELETE, notCheckable = true,
        func = function() ns.Engine.DeleteRoom(room) end,
    }

    EasyMenu(menu, legacyFrame, "cursor", 0, 0, "MENU")
end

------------------------------------------------------------
-- Public API
------------------------------------------------------------
function RoomMenu.Show(room)
    if not room then return end
    if MenuUtil and MenuUtil.CreateContextMenu then
        showModern(room)
    elseif type(EasyMenu) == "function" then
        showLegacy(room)
    else
        ns.Print(ns.L.MSG_MENU_UNAVAILABLE)
    end
end
