/datum/hud/ghost
	var/atom/movable/screen/spawners_menu_button

/mob/dead/observer/add_to_hud(datum/hud/ghost/hud)
	hud.ui_style = null

	hud.init_screens(list(
		/atom/movable/screen/ghost/jumptomob,
		/atom/movable/screen/ghost/orbit,
		/atom/movable/screen/ghost/reenter_corpse,
		/atom/movable/screen/ghost/teleport,
		/atom/movable/screen/ghost/mafia,
		/atom/movable/screen/ghost/toggle_darkness,
	))

	hud.spawners_menu_button = new /atom/movable/screen/ghost/spawners_menu
	hud.spawners_menu_button.add_to_hud(hud)
