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

/atom/movable/screen/xenomorph/leap/update_icon(mob/living/carbon/xenomorph/humanoid/hunter/AH)
	icon_state = "leap_[AH.leap_on_click ? "on":"off"]"

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

	add_intents()
	add_move_intent()
	add_hands()

	var/list/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first/alien,
		/atom/movable/screen/inventory/swap/second/alien,
		/atom/movable/screen/resist,
	)
	init_screens(types, ui_style, list_to = hotkeybuttons)

	add_nightvision_icon()

	if(isxenohunter(mymob))
		add_leap_icon()

	if(locate(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin) in mymob.verbs)
		add_neurotoxin_icon()

	add_throw_icon()
	add_plasma_display()
	add_healths(type = /atom/movable/screen/health/alien)
	add_pullin(ui_style)
	add_zone_sel(ui_style)
