/datum/emote/clickable/help_replicator
	key = "help"
	message_1p = "You asked for help."
	message_3p = "requests assistance."
	cooldown = 10 SECONDS
	duration = 7 SECONDS
	message_type = SHOWMSG_AUDIO

	cloud = "cloud-medic"
	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
		EMOTE_STATE(is_one_hand_usable),
		EMOTE_STATE(is_not_species, ZOMBIE)
	)

	// to-do: (replicators) add a sound here. the sound should be pleasant and musical

/datum/emote/clickable/help_replicator/add_cloud(mob/living/simple_animal/hostile/replicator/user)
	. = ..()
	user.request_help_until = world.time + 7 SECONDS

	for(var/r in global.alive_replicators)
		var/mob/living/simple_animal/hostile/replicator/R = r
		if(R == user)
			continue
		if(get_dist(user, R) > emote_range)
			continue
		 if(R.is_controlled())
		 	to_chat(R, "<span class='notice'>[HELP_LINK(R, user)]</span>")
		 	continue

		R.state = REPLICATOR_STATE_GOING_TO_HELP
		R.target_coordinates = list("x" = user.x, "y" = user.y, "z" = user.z)

/datum/emote/clickable/help_replicator/on_cloud_click(mob/living/carbon/human/target, mob/living/carbon/human/clicker)
	if(target != clicker)
		clicker.help_other(target)


/datum/emote/replicator/beep
	key = "beep"

	message_1p = "You beep."
	message_3p = "beeps."

	message_impaired_production = "makes a weak noise."
	message_impaired_reception = "flickers."

	message_miming = "makes robot noises."
	message_muzzled = "makes a weak noise."

	message_type = SHOWMSG_AUDIO

	sound = 'sound/machines/twobeep.ogg'

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

	cloud = "robot0"

/datum/emote/replicator/beep/play_sound(mob/user, intentional, emote_sound)
	// Handling corridor case.
	if(user.invisibility > 0)
		return

	// Handling pipes.
	if(!isturf(user.loc))
		return

	var/mob/living/simple_animal/hostile/replicator/R = user
	R.playsound_stealthy(user, emote_sound, vol=75)

/datum/emote/replicator/beep/exclamation
	key = "beep!"

	message_1p = "You beep!"
	message_3p = "beeps!"

	cloud = "robot2"

/datum/emote/replicator/beep/question
	key = "beep?"

	message_1p = "You beep?"
	message_3p = "beeps?"

	cloud = "robot1"
