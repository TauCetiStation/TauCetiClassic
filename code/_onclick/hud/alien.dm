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
	icon_state = "power_display3"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/xenomorph/plasma_display/update_icon(mymob)
	var/mob/living/carbon/xenomorph/X = mymob
	X.updatePlasmaDisplay()

/datum/hud/proc/alien_hud()
	ui_style = 'icons/mob/screen1_xeno.dmi'

	var/atom/movable/screen/using

	add_intents(ui_style)
	add_move_intent(ui_style)
	add_hands(ui_style)

	var/list/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first/alien,
		/atom/movable/screen/inventory/swap/second/alien,
		/atom/movable/screen/resist,
	)
	init_screens(types, ui_style, list_to = hotkeybuttons)

	mymob.nightvisionicon = new /atom/movable/screen/xenomorph/nightvision()
	src.adding += mymob.nightvisionicon

	if(isxenohunter(mymob))
		mymob.leap_icon = new /atom/movable/screen/xenomorph/leap()
		src.adding += mymob.leap_icon

	if(locate(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin) in mymob.verbs)
		mymob.neurotoxin_icon = new /atom/movable/screen/xenomorph/neurotoxin()
		src.adding += mymob.neurotoxin_icon

	add_throw_icon(ui_style)

	using = new /atom/movable/screen/xenomorph/plasma_display()
	mymob.xenomorph_plasma_display = using
	using.update_icon(mymob)

	add_healths(type = /atom/movable/screen/health/alien)
	add_pullin(ui_style)
	add_zone_sel(ui_style)

	mymob.client.screen += list(mymob.xenomorph_plasma_display)
