/datum/hud/ghost
	var/atom/movable/screen/spawners_menu_button

/datum/hud/ghost/New()
	ui_style = null

	var/list/types = list(
		/atom/movable/screen/ghost/jumptomob,
		/atom/movable/screen/ghost/orbit,
		/atom/movable/screen/ghost/reenter_corpse,
		/atom/movable/screen/ghost/teleport,
		/atom/movable/screen/ghost/mafia,
		/atom/movable/screen/ghost/toggle_darkness,
	)
	init_screens(types)

	spawners_menu_button = new /atom/movable/screen/ghost/spawners_menu
	spawners_menu_button.add_to_hud(src)

	..()

/datum/hud/ghost/show_hud(version = 0)
	if(!ismob(mymob))
		return FALSE
	if(!mymob.client)
		return FALSE

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
	return TRUE
