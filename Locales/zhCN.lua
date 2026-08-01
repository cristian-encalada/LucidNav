local addonName, ns = ...

------------------------------------------------------------
-- Simplified Chinese overrides. Only overwrites translated keys; ns.L
-- itself is never reassigned (that would drop every un-overridden English
-- key from enUS.lua). Traditional Chinese (zhTW) is out of scope -- zhTW
-- clients fall back to English.
--
-- First-draft, Claude-authored translation (no native-speaker review pass) --
-- refinable over time via issues/PRs, same as any addon localization.
------------------------------------------------------------
if GetLocale() ~= "zhCN" then return end

local L = ns.L

L.DIR_NORTH = "北"
L.DIR_EAST  = "东"
L.DIR_SOUTH = "南"
L.DIR_WEST  = "西"
L.COLOR_YELLOW = "黄色"
L.COLOR_BLUE   = "蓝色"
L.COLOR_RED    = "红色"
L.COLOR_GREEN  = "绿色"
L.COLOR_PURPLE = "紫色"
L.POI_NAME_RUNE = "%s符文"
L.POI_NAME_ORB  = "%s宝珠"

------------------------------------------------------------
-- Buttons
------------------------------------------------------------
L.BTN_CLEAR          = "清除"
L.BTN_CLICK_AGAIN    = "再次点击！"
L.BTN_GOT_PORTED     = "我被传送了！"
L.BTN_GRID_MAP       = "网格地图"
L.BTN_NEW_MAP        = "新地图"
L.BTN_RESTORE        = "恢复"
L.BTN_SAVE           = "保存"
L.BTN_SET_PLAYER_LOC = "设置位置"
L.BTN_TRACK          = "追踪"

------------------------------------------------------------
-- Static labels
------------------------------------------------------------
L.LBL_CURRENT                = "当前："
L.LBL_CURRENT_ROOM           = "当前房间"
L.LBL_HERE                   = "（此处）"
L.LBL_MAP_AUDIT              = "地图检查"
L.LBL_MARKERS                = "标记"
L.LBL_NAV_TARGET             = "导航目标："
L.LBL_NONE                   = "无"
L.LBL_OPACITY                = "不透明度"
L.LBL_SELECTED               = "已选择："
L.LBL_TELEPORT_TRAP          = "传送陷阱"
L.LBL_UNEXPLORED_ROOM_PREFIX = "未探索的房间："
L.LBL_UNEXPLORED_TERRITORY   = "未探索区域"
L.LBL_WRAP_AUDIT             = "环绕检查"
L.LBL_X                      = "X："
L.LBL_Y                      = "Y："

------------------------------------------------------------
-- Tooltips
------------------------------------------------------------
L.TIP_CENTER_CAMERA  = "将摄像机居中到当前房间"
L.TIP_CLEAR_POI      = "清除所选/当前房间的兴趣点标记"
L.TIP_EDGE_WRAP      = "边缘环绕"
L.TIP_ERASE_MAP      = "清除地图并重新开始"
L.TIP_GOT_PORTED     = "将当前房间标记为传送陷阱房间"
L.TIP_HELP           = "帮助 — 如何使用此插件"
L.TIP_SET_PLAYER_LOC = "将玩家位置移动到所选房间"
L.TIP_TOGGLE_MATCH   = "将%s一对标记为已配对/未配对"
L.TIP_TOGGLE_WALL    = "%s墙"
L.TIP_UNDO           = "撤销上一步操作"

------------------------------------------------------------
-- Right-click context menu
------------------------------------------------------------
L.MENU_CHECKPOINTS       = "检查点"
L.MENU_CHECKPOINT_ENTRY  = "%s（%s）"
L.MENU_CLEAR_TRAP        = "清除陷阱"
L.MENU_DELETE            = "删除房间"
L.MENU_DELETE_CHECKPOINT = "删除"
L.MENU_DETACH            = "断开连接（移除所有相邻房间）"
L.MENU_RESTORE           = "恢复"
L.MENU_ROOM_TITLE        = "房间 %d"
L.MENU_SET_CURRENT       = "设为当前房间"
L.MENU_UNDO              = "撤销上一步操作"
L.MENU_UNLINK            = "断开相邻房间连接"

------------------------------------------------------------
-- Dialogs
------------------------------------------------------------
L.DLG_JUMP_BODY = "你进入了地图上已存在的房间。\n这是你原本想进入的那个房间吗？"
L.DLG_JUMP_YES  = "是的，保持连接"
L.DLG_JUMP_NO   = "不，跳转到新房间"
L.CHK_AUTO_KEEP_LINKED = "本次会话不再询问"
L.TIP_AUTO_KEEP_LINKED = "本次会话跳过此对话框，始终假定是同一房间（如果猜错，用撤销/取消连接修正）"

L.DLG_RESET_TITLE = "清除地图？"
L.DLG_RESET_BODY  = "这将永久清除你的整个地图。\n你确定吗？"
L.DLG_RESET_YES   = "是的，清除它"
L.DLG_RESET_NO    = "取消"

L.DLG_HELP_TITLE = "— 帮助"

L.DLG_HELP_H_NAVIGATE = "我该如何在地图上导航？"
L.DLG_HELP_B_NAVIGATE = "在地图任意位置按住鼠标右键拖动即可平移视图。"

L.DLG_HELP_H_MARKING = "我该如何标记墙壁和兴趣点？"
L.DLG_HELP_B_MARKING = "点击房间的中心以选中它（会出现一个圆环）。\n"
    .. "点击房间的边缘以切换该墙壁。\n"
    .. "点击右侧面板上对应颜色的符文/宝珠按钮，将所选（或当前）房间标记为该兴趣点。"

L.DLG_HELP_H_TRAP = "我该如何标记传送陷阱？"
L.DLG_HELP_B_TRAP = "当你被传送时，立即点击『我被传送了！』。陷阱房间会变为橙色。"

L.DLG_HELP_H_LOGOUT = "下线或崩溃后会发生什么？"
L.DLG_HELP_B_LOGOUT = "正常下线（20秒计时器）：你会重新出现在1号房间，插件会自动重置你的位置。\n"
    .. "强制关闭/游戏崩溃/断线：你会返回到迷宫中最后所在的房间。请走回一个已知房间，然后使用『设置位置』来纠正你的位置。\n"
    .. "迷宫大约每天在服务器午夜时重新生成一次（并非副本重置）——短暂重新登录不会影响当前迷宫，但请在换日前完成本次探索。"

L.DLG_HELP_H_TIPS = "解开迷宫的小贴士"
L.DLG_HELP_B_TIPS = "• 不要过早熄灭符文——它们是重要的导航地标。\n"
    .. "• 优先使用导航前往未探索的房间。\n"
    .. "• 传送陷阱以橙色标记——导航会避开经过它。"

------------------------------------------------------------
-- Chat/print messages
------------------------------------------------------------
L.MSG_ALL_POIS_MARKED = "|cff00ff00所有5个符文和5个宝珠都已标记！|r 现在你可以开始将宝珠与符文配对了。"
L.MSG_ARRIVED         = "即将抵达！"
L.MSG_GO_DIRECTION_THEN = "向%s前进，然后"

L.MSG_CANNOT_DELETE_ENTRANCE  = "无法删除入口房间（1号房间）。"
L.MSG_CANNOT_DELETE_ONLY_ROOM = "无法删除地图上唯一的房间。"

L.MSG_CHECKPOINTS_HEADER   = "LucidNav 检查点："
L.MSG_CHECKPOINT_DELETED   = "检查点已删除：%s"
L.MSG_CHECKPOINT_NOT_FOUND = "没有名为『%s』的检查点。"
L.MSG_CHECKPOINT_RESTORED  = "检查点已恢复：%s"
L.MSG_CHECKPOINT_SAVED     = "检查点已保存：%s"
L.MSG_NO_CHECKPOINTS       = "没有已保存的检查点。"
L.MSG_NO_CHECKPOINTS_YET   = "尚未保存任何检查点，请先点击保存。"

L.MSG_CPU_PROFILING_OFF  = "CPU性能分析已关闭。启用方法：输入|cffffff00/console scriptProfile 1|r，然后输入/reload。"
L.MSG_DEBUG_OFF          = "调试已关闭 — 最终摘要："
L.MSG_DEBUG_ON           = "调试已开启 — 实时事件记录，每%d秒生成一次报告。再次运行|cffffff00/ln debug|r可停止并打印完整摘要。"
L.MSG_DEBUG_STATS_HEADER = "本次会话统计："

L.MSG_DEDUP_SKIPPED_TRAP = "跳过地图去重：其中一个房间是传送陷阱房间。"

L.MSG_DESTINATION_STEPS  = "我已侦测到你的目标（%s），距此处%d步！"
L.MSG_UNEXPLORED_STEPS   = "我已侦测到一个未探索的房间，距此处%d步！"
L.MSG_NO_ROUTE           = "未找到从当前房间到目标的路线；请继续探索，直到到达一个已知的兴趣点，以便重新连接到地图的其余部分"
L.MSG_NO_UNEXPLORED      = "奇怪，根据这个结果，你已经没有未探索的区域了.."
L.MSG_TARGET_NOT_DISCOVERED = "该目标尚未被发现，正在导航至最近的未探索区域"

L.MSG_EHH_EXPORTED      = "路线已导出。按CTRL+A、CTRL+C复制，然后粘贴到 nightswimmer.github.io/EndlessHalls"
L.MSG_EHH_NEED_2_POIS   = "错误：导出到EndlessHallsHelper至少需要标记2个兴趣点"
L.MSG_EHH_NO_UNEXPLORED = "错误，EHH不处理未探索的房间"

L.MSG_FOUND_SAVED_MAP = "发现了一份来自%s的已保存地图，正在加载..."
L.MSG_NO_SAVED_MAP    = "未找到已保存的地图，正在重新开始。"
L.MSG_MAP_CLEARED     = "地图已清除，正在重新开始。"
L.MSG_STARTUP_TIP     = "按住鼠标右键拖动以平移地图。点击房间中心以选中它。点击边缘以切换墙壁。"

L.MSG_LOAD_SAME_ROOM_WARNING = "警告！你必须在保存地图时所在的同一房间加载该地图"
L.MSG_LOADING_MAP            = "正在加载此地图："

L.MSG_MENU_UNAVAILABLE = "此客户端不支持右键菜单。"

L.MSG_POI_ALREADY_DEFINED = "小心，小心，小心！这个兴趣点已经被定义为%d号房间！再次点击以确认地图中存在环路并对节点去重"
L.MSG_POI_UNREACHABLE     = "%s（%d号房间）已无法从此处到达 — 你可能已用墙壁将其隔离。"
L.MSG_ROOM_MISSING_NEIGHBOR = "错误：%d号房间引用了不存在的%d号房间"
L.MSG_SELECT_ROOM_FIRST   = "请先选择一个房间（点击其中心）。"

L.MSG_TRAP_ENTRANCE_UNKNOWN = "警告：无法识别陷阱房间的入口，正在为当前位置创建新房间。"
L.MSG_TRAP_EXIT_WALLED      = "%d号房间通往%s的出口已被墙壁封锁。"
L.MSG_TRAP_MARKED           = "%d号房间已被标记为传送陷阱房间（地图上显示为橙色）。"
L.MSG_TRAP_NOT_IDENTIFIED   = "传送陷阱尚未被识别。"
L.MSG_TRAP_NO_MOVEMENT      = "无法处理陷阱：尚未记录到任何移动，请先走动一下。"

L.MSG_UNDO_DID  = "已撤销：%s"
L.MSG_UNDO_NONE = "没有可撤销的操作。"

-- Undo snapshot labels (echoed back via MSG_UNDO_DID)
L.MSG_LABEL_ACTION      = "操作"
L.MSG_LABEL_CLEAR_TRAP  = "清除陷阱"
L.MSG_LABEL_DEDUP       = "去重"
L.MSG_LABEL_DELETE_ROOM = "删除房间"
L.MSG_LABEL_DETACH      = "断开连接"
L.MSG_LABEL_JUMP_OVER   = "跳转"
L.MSG_LABEL_MAP_ROOM    = "地图房间"
L.MSG_LABEL_PRE_RESTORE = "恢复前"
L.MSG_LABEL_RESET       = "重置"
L.MSG_LABEL_TRAP        = "陷阱"
L.MSG_LABEL_UNLINK      = "断开：%s"

------------------------------------------------------------
-- Debug/audit (Core/Debug.lua, AuditMap/AuditWrap)
------------------------------------------------------------
L.STAT_ROOMS_DISCOVERED    = "已发现房间数"
L.STAT_POIS_SET            = "已标记兴趣点数"
L.STAT_TRAPS_MARKED        = "已标记陷阱数"
L.STAT_DEDUPS              = "已执行去重次数"
L.STAT_DEDUP_ROOMS_REMOVED = "  因去重而移除的房间数"
L.STAT_DEDUP_SKIPPED_TRAP  = "跳过的去重次数（陷阱房间）"
L.STAT_JUMPS               = "跳转次数（选择了新房间）"
L.STAT_KEEP_LINKED         = "保持连接次数（选择了现有房间）"
L.STAT_WALL_TOGGLES        = "墙壁切换次数"
L.STAT_ROOMS_DELETED       = "已删除房间数"
L.STAT_POI_CONFLICTS       = "已提示的兴趣点冲突数"
L.STAT_NAV_NO_ROUTE        = "导航：未找到路线"

L.AUDIT_CLEAN            = "%s：正常"
L.AUDIT_ISSUES_SUMMARY   = "%s：%d个问题"
L.AUDIT_ORPHANED          = "%d号房间是孤立的（没有相邻房间）。"
L.AUDIT_DANGLING_NEIGHBOR = "%d号房间的%s方向指向一个已不在地图上的房间。"
L.AUDIT_ASYMMETRIC_LINK   = "不对称连接：%d号房间在%s方向指向%d号房间，但没有反向连接。"
L.AUDIT_WALL_MISMATCH     = "%d号房间与%d号房间之间存在墙壁不匹配（%s侧）。"
L.AUDIT_CANVAS_OVERLAP    = "画布单元格%s处存在重叠：房间%s。"
L.AUDIT_WRAP_MISMATCH     = "%s %s-> %d号房间：模型预测为%s，但%d号房间实际位于%s。"
