#define MESSAGE_TYPE_SYSTEM "system"
#define MESSAGE_TYPE_LOCALCHAT "localchat"
#define MESSAGE_TYPE_RADIO "radio"
#define MESSAGE_TYPE_INFO "info"
#define MESSAGE_TYPE_WARNING "warning"
#define MESSAGE_TYPE_DEADCHAT "deadchat"
#define MESSAGE_TYPE_OOC "ooc"
#define MESSAGE_TYPE_ADMINPM "adminpm"
#define MESSAGE_TYPE_COMBAT "combat"
#define MESSAGE_TYPE_ADMINCHAT "adminchat"
#define MESSAGE_TYPE_MODCHAT "modchat"
#define MESSAGE_TYPE_EVENTCHAT "eventchat"
#define MESSAGE_TYPE_ADMINLOG "adminlog"
#define MESSAGE_TYPE_ATTACKLOG "attacklog"
#define MESSAGE_TYPE_DEBUG "debug"


// To chat defines
#define to_chat_private(usr, msg, type) to_chat(usr, msg, type, confidential = TRUE)

#define to_chat_admin_pm(usr, msg) to_chat_private(usr, msg, MESSAGE_TYPE_ADMINPM)
#define to_chat_admin_chat(usr, msg) to_chat_private(usr, msg, MESSAGE_TYPE_ADMINCHAT)
#define to_chat_admin_log(usr, msg) to_chat_private(usr, msg, MESSAGE_TYPE_ADMINLOG)
#define to_chat_attack_log(usr, msg) to_chat_private(usr, msg, MESSAGE_TYPE_ATTACKLOG)
#define to_chat_debug(usr, msg) to_chat_private(usr, msg, MESSAGE_TYPE_DEBUG)

#define global_ooc_info(msg) send2ooc(msg, colour = "purple", prefix = "OOC-INFO")

//Define to create a tooltip when hovering over an item.
//hover_element - Pointed item
//text - Display text
#define EMBED_TIP(hover_element, text) "<span class='embedded_tip'>[hover_element]<span class='embedded_tip-mark'>(?)</span><span class='embedded_tip-text'>[text]</span></span>"
#define EMBED_TIP_MINI(hover_element, text) "<span class='embedded_tip embedded_tip--mini'>[hover_element]<span class='embedded_tip-mark'>(?)</span><span class='embedded_tip-text'>[text]</span></span>"
