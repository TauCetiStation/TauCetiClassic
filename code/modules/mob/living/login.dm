
/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	//Round specific stuff like hud updates
	if(ticker && ticker.mode)
		switch(ticker.mode.name)
			if("gang war")
				if((mind in ticker.mode.A_bosses) || (mind in ticker.mode.A_gang))
					ticker.mode.update_gang_icons_added(src.mind,"A")
				if((mind in ticker.mode.B_bosses) || (mind in ticker.mode.B_gang))
					ticker.mode.update_gang_icons_added(src.mind,"B")
			if("mutiny")
				var/datum/game_mode/mutiny/mode = get_mutiny_mode()
				if(mode)
					mode.update_all_icons()

	//Zombies
	if(src in zombie_list)
		update_all_zombie_icons()

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	noob_notify(src)
	
	if(config.guard_enabled)
		client.guard.trigger_init()

	//Jukebox
	client.media = new /datum/media_manager(src)
	client.media.open()
	client.media.update_music()

	return .
