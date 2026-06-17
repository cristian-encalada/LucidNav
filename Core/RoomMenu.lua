local addonName, ns = ...
local C = ns.C

ns.RoomMenu = ns.RoomMenu or {}
local RoomMenu = ns.RoomMenu

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
        root:CreateTitle("Room " .. room.index)

        root:CreateButton("Set as current room", function()
            ns.Engine.SetCurrentRoom(room)
        end)

        if hasAnyNeighbor(room) then
            local unlink = root:CreateButton("Unlink neighbor")
            for i = 1, 4 do
                if room.neighbors[i] then
                    local dir, dirName = i, C.direction_strings[i]
                    unlink:CreateButton(dirName, function()
                        if ns.History then ns.History.Snapshot("Unlink " .. dirName) end
                        ns.Engine.UnlinkNeighbor(room, dir)
                    end)
                end
            end

            root:CreateButton("Detach (unlink all neighbors)", function()
                if ns.History then ns.History.Snapshot("Detach") end
                ns.Engine.DetachRoom(room)
            end)
        end

        if ns.History and ns.History.HasEntries() then
            root:CreateButton("Undo last action", function()
                ns.History.Undo()
            end)
        end
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
        { text = "Room " .. room.index, isTitle = true, notCheckable = true },
        {
            text = "Set as current room", notCheckable = true,
            func = function() ns.Engine.SetCurrentRoom(room) end,
        },
    }

    if hasAnyNeighbor(room) then
        local sub = {}
        for i = 1, 4 do
            if room.neighbors[i] then
                local dir, dirName = i, C.direction_strings[i]
                sub[#sub+1] = {
                    text = dirName, notCheckable = true,
                    func = function()
                        if ns.History then ns.History.Snapshot("Unlink " .. dirName) end
                        ns.Engine.UnlinkNeighbor(room, dir)
                    end,
                }
            end
        end
        menu[#menu+1] = { text = "Unlink neighbor", notCheckable = true, hasArrow = true, menuList = sub }
        menu[#menu+1] = {
            text = "Detach (unlink all neighbors)", notCheckable = true,
            func = function()
                if ns.History then ns.History.Snapshot("Detach") end
                ns.Engine.DetachRoom(room)
            end,
        }
    end

    menu[#menu+1] = {
        text = "Undo last action", notCheckable = true,
        disabled = not (ns.History and ns.History.HasEntries()),
        func = function() if ns.History then ns.History.Undo() end end,
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
        print("|cff00ff00LucidNav:|r Context menu API unavailable on this client.")
    end
end
