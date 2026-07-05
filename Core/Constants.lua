local addonName, ns = ...

local bW, bH = 8, 8  -- border hit-zone for edge-click wall detection

ns.C = {
    -- Canvas
    containerW = 25000,
    containerH = 25000,
    -- Cell size
    buttonW = 35,
    buttonH = 35,
    -- Canvas spacing between cell origins (paper-style: tight gap so adjacent
    -- open rooms read as connected and shared walls align).
    cellStep = 36,  -- buttonW + 1
    -- Wall line rendering (paper-style edges, replacing the old X/mute icon)
    wallColor     = {0.95, 0.95, 0.95, 1},
    wallThickness = 3,
    dashSegments  = 4,   -- short bars used to draw a dashed (overlapped) edge
    dashGap       = 3,   -- px gap between dash segments
    -- Edge hit-zone widths (for click detection)
    borderW = bW,
    borderH = bH,
    -- Wall indicator texture size and inset (kept inside the cell to avoid overlap)
    blockW    = 10,
    blockH    = 10,
    wallInset = 5,  -- pixels inward from cell edge for wall indicator center
    -- Cardinal directions
    north = 1, east = 2, south = 3, west = 4,
    oppositeDir            = {3, 4, 1, 2},
    coord_offset           = {{0, -1}, {1, 0}, {0, 1}, {-1, 0}},
    dir_to_region          = {"TOP", "RIGHT", "BOTTOM", "LEFT"},
    dir_to_region_opposite = {"BOTTOM", "LEFT", "TOP", "RIGHT"},
    direction_strings      = {"North", "East", "South", "West"},
    -- POI colors
    color_strings = {"Yellow", "Blue", "Red", "Green", "Purple"},
    poi_hex_colors = {
        "ffff00",  -- yellow
        "0099ff",  -- blue
        "ff0000",  -- red
        "00ff00",  -- green
        "ff00ff",  -- purple
    },
    poi_hex_colors_found = {
        "888844",
        "446688",
        "884444",
        "448844",
        "884488",
    },
    poi_rgb = {
        {1, 1, 0},     -- yellow
        {0, 0.6, 1},   -- blue
        {1, 0, 0},     -- red
        {0, 1, 0},     -- green
        {1, 0, 1},     -- purple
    },
    -- EHH export strings
    EHHPOIStrings = {
        "#Y","#B","#R","#G","#P",
        "$Y","$B","$R","$G","$P",
    },
    -- Cell fill colors
    cellColor = {
        default       = {0.22, 0.22, 0.22, 1},
        border        = {0.12, 0.12, 0.12, 1},
        visited       = {0.32, 0.32, 0.32, 1},
        borderVisited = {0.20, 0.20, 0.20, 1},
        trap          = {1.00, 0.50, 0.00, 1},
        trapBorder    = {0.75, 0.30, 0.00, 1},
        orphanBorder  = {0.80, 0.10, 0.10, 1},
        -- Warm amber tint shown on rooms that share a maze grid cell (cross/overlap).
        overlapOverlay = {0.85, 0.65, 0.15, 0.22},
    },
    -- Semi-transparent highlight shown on the edge zone currently under the cursor.
    wallHoverColor = {1, 1, 1, 0.35},
    -- Old save format container size (for backward-compat conversion)
    oldContainerW = 50000,
    oldButtonStep = 23,   -- old buttonW(18) + 5
    -- Textures
    player_icon = "interface\\worldmap\\WorldMapArrow",
}
