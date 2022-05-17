/atom/movable/screen/inventory/larva_mouth
	name = "mouth"
	icon = 'icons/mob/screen1_xeno.dmi'
	icon_state = "hand_larva_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND


/datum/hud/proc/larva_hud()
	var/style = 'icons/mob/screen1_xeno.dmi'

	add_intents(style)
	add_move_intent(style)
	add_hands(r_type = /atom/movable/screen/inventory/larva_mouth, l_type = null)

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	src.adding += mymob.nightvisionicon

	add_healths(type = /atom/movable/screen/health/alien)
	add_pullin(style)

	mymob.zone_sel = new /atom/movable/screen/zone_sel/alien()
	mymob.zone_sel.update_icon()

	mymob.client.screen += list( mymob.zone_sel)
