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

// TO-DO: sound

/datum/emote/clickable/help_replicator/add_cloud(mob/living/simple_animal/replicator/user)
	. = ..()
	user.request_help_until = world.time + 7 SECONDS

	for(var/r in global.replicators)
		var/mob/living/simple_animal/replicator/R = r
		if(R == user)
			continue
		if(get_dist(user, R) > emote_range)
			continue
		 if(R.ckey)
		 	to_chat(R, "<span class='notice'>[HELP_LINK(R, user)]</span>")
		 	continue

		R.state = REPLICATOR_STATE_GOING_TO_HELP
		R.target_coordinates = list("x" = user.x, "y" = user.y, "z" = user.z)

/datum/emote/clickable/help_replicator/on_cloud_click(mob/living/carbon/human/target, mob/living/carbon/human/clicker)
	if(target != clicker)
		clicker.help_other(target)
