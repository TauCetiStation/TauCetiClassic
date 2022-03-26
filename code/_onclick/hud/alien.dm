/atom/movable/screen/xenomorph
	icon = 'icons/mob/screen1_xeno.dmi'

/atom/movable/screen/xenomorph/leap
	name = "toggle leap"
	icon_state = "leap_off"

/atom/movable/screen/xenomorph/leap/Click()
	if(isxenoadult(usr))
		var/mob/living/carbon/xenomorph/humanoid/hunter/AH = usr
		AH.toggle_leap()

/atom/movable/screen/xenomorph/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"

/atom/movable/screen/xenomorph/nightvision/Click()
	if(isxeno(usr))
		var/mob/living/carbon/xenomorph/A = usr
		A.toggle_nvg()

/atom/movable/screen/xenomorph/neurotoxin
	name = "toggle neurotoxin"
	icon_state = "neurotoxin0"

/atom/movable/screen/xenomorph/neurotoxin/Click()
	var/mob/living/carbon/xenomorph/humanoid/AH = usr
	AH.toggle_neurotoxin()

/datum/hud/proc/alien_hud()

	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen()
	using.name = "act_intent"
	using.set_dir(SOUTHWEST)
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = "intent_" + mymob.a_intent
	using.screen_loc = ui_acti
	using.layer = ABOVE_HUD_LAYER
	using.plane = ABOVE_HUD_PLANE
	src.adding += using
	action_intent = using

//intent small hud objects
	var/icon/ico

	ico = new('icons/mob/screen1_xeno.dmi', "black")
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

	ico = new('icons/mob/screen1_xeno.dmi', "black")
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

	ico = new('icons/mob/screen1_xeno.dmi', "black")
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

	ico = new('icons/mob/screen1_xeno.dmi', "black")
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
	inv_box.name = "r_hand"
	inv_box.set_dir(WEST)
	inv_box.icon = 'icons/mob/screen1_xeno.dmi'
	inv_box.icon_state = "hand_r_inactive"
	if(mymob && !mymob.hand)	//This being 0 or null means the right hand is in use
		inv_box.icon_state = "hand_r_active"
	inv_box.screen_loc = ui_rhand
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.slot_id = SLOT_R_HAND
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory()
	inv_box.name = "l_hand"
	inv_box.set_dir(EAST)
	inv_box.icon = 'icons/mob/screen1_xeno.dmi'
	inv_box.icon_state = "hand_l_inactive"
	if(mymob && mymob.hand)	//This being 1 means the left hand is in use
		inv_box.icon_state = "hand_l_active"
	inv_box.screen_loc = ui_lhand
	inv_box.layer = HUD_LAYER
	inv_box.plane = HUD_PLANE
	inv_box.slot_id = SLOT_L_HAND
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /atom/movable/screen/inventory()
	using.name = "hand"
	using.set_dir(SOUTH)
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = "swap_1"
	using.screen_loc = ui_swaphand1
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

	using = new /atom/movable/screen/inventory()
	using.name = "hand"
	using.set_dir(SOUTH)
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = "swap_2"
	using.screen_loc = ui_swaphand2
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	mymob.nightvisionicon.screen_loc = ui_alien_nightvision
	src.adding += mymob.nightvisionicon

	using = new /atom/movable/screen()
	using.name = "resist"
	using.icon = 'icons/mob/screen1_xeno.dmi'
	using.icon_state = "act_resist"
	using.screen_loc = ui_pull_resist
	using.layer = HUD_LAYER
	using.plane = HUD_PLANE
	src.adding += using

	if(isxenohunter(mymob))
		mymob.leap_icon = new /atom/movable/screen/xenomorph/leap()
		mymob.leap_icon.screen_loc = ui_storage2
		src.adding += mymob.leap_icon

	if(locate(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin) in mymob.verbs)
		mymob.neurotoxin_icon = new /atom/movable/screen/xenomorph/neurotoxin()
		mymob.neurotoxin_icon.screen_loc = ui_storage1
		src.adding += mymob.neurotoxin_icon

	mymob.throw_icon = new /atom/movable/screen()
	mymob.throw_icon.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.throw_icon.icon_state = "act_throw_off"
	mymob.throw_icon.name = "throw"
	mymob.throw_icon.screen_loc = ui_drop_throw

	mymob.xenomorph_plasma_display = new /atom/movable/screen()
	mymob.xenomorph_plasma_display.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.xenomorph_plasma_display.icon_state = "power_display3"
	mymob.xenomorph_plasma_display.name = "plasma stored"
	mymob.xenomorph_plasma_display.screen_loc = ui_alienplasmadisplay
	var/mob/living/carbon/xenomorph/X = mymob
	X.updatePlasmaDisplay()

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
	mymob.zone_sel.icon = 'icons/mob/screen1_xeno.dmi'
	mymob.zone_sel.cut_overlays()
	mymob.zone_sel.add_overlay(image('icons/mob/zone_sel.dmi', "[mymob.get_targetzone()]"))

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.healths, mymob.xenomorph_plasma_display, mymob.pullin) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
