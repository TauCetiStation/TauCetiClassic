/mob/living/carbon/human
	var/list/default_emotes = list(
		/datum/emote/laugh
	)
	var/list/current_emotes = list(
	)

	var/list/next_emote_use
	var/list/next_audio_emote_produce

/mob/living/carbon/human/atom_init()
	. = ..()
	for(var/emote in default_emotes)
		var/datum/emote/E = global.all_emotes[emote]
		set_emote(E.key, E)

/mob/living/carbon/human/proc/get_emote(key)
	return current_emotes[key]

/mob/living/carbon/human/proc/set_emote(key, datum/emote/emo)
	var/datum/emote/current = get_emote(key)
	if(current && current.priority > emo.priority)
		return

	current_emotes[key] = emo

/mob/living/carbon/human/proc/clear_emote(key)
	current_emotes.Remove(key)

/mob/living/carbon/human/emote(act = "", message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	var/datum/emote/emo = get_emote(act)
	if(!emo)
		return

	if(!emo.can_emote(src, !auto))
		return

	emo.do_emote(src, act, !auto)

// A simpler emote. Just the message. Is counted as VISUAL. If you want anything more complex - make a datumized emote.
/mob/living/carbon/human/custom_emote(message, intentional=FALSE)
	log_emote("[key_name(src)] : [message]")

	visible_message(message, ignored_mobs = observer_list)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue

		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				// ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
				to_chat(M, "[FOLLOW_LINK(M, src)] [message]")
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(intentional)
					to_chat(M, "[FOLLOW_LINK(M, src)] [message]")
