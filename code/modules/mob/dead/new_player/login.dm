/mob/dead/new_player/Login()
	if(!mind)
		mind = new /datum/mind(key)
		mind.active = TRUE
		mind.set_current(src)

	my_client = client
	..()

	if(join_motd)
		to_chat(src, "<div class='motd'>[join_motd]</div>")
	if(test_merges)
		client.show_test_merges()
	if(host_announcements)
		to_chat(src, "<div class='host_announcements emojify linkify'>[host_announcements]</div>")

	SSround_aspects.local_announce_aspect(client)

	sight |= SEE_TURFS

	show_titlescreen()
	playsound_lobbymusic()
//	handle_privacy_poll() // commented cause polls are kinda broken now, needs refactoring
