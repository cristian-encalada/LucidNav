local addonName, ns = ...

------------------------------------------------------------
-- Chat output helpers. Centralizing the color-prefix here means call sites
-- build only the message body -- no copy-pasted "|cff...LucidNav...|r"
-- literal per file -- and gives the localization pass exactly one place to
-- make the prefix itself translatable.
------------------------------------------------------------
function ns.Print(msg)
    print("|cff00ff00LucidNav:|r " .. msg)
end

function ns.PrintWarning(msg)
    print("|cffff8800LucidNav warning:|r " .. msg)
end

function ns.PrintDebug(msg)
    print("|cff66ccffLucidNav[dbg]:|r " .. msg)
end

------------------------------------------------------------
-- Wrap `text` in a "|cffRRGGBB...|r" hex color code.
------------------------------------------------------------
function ns.ColorText(hex, text)
    return "|cff" .. hex .. text .. "|r"
end

------------------------------------------------------------
-- POI display name ("Yellow Rune", "Blue Orb", ...) from a poi_index
-- (1-5 = rune, 6-10 = orb), optionally hex-colored for chat/label text.
-- Single source of truth so the Rune/Orb suffix isn't re-derived at every
-- call site (and so localization only needs to change word order here).
------------------------------------------------------------
function ns.PoiName(i, withColor)
    local C, L = ns.C, ns.L
    local isOrb = i > 5
    local colorIdx = isOrb and (i - 5) or i
    -- Locales with a gendered color adjective (esES/ptBR: "Runa Amarilla" vs.
    -- "Orbe Amarillo") supply a fully-inflected name table per POI type,
    -- since a single %s template can't agree with both a feminine and a
    -- masculine noun. Locales without that problem (enUS, deDE's neutral
    -- "der Farbe X" apposition, zhCN) fall back to the format template.
    local names = isOrb and L.POI_ORB_NAMES or L.POI_RUNE_NAMES
    local name = names and names[colorIdx]
        or string.format(isOrb and L.POI_NAME_ORB or L.POI_NAME_RUNE, L.COLOR[colorIdx])
    if withColor then
        return ns.ColorText(C.poi_hex_colors[colorIdx], name)
    end
    return name
end
