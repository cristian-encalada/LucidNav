local addonName, ns = ...

ns.Checkpoints = ns.Checkpoints or {}
local Checkpoints = ns.Checkpoints

local MAX_CHECKPOINTS = 10

------------------------------------------------------------
-- Persistent, named map snapshots (the in-game replacement for the
-- "screenshot every time I make progress" workflow). Unlike History
-- (in-memory, step-granular, lost on /reload), checkpoints are stored in
-- LucidNavDB.checkpoints and survive reloads and relogs.
------------------------------------------------------------
local function store()
    if LucidNavDB == nil then LucidNavDB = {} end
    LucidNavDB.checkpoints = LucidNavDB.checkpoints or {}
    return LucidNavDB.checkpoints
end

local function count(tbl)
    local n = 0
    for _ in pairs(tbl) do n = n + 1 end
    return n
end

------------------------------------------------------------
-- Save the current map under `name` (defaults to a timestamp).
------------------------------------------------------------
function Checkpoints.Save(name)
    if not ns.Engine then return end
    local cp = store()
    name = (name and name ~= "") and name or date("%H:%M:%S")

    -- Enforce the cap by dropping the oldest entry (unless we are overwriting).
    if cp[name] == nil and count(cp) >= MAX_CHECKPOINTS then
        local oldestName, oldestTime
        for k, v in pairs(cp) do
            if oldestTime == nil or (v.ts or 0) < oldestTime then
                oldestTime, oldestName = (v.ts or 0), k
            end
        end
        if oldestName then cp[oldestName] = nil end
    end

    cp[name] = {
        name  = name,
        csv   = ns.Engine.SerializeMap(),
        saved = date("%Y-%m-%d %H:%M"),
        ts    = time(),
    }
    print("|cff00ff00LucidNav:|r Checkpoint saved: " .. name)
end

------------------------------------------------------------
-- Restore a named checkpoint (the restore itself is undoable).
------------------------------------------------------------
function Checkpoints.Restore(name)
    local cp = store()
    local entry = name and cp[name]
    if not entry then
        print("|cff00ff00LucidNav:|r No checkpoint named '" .. tostring(name) .. "'.")
        return
    end
    if ns.History then ns.History.Snapshot("Pre-restore") end
    ns.Engine.ImportMap(entry.csv)
    print("|cff00ff00LucidNav:|r Restored checkpoint: " .. name)
end

------------------------------------------------------------
-- Return an array of {name, saved, ts} sorted newest-first (for UI/slash).
------------------------------------------------------------
function Checkpoints.List()
    local cp = store()
    local out = {}
    for _, v in pairs(cp) do
        out[#out + 1] = { name = v.name, saved = v.saved, ts = v.ts or 0 }
    end
    table.sort(out, function(a, b) return a.ts > b.ts end)
    return out
end

function Checkpoints.Delete(name)
    local cp = store()
    if cp[name] then
        cp[name] = nil
        print("|cff00ff00LucidNav:|r Checkpoint deleted: " .. name)
    end
end
