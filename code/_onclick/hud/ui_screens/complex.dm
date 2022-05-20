/atom/movable/screen/complex
	var/list/types
	var/list/screens = list()
	var/screens_slot = hud_slot_other
	var/shown = FALSE

/atom/movable/screen/complex/atom_init()
	. = ..()
	var/atom/movable/screen/screen
	for(var/type in types)
		screen = new type
		screens += screen
		if(screens_slot)
			screen.hud_slot = screens_slot

/atom/movable/screen/complex/Destroy()
	QDEL_LIST(screens)
	return ..()

/atom/movable/screen/complex/action()
	shown = !shown
	if(shown)
		usr.client.screen += screens
	else
		usr.client.screen -= screens

/atom/movable/screen/complex/add_to_hud(datum/hud/hud)
	. = ..()

	for(var/atom/movable/screen/screen as anything in screens)
		screen.add_to_hud(hud)

/atom/movable/screen/complex/update_by_hud(datum/hud/hud)
	. = ..()

	for(var/atom/movable/screen/screen as anything in screens)
		screen.update_by_hud(hud)

/atom/movable/screen/complex/remove_from_hud(datum/hud/hud)
	. = ..()

	for(var/atom/movable/screen/screen as anything in screens)
		screen.remove_from_hud(hud)

// Human inventory
/atom/movable/screen/complex/human
	name = "toggle"
	icon_state = "other"
	screen_loc = ui_inventory
	plane = ABOVE_HUD_PLANE

	types = list(
		/atom/movable/screen/inventory/uniform,
		/atom/movable/screen/inventory/suit,
		/atom/movable/screen/inventory/mask,
		/atom/movable/screen/inventory/gloves,
		/atom/movable/screen/inventory/eyes,
		/atom/movable/screen/inventory/l_ear,
		/atom/movable/screen/inventory/r_ear,
		/atom/movable/screen/inventory/head,
		/atom/movable/screen/inventory/shoes,
	)

/atom/movable/screen/complex/human/action()
	..()
	usr.hud_used.inventory_shown = shown
	usr.hud_used.hidden_inventory_update()

// Act intent
/atom/movable/screen/complex/act_intent
	name = "act_intent"
	screen_loc = ui_acti
	plane = ABOVE_HUD_PLANE

	hud_slot = hud_slot_main
	copy_flags = hud_copy_icon

	types = list(
		/atom/movable/screen/intent/help, /atom/movable/screen/intent/push,
		/atom/movable/screen/intent/grab, /atom/movable/screen/intent/harm
	)
	screens_slot = hud_slot_main
	shown = TRUE // always shown

/atom/movable/screen/complex/act_intent/atom_init()
	. = ..()
	for(var/atom/movable/screen/screen as anything in screens)
		screen.update_icon(src)
		screen.screen_loc = src.screen_loc

/atom/movable/screen/complex/act_intent/action()
	usr.a_intent_change(INTENT_HOTKEY_RIGHT)

/atom/movable/screen/complex/act_intent/update_icon(mob/mymob)
	icon_state = "intent_" + mymob.a_intent

/atom/movable/screen/complex/act_intent/add_to_hud(datum/hud/hud)
	. = ..()
	update_icon(hud.mymob)

// Toggleable sequential lists
/atom/movable/screen/complex/ordered
	var/loc_prefix
	var/loc_postgix
	var/start_position

/atom/movable/screen/complex/ordered/atom_init()
	. = ..()
	var/position = start_position
	for(var/atom/movable/screen/screen as anything in screens)
		screen.screen_loc = "[loc_prefix][position][loc_postgix]"
		position++

/atom/movable/screen/complex/ordered/robot_pda
	name = "Show Pda Screens"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "pda"
	screen_loc = ui_borg_show_pda
	plane = ABOVE_HUD_PLANE

	types = list(
		/atom/movable/screen/robot_pda/send, /atom/movable/screen/robot_pda/log,
		/atom/movable/screen/robot_pda/ringtone, /atom/movable/screen/robot_pda/toggle,
	)
	loc_prefix = "SOUTH+"
	loc_postgix = ":6,WEST"
	start_position = 2

/atom/movable/screen/complex/ordered/robot_image
	name = "Show Foto Screens"
	icon = 'icons/mob/screen1_robot.dmi'
	icon_state = "photo"
	screen_loc = ui_borg_show_foto
	plane = ABOVE_HUD_PLANE

	types = list(
		/atom/movable/screen/robot_image/take, /atom/movable/screen/robot_image/view,
		/atom/movable/screen/robot_image/delete
	)
	loc_prefix = "SOUTH+"
	loc_postgix = ":6,WEST+1"
	start_position = 2
