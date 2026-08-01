local addonName, ns = ...

------------------------------------------------------------
-- Spanish overrides. One neutral table serves both esES (Spain) and esMX
-- (Latin America) -- avoids "vosotros", keeps register usable in either
-- region. Only overwrites translated keys; ns.L itself is never reassigned
-- (that would drop every un-overridden English key from enUS.lua).
--
-- First-draft, Claude-authored translation (no native-speaker review pass) --
-- refinable over time via issues/PRs, same as any addon localization.
------------------------------------------------------------
local loc = GetLocale()
if loc ~= "esES" and loc ~= "esMX" then return end

local L = ns.L

L.DIR_NORTH = "Norte"
L.DIR_EAST  = "Este"
L.DIR_SOUTH = "Sur"
L.DIR_WEST  = "Oeste"
L.COLOR_YELLOW = "Amarillo"
L.COLOR_BLUE   = "Azul"
L.COLOR_RED    = "Rojo"
L.COLOR_GREEN  = "Verde"
L.COLOR_PURPLE = "Morado"
-- Fully-inflected short names ("Runa Amarilla", "Orbe Amarillo"): Spanish
-- puts the color adjective after the noun (reverse of English "Yellow
-- Rune") and it must agree in gender with "Runa" (fem.) vs "Orbe" (masc.),
-- so a single %s template can't serve both -- hence one array per POI type
-- instead of POI_NAME_RUNE/POI_NAME_ORB + L.COLOR.
L.POI_RUNE_NAMES = { "Runa Amarilla", "Runa Azul", "Runa Roja", "Runa Verde", "Runa Morada" }
L.POI_ORB_NAMES  = { "Orbe Amarillo", "Orbe Azul", "Orbe Rojo", "Orbe Verde", "Orbe Morado" }

------------------------------------------------------------
-- Buttons
------------------------------------------------------------
L.BTN_CLEAR          = "Limpiar"
L.BTN_CLICK_AGAIN    = "¡Haz clic de nuevo!"
L.BTN_GOT_PORTED     = "¡Me han teletransportado!"
L.BTN_GRID_MAP       = "Mapa de cuadrícula"
L.BTN_NEW_MAP        = "Mapa nuevo"
L.BTN_RESTORE        = "Restaurar"
L.BTN_SAVE           = "Guardar"
L.BTN_SET_PLAYER_LOC = "Fijar ubicación"
L.BTN_TRACK          = "Seguimiento"

------------------------------------------------------------
-- Static labels
------------------------------------------------------------
L.LBL_CURRENT                = "Actual:"
L.LBL_CURRENT_ROOM           = "Sala actual"
L.LBL_HERE                   = "(aquí)"
L.LBL_MAP_AUDIT              = "Auditoría del mapa"
L.LBL_MARKERS                = "Marcadores"
L.LBL_NAV_TARGET             = "Objetivo de navegación:"
L.LBL_NONE                   = "Ninguna"
L.LBL_OPACITY                = "Opacidad"
L.LBL_SELECTED               = "Seleccionada:"
L.LBL_TELEPORT_TRAP          = "Trampa de teletransporte"
L.LBL_UNEXPLORED_ROOM_PREFIX = "Sala sin explorar: "
L.LBL_UNEXPLORED_TERRITORY   = "Territorio sin explorar"
L.LBL_WRAP_AUDIT             = "Auditoría de bordes"
L.LBL_X                      = "X:"
L.LBL_Y                      = "Y:"

------------------------------------------------------------
-- Tooltips
------------------------------------------------------------
L.TIP_CENTER_CAMERA  = "Centrar la cámara en la sala actual"
L.TIP_CLEAR_POI      = "Quitar el marcador de PDI de la sala seleccionada/actual"
L.TIP_EDGE_WRAP      = "Borde envolvente"
L.TIP_ERASE_MAP      = "Borrar el mapa y empezar de nuevo"
L.TIP_GOT_PORTED     = "Marcar la sala actual como la sala trampa de teletransporte"
L.TIP_HELP           = "Ayuda — cómo usar el addon"
L.TIP_SET_PLAYER_LOC = "Mover la posición del jugador a la sala seleccionada"
L.TIP_TOGGLE_MATCH   = "Marcar el par %s como emparejado/sin emparejar"
L.TIP_TOGGLE_WALL    = "Muro %s"
L.TIP_UNDO           = "Deshacer la última acción"

------------------------------------------------------------
-- Right-click context menu
------------------------------------------------------------
L.MENU_CHECKPOINTS       = "Puntos de control"
L.MENU_CHECKPOINT_ENTRY  = "%s  (%s)"
L.MENU_CLEAR_TRAP        = "Quitar trampa"
L.MENU_DELETE            = "Eliminar sala"
L.MENU_DELETE_CHECKPOINT = "Eliminar"
L.MENU_DETACH            = "Desvincular (quitar todos los vecinos)"
L.MENU_RESTORE           = "Restaurar"
L.MENU_ROOM_TITLE        = "Sala %d"
L.MENU_SET_CURRENT       = "Establecer como sala actual"
L.MENU_UNDO              = "Deshacer última acción"
L.MENU_UNLINK            = "Desvincular vecino"

------------------------------------------------------------
-- Dialogs
------------------------------------------------------------
L.DLG_JUMP_BODY = "Has llegado a una sala que ya existe en el mapa.\n¿Es esta la misma sala a la que esperabas entrar?"
L.DLG_JUMP_YES  = "Sí, mantener vinculada"
L.DLG_JUMP_NO   = "No, saltar a otra"
L.CHK_AUTO_KEEP_LINKED = "No preguntar más esta sesión"
L.TIP_AUTO_KEEP_LINKED = "Omite este cuadro el resto de la sesión y asume siempre que es la misma sala (usa deshacer/desvincular si se equivoca)"

L.DLG_RESET_TITLE = "¿Borrar mapa?"
L.DLG_RESET_BODY  = "Esto borrará permanentemente todo tu mapa.\n¿Estás seguro?"
L.DLG_RESET_YES   = "Sí, bórralo"
L.DLG_RESET_NO    = "Cancelar"

L.DLG_HELP_TITLE = "— Ayuda"

L.DLG_HELP_H_NAVIGATE = "¿Cómo navego por el mapa?"
L.DLG_HELP_B_NAVIGATE = "Arrastra con el botón derecho en cualquier parte del mapa para desplazar la vista."

L.DLG_HELP_H_MARKING = "¿Cómo marco muros y puntos de interés?"
L.DLG_HELP_B_MARKING = "Haz clic en el CENTRO de una sala para seleccionarla (aparece un anillo).\n"
    .. "Haz clic en un BORDE de una sala para alternar ese muro.\n"
    .. "Haz clic en un botón de Runa/Orbe de color en el panel derecho para marcar la sala seleccionada (o actual) con ese PDI."

L.DLG_HELP_H_TRAP = "¿Cómo marco la trampa de teletransporte?"
L.DLG_HELP_B_TRAP = "Cuando te teletransporten, haz clic de inmediato en '¡Me han teletransportado!'. La sala trampa se vuelve naranja."

L.DLG_HELP_H_LOGOUT = "¿Qué ocurre después de cerrar sesión o un cierre inesperado?"
L.DLG_HELP_B_LOGOUT = "Cierre de sesión normal (temporizador de 20 segundos): reapareces en la Sala 1. El addon restablece tu posición automáticamente.\n"
    .. "Cierre forzado / fallo del juego / desconexión: vuelves a tu última sala del laberinto. Camina de regreso a una sala conocida y usa 'Fijar ubicación' para corregir tu posición.\n"
    .. "El laberinto se regenera una vez al día, aproximadamente a la medianoche del reino (no con el reinicio de mazmorras) — un relog rápido conserva el mismo laberinto, pero termina tu partida antes de que cambie el día."

L.DLG_HELP_H_TIPS = "Consejos para resolver el laberinto"
L.DLG_HELP_B_TIPS = "• NO apagues las runas antes de tiempo — son puntos de referencia esenciales para la navegación.\n"
    .. "• Usa la navegación para llegar primero a las salas sin explorar.\n"
    .. "• La trampa de teletransporte está marcada en naranja — la navegación evita pasar por ella."

------------------------------------------------------------
-- Chat/print messages
------------------------------------------------------------
L.MSG_ALL_POIS_MARKED = "|cff00ff00¡Se han marcado las 5 runas y los 5 orbes!|r Ya puedes empezar a emparejar orbes con runas."
L.MSG_ARRIVED         = "¡llegarás!"
L.MSG_GO_DIRECTION_THEN = "Ve al %s, luego "

L.MSG_CANNOT_DELETE_ENTRANCE  = "No se puede eliminar la sala de entrada (Sala 1)."
L.MSG_CANNOT_DELETE_ONLY_ROOM = "No se puede eliminar la única sala del mapa."

L.MSG_CHECKPOINTS_HEADER   = "Puntos de control de LucidNav:"
L.MSG_CHECKPOINT_DELETED   = "Punto de control eliminado: %s"
L.MSG_CHECKPOINT_NOT_FOUND = "No existe ningún punto de control llamado '%s'."
L.MSG_CHECKPOINT_RESTORED  = "Punto de control restaurado: %s"
L.MSG_CHECKPOINT_SAVED     = "Punto de control guardado: %s"
L.MSG_NO_CHECKPOINTS       = "No hay puntos de control guardados."
L.MSG_NO_CHECKPOINTS_YET   = "Todavía no hay puntos de control guardados. Haz clic en Guardar primero."

L.MSG_CPU_PROFILING_OFF  = "La perfilación de CPU está DESACTIVADA. Para activarla: |cffffff00/console scriptProfile 1|r y luego /reload."
L.MSG_DEBUG_OFF          = "depuración DESACTIVADA — resumen final:"
L.MSG_DEBUG_ON           = "depuración ACTIVADA — registro de eventos en vivo + un informe cada %d s. Ejecuta |cffffff00/ln debug|r de nuevo para detenerla e imprimir un resumen completo."
L.MSG_DEBUG_STATS_HEADER = "estadísticas de la sesión:"

L.MSG_DEDUP_SKIPPED_TRAP = "Omitiendo la deduplicación del mapa: una de las salas es la sala trampa de teletransporte."

L.MSG_DESTINATION_STEPS  = "¡He detectado tu destino (%s) a %d pasos de aquí!"
L.MSG_UNEXPLORED_STEPS   = "¡He detectado una sala sin explorar a %d pasos de aquí!"
L.MSG_NO_ROUTE           = "No se encontró una ruta desde la sala actual hasta el objetivo; sigue explorando hasta llegar a un PDI conocido para reconectarte con el resto del mapa"
L.MSG_NO_UNEXPLORED      = "Qué raro, según esto no tienes territorio sin explorar.."
L.MSG_TARGET_NOT_DISCOVERED = "Ese objetivo aún no ha sido descubierto. Navegando hacia el territorio sin explorar más cercano"

L.MSG_EHH_EXPORTED      = "Rutas exportadas. CTRL+A, CTRL+C para copiar y luego pegar en nightswimmer.github.io/EndlessHalls"
L.MSG_EHH_NEED_2_POIS   = "Error: se necesitan al menos 2 PDI marcados para exportar a EndlessHallsHelper"
L.MSG_EHH_NO_UNEXPLORED = "Error, EHH no tiene en cuenta las salas sin explorar"

L.MSG_FOUND_SAVED_MAP = "Se encontró un mapa guardado de %s. Cargándolo..."
L.MSG_NO_SAVED_MAP    = "No se encontró ningún mapa guardado. Empezando de nuevo."
L.MSG_MAP_CLEARED     = "Mapa borrado. Empezando de nuevo."
L.MSG_STARTUP_TIP     = "Arrastra con el botón derecho para desplazar el mapa. Haz clic en el centro de una sala para seleccionarla. Haz clic en un borde para alternar un muro."

L.MSG_LOAD_SAME_ROOM_WARNING = "¡ADVERTENCIA! Debes cargar el mapa desde la misma sala en la que estabas cuando lo guardaste"
L.MSG_LOADING_MAP            = "Cargando este mapa:"

L.MSG_MENU_UNAVAILABLE = "El menú contextual no está disponible en este cliente."

L.MSG_POI_ALREADY_DEFINED = "¡CUIDADO, CUIDADO, CUIDADO! Este punto de interés ya estaba definido como la sala %d. Haz clic de nuevo para confirmar un bucle en el mapa y deduplicar los nodos"
L.MSG_POI_UNREACHABLE     = "%s (sala %d) ya no es alcanzable desde aquí — puede que la hayas dejado aislada con un muro."
L.MSG_ROOM_MISSING_NEIGHBOR = "Error: la sala %d hace referencia a la sala %d, que no existe"
L.MSG_SELECT_ROOM_FIRST   = "Selecciona primero una sala (haz clic en su centro)."

L.MSG_TRAP_ENTRANCE_UNKNOWN = "Advertencia: no se pudo identificar la entrada de la sala trampa. Creando una sala nueva para la posición actual."
L.MSG_TRAP_EXIT_WALLED      = "La sala %d ha bloqueado con un muro su salida hacia el %s."
L.MSG_TRAP_MARKED           = "La sala %d se ha marcado como la sala trampa de teletransporte (naranja en el mapa)."
L.MSG_TRAP_NOT_IDENTIFIED   = "Todavía no se ha identificado la trampa de teletransporte."
L.MSG_TRAP_NO_MOVEMENT      = "No se puede procesar la trampa: aún no se ha registrado movimiento. Camina primero."

L.MSG_UNDO_DID  = "Deshecho: %s"
L.MSG_UNDO_NONE = "No hay nada que deshacer."

-- Undo snapshot labels (echoed back via MSG_UNDO_DID)
L.MSG_LABEL_ACTION      = "acción"
L.MSG_LABEL_CLEAR_TRAP  = "Quitar trampa"
L.MSG_LABEL_DEDUP       = "Deduplicación"
L.MSG_LABEL_DELETE_ROOM = "Eliminar sala"
L.MSG_LABEL_DETACH      = "Desvincular"
L.MSG_LABEL_JUMP_OVER   = "Saltar a otra"
L.MSG_LABEL_MAP_ROOM    = "Sala del mapa"
L.MSG_LABEL_PRE_RESTORE = "Antes de restaurar"
L.MSG_LABEL_RESET       = "Reinicio"
L.MSG_LABEL_TRAP        = "Trampa"
L.MSG_LABEL_UNLINK      = "Desvincular %s"

------------------------------------------------------------
-- Debug/audit (Core/Debug.lua, AuditMap/AuditWrap)
------------------------------------------------------------
L.STAT_ROOMS_DISCOVERED    = "Salas descubiertas"
L.STAT_POIS_SET            = "PDI marcados"
L.STAT_TRAPS_MARKED        = "Trampas marcadas"
L.STAT_DEDUPS              = "Deduplicaciones realizadas"
L.STAT_DEDUP_ROOMS_REMOVED = "  salas eliminadas por deduplicación"
L.STAT_DEDUP_SKIPPED_TRAP  = "Deduplicaciones omitidas (sala trampa)"
L.STAT_JUMPS               = "Saltos (se eligió una sala nueva)"
L.STAT_KEEP_LINKED         = "Mantenidas vinculadas (se eligió la existente)"
L.STAT_WALL_TOGGLES        = "Muros alternados"
L.STAT_ROOMS_DELETED       = "Salas eliminadas"
L.STAT_POI_CONFLICTS       = "Conflictos de PDI avisados"
L.STAT_NAV_NO_ROUTE        = "Navegación: no se encontró ruta"

L.AUDIT_CLEAN            = "%s: sin problemas"
L.AUDIT_ISSUES_SUMMARY   = "%s: %d problema(s)"
L.AUDIT_ORPHANED          = "La sala %d está aislada (sin vecinos)."
L.AUDIT_DANGLING_NEIGHBOR = "La sala %d apunta hacia el %s a una sala que ya no está en el mapa."
L.AUDIT_ASYMMETRIC_LINK   = "Enlace asimétrico: la sala %d apunta al %s hacia la sala %d, pero no hay enlace de vuelta."
L.AUDIT_WALL_MISMATCH     = "Discrepancia de muro entre las salas %d y %d (lado %s)."
L.AUDIT_CANVAS_OVERLAP    = "Solapamiento de lienzo en la celda %s: salas %s."
L.AUDIT_WRAP_MISMATCH     = "%s %s-> sala %d: el modelo predice %s, pero la sala %d está en %s."
