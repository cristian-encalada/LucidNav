local addonName, ns = ...

------------------------------------------------------------
-- Base (fallback) locale. Always fully populated regardless of GetLocale() --
-- every ns.L.KEY used anywhere in the addon must be defined here. Regional
-- files (esES.lua, ptBR.lua) only overwrite the keys they translate.
------------------------------------------------------------
ns.L = {}
local L = ns.L

-- Direction / POI-color scalars. The indexed array forms (L.DIR, L.COLOR)
-- are assembled by Locales.lua after every regional override has applied.
L.DIR_NORTH   = "North"
L.DIR_EAST    = "East"
L.DIR_SOUTH   = "South"
L.DIR_WEST    = "West"
L.COLOR_YELLOW = "Yellow"
L.COLOR_BLUE   = "Blue"
L.COLOR_RED    = "Red"
L.COLOR_GREEN  = "Green"
L.COLOR_PURPLE = "Purple"
-- POI display name template ("%s" = the color, e.g. "Yellow Rune"). A full
-- template (not just a suffix) so each locale can place the color adjective
-- before or after the noun as its grammar requires.
L.POI_NAME_RUNE = "%s Rune"
L.POI_NAME_ORB  = "%s Orb"

------------------------------------------------------------
-- Buttons
------------------------------------------------------------
L.BTN_CLEAR          = "Clear"
L.BTN_CLICK_AGAIN    = "Click again!"
L.BTN_GOT_PORTED     = "I got ported!"
L.BTN_GRID_MAP       = "Grid Map"
L.BTN_NEW_MAP        = "New Map"
L.BTN_RESTORE        = "Restore"
L.BTN_SAVE           = "Save"
L.BTN_SET_PLAYER_LOC = "Set Player Loc"
L.BTN_TRACK          = "Track"

------------------------------------------------------------
-- Static labels
------------------------------------------------------------
L.LBL_CURRENT                = "Current:"
L.LBL_CURRENT_ROOM           = "Current Room"
L.LBL_HERE                   = "(here)"
L.LBL_MAP_AUDIT              = "Map audit"
L.LBL_MARKERS                = "Markers"
L.LBL_NAV_TARGET             = "Navigation Target:"
L.LBL_NONE                   = "None"
L.LBL_OPACITY                = "Opacity"
L.LBL_SELECTED               = "Selected:"
L.LBL_TELEPORT_TRAP          = "Teleport Trap"
L.LBL_UNEXPLORED_ROOM_PREFIX = "Unexplored room: "
L.LBL_UNEXPLORED_TERRITORY   = "Unexplored Territory"
L.LBL_WRAP_AUDIT             = "Wrap audit"
L.LBL_X                      = "X:"
L.LBL_Y                      = "Y:"

------------------------------------------------------------
-- Tooltips
------------------------------------------------------------
L.TIP_CENTER_CAMERA  = "Center camera on current room"
L.TIP_CLEAR_POI      = "Clear POI marker from selected/current room"
L.TIP_EDGE_WRAP      = "Edge wrap"
L.TIP_ERASE_MAP      = "Erase map and start over"
L.TIP_GOT_PORTED     = "Mark current room as the teleport trap room"
L.TIP_HELP           = "Help — how to use the addon"
L.TIP_SET_PLAYER_LOC = "Move the player position to the selected room"
L.TIP_TOGGLE_MATCH   = "Mark %s pair as matched/unmatched"
L.TIP_TOGGLE_WALL    = "%s Wall"
L.TIP_UNDO           = "Undo last action"

------------------------------------------------------------
-- Right-click context menu
------------------------------------------------------------
L.MENU_CHECKPOINTS       = "Checkpoints"
L.MENU_CHECKPOINT_ENTRY  = "%s  (%s)"
L.MENU_CLEAR_TRAP        = "Clear trap"
L.MENU_DELETE            = "Delete room"
L.MENU_DELETE_CHECKPOINT = "Delete"
L.MENU_DETACH            = "Detach (unlink all neighbors)"
L.MENU_RESTORE           = "Restore"
L.MENU_ROOM_TITLE        = "Room %d"
L.MENU_SET_CURRENT       = "Set as current room"
L.MENU_UNDO              = "Undo last action"
L.MENU_UNLINK            = "Unlink neighbor"

------------------------------------------------------------
-- Dialogs
------------------------------------------------------------
L.DLG_JUMP_BODY  = "You have encountered an existing room on the map.\nIs this the same room you expected to enter?"
L.DLG_JUMP_YES   = "Yes, keep it linked"
L.DLG_JUMP_NO    = "No, jump over"
L.CHK_AUTO_KEEP_LINKED = "Don't ask again this session"
L.TIP_AUTO_KEEP_LINKED = "Skip this dialog for the rest of the session and always assume it's the same room (undo/detach the room if it guesses wrong)"

L.DLG_RESET_TITLE = "Erase Map?"
L.DLG_RESET_BODY  = "This will permanently erase your entire map.\nAre you sure?"
L.DLG_RESET_YES   = "Yes, erase it"
L.DLG_RESET_NO    = "Cancel"

L.DLG_HELP_TITLE = "— Help"

L.DLG_HELP_H_NAVIGATE = "How do I navigate the map?"
L.DLG_HELP_B_NAVIGATE = "Right-click drag anywhere on the map to pan the view."

L.DLG_HELP_H_MARKING = "How do I mark walls and points of interest?"
L.DLG_HELP_B_MARKING = "Click the CENTER of a room to select it (a ring appears).\n"
    .. "Click an EDGE of a room to toggle that wall.\n"
    .. "Click a colored Rune/Orb button on the right panel to mark the selected (or current) room as that POI."

L.DLG_HELP_H_TRAP = "How do I mark the teleport trap?"
L.DLG_HELP_B_TRAP = "When you get ported, immediately click 'I got ported!'. The trap room turns orange."

L.DLG_HELP_H_LOGOUT = "What happens after a logout or crash?"
L.DLG_HELP_B_LOGOUT = "Proper logout (20-second timer): you respawn at Room 1. The addon resets your position automatically.\n"
    .. "Force-close / crash / DC: you return to your last room in the maze. Walk back to a known room and use 'Set Player Loc' to correct your position.\n"
    .. "The maze regenerates once a day, around realm midnight (not the dungeon lockout reset) -- a quick relog keeps the same maze, but finish your run before the day rolls over."

L.DLG_HELP_H_TIPS = "Tips for solving the maze"
L.DLG_HELP_B_TIPS = "• Do NOT extinguish runes early — they are essential navigation landmarks.\n"
    .. "• Use navigation to reach unexplored rooms first.\n"
    .. "• The teleport trap is marked in orange — navigation avoids routing through it."

------------------------------------------------------------
-- Chat/print messages
------------------------------------------------------------
L.MSG_ALL_POIS_MARKED = "|cff00ff00All 5 runes and 5 orbs have been marked!|r You can now start matching orbs to runes."
L.MSG_ARRIVED         = "you'll arrive!"
L.MSG_GO_DIRECTION_THEN = "Go %s, then "

L.MSG_CANNOT_DELETE_ENTRANCE  = "Cannot delete the entrance room (Room 1)."
L.MSG_CANNOT_DELETE_ONLY_ROOM = "Cannot delete the only room on the map."

L.MSG_CHECKPOINTS_HEADER   = "LucidNav checkpoints:"
L.MSG_CHECKPOINT_DELETED   = "Checkpoint deleted: %s"
L.MSG_CHECKPOINT_NOT_FOUND = "No checkpoint named '%s'."
L.MSG_CHECKPOINT_RESTORED  = "Restored checkpoint: %s"
L.MSG_CHECKPOINT_SAVED     = "Checkpoint saved: %s"
L.MSG_NO_CHECKPOINTS       = "No checkpoints saved."
L.MSG_NO_CHECKPOINTS_YET   = "No checkpoints saved yet. Click Save first."

L.MSG_CPU_PROFILING_OFF  = "CPU profiling is OFF. To enable: |cffffff00/console scriptProfile 1|r then /reload."
L.MSG_DEBUG_OFF          = "debug OFF — final summary:"
L.MSG_DEBUG_ON           = "debug ON — live event logging + a report every %ds. Run |cffffff00/ln debug|r again to stop and print a full summary."
L.MSG_DEBUG_STATS_HEADER = "session stats:"

L.MSG_DEDUP_SKIPPED_TRAP = "Skipping map deduplication: one of the rooms is the teleport trap room."

L.MSG_DESTINATION_STEPS  = "I have detected your destination (%s) %d steps from here!"
L.MSG_UNEXPLORED_STEPS   = "I have detected an unexplored room %d steps from here!"
L.MSG_NO_ROUTE           = "No route from current room to target found, keep wandering until you hit a known POI so you can reattach to the rest of the map"
L.MSG_NO_UNEXPLORED      = "Hmm, that's odd, according to this you have no unexplored territory.."
L.MSG_TARGET_NOT_DISCOVERED = "That target has not been discovered yet. Navigating to the nearest unexplored territory"

L.MSG_EHH_EXPORTED      = "Routes exported. CTRL+A, CTRL+C to copy, then paste at nightswimmer.github.io/EndlessHalls"
L.MSG_EHH_NEED_2_POIS   = "Error: need at least 2 POIs marked to export to EndlessHallsHelper"
L.MSG_EHH_NO_UNEXPLORED = "Error, EHH does not care about unexplored rooms"

L.MSG_FOUND_SAVED_MAP = "Found a saved map from %s. Loading it..."
L.MSG_NO_SAVED_MAP    = "No saved map found. Starting fresh."
L.MSG_MAP_CLEARED     = "Map cleared. Starting fresh."
L.MSG_STARTUP_TIP     = "Right-click drag to pan the map. Click a room center to select it. Click an edge to toggle a wall."

L.MSG_LOAD_SAME_ROOM_WARNING = "WARNING! You must load the map from the same room as you were when you saved the map"
L.MSG_LOADING_MAP            = "Loading this map:"

L.MSG_MENU_UNAVAILABLE = "Context menu API unavailable on this client."

L.MSG_POI_ALREADY_DEFINED = "WOAH WOAH WOAH, this point of interest was already defined as room %d! Click again to confirm a loop in the map and de-duplicate nodes"
L.MSG_POI_UNREACHABLE     = "%s (room %d) is no longer reachable from here — you may have walled it off."
L.MSG_ROOM_MISSING_NEIGHBOR = "Error: room %d references missing room %d"
L.MSG_SELECT_ROOM_FIRST   = "Select a room first (click its center)."

L.MSG_TRAP_ENTRANCE_UNKNOWN = "Warning: could not identify the trap room entrance. Creating new room for current position."
L.MSG_TRAP_EXIT_WALLED      = "Room %d's %s exit walled off."
L.MSG_TRAP_MARKED           = "Room %d marked as the teleport trap room (orange on map)."
L.MSG_TRAP_NOT_IDENTIFIED   = "Teleport trap has not been identified yet."
L.MSG_TRAP_NO_MOVEMENT      = "Cannot process trap: no movement recorded yet. Walk somewhere first."

L.MSG_UNDO_DID  = "Undid: %s"
L.MSG_UNDO_NONE = "Nothing to undo."

-- Undo snapshot labels (echoed back via MSG_UNDO_DID)
L.MSG_LABEL_ACTION      = "action"
L.MSG_LABEL_CLEAR_TRAP  = "Clear trap"
L.MSG_LABEL_DEDUP       = "Dedup"
L.MSG_LABEL_DELETE_ROOM = "Delete room"
L.MSG_LABEL_DETACH      = "Detach"
L.MSG_LABEL_JUMP_OVER   = "Jump over"
L.MSG_LABEL_MAP_ROOM    = "Map room"
L.MSG_LABEL_PRE_RESTORE = "Pre-restore"
L.MSG_LABEL_RESET       = "Reset"
L.MSG_LABEL_TRAP        = "Trap"
L.MSG_LABEL_UNLINK      = "Unlink %s"

------------------------------------------------------------
-- Debug/audit (Core/Debug.lua, AuditMap/AuditWrap)
------------------------------------------------------------
L.STAT_ROOMS_DISCOVERED   = "Rooms discovered"
L.STAT_POIS_SET           = "POIs set"
L.STAT_TRAPS_MARKED       = "Traps marked"
L.STAT_DEDUPS             = "Dedups performed"
L.STAT_DEDUP_ROOMS_REMOVED = "  rooms merged away by dedup"
L.STAT_DEDUP_SKIPPED_TRAP = "Dedups skipped (trap room)"
L.STAT_JUMPS              = "Jump-overs (chose new room)"
L.STAT_KEEP_LINKED        = "Kept-linked (chose existing)"
L.STAT_WALL_TOGGLES       = "Wall toggles"
L.STAT_ROOMS_DELETED      = "Rooms deleted"
L.STAT_POI_CONFLICTS      = "POI conflicts warned"
L.STAT_NAV_NO_ROUTE       = "Navigation: no route found"

L.AUDIT_CLEAN            = "%s: clean"
L.AUDIT_ISSUES_SUMMARY   = "%s: %d issue(s)"
L.AUDIT_ORPHANED          = "Room %d is orphaned (no neighbors)."
L.AUDIT_DANGLING_NEIGHBOR = "Room %d -> %s points at a room not in the map."
L.AUDIT_ASYMMETRIC_LINK   = "Asymmetric link: room %d %s -> room %d, but no back-link."
L.AUDIT_WALL_MISMATCH     = "Wall mismatch between rooms %d and %d (%s edge)."
L.AUDIT_CANVAS_OVERLAP    = "Canvas overlap at cell %s: rooms %s."
L.AUDIT_WRAP_MISMATCH     = "%s %s-> room %d: model predicts %s, but room %d is at %s."
