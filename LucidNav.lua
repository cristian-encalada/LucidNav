-- Lucid Nightmare Navigator Enhanced
--       by Cristian Encalada (cris.encalada.camargo@gmail.com)
-- Fork of LucidNightmareNavigator by Wonderpants of Thrall (Debuggernaut)

local addonName, ns = ...
ns.ADDON_NAME = addonName

SLASH_LucidNav1 = "/lucid"
SLASH_LucidNav2 = "/ln"
SLASH_LucidNav3 = "/lnn"
SlashCmdList["LucidNav"] = function(msg)
    msg = msg or ""
    local arg, rest = msg:match("^%s*(%S*)%s*(.-)%s*$")
    arg = (arg or ""):lower()
    if arg == "debug" then
        -- Single debug switch: toggles live logging + periodic reporting, and
        -- prints a full summary (memory, stats, map audit, wrap audit) on stop.
        if ns.Debug then ns.Debug.Toggle() end
    elseif arg == "undo" then
        if ns.History then ns.History.Undo() end
    elseif arg == "save" then
        if ns.Checkpoints then ns.Checkpoints.Save(rest) end
    elseif arg == "restore" then
        if ns.Checkpoints then ns.Checkpoints.Restore(rest) end
    elseif arg == "checkpoints" then
        if ns.Checkpoints then
            local list = ns.Checkpoints.List()
            if #list == 0 then
                ns.Print(ns.L.MSG_NO_CHECKPOINTS)
            else
                print(ns.ColorText(ns.C.textColor.info, ns.L.MSG_CHECKPOINTS_HEADER))
                for _, cp in ipairs(list) do
                    print(string.format("  - %s  (%s)", cp.name, cp.saved or ""))
                end
            end
        end
    else
        ns.MapUI.Toggle()
    end
end
