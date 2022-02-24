/mob/living/carbon/human
	var/list/default_emotes = list(
	)
	var/list/current_emotes = list(
	)

	var/list/next_emote_use
	var/list/next_audio_emote_produce

/mob/living/carbon/human/proc/get_emote(key)
	return current_emotes[key]

/mob/living/carbon/human/proc/set_emote(key, datum/emote/emo)
	var/datum/emote/current = get_emote(key)
	if(current && current.priority > emo.priority)
		return

	current_emotes[key] = emo

/mob/living/carbon/human/proc/clear_emote(key)
	current_emotes.Remove(key)

/mob/living/carbon/human/proc/emote(act = "", message_type = SHOWMSG_VISUAL, message = "", auto = TRUE)
	var/datum/emote/emo = get_emote(act)
	if(!emo)
		return

	if(!emo.can_emote(src, auto))
		return

	emo.do_emote(src, auto)
