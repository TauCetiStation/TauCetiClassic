/mob/dead/new_player/Login()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	..()

	if(join_motd)
		to_chat(src, "<div class=\"motd\">[join_motd]</div>")

	sight |= SEE_TURFS

	new_player_panel()
	client.playtitlemusic()
//	handle_privacy_poll() // commented cause polls are kinda broken now, needs refactoring
