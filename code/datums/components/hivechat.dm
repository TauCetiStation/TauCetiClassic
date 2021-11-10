#define HIVE_BLOB "blob"
// The hive chat component.

var/global/list/list/atom/hivechat_hearers = list()

/datum/component/hivechat
	// This is to differentiate between multiple hivechats on parent
	var/chat_id = "abstract"

// Return all atoms that can hear the hive chat
/datum/component/hivechat/proc/get_hearers()
	return hivechat_hearers[chat_id]

// Renders the message 
/datum/component/hivechat/proc/display(text)
	return "Hivemind, [parent]: [text]"

/datum/component/hivechat/Initialize()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	RegisterSignal(parent, COMSIG_HIVE_SEND, .proc/send_message)
	if(!hivechat_hearers[chat_id])
		hivechat_hearers[chat_id] = list()
	hivechat_hearers[chat_id] += parent

/datum/component/hivechat/Destroy()
	. = ..()
	hivechat_hearers[chat_id] -= parent
	
/datum/component/hivechat/proc/send_message(_, _chat_id, message)
	SIGNAL_HANDLER
	if(_chat_id != chat_id)
		return
	var/sanitized = sanitize(message)
	if(!length(sanitized))
		return
	var/displayed = display(sanitized)
	for(var/atom/A in get_hearers())
		to_chat(A, displayed)
	for(var/O in observer_list)
		to_chat(O, "[FOLLOW_LINK(O, parent)] [displayed]")
	log_say("[key_name(parent)] : HIVESAY\[[chat_id]\]: [sanitized]")

/datum/component/hivechat/blob 
	chat_id = HIVE_BLOB

/datum/component/hivechat/blob/display(message)
	message = "<span class='say_quote'>says,</span> \"<span class='body'>[message]</span>\""
	message = "<font color=\"#EE4000\"><i><span class='game say'>Blob Telepathy, <span class='name'>[parent]</span> <span class='message'>[message]</span></span></i></font>"
	return message
