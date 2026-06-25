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
    if arg == "undo" then
        if ns.History then ns.History.Undo() end
    elseif arg == "save" then
        if ns.Checkpoints then ns.Checkpoints.Save(rest) end
    elseif arg == "restore" then
        if ns.Checkpoints then ns.Checkpoints.Restore(rest) end
    elseif arg == "checkpoints" then
        if ns.Checkpoints then
            local list = ns.Checkpoints.List()
            if #list == 0 then
                print("|cff00ff00LucidNav:|r No checkpoints saved.")
            else
                print("|cff00ff00LucidNav checkpoints:|r")
                for _, cp in ipairs(list) do
                    print("  - " .. cp.name .. "  (" .. (cp.saved or "") .. ")")
                end
            end
        end
    else
        ns.MapUI.Toggle()
    end
end
