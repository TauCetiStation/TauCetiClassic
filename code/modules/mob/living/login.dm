
/mob/living/Login()
	..()
	//Mind updates
	mind_initialize()	//updates the mind (or creates and initializes one if one doesn't exist)
	mind.active = 1		//indicates that the mind is currently synced with a client

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
