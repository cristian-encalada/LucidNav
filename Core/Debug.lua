local addonName, ns = ...

ns.Debug = ns.Debug or {}
local Debug = ns.Debug

------------------------------------------------------------
-- Lightweight debug / profiling facility.
--
-- Off by default (zero overhead when disabled — every entry point early-returns
-- on the `enabled` flag before doing any work). Toggle with `/ln debug`, take a
-- one-shot snapshot with `/ln mem`.
--
-- Memory uses the WoW addon profiler (UpdateAddOnMemoryUsage/GetAddOnMemoryUsage,
-- reported in KiB). CPU is only available when the `scriptProfile` CVar is "1"
-- and the client has been reloaded since — we report that requirement instead of
-- silently showing zeros.
------------------------------------------------------------

local enabled  = false
local counters = {}

-- Memory tracking baselines (KiB)
local baselineMem            -- first sample after enabling
local lastMem                -- previous periodic sample

-- Periodic profiler
local PROFILE_INTERVAL = 5   -- seconds between automatic memory reports
local profiler                -- frame, created lazily
local accum     = 0
local frames    = 0          -- frames counted in the current window

local function p(msg)
    ns.PrintDebug(msg)
end

-- API shims: a few of these globals have namespaced variants across client
-- versions. Prefer the global, fall back to the namespace, tolerate absence.
local function getCVar(name)
    if GetCVar then return GetCVar(name) end
    if C_CVar and C_CVar.GetCVar then return C_CVar.GetCVar(name) end
    return nil
end

local UpdateMem = UpdateAddOnMemoryUsage
local GetMem    = GetAddOnMemoryUsage
local UpdateCPU = UpdateAddOnCPUUsage
local GetCPU    = GetAddOnCPUUsage

------------------------------------------------------------
-- Session stats (ALWAYS tracked, independent of debug mode)
--
-- These are user-paced events (a room discovered, a dedup, a wall toggle), so
-- recording them is essentially free. They give a running picture of how the
-- map was built and how many corrective actions (dedups, jumps, deletes) were
-- needed — useful for spotting mistake-prone steps during testing.
------------------------------------------------------------
local stats = {}

-- Stable display order + friendly labels for the known stat keys.
local STAT_ORDER = {
    "roomsDiscovered", "poisSet", "trapsMarked",
    "dedups", "dedupRoomsRemoved", "dedupSkippedTrap",
    "jumps", "keepLinked", "wallToggles", "roomsDeleted",
    "poiConflicts", "navNoRoute",
}
local STAT_LABEL = {
    roomsDiscovered   = "Rooms discovered",
    poisSet           = "POIs set",
    trapsMarked       = "Traps marked",
    dedups            = "Dedups performed",
    dedupRoomsRemoved = "  rooms merged away by dedup",
    dedupSkippedTrap  = "Dedups skipped (trap room)",
    jumps             = "Jump-overs (chose new room)",
    keepLinked        = "Kept-linked (chose existing)",
    wallToggles       = "Wall toggles",
    roomsDeleted      = "Rooms deleted",
    poiConflicts      = "POI conflicts warned",
    navNoRoute        = "Navigation: no route found",
}

function Debug.Stat(key, n)
    stats[key] = (stats[key] or 0) + (n or 1)
    if enabled then Debug.Log("stat %s -> %d", key, stats[key]) end
end

function Debug.GetStat(key) return stats[key] or 0 end

function Debug.PrintStats()
    p("session stats:")
    local shown = {}
    for _, k in ipairs(STAT_ORDER) do
        shown[k] = true
        p(string.format("  %-32s %d", (STAT_LABEL[k] or k) .. ":", stats[k] or 0))
    end
    -- any unexpected keys not in STAT_ORDER
    for k, v in pairs(stats) do
        if not shown[k] then p(string.format("  %-32s %d", k .. ":", v)) end
    end
end

function Debug.ResetStats()
    wipe(stats)
    if LucidNavDB and LucidNavDB.stats then wipe(LucidNavDB.stats) end
end

-- Copy the live counters into SavedVariables so they survive /reload and logout.
local function saveStats()
    if not LucidNavDB then LucidNavDB = {} end
    LucidNavDB.stats = LucidNavDB.stats or {}
    wipe(LucidNavDB.stats)
    for k, v in pairs(stats) do LucidNavDB.stats[k] = v end
end

------------------------------------------------------------
-- Public: cheap guards used by hot paths
------------------------------------------------------------
function Debug.IsEnabled() return enabled end

-- Increment a named counter (no-op while disabled). Safe to call from anywhere.
function Debug.Count(key, n)
    if not enabled then return end
    counters[key] = (counters[key] or 0) + (n or 1)
end

-- printf-style log line, gated on debug mode.
function Debug.Log(fmt, ...)
    if not enabled then return end
    if select("#", ...) > 0 then fmt = string.format(fmt, ...) end
    p(fmt)
end

------------------------------------------------------------
-- Memory / CPU snapshot
------------------------------------------------------------
local function sampleMemoryKB()
    if not (UpdateMem and GetMem) then return 0 end
    UpdateMem()
    return GetMem(addonName) or 0
end

local function roomStats()
    if not (ns.Engine and ns.Engine.GetDebugStats) then return "rooms=? pool=?" end
    local s = ns.Engine.GetDebugStats()
    return string.format("rooms=%d pool=%d", s.rooms or 0, s.pool or 0)
end

-- Print a full snapshot. `tag` labels the line (e.g. "periodic", "manual").
function Debug.Report(tag)
    local kb = sampleMemoryKB()
    baselineMem = baselineMem or kb
    local sinceBase = kb - baselineMem
    local sinceLast = lastMem and (kb - lastMem) or 0
    lastMem = kb

    p(string.format(
        "%s | mem=%.1f KB (Δlast=%+.1f, Δbase=%+.1f) | %s",
        tag or "report", kb, sinceLast, sinceBase, roomStats()
    ))

    -- CPU (only meaningful with scriptProfile enabled)
    if getCVar("scriptProfile") == "1" and UpdateCPU and GetCPU then
        UpdateCPU()
        local cpu = GetCPU(addonName) or 0
        p(string.format("    cpu=%.2f ms (cumulative since reload)", cpu))
    end
end

------------------------------------------------------------
-- Aggregated reports (everything in one place)
------------------------------------------------------------
local function printList(title, list)
    if #list == 0 then
        p(title .. ": clean")
    else
        p(string.format("%s: %d issue(s)", title, #list))
        for _, m in ipairs(list) do p("    - " .. m) end
    end
end

-- The full picture: memory, session stats, map-structure audit, grid wrap audit.
-- Printed on enable (baseline) and on disable (final summary).
function Debug.FullReport(tag)
    Debug.Report(tag)
    Debug.PrintStats()
    if ns.Engine and ns.Engine.AuditMap then
        printList("Map audit", ns.Engine.AuditMap())
    end
    if ns.GridMap and ns.GridMap.AuditWrap then
        printList("Wrap audit", ns.GridMap.AuditWrap())
    end
end

------------------------------------------------------------
-- Periodic profiler frame
------------------------------------------------------------
local function ensureProfiler()
    if profiler then return end
    profiler = CreateFrame("Frame")
    profiler:SetScript("OnUpdate", function(_, elapsed)
        if not enabled then return end
        frames = frames + 1
        accum  = accum + (elapsed or 0)
        if accum >= PROFILE_INTERVAL then
            local fps = frames / accum
            Debug.Report(string.format("periodic(%.0fs, %.0f fps)", accum, fps))
            -- show and reset per-window action counters
            for k, v in pairs(counters) do
                p(string.format("    %s = %d (last %.0fs)", k, v, accum))
                counters[k] = 0
            end
            -- NOTE: audits are intentionally NOT run here. They allocate tables
            -- every call and would dominate the idle memory delta we're trying to
            -- measure. Full audit detail prints on /ln debug off instead.
            accum, frames = 0, 0
        end
    end)
end

------------------------------------------------------------
-- Public: toggle / commands
------------------------------------------------------------
function Debug.SetEnabled(on)
    if on then
        enabled = true
        ensureProfiler()
        baselineMem, lastMem = nil, nil
        accum, frames = 0, 0
        wipe(counters)
        p("debug ON — live event logging + a report every " .. PROFILE_INTERVAL
          .. "s. Run |cffffff00/ln debug|r again to stop and print a full summary.")
        if getCVar("scriptProfile") ~= "1" then
            p("CPU profiling is OFF. To enable: |cffffff00/console scriptProfile 1|r then /reload.")
        end
        Debug.FullReport("baseline")
    else
        -- Final, comprehensive summary before going quiet.
        p("debug OFF — final summary:")
        Debug.FullReport("final")
        enabled = false
    end
    if LucidNavDB then LucidNavDB.debug = enabled end
end

function Debug.Toggle()
    Debug.SetEnabled(not enabled)
end

-- Called once after SavedVariables are available, to restore persisted state.
function Debug.Initialize()
    -- Restore accumulated stats first so the baseline report shows real totals.
    if LucidNavDB and LucidNavDB.stats then
        wipe(stats)
        for k, v in pairs(LucidNavDB.stats) do stats[k] = v end
    end
    if LucidNavDB and LucidNavDB.debug then
        Debug.SetEnabled(true)
    end
end

-- Self-initialize at login so the periodic profiler can run (and report the
-- loaded-but-window-closed footprint) without needing to open the window first.
-- Save stats on logout/reload so the debug data is never lost between sessions.
local evtFrame = CreateFrame("Frame")
evtFrame:RegisterEvent("PLAYER_LOGIN")
evtFrame:RegisterEvent("PLAYER_LOGOUT")
evtFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_LOGIN" then
        Debug.Initialize()
    else  -- PLAYER_LOGOUT (also fires on /reload)
        saveStats()
    end
end)
