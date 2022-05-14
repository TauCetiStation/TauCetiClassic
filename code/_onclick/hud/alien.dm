/atom/movable/screen/xenomorph
	icon = 'icons/mob/screen1_xeno.dmi'

/atom/movable/screen/xenomorph/leap
	name = "toggle leap"
	icon_state = "leap_off"
	screen_loc = ui_storage2

/atom/movable/screen/xenomorph/leap/action()
	if(isxenoadult(usr))
		var/mob/living/carbon/xenomorph/humanoid/hunter/AH = usr
		AH.toggle_leap()

/atom/movable/screen/xenomorph/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision

/atom/movable/screen/xenomorph/nightvision/action()
	if(isxeno(usr))
		var/mob/living/carbon/xenomorph/A = usr
		A.toggle_nvg()

/atom/movable/screen/xenomorph/neurotoxin
	name = "toggle neurotoxin"
	icon_state = "neurotoxin0"
	screen_loc = ui_storage1

/atom/movable/screen/xenomorph/neurotoxin/action()
	var/mob/living/carbon/xenomorph/humanoid/AH = usr
	AH.toggle_neurotoxin()

/atom/movable/screen/xenomorph/plasma_display
	name = "plasma stored"
	icon = 'icons/mob/screen1_xeno.dmi'
	icon_state = "power_display3"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/xenomorph/plasma_display/update_icon(mymob)
	var/mob/living/carbon/xenomorph/X = mymob
	X.updatePlasmaDisplay()

/datum/hud/proc/alien_hud()
	var/style = 'icons/mob/screen1_xeno.dmi'

	src.adding = list()
	src.other = list()

	var/atom/movable/screen/using
	var/atom/movable/screen/inventory/inv_box

	using = new /atom/movable/screen/act_intent/alien()
	using.update_icon(mymob)
	src.adding += using
	action_intent = using

//intent small hud objects
	using = new /atom/movable/screen/intent/help()
	using.update_icon(style)
	src.adding += using
	help_intent = using

	using = new /atom/movable/screen/intent/push()
	using.update_icon(style)
	src.adding += using
	push_intent = using

	using = new /atom/movable/screen/intent/grab()
	using.update_icon(style)
	src.adding += using
	grab_intent = using

	using = new  /atom/movable/screen/intent/harm()
	using.update_icon(style)
	src.adding += using
	harm_intent = using

//end intent small hud objects

	using = new /atom/movable/screen/move_intent/alien()
	using.update_icon(mymob)
	src.adding += using
	move_intent = using

	using = new /atom/movable/screen/drop/alien()
	src.adding += using

	inv_box = new /atom/movable/screen/inventory/hand/r/alien()
	src.r_hand_hud_object = inv_box
	src.adding += inv_box

	inv_box = new /atom/movable/screen/inventory/hand/l/alien()
	src.l_hand_hud_object = inv_box
	src.adding += inv_box

	using = new /atom/movable/screen/inventory/swap/first/alien()
	src.adding += using

	using = new/atom/movable/screen/inventory/swap/second/alien()
	src.adding += using

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	src.adding += mymob.nightvisionicon

	using = new /atom/movable/screen/resist/alien()
	src.adding += using

	if(isxenohunter(mymob))
		mymob.leap_icon = new /atom/movable/screen/xenomorph/leap()
		src.adding += mymob.leap_icon

	if(locate(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin) in mymob.verbs)
		mymob.neurotoxin_icon = new /atom/movable/screen/xenomorph/neurotoxin()
		src.adding += mymob.neurotoxin_icon

	mymob.throw_icon = new /atom/movable/screen/throw/alien()

	using = new /atom/movable/screen/xenomorph/plasma_display()
	using.update_icon(mymob)
	mymob.xenomorph_plasma_display = using

	mymob.healths = new /atom/movable/screen/health/alien()

	mymob.pullin = new /atom/movable/screen/pull/alien()
	mymob.pullin.update_icon(mymob)

	mymob.zone_sel = new /atom/movable/screen/zone_sel/alien()
	mymob.zone_sel.update_icon()

	mymob.client.screen = list()

	mymob.client.screen += list( mymob.throw_icon, mymob.zone_sel, mymob.healths, mymob.xenomorph_plasma_display, mymob.pullin) //, mymob.hands, mymob.rest, mymob.sleep, mymob.mach )
	mymob.client.screen += src.adding + src.other
	mymob.client.screen += mymob.client.void
