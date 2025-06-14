var/global/list/all_emotes
var/global/list/emotes_for_emote_panel // for custom emote panel

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
	var/emote_range = 7

	// Sound produced. (HAHAHAHA)
	var/sound
	// Mutes shouldn't clap silently (but mimes should!)
	var/soundless_for_mute = TRUE
	// Whether sound pitch varies with age.
	var/age_variations = FALSE

	// What group does this emote belong to. By default uses emote type
	var/cooldown_group = null
	// Cooldown for emote usage.
	var/cooldown = 0.8 SECONDS
	// Cooldown for the audio of the emote, if it has one.
	var/audio_cooldown = 3 SECONDS

	// Visual cue with a cloud above head for some emotes.
	var/cloud
	// How long emote cloud will float above character.
	var/cloud_duration = 3 SECONDS

	// If specified, requires a greater degree of consciousness than the stat specified.
	var/required_stat = null
	// If specified requires a greater degree of consciousness than the stat specified, when intentionally performing the emote.
	var/required_intentional_stat = null
	// If performing mob has the trait, the emote can't be performed.
	var/list/blocklist_traits = null
	// If unintentionally permorming mob has the trait, the emote can't be performed.
	var/list/blocklist_unintentional_traits = null
	// If the mob doesn't have a usable arm, the emote can't be performed.
	var/require_usable_hand = FALSE
	// If the mob doesn't have all bodyparts in the list, the emote can't be performed.
	var/list/required_bodyparts = null

/datum/emote/proc/get_emote_message_1p(mob/user)
	return "<i>[message_1p]</i>"

/datum/emote/proc/get_impaired_msg(mob/user)
	return message_impaired_reception

/datum/emote/proc/get_emote_message_3p(mob/user)
	var/msg = message_3p
	if(message_miming && HAS_TRAIT(src, TRAIT_MIMING))
		msg = message_miming
	else if(message_muzzled && istype(user.wear_mask, /obj/item/clothing/mask/muzzle))
		msg = message_muzzled
	else if(message_impaired_production && (message_type & SHOWMSG_AUDIO) && HAS_TRAIT(user, TRAIT_MUTE))
		msg = message_impaired_production

	if(!msg)
		return null

	return msg

/datum/emote/proc/get_cooldown_group()
	if(isnull(cooldown_group))
		return type

	return cooldown_group

/datum/emote/proc/check_cooldown(list/cooldowns, intentional)
	if(!cooldowns)
		return TRUE

	return cooldowns[get_cooldown_group()] < world.time

/datum/emote/proc/set_cooldown(list/cooldowns, value, intentional)
	LAZYSET(cooldowns, get_cooldown_group(), world.time + value)

/datum/emote/proc/can_play_sound(mob/user, intentional)
	if(HAS_TRAIT(user, TRAIT_MUTE) && soundless_for_mute)
		return FALSE
	if(istype(user.wear_mask, /obj/item/clothing/mask/muzzle) && soundless_for_mute)
		return FALSE
	if(isliving(user))
		var/mob/living/L = user
		if(L.silent && soundless_for_mute)
			return FALSE
	if(HAS_TRAIT(user, TRAIT_MIMING))
		return FALSE
	if(!check_cooldown(user.next_audio_emote_produce, intentional))
		return FALSE
	return TRUE

/datum/emote/proc/get_sound(mob/user, intentional)
	return sound

/datum/emote/proc/play_sound(mob/user, intentional, emote_sound)
	var/sound_frequency = null
	if(age_variations && ishuman(user))
		// TO-DO: add get_min_age, get_max_age to all mobs? ~Luduk
		var/mob/living/carbon/human/H = user
		var/voice_frequency = TRANSLATE_RANGE(H.age, H.species.min_age, H.species.max_age, 0.85, 1.05)
		sound_frequency = 1.05 - (voice_frequency - 0.85)

	playsound(user, emote_sound, VOL_EFFECTS_MASTER, null, FALSE, sound_frequency)

/datum/emote/proc/can_emote(mob/user, intentional)
	if(!check_cooldown(user.next_emote_use, intentional))
		if(intentional)
			to_chat(user, "<span class='notice'>You can't emote so much, give it a rest.</span>")
		return FALSE

	if(!isnull(required_stat) && user.stat > required_stat)
		if(intentional)
			to_chat(user, "<span class='notice'>You can't emote in this state.</span>")
		return FALSE

	if(!isnull(required_intentional_stat) && intentional && user.stat > required_stat)
		to_chat(user, "<span class='notice'>You can't emote in this state.</span>")
		return FALSE

	if(blocklist_traits)
		for(var/trait in blocklist_traits)
			if(HAS_TRAIT(user, trait))
				return FALSE

	if(blocklist_unintentional_traits && !intentional)
		for(var/trait in blocklist_unintentional_traits)
			if(HAS_TRAIT(user, trait))
				return FALSE

	if(require_usable_hand)
		if(user.restrained())
			if(intentional)
				to_chat(user, "<span class='notice'>You can't perform this emote while being restrained.</span>")
			return FALSE

		if(ishuman(user))
			var/mob/living/carbon/human/H = user

			var/obj/item/organ/external/l_arm = H.get_bodypart(BP_L_ARM)
			var/obj/item/organ/external/r_arm = H.get_bodypart(BP_R_ARM)

			var/l_arm_usable = l_arm && l_arm.is_usable()
			var/r_arm_usable = r_arm && r_arm.is_usable()

			if(!l_arm_usable && !r_arm_usable)
				return FALSE

	if(required_bodyparts && ishuman(user))
		var/mob/living/carbon/human/H = user

		for(var/zone in required_bodyparts)
			var/obj/item/organ/external/BP = H.get_bodypart(zone)
			if(!BP)
				if(intentional)
					to_chat(H, "<span class='notice'>You can't perform this emote without a [parse_zone(zone)]</span>")
				return FALSE

	return TRUE

/datum/emote/proc/do_emote(mob/user, emote_key, intentional)
	LAZYINITLIST(user.next_emote_use)
	set_cooldown(user.next_emote_use, cooldown, intentional)

	var/msg_1p = get_emote_message_1p(user)
	var/msg_3p = "<b>[user]</b> <i>[get_emote_message_3p(user)]</i>"
	var/range = !isnull(emote_range) ? emote_range : world.view
	var/deaf_impaired_msg = "<b>[user]</b> [get_impaired_msg(user)]"

	if(!msg_1p)
		msg_1p = msg_3p

	log_emote("[key_name(user)] : [msg_3p]")

	if(msg_3p)
		if(message_type & SHOWMSG_VISUAL)
			user.visible_message(msg_3p, msg_1p, message_impaired_reception, viewing_distance = range, ignored_mobs = observer_list, runechat_msg = get_emote_message_3p(user))
		else if(message_type & SHOWMSG_AUDIO)
			user.audible_message(msg_3p, msg_1p, deaf_impaired_msg, hearing_distance = range, ignored_mobs = observer_list, runechat_msg = get_emote_message_3p(user), deaf_runechat_msg = get_impaired_msg(user))

	else
		to_chat(user, msg_1p)

	var/emote_sound = get_sound(user, intentional)
	if(emote_sound && can_play_sound(user, intentional))
		LAZYINITLIST(user.next_audio_emote_produce)
		set_cooldown(user.next_audio_emote_produce, audio_cooldown, intentional)
		play_sound(user, intentional, emote_sound)

	for(var/mob/M as anything in observer_list)
		if(!M.client)
			continue

		if(M in viewers(get_turf(user), world.view))
			M.show_runechat_message(user, null, get_emote_message_3p(user), null, SHOWMSG_VISUAL)

		switch(M.client.prefs.chat_ghostsight)
			if(CHAT_GHOSTSIGHT_ALL)
				// ghosts don't need to be checked for deafness, type of message, etc. So to_chat() is better here
				to_chat(M, "[FOLLOW_LINK(M, user)] [msg_3p]")
			if(CHAT_GHOSTSIGHT_ALLMANUAL)
				if(intentional)
					to_chat(M, "[FOLLOW_LINK(M, user)] [msg_3p]")

	if(cloud)
		add_cloud(user)

/datum/emote/proc/add_cloud(mob/user)
	var/image/emote_bubble = image('icons/mob/emote.dmi', user, cloud, EMOTE_LAYER)
	emote_bubble.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	flick_overlay(emote_bubble, clients, cloud_duration)
	QDEL_IN(emote_bubble, cloud_duration)
