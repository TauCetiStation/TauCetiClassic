
/mob/living/Login()
	..()
	//Mind updates
	sync_mind()	//updates the mind (or creates and initializes one if one doesn't exist) and sync with client
	hud_used.add_roles() // add mind roles to hud

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	noob_notify(src)

	if(config.guard_enabled)
		client.guard.trigger_init()

	//Jukebox
	client.media?.open()

	// unresting mob after ghosting
	SetCrawling(FALSE)

	return .
