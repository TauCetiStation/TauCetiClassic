// basic screens
/atom/movable/screen/health/alien
	icon = 'icons/hud/screen2_xeno.dmi'
	screen_loc = ui_alien_health

/atom/movable/screen/xenomorph
	icon = 'icons/hud/screen1_xeno.dmi'

/atom/movable/screen/xenomorph/plasma_display
	name = "plasma stored"
	icon_state = "power_display3"
	screen_loc = ui_alienplasmadisplay

/atom/movable/screen/xenomorph/plasma_display/update_icon(mymob)
	var/mob/living/carbon/xenomorph/X = mymob
	X.updatePlasmaDisplay()

/atom/movable/screen/xenomorph/plasma_display/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.pwr_display = src
	update_icon(hud.mymob)

/atom/movable/screen/xenomorph/nightvision
	name = "toggle night-vision"
	icon_state = "nightvision1"
	screen_loc = ui_alien_nightvision

/atom/movable/screen/xenomorph/nightvision/action()
	if(isxeno(usr))
		var/mob/living/carbon/xenomorph/A = usr
		A.toggle_nvg()

/atom/movable/screen/xenomorph/nightvision/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.nightvisionicon = src

// adult xenos screes
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

/atom/movable/screen/xenomorph/leap/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.leap_icon = src

/atom/movable/screen/xenomorph/neurotoxin
	name = "toggle neurotoxin"
	icon_state = "neurotoxin0"
	screen_loc = ui_storage1

/atom/movable/screen/xenomorph/neurotoxin/action()
	var/mob/living/carbon/xenomorph/humanoid/AH = usr
	AH.toggle_neurotoxin()

/atom/movable/screen/xenomorph/neurotoxin/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.neurotoxin_icon = src

// larva
/atom/movable/screen/inventory/larva_mouth
	name = "mouth"
	icon = 'icons/hud/screen1_xeno.dmi'
	icon_state = "hand_larva_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND

/atom/movable/screen/inventory/larva_mouth/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.r_hand_hud_object = src

// facehugger
/atom/movable/screen/inventory/tail
	name = "tail"
	icon = 'icons/hud/screen1_xeno.dmi'
	icon_state = "hand_tail_active"
	screen_loc = ui_rhand
	slot_id = SLOT_R_HAND

/atom/movable/screen/inventory/tail/add_to_hud(datum/hud/hud)
	..()
	hud.mymob.r_hand_hud_object = src

