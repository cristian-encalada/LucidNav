-- Lucid Nightmare Navigator Enhanced
--       by Cristian Encalada (cris.encalada.camargo@gmail.com)
-- Fork of LucidNightmareNavigator by Wonderpants of Thrall (Debuggernaut)

local addonName, ns = ...
ns.ADDON_NAME = addonName

SLASH_LucidNav1 = "/lucid"
SLASH_LucidNav2 = "/ln"
SLASH_LucidNav3 = "/lnn"
SlashCmdList["LucidNav"] = function(msg)
    local arg = (msg or ""):lower():match("^%s*(%S*)")
    if arg == "undo" then
        if ns.History then ns.History.Undo() end
    else
        ns.MapUI.Toggle()
    end
end
