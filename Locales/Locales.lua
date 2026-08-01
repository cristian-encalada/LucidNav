local addonName, ns = ...

------------------------------------------------------------
-- Assembles the indexed array forms other modules index by direction/color
-- number (ns.L.DIR[1..4], ns.L.COLOR[1..5]) from the scalar keys, after every
-- regional override (esES.lua, ptBR.lua) has already applied. Must load last
-- among the Locales/*.lua files.
------------------------------------------------------------
local L = ns.L

L.DIR = {L.DIR_NORTH, L.DIR_EAST, L.DIR_SOUTH, L.DIR_WEST}
L.COLOR = {L.COLOR_YELLOW, L.COLOR_BLUE, L.COLOR_RED, L.COLOR_GREEN, L.COLOR_PURPLE}
