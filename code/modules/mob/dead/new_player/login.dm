/mob/dead/new_player/Login()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	..()

	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")
	if(join_test_merge)
		to_chat(src, "<div>[join_test_merge]</div>")

	sight |= SEE_TURFS

	new_player_panel()
	client.playtitlemusic()
	handle_privacy_poll()
