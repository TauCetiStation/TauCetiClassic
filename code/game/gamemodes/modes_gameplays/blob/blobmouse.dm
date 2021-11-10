// The mouse that will later burst into a blob. Can talk into blob hivechat
/mob/living/simple_animal/mouse/blob

/mob/living/simple_animal/mouse/blob/atom_init()
	. = ..()
	AddComponent(/datum/component/hivechat/blob)

/mob/living/simple_animal/mouse/blob/say(message)
	if(!message)
		return
	if (src.client)
		if(client.prefs.muted & MUTE_IC)
			to_chat(src, "You cannot send IC messages (muted).")
			return
		if (client.handle_spam_prevention(message,MUTE_IC))
			return

	if (stat)
		return
	SEND_SIGNAL(src, COMSIG_HIVE_SEND, HIVE_BLOB, message)
