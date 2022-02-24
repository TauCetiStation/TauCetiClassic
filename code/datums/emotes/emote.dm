/*
 * Singleton emote datum.
 *
 * Contains all information neccessary to:
 * - be set for mob by default
 * - check whether can be performed
 * - be performed for user
 */
/datum/emote
	// Default command to use emote ie. '*[key]'
	var/key

	// First person message ('You laugh!')
	var/message_1p
	// Third person message ('laughs!') -> ('James Morgan laughs!')
	var/message_3p
	// From mute message ('laughs silently.') -> ('James Morgan laughs silently.')
	var/message_impaired_production
	// For deaf/blind message ('You hear someone laughing.', 'You see someone opening and closing their mouth.')
	var/message_impaired_reception
	// Mime message ('acts out a laugh!') -> ('James Morgan acts out a laugh!')
	var/message_miming
	// Muzzled message ('giggles sligthly.') -> ('James Morgan giggles sligthly.')
	var/message_muzzled
	// Audible/visual flag
	var/message_type = SHOWMSG_VISUAL

	// Range outside which emote is not shown
	var/emote_range

	// Sound produced. (HAHAHAHA)
	var/sound

	// What group does this emote belong to. By default uses emote type
	var/cooldown_group = null
	// Cooldown for emote usage.
	var/cooldown = 0.8 SECONDS
	// Cooldown for the audio of the emote, if it has one.
	var/audio_cooldown = 2 SECONDS

	// Visual cue with a cloud above head for some emotes.
	var/cloud

	var/state_checks

/datum/emote/proc/get_emote_message_1p(mob/living/carbon/human/user)
	return message_1p

/datum/emote/proc/get_emote_message_3p(mob/living/carbon/human/user)
	var/msg = message_3p

	if(user.miming)
		msg = message_miming
	else if((message_type & SHOWMSG_AUDIO) && HAS_TRAIT(user, TRAIT_MUTE))
		msg = message_impaired_production
	else if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		msg = message_muzzled

	return "<b>[user]</b> [msg]"

/datum/emote/proc/his_macro(mob/living/carbon/human/user)
	. = "its" // maybe put it in a separate file and expand the variables in such cases? I don't know how to make it through the BYOND macro
	switch(gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "his"
		if(PLURAL)
			. = "their"

/datum/emote/proc/he_macro(mob/living/carbon/human/user)
	. = "it" // this too
	switch(gender)
		if(FEMALE)
			. = "she"
		if(MALE)
			. = "he"
		if(PLURAL)
			. = "they"

/datum/emote/proc/get_cooldown_group(mob/living/carbon/human/user)
	if(isnull(cooldown_group))
		return type

	return cooldown_group

/datum/emote/proc/check_cooldown(mob/living/carbon/human/user, list/cooldowns, intentional)
	if(!intentional)
		return TRUE

	if(!cooldowns)
		return TRUE

	return cooldowns[get_cooldown_group(user)] < world.time

/datum/emote/proc/set_cooldown(mob/living/carbon/human/user, list/cooldowns, value, intentional)
	if(!intentional)
		return

	LAZYSET(cooldowns, get_cooldown_group(user), world.time + value)

/datum/emote/proc/get_sound(mob/living/carbon/human/user, intentional)
	return sound

/datum/emote/proc/play_sound(mob/living/carbon/human/user, intentional)
	playsound(src, get_sound(user, intentional), VOL_EFFECTS_MASTER, null, FALSE, null)

/datum/emote/proc/can_emote(mob/living/carbon/human/user, intentional)
	if(!check_cooldown(user, use.next_emote_use, intentional))
		return FALSE

	for(var/datum/callback/state as anything in state_checks)
		if(!state.Invoke(user, intentional))
			returN FALSE

	return TRUE

/datum/emote/proc/do_emote(mob/living/carbon/human/user, intentional)
	log_emote("[key_name(user)] : [message]")

	set_cooldown(user, user.next_emote_use, cooldown, intentional)

	for(var/obj/item/weapon/implant/I in user)
		if(!I.implanted)
			continue
		I.trigger(key, user)

	var/msg_3p = get_emote_message_3p(user)
	var/range = !isnull(emote_range) ? emote_range : world.view

	if(message_type & SHOWMSG_VISUAL)
		visible_message(msg_3p, message_impaired, viewing_distance = range, ignored_mobs = observer_list)
	else if(message_type & SHOWMSG_AUDIO)
		audible_message(msg_3p, message_impaired, hearing_distance = range, ignored_mobs = observer_list)

	if(sound && check_cooldown(user, user.next_audio_emote_produce, intentional))
		set_cooldown(user, user.next_audio_emote_produce, audio_cooldown, intentional)
		play_sound(user, intentional)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue

		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				// ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
				to_chat(M, "[FOLLOW_LINK(M, src)] [msg_3p]")
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(!auto)
					to_chat(M, "[FOLLOW_LINK(M, src)] [msg_3p]")

	play_rock_paper_scissors_animation(act)

	if(cloud)
		var/image/emote_bubble = image('icons/mob/emote.dmi', src, cloud, EMOTE_LAYER)
		emote_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		flick_overlay(emote_bubble, clients, 30)
		QDEL_IN(emote_bubble, 3 SECONDS)
