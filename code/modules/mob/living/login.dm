
/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	//Round specific stuff like hud updates
	if(ticker && ticker.mode)
		switch(ticker.mode.name)
			if("revolution")
				if((mind in ticker.mode.revolutionaries) || (mind in ticker.mode.head_revolutionaries))
					ticker.mode.update_all_rev_icons()
			if("gang")
				if((mind in ticker.mode.A_bosses) || (mind in ticker.mode.A_gang))
					ticker.mode.update_gang_icons_added(src.mind,"A")
				if((mind in ticker.mode.B_bosses) || (mind in ticker.mode.B_gang))
					ticker.mode.update_gang_icons_added(src.mind,"B")
			if("rp-revolution")
				if((mind in ticker.mode.revolutionaries) || (mind in ticker.mode.head_revolutionaries))
					ticker.mode.update_all_rev_icons()
			if("cult")
				if(mind in ticker.mode.cult)
					ticker.mode.update_all_cult_icons()
			if("nuclear emergency")
				if(mind in ticker.mode.syndicates)
					ticker.mode.update_all_synd_icons()
			if("mutiny")
				var/datum/game_mode/mutiny/mode = get_mutiny_mode()
				if(mode)
					mode.update_all_icons()
			if("shadowlings")
				if((mind in ticker.mode.thralls) || (mind in ticker.mode.shadows))
					ticker.mode.update_all_shadows_icons()

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")
	//Should update regardless of if we can ventcrawl, since we can end up in pipes in other ways.
	update_pipe_vision()

	noob_notify(src)

	//Jukebox
	client.media = new /datum/media_manager(src)
	client.media.open()
	client.media.update_music()

	return .
