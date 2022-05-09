/datum/emote/dance
	key = "dance"

	message_1p = "You dances!"
	message_3p = "dances around."

	message_type = SHOWMSG_VISUAL

	cooldown = 5 SECONDS

	state_checks = list(
		EMOTE_STATE(is_stat, CONSCIOUS),
	)

/datum/emote/dance/do_emote(mob/user, emote_key, intentional)
	. = ..()
	INVOKE_ASYNC(src, .proc/dance, user)

/datum/emote/dance/proc/dance(mob/user)
	for(var/i in 1 to 20)
		var/list/pos_dirs = cardinal.Copy()
		user.set_dir(pick(pos_dirs - user.dir))
		sleep(1)
