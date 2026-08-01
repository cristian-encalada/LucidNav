local addonName, ns = ...

------------------------------------------------------------
-- Portuguese (Brazil) overrides. Only overwrites translated keys; ns.L
-- itself is never reassigned (that would drop every un-overridden English
-- key from enUS.lua).
--
-- First-draft, Claude-authored translation (no native-speaker review pass) --
-- refinable over time via issues/PRs, same as any addon localization.
------------------------------------------------------------
if GetLocale() ~= "ptBR" then return end

local L = ns.L

L.DIR_NORTH = "Norte"
L.DIR_EAST  = "Leste"
L.DIR_SOUTH = "Sul"
L.DIR_WEST  = "Oeste"
L.COLOR_YELLOW = "Amarelo"
L.COLOR_BLUE   = "Azul"
L.COLOR_RED    = "Vermelho"
L.COLOR_GREEN  = "Verde"
L.COLOR_PURPLE = "Roxo"
-- Fully-inflected short names ("Runa Amarela", "Orbe Amarelo"): Portuguese
-- puts the color adjective after the noun (reverse of English "Yellow
-- Rune") and it must agree in gender with "Runa" (fem.) vs "Orbe" (masc.),
-- so a single %s template can't serve both -- hence one array per POI type
-- instead of POI_NAME_RUNE/POI_NAME_ORB + L.COLOR.
L.POI_RUNE_NAMES = { "Runa Amarela", "Runa Azul", "Runa Vermelha", "Runa Verde", "Runa Roxa" }
L.POI_ORB_NAMES  = { "Orbe Amarelo", "Orbe Azul", "Orbe Vermelho", "Orbe Verde", "Orbe Roxo" }

------------------------------------------------------------
-- Buttons
------------------------------------------------------------
L.BTN_CLEAR          = "Limpar"
L.BTN_CLICK_AGAIN    = "Clique novamente!"
L.BTN_GOT_PORTED     = "Fui teletransportado!"
L.BTN_GRID_MAP       = "Mapa de grade"
L.BTN_NEW_MAP        = "Novo mapa"
L.BTN_RESTORE        = "Restaurar"
L.BTN_SAVE           = "Salvar"
L.BTN_SET_PLAYER_LOC = "Definir localização"
L.BTN_TRACK          = "Rastrear"

------------------------------------------------------------
-- Static labels
------------------------------------------------------------
L.LBL_CURRENT                = "Atual:"
L.LBL_CURRENT_ROOM           = "Sala atual"
L.LBL_HERE                   = "(aqui)"
L.LBL_MAP_AUDIT              = "Auditoria do mapa"
L.LBL_MARKERS                = "Marcadores"
L.LBL_NAV_TARGET             = "Alvo de navegação:"
L.LBL_NONE                   = "Nenhuma"
L.LBL_OPACITY                = "Opacidade"
L.LBL_SELECTED               = "Selecionada:"
L.LBL_TELEPORT_TRAP          = "Armadilha de teletransporte"
L.LBL_UNEXPLORED_ROOM_PREFIX = "Sala inexplorada: "
L.LBL_UNEXPLORED_TERRITORY   = "Território inexplorado"
L.LBL_WRAP_AUDIT             = "Auditoria de bordas"
L.LBL_X                      = "X:"
L.LBL_Y                      = "Y:"

------------------------------------------------------------
-- Tooltips
------------------------------------------------------------
L.TIP_CENTER_CAMERA  = "Centralizar a câmera na sala atual"
L.TIP_CLEAR_POI      = "Remover o marcador de PDI da sala selecionada/atual"
L.TIP_EDGE_WRAP      = "Borda de repetição"
L.TIP_ERASE_MAP      = "Apagar o mapa e recomeçar"
L.TIP_GOT_PORTED     = "Marcar a sala atual como a sala armadilha de teletransporte"
L.TIP_HELP           = "Ajuda — como usar o addon"
L.TIP_SET_PLAYER_LOC = "Mover a posição do jogador para a sala selecionada"
L.TIP_TOGGLE_MATCH   = "Marcar o par %s como combinado/não combinado"
L.TIP_TOGGLE_WALL    = "Parede %s"
L.TIP_UNDO           = "Desfazer a última ação"

------------------------------------------------------------
-- Right-click context menu
------------------------------------------------------------
L.MENU_CHECKPOINTS       = "Pontos de controle"
L.MENU_CHECKPOINT_ENTRY  = "%s  (%s)"
L.MENU_CLEAR_TRAP        = "Remover armadilha"
L.MENU_DELETE            = "Excluir sala"
L.MENU_DELETE_CHECKPOINT = "Excluir"
L.MENU_DETACH            = "Desvincular (remover todos os vizinhos)"
L.MENU_RESTORE           = "Restaurar"
L.MENU_ROOM_TITLE        = "Sala %d"
L.MENU_SET_CURRENT       = "Definir como sala atual"
L.MENU_UNDO              = "Desfazer última ação"
L.MENU_UNLINK            = "Desvincular vizinho"

------------------------------------------------------------
-- Dialogs
------------------------------------------------------------
L.DLG_JUMP_BODY = "Você encontrou uma sala que já existe no mapa.\nEssa é a mesma sala em que você esperava entrar?"
L.DLG_JUMP_YES  = "Sim, manter vinculada"
L.DLG_JUMP_NO   = "Não, pular para outra"
L.CHK_AUTO_KEEP_LINKED = "Não perguntar mais nesta sessão"
L.TIP_AUTO_KEEP_LINKED = "Pula esta janela pelo resto da sessão e sempre assume que é a mesma sala (use desfazer/desvincular se errar)"

L.DLG_RESET_TITLE = "Apagar mapa?"
L.DLG_RESET_BODY  = "Isso apagará permanentemente todo o seu mapa.\nTem certeza?"
L.DLG_RESET_YES   = "Sim, apagar"
L.DLG_RESET_NO    = "Cancelar"

L.DLG_HELP_TITLE = "— Ajuda"

L.DLG_HELP_H_NAVIGATE = "Como eu navego pelo mapa?"
L.DLG_HELP_B_NAVIGATE = "Arraste com o botão direito em qualquer lugar do mapa para movimentar a visualização."

L.DLG_HELP_H_MARKING = "Como eu marco paredes e pontos de interesse?"
L.DLG_HELP_B_MARKING = "Clique no CENTRO de uma sala para selecioná-la (um anel aparece).\n"
    .. "Clique em uma BORDA de uma sala para alternar essa parede.\n"
    .. "Clique em um botão de Runa/Orbe colorido no painel direito para marcar a sala selecionada (ou atual) com esse PDI."

L.DLG_HELP_H_TRAP = "Como eu marco a armadilha de teletransporte?"
L.DLG_HELP_B_TRAP = "Quando você for teletransportado, clique imediatamente em 'Fui teletransportado!'. A sala armadilha fica laranja."

L.DLG_HELP_H_LOGOUT = "O que acontece depois de sair do jogo ou de uma queda?"
L.DLG_HELP_B_LOGOUT = "Logout normal (temporizador de 20 segundos): você reaparece na Sala 1. O addon redefine sua posição automaticamente.\n"
    .. "Fechamento forçado / queda do jogo / desconexão: você retorna à última sala do labirinto. Caminhe de volta a uma sala conhecida e use 'Definir localização' para corrigir sua posição.\n"
    .. "O labirinto é regenerado uma vez por dia, por volta da meia-noite do reino (não no reset de masmorras) — um relog rápido mantém o mesmo labirinto, mas termine sua run antes da virada do dia."

L.DLG_HELP_H_TIPS = "Dicas para resolver o labirinto"
L.DLG_HELP_B_TIPS = "• NÃO apague as runas antes da hora — elas são pontos de referência essenciais para a navegação.\n"
    .. "• Use a navegação para chegar primeiro às salas inexploradas.\n"
    .. "• A armadilha de teletransporte é marcada em laranja — a navegação evita passar por ela."

------------------------------------------------------------
-- Chat/print messages
------------------------------------------------------------
L.MSG_ALL_POIS_MARKED = "|cff00ff00Todas as 5 runas e os 5 orbes foram marcados!|r Agora você pode começar a combinar orbes com runas."
L.MSG_ARRIVED         = "você vai chegar!"
L.MSG_GO_DIRECTION_THEN = "Vá para %s, depois "

L.MSG_CANNOT_DELETE_ENTRANCE  = "Não é possível excluir a sala de entrada (Sala 1)."
L.MSG_CANNOT_DELETE_ONLY_ROOM = "Não é possível excluir a única sala do mapa."

L.MSG_CHECKPOINTS_HEADER   = "Pontos de controle do LucidNav:"
L.MSG_CHECKPOINT_DELETED   = "Ponto de controle excluído: %s"
L.MSG_CHECKPOINT_NOT_FOUND = "Não existe nenhum ponto de controle chamado '%s'."
L.MSG_CHECKPOINT_RESTORED  = "Ponto de controle restaurado: %s"
L.MSG_CHECKPOINT_SAVED     = "Ponto de controle salvo: %s"
L.MSG_NO_CHECKPOINTS       = "Nenhum ponto de controle salvo."
L.MSG_NO_CHECKPOINTS_YET   = "Ainda não há pontos de controle salvos. Clique em Salvar primeiro."

L.MSG_CPU_PROFILING_OFF  = "A análise de CPU está DESATIVADA. Para ativar: |cffffff00/console scriptProfile 1|r e depois /reload."
L.MSG_DEBUG_OFF          = "depuração DESATIVADA — resumo final:"
L.MSG_DEBUG_ON           = "depuração ATIVADA — registro de eventos ao vivo + um relatório a cada %d s. Execute |cffffff00/ln debug|r novamente para parar e imprimir um resumo completo."
L.MSG_DEBUG_STATS_HEADER = "estatísticas da sessão:"

L.MSG_DEDUP_SKIPPED_TRAP = "Pulando a deduplicação do mapa: uma das salas é a sala armadilha de teletransporte."

L.MSG_DESTINATION_STEPS  = "Detectei seu destino (%s) a %d passos daqui!"
L.MSG_UNEXPLORED_STEPS   = "Detectei uma sala inexplorada a %d passos daqui!"
L.MSG_NO_ROUTE           = "Não foi encontrada uma rota da sala atual até o alvo; continue explorando até alcançar um PDI conhecido para se reconectar ao resto do mapa"
L.MSG_NO_UNEXPLORED      = "Que estranho, segundo isso você não tem território inexplorado.."
L.MSG_TARGET_NOT_DISCOVERED = "Esse alvo ainda não foi descoberto. Navegando para o território inexplorado mais próximo"

L.MSG_EHH_EXPORTED      = "Rotas exportadas. CTRL+A, CTRL+C para copiar e depois colar em nightswimmer.github.io/EndlessHalls"
L.MSG_EHH_NEED_2_POIS   = "Erro: são necessários pelo menos 2 PDIs marcados para exportar para o EndlessHallsHelper"
L.MSG_EHH_NO_UNEXPLORED = "Erro, o EHH não se importa com salas inexploradas"

L.MSG_FOUND_SAVED_MAP = "Encontrado um mapa salvo de %s. Carregando..."
L.MSG_NO_SAVED_MAP    = "Nenhum mapa salvo encontrado. Começando do zero."
L.MSG_MAP_CLEARED     = "Mapa apagado. Começando do zero."
L.MSG_STARTUP_TIP     = "Arraste com o botão direito para movimentar o mapa. Clique no centro de uma sala para selecioná-la. Clique em uma borda para alternar uma parede."

L.MSG_LOAD_SAME_ROOM_WARNING = "AVISO! Você deve carregar o mapa a partir da mesma sala em que estava quando o salvou"
L.MSG_LOADING_MAP            = "Carregando este mapa:"

L.MSG_MENU_UNAVAILABLE = "O menu de contexto não está disponível neste cliente."

L.MSG_POI_ALREADY_DEFINED = "CALMA, CALMA, CALMA! Este ponto de interesse já estava definido como a sala %d! Clique novamente para confirmar um loop no mapa e deduplicar os nós"
L.MSG_POI_UNREACHABLE     = "%s (sala %d) não está mais acessível a partir daqui — você pode tê-la isolado com uma parede."
L.MSG_ROOM_MISSING_NEIGHBOR = "Erro: a sala %d faz referência à sala %d, que não existe"
L.MSG_SELECT_ROOM_FIRST   = "Selecione uma sala primeiro (clique no seu centro)."

L.MSG_TRAP_ENTRANCE_UNKNOWN = "Aviso: não foi possível identificar a entrada da sala armadilha. Criando uma nova sala para a posição atual."
L.MSG_TRAP_EXIT_WALLED      = "A sala %d bloqueou com uma parede sua saída para o %s."
L.MSG_TRAP_MARKED           = "A sala %d foi marcada como a sala armadilha de teletransporte (laranja no mapa)."
L.MSG_TRAP_NOT_IDENTIFIED   = "A armadilha de teletransporte ainda não foi identificada."
L.MSG_TRAP_NO_MOVEMENT      = "Não é possível processar a armadilha: nenhum movimento registrado ainda. Ande primeiro."

L.MSG_UNDO_DID  = "Desfeito: %s"
L.MSG_UNDO_NONE = "Nada para desfazer."

-- Undo snapshot labels (echoed back via MSG_UNDO_DID)
L.MSG_LABEL_ACTION      = "ação"
L.MSG_LABEL_CLEAR_TRAP  = "Remover armadilha"
L.MSG_LABEL_DEDUP       = "Deduplicação"
L.MSG_LABEL_DELETE_ROOM = "Excluir sala"
L.MSG_LABEL_DETACH      = "Desvincular"
L.MSG_LABEL_JUMP_OVER   = "Pular para outra"
L.MSG_LABEL_MAP_ROOM    = "Sala do mapa"
L.MSG_LABEL_PRE_RESTORE = "Antes de restaurar"
L.MSG_LABEL_RESET       = "Reinício"
L.MSG_LABEL_TRAP        = "Armadilha"
L.MSG_LABEL_UNLINK      = "Desvincular %s"

------------------------------------------------------------
-- Debug/audit (Core/Debug.lua, AuditMap/AuditWrap)
------------------------------------------------------------
L.STAT_ROOMS_DISCOVERED    = "Salas descobertas"
L.STAT_POIS_SET            = "PDIs marcados"
L.STAT_TRAPS_MARKED        = "Armadilhas marcadas"
L.STAT_DEDUPS              = "Deduplicações realizadas"
L.STAT_DEDUP_ROOMS_REMOVED = "  salas removidas por deduplicação"
L.STAT_DEDUP_SKIPPED_TRAP  = "Deduplicações puladas (sala armadilha)"
L.STAT_JUMPS               = "Saltos (sala nova escolhida)"
L.STAT_KEEP_LINKED         = "Mantidas vinculadas (existente escolhida)"
L.STAT_WALL_TOGGLES        = "Paredes alternadas"
L.STAT_ROOMS_DELETED       = "Salas excluídas"
L.STAT_POI_CONFLICTS       = "Conflitos de PDI avisados"
L.STAT_NAV_NO_ROUTE        = "Navegação: nenhuma rota encontrada"

L.AUDIT_CLEAN            = "%s: sem problemas"
L.AUDIT_ISSUES_SUMMARY   = "%s: %d problema(s)"
L.AUDIT_ORPHANED          = "A sala %d está isolada (sem vizinhos)."
L.AUDIT_DANGLING_NEIGHBOR = "A sala %d aponta para o %s, para uma sala que não está mais no mapa."
L.AUDIT_ASYMMETRIC_LINK   = "Link assimétrico: a sala %d aponta para o %s até a sala %d, mas não há link de volta."
L.AUDIT_WALL_MISMATCH     = "Incompatibilidade de parede entre as salas %d e %d (lado %s)."
L.AUDIT_CANVAS_OVERLAP    = "Sobreposição de tela na célula %s: salas %s."
L.AUDIT_WRAP_MISMATCH     = "%s %s-> sala %d: o modelo prevê %s, mas a sala %d está em %s."
