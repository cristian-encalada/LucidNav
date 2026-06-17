local addonName, ns = ...

ns.History = ns.History or {}
local History = ns.History

local MAX_ENTRIES = 20
local stack = {}

------------------------------------------------------------
-- Capture the current map state onto the undo stack.
-- Snapshots are in-memory only (never written to SavedVariables).
------------------------------------------------------------
function History.Snapshot(label)
    if not ns.Engine then return end
    local cur = ns.Engine.GetCurrentRoom()
    local sel = ns.Engine.GetSelectedRoom()
    stack[#stack + 1] = {
        csv         = ns.Engine.SerializeMap(),
        currentIdx  = cur and cur.index or nil,
        selectedIdx = sel and sel.index or nil,
        label       = label or "action",
    }
    -- Cap the stack, dropping the oldest entry silently.
    while #stack > MAX_ENTRIES do
        table.remove(stack, 1)
    end
end

------------------------------------------------------------
-- Restore the most recent snapshot.
------------------------------------------------------------
function History.Undo()
    local entry = table.remove(stack)
    if not entry then
        print("|cff00ff00LucidNav:|r Nothing to undo.")
        return
    end
    ns.Engine.EraseRooms()
    ns.Engine.ImportMap(entry.csv)
    ns.Engine.SetSelectedByIndex(entry.selectedIdx)
    print("|cff00ff00LucidNav:|r Undid: " .. entry.label)
end

------------------------------------------------------------
-- Drop all snapshots (called on a full map reset).
------------------------------------------------------------
function History.Clear()
    wipe(stack)
end

function History.HasEntries()
    return #stack > 0
end
