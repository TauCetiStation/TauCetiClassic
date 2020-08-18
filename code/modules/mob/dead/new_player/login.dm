/mob/dead/new_player/Login()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.current = src

	..()

	if(join_motd)
		to_chat(src, "<div class='motd'>[join_motd]</div>")
	if(join_test_merge)
		to_chat(src, "<div class='test_merges'>[join_test_merge]</div>")
	if(host_announcements)
		to_chat(src, "<div class='host_announcements emojify linkify'>[host_announcements]</div>")

	sight |= SEE_TURFS

	new_player_panel()
	playsound_lobbymusic()
//	handle_privacy_poll() // commented cause polls are kinda broken now, needs refactoring
