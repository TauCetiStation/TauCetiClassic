/atom/movable/screen/inventory/larva_mouth
	name = "mouth"
	icon = 'icons/mob/screen1_xeno.dmi'
	icon_state = "hand_larva_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND


/datum/hud/proc/larva_hud()
	ui_style = 'icons/mob/screen1_xeno.dmi'

	add_intents(ui_style)
	add_move_intent(ui_style)
	add_hands(r_type = /atom/movable/screen/inventory/larva_mouth, l_type = FALSE)
	add_nightvision_icon()
	add_healths(type = /atom/movable/screen/health/alien)
	add_pullin(ui_style)
	add_zone_sel(ui_style)
