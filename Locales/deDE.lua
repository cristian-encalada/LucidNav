local addonName, ns = ...

------------------------------------------------------------
-- German overrides. Only overwrites translated keys; ns.L itself is never
-- reassigned (that would drop every un-overridden English key from
-- enUS.lua).
--
-- First-draft, Claude-authored translation (no native-speaker review pass) --
-- refinable over time via issues/PRs, same as any addon localization.
------------------------------------------------------------
if GetLocale() ~= "deDE" then return end

local L = ns.L

L.DIR_NORTH = "Norden"
L.DIR_EAST  = "Osten"
L.DIR_SOUTH = "Süden"
L.DIR_WEST  = "Westen"
-- Color nouns (not inflected adjectives) used in an apposition pattern
-- ("Paar der Farbe Gelb") so the same word works regardless of the
-- grammatical gender of whatever noun it modifies elsewhere (e.g. Paar).
L.COLOR_YELLOW = "Gelb"
L.COLOR_BLUE   = "Blau"
L.COLOR_RED    = "Rot"
L.COLOR_GREEN  = "Grün"
L.COLOR_PURPLE = "Lila"
-- Fully-inflected short names ("Gelbe Rune", "Gelbe Kugel"): Rune and Kugel
-- are both feminine, so one adjective inflection (nominative -e ending)
-- serves both nouns, unlike esES/ptBR where rune/orb have different genders.
L.POI_RUNE_NAMES = { "Gelbe Rune", "Blaue Rune", "Rote Rune", "Grüne Rune", "Lila Rune" }
L.POI_ORB_NAMES  = { "Gelbe Kugel", "Blaue Kugel", "Rote Kugel", "Grüne Kugel", "Lila Kugel" }

------------------------------------------------------------
-- Buttons
------------------------------------------------------------
L.BTN_CLEAR          = "Leeren"
L.BTN_CLICK_AGAIN    = "Nochmal klicken!"
L.BTN_GOT_PORTED     = "Ich wurde teleportiert!"
L.BTN_GRID_MAP       = "Rasterkarte"
L.BTN_NEW_MAP        = "Neue Karte"
L.BTN_RESTORE        = "Wiederherstellen"
L.BTN_SAVE           = "Speichern"
L.BTN_SET_PLAYER_LOC = "Position setzen"
L.BTN_TRACK          = "Verfolgen"

------------------------------------------------------------
-- Static labels
------------------------------------------------------------
L.LBL_CURRENT                = "Aktuell:"
L.LBL_CURRENT_ROOM           = "Aktueller Raum"
L.LBL_HERE                   = "(hier)"
L.LBL_MAP_AUDIT              = "Kartenprüfung"
L.LBL_MARKERS                = "Markierungen"
L.LBL_NAV_TARGET             = "Navigationsziel:"
L.LBL_NONE                   = "Keiner"
L.LBL_OPACITY                = "Deckkraft"
L.LBL_SELECTED               = "Ausgewählt:"
L.LBL_TELEPORT_TRAP          = "Teleport-Falle"
L.LBL_UNEXPLORED_ROOM_PREFIX = "Unerforschter Raum: "
L.LBL_UNEXPLORED_TERRITORY   = "Unerforschtes Gebiet"
L.LBL_WRAP_AUDIT             = "Umlaufprüfung"
L.LBL_X                      = "X:"
L.LBL_Y                      = "Y:"

------------------------------------------------------------
-- Tooltips
------------------------------------------------------------
L.TIP_CENTER_CAMERA  = "Kamera auf aktuellen Raum zentrieren"
L.TIP_CLEAR_POI      = "POI-Markierung vom ausgewählten/aktuellen Raum entfernen"
L.TIP_EDGE_WRAP      = "Kartenumlauf"
L.TIP_ERASE_MAP      = "Karte löschen und neu beginnen"
L.TIP_GOT_PORTED     = "Aktuellen Raum als Teleport-Fallenraum markieren"
L.TIP_HELP           = "Hilfe — wie man das Addon benutzt"
L.TIP_SET_PLAYER_LOC = "Spielerposition zum ausgewählten Raum verschieben"
L.TIP_TOGGLE_MATCH   = "Paar der Farbe %s als zusammengehörig/nicht zusammengehörig markieren"
-- Compound word, not "%s wand" -- "Norden"/"Osten"/... only compound cleanly
-- with their short (non-declined) stems: Nord/Ost/Süd/West + "wand".
L.WALL_NAMES         = { "Nordwand", "Ostwand", "Südwand", "Westwand" }
L.TIP_TOGGLE_WALL    = "%s Wand"
L.TIP_UNDO           = "Letzte Aktion rückgängig machen"

------------------------------------------------------------
-- Right-click context menu
------------------------------------------------------------
L.MENU_CHECKPOINTS       = "Kontrollpunkte"
L.MENU_CHECKPOINT_ENTRY  = "%s  (%s)"
L.MENU_CLEAR_TRAP        = "Falle entfernen"
L.MENU_DELETE            = "Raum löschen"
L.MENU_DELETE_CHECKPOINT = "Löschen"
L.MENU_DETACH            = "Trennen (alle Nachbarn entfernen)"
L.MENU_RESTORE           = "Wiederherstellen"
L.MENU_ROOM_TITLE        = "Raum %d"
L.MENU_SET_CURRENT       = "Als aktuellen Raum festlegen"
L.MENU_UNDO              = "Letzte Aktion rückgängig machen"
L.MENU_UNLINK            = "Nachbarn trennen"

------------------------------------------------------------
-- Dialogs
------------------------------------------------------------
L.DLG_JUMP_BODY = "Du bist auf einen bereits vorhandenen Raum auf der Karte gestoßen.\nIst das derselbe Raum, den du betreten wolltest?"
L.DLG_JUMP_YES  = "Ja, verknüpft lassen"
L.DLG_JUMP_NO   = "Nein, zu neuem Raum springen"
L.CHK_AUTO_KEEP_LINKED = "Für diese Sitzung nicht mehr fragen"
L.TIP_AUTO_KEEP_LINKED = "Diesen Dialog für den Rest der Sitzung überspringen und immer annehmen, dass es derselbe Raum ist (bei Fehlern: rückgängig machen/trennen)"

L.DLG_RESET_TITLE = "Karte löschen?"
L.DLG_RESET_BODY  = "Dadurch wird deine gesamte Karte dauerhaft gelöscht.\nBist du sicher?"
L.DLG_RESET_YES   = "Ja, löschen"
L.DLG_RESET_NO    = "Abbrechen"

L.DLG_HELP_TITLE = "— Hilfe"

L.DLG_HELP_H_NAVIGATE = "Wie navigiere ich auf der Karte?"
L.DLG_HELP_B_NAVIGATE = "Ziehe mit der rechten Maustaste an einer beliebigen Stelle der Karte, um die Ansicht zu verschieben."

L.DLG_HELP_H_MARKING = "Wie markiere ich Wände und Punkte von Interesse?"
L.DLG_HELP_B_MARKING = "Klicke auf die MITTE eines Raums, um ihn auszuwählen (ein Ring erscheint).\n"
    .. "Klicke auf einen RAND eines Raums, um diese Wand umzuschalten.\n"
    .. "Klicke auf einen farbigen Rune/Kugel-Knopf im rechten Panel, um den ausgewählten (oder aktuellen) Raum als diesen POI zu markieren."

L.DLG_HELP_H_TRAP = "Wie markiere ich die Teleport-Falle?"
L.DLG_HELP_B_TRAP = "Wenn du teleportiert wirst, klicke sofort auf 'Ich wurde teleportiert!'. Der Fallenraum wird orange."

L.DLG_HELP_H_LOGOUT = "Was passiert nach einem Logout oder Absturz?"
L.DLG_HELP_B_LOGOUT = "Normaler Logout (20-Sekunden-Timer): Du erscheinst wieder in Raum 1. Das Addon setzt deine Position automatisch zurück.\n"
    .. "Erzwungenes Beenden / Absturz / Verbindungsabbruch: Du kehrst zu deinem letzten Raum im Labyrinth zurück. Gehe zurück zu einem bekannten Raum und benutze 'Position setzen', um deine Position zu korrigieren.\n"
    .. "Das Labyrinth wird einmal täglich etwa um Mitternacht (Realm-Zeit) neu generiert (nicht beim Dungeon-Reset) — ein kurzer Relog behält dasselbe Labyrinth, aber beende deinen Lauf, bevor der Tag wechselt."

L.DLG_HELP_H_TIPS = "Tipps zum Lösen des Labyrinths"
L.DLG_HELP_B_TIPS = "• Lösche Runen NICHT zu früh — sie sind wichtige Orientierungspunkte für die Navigation.\n"
    .. "• Nutze die Navigation, um zuerst unerforschte Räume zu erreichen.\n"
    .. "• Die Teleport-Falle ist orange markiert — die Navigation vermeidet, durch sie hindurchzuführen."

------------------------------------------------------------
-- Chat/print messages
------------------------------------------------------------
L.MSG_ALL_POIS_MARKED = "|cff00ff00Alle 5 Runen und 5 Kugeln wurden markiert!|r Du kannst jetzt beginnen, Kugeln mit Runen zu verbinden."
L.MSG_ARRIVED         = "du kommst an!"
L.MSG_GO_DIRECTION_THEN = "Gehe nach %s, dann "

L.MSG_CANNOT_DELETE_ENTRANCE  = "Der Eingangsraum (Raum 1) kann nicht gelöscht werden."
L.MSG_CANNOT_DELETE_ONLY_ROOM = "Der einzige Raum auf der Karte kann nicht gelöscht werden."

L.MSG_CHECKPOINTS_HEADER   = "LucidNav-Kontrollpunkte:"
L.MSG_CHECKPOINT_DELETED   = "Kontrollpunkt gelöscht: %s"
L.MSG_CHECKPOINT_NOT_FOUND = "Es gibt keinen Kontrollpunkt namens '%s'."
L.MSG_CHECKPOINT_RESTORED  = "Kontrollpunkt wiederhergestellt: %s"
L.MSG_CHECKPOINT_SAVED     = "Kontrollpunkt gespeichert: %s"
L.MSG_NO_CHECKPOINTS       = "Keine Kontrollpunkte gespeichert."
L.MSG_NO_CHECKPOINTS_YET   = "Noch keine Kontrollpunkte gespeichert. Klicke zuerst auf Speichern."

L.MSG_CPU_PROFILING_OFF  = "CPU-Profiling ist DEAKTIVIERT. Zum Aktivieren: |cffffff00/console scriptProfile 1|r und dann /reload."
L.MSG_DEBUG_OFF          = "Debug DEAKTIVIERT — Abschlussbericht:"
L.MSG_DEBUG_ON           = "Debug AKTIVIERT — Live-Ereignisprotokoll + ein Bericht alle %d Sekunden. Führe |cffffff00/ln debug|r erneut aus, um zu stoppen und einen vollständigen Bericht auszugeben."
L.MSG_DEBUG_STATS_HEADER = "Sitzungsstatistik:"

L.MSG_DEDUP_SKIPPED_TRAP = "Kartendeduplizierung übersprungen: einer der Räume ist der Teleport-Fallenraum."

L.MSG_DESTINATION_STEPS  = "Ich habe dein Ziel (%s) %d Schritte von hier entfernt entdeckt!"
L.MSG_UNEXPLORED_STEPS   = "Ich habe einen unerforschten Raum %d Schritte von hier entfernt entdeckt!"
L.MSG_NO_ROUTE           = "Es wurde keine Route vom aktuellen Raum zum Ziel gefunden; erkunde weiter, bis du einen bekannten POI erreichst, um dich wieder mit dem Rest der Karte zu verbinden"
L.MSG_NO_UNEXPLORED      = "Seltsam, laut diesem hast du kein unerforschtes Gebiet mehr.."
L.MSG_TARGET_NOT_DISCOVERED = "Dieses Ziel wurde noch nicht entdeckt. Navigiere zum nächstgelegenen unerforschten Gebiet"

L.MSG_EHH_EXPORTED      = "Routen exportiert. STRG+A, STRG+C zum Kopieren, dann bei nightswimmer.github.io/EndlessHalls einfügen"
L.MSG_EHH_NEED_2_POIS   = "Fehler: es müssen mindestens 2 POIs markiert sein, um zu EndlessHallsHelper zu exportieren"
L.MSG_EHH_NO_UNEXPLORED = "Fehler, EHH kümmert sich nicht um unerforschte Räume"

L.MSG_FOUND_SAVED_MAP = "Eine gespeicherte Karte von %s gefunden. Wird geladen..."
L.MSG_NO_SAVED_MAP    = "Keine gespeicherte Karte gefunden. Beginne neu."
L.MSG_MAP_CLEARED     = "Karte gelöscht. Beginne neu."
L.MSG_STARTUP_TIP     = "Ziehe mit der rechten Maustaste, um die Karte zu verschieben. Klicke auf die Mitte eines Raums, um ihn auszuwählen. Klicke auf einen Rand, um eine Wand umzuschalten."

L.MSG_LOAD_SAME_ROOM_WARNING = "WARNUNG! Du musst die Karte aus demselben Raum laden, in dem du dich beim Speichern befandest"
L.MSG_LOADING_MAP            = "Lade diese Karte:"

L.MSG_MENU_UNAVAILABLE = "Das Kontextmenü ist auf diesem Client nicht verfügbar."

L.MSG_POI_ALREADY_DEFINED = "VORSICHT, VORSICHT, VORSICHT! Dieser Punkt von Interesse wurde bereits als Raum %d definiert! Klicke erneut, um eine Schleife auf der Karte zu bestätigen und die Knoten zu deduplizieren"
L.MSG_POI_UNREACHABLE     = "%s (Raum %d) ist von hier aus nicht mehr erreichbar — möglicherweise hast du ihn mit einer Wand abgeriegelt."
L.MSG_ROOM_MISSING_NEIGHBOR = "Fehler: Raum %d verweist auf Raum %d, der nicht existiert"
L.MSG_SELECT_ROOM_FIRST   = "Wähle zuerst einen Raum aus (klicke auf seine Mitte)."

L.MSG_TRAP_ENTRANCE_UNKNOWN = "Warnung: der Eingang des Fallenraums konnte nicht identifiziert werden. Erstelle einen neuen Raum für die aktuelle Position."
L.MSG_TRAP_EXIT_WALLED      = "Raum %d hat seinen Ausgang im %s mit einer Wand versperrt."
L.MSG_TRAP_MARKED           = "Raum %d wurde als Teleport-Fallenraum markiert (orange auf der Karte)."
L.MSG_TRAP_NOT_IDENTIFIED   = "Die Teleport-Falle wurde noch nicht identifiziert."
L.MSG_TRAP_NO_MOVEMENT      = "Die Falle kann nicht verarbeitet werden: es wurde noch keine Bewegung erfasst. Lauf zuerst ein Stück."

L.MSG_UNDO_DID  = "Rückgängig gemacht: %s"
L.MSG_UNDO_NONE = "Nichts rückgängig zu machen."

-- Undo snapshot labels (echoed back via MSG_UNDO_DID)
L.MSG_LABEL_ACTION      = "Aktion"
L.MSG_LABEL_CLEAR_TRAP  = "Falle entfernen"
L.MSG_LABEL_DEDUP       = "Deduplizierung"
L.MSG_LABEL_DELETE_ROOM = "Raum löschen"
L.MSG_LABEL_DETACH      = "Trennen"
L.MSG_LABEL_JUMP_OVER   = "Sprung"
L.MSG_LABEL_MAP_ROOM    = "Kartenraum"
L.MSG_LABEL_PRE_RESTORE = "Vor Wiederherstellung"
L.MSG_LABEL_RESET       = "Zurücksetzen"
L.MSG_LABEL_TRAP        = "Falle"
L.MSG_LABEL_UNLINK      = "Trennen: %s"

------------------------------------------------------------
-- Debug/audit (Core/Debug.lua, AuditMap/AuditWrap)
------------------------------------------------------------
L.STAT_ROOMS_DISCOVERED    = "Entdeckte Räume"
L.STAT_POIS_SET            = "Markierte POIs"
L.STAT_TRAPS_MARKED        = "Markierte Fallen"
L.STAT_DEDUPS              = "Durchgeführte Deduplizierungen"
L.STAT_DEDUP_ROOMS_REMOVED = "  durch Deduplizierung entfernte Räume"
L.STAT_DEDUP_SKIPPED_TRAP  = "Übersprungene Deduplizierungen (Fallenraum)"
L.STAT_JUMPS               = "Sprünge (neuer Raum gewählt)"
L.STAT_KEEP_LINKED         = "Verknüpft belassen (bestehender gewählt)"
L.STAT_WALL_TOGGLES        = "Umgeschaltete Wände"
L.STAT_ROOMS_DELETED       = "Gelöschte Räume"
L.STAT_POI_CONFLICTS       = "Gemeldete POI-Konflikte"
L.STAT_NAV_NO_ROUTE        = "Navigation: keine Route gefunden"

L.AUDIT_CLEAN            = "%s: einwandfrei"
L.AUDIT_ISSUES_SUMMARY   = "%s: %d Problem(e)"
L.AUDIT_ORPHANED          = "Raum %d ist isoliert (keine Nachbarn)."
L.AUDIT_DANGLING_NEIGHBOR = "Raum %d verweist im %s auf einen Raum, der nicht mehr auf der Karte ist."
L.AUDIT_ASYMMETRIC_LINK   = "Asymmetrische Verknüpfung: Raum %d verweist im %s auf Raum %d, aber es gibt keine Rückverknüpfung."
L.AUDIT_WALL_MISMATCH     = "Wanddiskrepanz zwischen Raum %d und %d (Seite %s)."
L.AUDIT_CANVAS_OVERLAP    = "Überlappung auf der Karte in Zelle %s: Räume %s."
L.AUDIT_WRAP_MISMATCH     = "%s %s-> Raum %d: das Modell sagt %s vorher, aber Raum %d befindet sich bei %s."
