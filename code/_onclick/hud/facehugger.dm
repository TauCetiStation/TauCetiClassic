/datum/hud/proc/facehugger_hud()

	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen()
	using.name = "act_intent"
	using.icon = ui_style
	using.icon_state = "intent_" + mymob.a_intent
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	action_intent = using

	using = new /atom/movable/screen/inventory/craft
	src.adding += using

//intent small hud objects
	var/icon/ico

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,ico.Height()/2,ico.Width()/2,ico.Height())
	using = new /atom/movable/screen( src )
	using.name = INTENT_HELP
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	help_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,ico.Height()/2,ico.Width(),ico.Height())
	using = new /atom/movable/screen( src )
	using.name = INTENT_PUSH
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	push_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),ico.Width()/2,1,ico.Width(),ico.Height()/2)
	using = new /atom/movable/screen( src )
	using.name = INTENT_GRAB
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	grab_intent = using

	ico = new(ui_style, "black")
	ico.MapColors(0,0,0,0, 0,0,0,0, 0,0,0,0, 0,0,0,0, -1,-1,-1,-1)
	ico.DrawBox(rgb(255,255,255,1),1,1,ico.Width()/2,ico.Height()/2)
	using = new /atom/movable/screen( src )
	using.name = INTENT_HARM
	using.icon = ico
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	harm_intent = using

//end intent small hud objects

	using = new /atom/movable/screen()
	using.name = "mov_intent"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = (mymob.m_intent == "run" ? "running" : "walking")
	using.screen_loc = ui_movi
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen()
	using.name = "drop"
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = "act_drop"
	using.screen_loc = ui_drop_throw
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "tail"
	inv_box.set_dir(WEST)
	inv_box.icon = 'icons/mob/screen1_xeno.dmi'
	inv_box.icon_state = "hand_tail_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.slot_id = SLOT_R_HAND
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	mymob.nightvisionicon.screen_loc = ui_alien_nightvision
	src.adding += mymob.nightvisionicon

	mymob.healths = new /atom/movable/screen()
	mymob.healths.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.healths.icon_state = "health0"
	mymob.healths.name = "health"
	mymob.healths.screen_loc = ui_alien_health

	mymob.pullin = new /atom/movable/screen/pull()
	mymob.pullin.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.pullin.update_icon(mymob)
	mymob.pullin.screen_loc = ui_pull_resist

	mymob.zone_sel = new /atom/movable/screen/zone_sel()
	mymob.zone_sel.cut_overlays()
	mymob.zone_sel.add_overlay(image("icon" = 'icons/mob/zone_sel.dmi', "icon_state" = text("[]", mymob.get_targetzone())))

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.zone_sel, mymob.healths, mymob.pullin) //, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
