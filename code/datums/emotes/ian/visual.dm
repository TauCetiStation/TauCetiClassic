/datum/emote/ian/dance
	key = "dance"

	message_1p = "You dances!"
	message_3p = "dances around."

	message_type = SHOWMSG_VISUAL

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/ian/dance/do_emote(mob/living/carbon/ian/user, emote_key, intentional)
	. = ..()
	for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2))
		user.set_dir(i)
		sleep(1)
