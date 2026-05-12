-- Lucid Nightmare Navigator Enhanced
--       by Cristian Encalada (cris.encalada.camargo@gmail.com)
-- Fork of LucidNightmareNavigator by Wonderpants of Thrall (Debuggernaut)

local addonName, ns = ...
ns.ADDON_NAME = addonName

SLASH_LucidNav1 = "/lucid"
SLASH_LucidNav2 = "/ln"
SLASH_LucidNav3 = "/lnn"
SlashCmdList["LucidNav"] = function() ns.MapUI.Toggle() end
