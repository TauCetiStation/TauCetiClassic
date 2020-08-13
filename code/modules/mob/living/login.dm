
/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

	//Round specific stuff like hud updates
	if(SSticker && SSticker.mode)
		switch(SSticker.mode.name)
			if("revolution")
				if((mind in SSticker.mode.revolutionaries) || (mind in SSticker.mode.head_revolutionaries))
					SSticker.mode.update_all_rev_icons()
			if("gang war")
				if((mind in SSticker.mode.A_bosses) || (mind in SSticker.mode.A_gang))
					SSticker.mode.update_gang_icons_added(src.mind,"A")
				if((mind in SSticker.mode.B_bosses) || (mind in SSticker.mode.B_gang))
					SSticker.mode.update_gang_icons_added(src.mind,"B")
			if("rp-revolution")
				if((mind in SSticker.mode.revolutionaries) || (mind in SSticker.mode.head_revolutionaries))
					SSticker.mode.update_all_rev_icons()
			if("cult")
				if(mind in SSticker.mode.cult)
					SSticker.mode.update_all_cult_icons()
			if("nuclear emergency")
				if(mind in SSticker.mode.syndicates)
					SSticker.mode.update_all_synd_icons()
			if("mutiny")
				var/datum/game_mode/mutiny/mode = get_mutiny_mode()
				if(mode)
					mode.update_all_icons()
			if("shadowling")
				if((mind in SSticker.mode.thralls) || (mind in SSticker.mode.shadows))
					SSticker.mode.update_all_shadows_icons()

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
