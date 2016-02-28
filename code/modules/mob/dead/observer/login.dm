/mob/dead/observer/Login()
	..()
	if(ghostimage)
		ghostimage.icon_state = src.icon_state
	ghost_orbit = client.prefs.ghost_orbit

	updateghostimages()
