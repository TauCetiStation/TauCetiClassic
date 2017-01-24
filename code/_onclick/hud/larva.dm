/datum/hud/proc/larva_hud()

	src.adding = list()
	src.other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = new /obj/screen()
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	move_intent = using

	inv_box = new /obj/screen/inventory()
	inv_box.name = "mouth"
	inv_box.dir = WEST
	inv_box.icon = 'icons/mob/screen1_xeno.dmi'
	inv_box.icon_state = "hand_larva_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.slot_id = slot_r_hand
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	mymob.nightvisionicon = new /obj/screen/alien/nightvision()
	mymob.nightvisionicon.screen_loc = ui_alien_nightvision
	src.adding += mymob.nightvisionicon

	mymob.healths = new /obj/screen()
	mymob.healths.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.pullin = new /obj/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.zone_sel = new /obj/screen/zone_sel()
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
