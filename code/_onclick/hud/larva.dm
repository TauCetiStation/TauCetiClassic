/atom/movable/screen/inventory/larva_mouth
	name = "mouth"
	icon = 'icons/mob/screen1_xeno.dmi'
	icon_state = "hand_larva_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND


/datum/hud/proc/larva_hud()
	var/atom/movable/screen/using

	add_intents('icons/mob/screen1_xeno.dmi')

	using = new /atom/movable/screen/move_intent/alien()
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen/inventory/larva_mouth()
	src.r_hand_hud_object = using
	src.adding += using

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	src.adding += mymob.nightvisionicon

	mymob.healths = new /atom/movable/screen/health/alien()

	mymob.pullin = new /atom/movable/screen/pull/alien()
	mymob.pullin.update_icon(mymob)

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.update_icon()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach )
