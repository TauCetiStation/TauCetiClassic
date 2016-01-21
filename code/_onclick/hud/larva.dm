/datum/hud/proc/larva_hud()

	src.adding = list()
	src.other = list()

	var/obj/screen/using
	var/obj/screen/inventory/inv_box

	using = PoolOrNew(/obj/screen)
	using.name = "mov_intent"
	using.dir = SOUTHWEST
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = 20
	src.adding += using
	move_intent = using

	inv_box = PoolOrNew(/obj/screen/inventory)
	inv_box.name = "mouth"
	inv_box.dir = WEST
	inv_box.icon = 'icons/mob/screen1_xeno.dmi'
	inv_box.icon_state = "hand_larva_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = 19
	inv_box.slot_id = slot_r_hand
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	mymob.nightvisionicon = PoolOrNew(/obj/screen/alien/nightvision)
	mymob.nightvisionicon.screen_loc = ui_alien_nightvision
	src.adding += mymob.nightvisionicon

	mymob.healths = PoolOrNew(/obj/screen)
	mymob.healths.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.pullin = PoolOrNew(/obj/screen)
	mymob.pullin.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.pullin.icon_state = "pull0"
	mymob.pullin.name = "pull"
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.blind = PoolOrNew(/obj/screen)
	mymob.blind.icon = 'icons/mob/screen1_full.dmi'
	mymob.blind.icon_state = "blackimageoverlay"
	mymob.blind.name = " "
	mymob.blind.screen_loc = "1,1"
	mymob.blind.layer = 0

	mymob.flash = PoolOrNew(/obj/screen)
	mymob.flash.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.flash.icon_state = "blank"
	mymob.flash.name = "flash"
	mymob.flash.screen_loc = "1,1 to 15,15"
	mymob.flash.layer = 17

	mymob.zone_sel = PoolOrNew(/obj/screen/zone_sel)
	mymob.zone_sel.overlays.Cut()
	mymob.zone_sel.overlays += image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.zone_sel.selecting))

	mymob.client.reset_screen()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, mymob.pullin, mymob.blind, mymob.flash) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
