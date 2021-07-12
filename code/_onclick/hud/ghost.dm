/atom/movable/screen/ghost
	icon = 'icons/mob/screen_ghost.dmi'

/atom/movable/screen/ghost/MouseEntered()
	flick(icon_state + "_anim", src)

/atom/movable/screen/ghost/jumptomob
	name = "Jump to mob"
	icon_state = "jumptomob"

/atom/movable/screen/ghost/jumptomob/Click()
	var/mob/dead/observer/G = usr
	G.jumptomob()

/atom/movable/screen/ghost/orbit
	name = "Orbit"
	icon_state = "orbit"

/atom/movable/screen/ghost/orbit/Click()
	var/mob/dead/observer/G = usr
	G.follow()

/atom/movable/screen/ghost/reenter_corpse
	name = "Reenter corpse"
	icon_state = "reenter_corpse"

/atom/movable/screen/ghost/reenter_corpse/Click()
	var/mob/dead/observer/G = usr
	G.reenter_corpse()

/atom/movable/screen/ghost/teleport
	name = "Teleport"
	icon_state = "teleport"

/atom/movable/screen/ghost/teleport/Click()
	var/mob/dead/observer/G = usr
	G.dead_tele()

/atom/movable/screen/ghost/toggle_darkness
	name = "Toggle Darkness"
	icon_state = "toggle_darkness"

/atom/movable/screen/ghost/toggle_darkness/Click()
	var/mob/dead/observer/G = usr
	G.toggle_darkness()

/datum/hud/ghost/New()
	adding = list()
	var/atom/movable/screen/using

	using = new /atom/movable/screen/ghost/jumptomob()
	using.screen_loc = ui_ghost_jumptomob
	adding += using

	using = new /atom/movable/screen/ghost/orbit()
	using.screen_loc = ui_ghost_orbit
	adding += using

	using = new /atom/movable/screen/ghost/reenter_corpse()
	using.screen_loc = ui_ghost_reenter_corpse
	adding += using

	using = new /atom/movable/screen/ghost/teleport()
	using.screen_loc = ui_ghost_teleport
	adding += using

	using = new /atom/movable/screen/ghost/toggle_darkness()
	using.screen_loc = ui_ghost_toggle_darkness
	adding += using

	..()

/datum/hud/ghost/show_hud(version = 0)
	if(!ismob(mymob))
		return 0
	if(!mymob.client)
		return 0

	if(version)
		hud_version = version
	else
		hud_version = (hud_version == HUD_STYLE_STANDARD) ? HUD_STYLE_NOHUD : HUD_STYLE_STANDARD

	switch(hud_version)
		if(HUD_STYLE_STANDARD)
			hud_shown = TRUE
			mymob.client.screen += adding
		else
			hud_shown = FALSE
			mymob.client.screen -= adding
