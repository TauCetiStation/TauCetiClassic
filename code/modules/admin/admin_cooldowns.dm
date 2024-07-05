// admin cooldown system to temporary restrict players from doing something
// todo: attack, movement, consciousness (?) cooldowns

/proc/set_admin_cooldown(mob/M, type, time, by_who)
	if(!ismob(M))
		return

	if(!M.client)
		return

	if(M.client.holder)
		return

	if(!(type in global.admin_cooldowns_list))
		return

	var/datum/preferences/P = M.client.prefs

	LAZYSET(P.admin_cooldowns, type, world.time + time)

	if(ismob(by_who))
		to_chat(M, "<span class='warning bold'>You have been placed on [restriction2human(type)] cooldown by [by_who] for [time] minute\s!</span>")
		message_admins("<span class='notice'>[key_name_admin(by_who)] has placed [key_name_admin(M)] on [type] cooldown.</span>")
		log_admin("[key_name(by_who)] has placed [key_name(M)] on [type] cooldown.")
	else
		to_chat(M, "<span class='warning bold'>You have been placed on [restriction2human(type)] cooldown by [by_who] for [time] minute\s!</span>")
		message_admins("<span class='notice'>[by_who] has placed [key_name_admin(M)] on [type] cooldown.</span>")
		log_admin("[by_who] has placed [key_name(M)] on [type] cooldown.")

/proc/cancel_admin_cooldown(mob/M, type, by_who)
	if(!ismob(M))
		return

	if(!M.client)
		return

	if(!(type in global.admin_cooldowns_list))
		return

	var/datum/preferences/P = M.client.prefs

	LAZYREMOVE(P.admin_cooldowns, type)

	if(ismob(by_who))
		to_chat(M, "<span class='warning bold'>Your [restriction2human(type)] cooldown has been lifted.</span>")
		message_admins("<span class='notice'>[key_name_admin(by_who)] has lifted [key_name_admin(M)] [type] cooldown.</span>")
		log_admin("[key_name(by_who)] has lifted [key_name(M)] [type] cooldown.")
	else
		to_chat(M, "<span class='warning bold'>Your [restriction2human(type)] cooldown has been lifted.</span>")
		message_admins("<span class='notice'>[by_who] has lifted [key_name_admin(M)] [type] cooldown.</span>")
		log_admin("[by_who] has lifted [key_name(M)] [type] cooldown.")

/proc/restriction2human(type)
	switch(type)
		if(MUTE_IC, ADMIN_CD_IC)
			. = "IC (say and emote) chats"
		if(MUTE_OOC, ADMIN_CD_OOC)
			. = "OOC (ooc, looc, ghostchat) chats"
		if(MUTE_PRAY, ADMIN_CD_PRAY)
			. = "pray chat"
		if(MUTE_PM, ADMIN_CD_PM)
			. = "admin and mentor chats"
		else
			CRASH("Unknown restriction [type]!")
