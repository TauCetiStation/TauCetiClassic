/atom/movable/screen/inventory/tail
	name = "tail"
	icon = 'icons/mob/screen1_xeno.dmi'
	icon_state = "hand_tail_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND


/datum/hud/proc/facehugger_hud()
	var/atom/movable/screen/using

	add_intents('icons/mob/screen1_xeno.dmi')

	add_move_intent('icons/mob/screen1_xeno.dmi')

	using = new /atom/movable/screen/drop/alien()
	src.adding += using

	add_hands(r_type = /atom/movable/screen/inventory/tail)

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	src.adding += mymob.nightvisionicon

	add_healths(type = /atom/movable/screen/health/alien)

	mymob.pullin = new /atom/movable/screen/pull/alien()
	mymob.pullin.update_icon(mymob)

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.update_icon()

	mymob.client.screen += list( mymob.zone_sel, mymob.pullin)
