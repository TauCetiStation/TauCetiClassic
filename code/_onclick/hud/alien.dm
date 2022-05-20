/datum/hud/proc/alien_base_hud()
	ui_style = 'icons/mob/screen1_xeno.dmi'

	add_intents()
	add_move_intent()
	add_nightvision_icon()
	add_healths(type = /atom/movable/screen/health/alien)
	add_pullin()
	add_zone_sel()

/datum/hud/proc/alien_hud()
	alien_base_hud()

	var/list/types = list(
		/atom/movable/screen/drop,
		/atom/movable/screen/inventory/swap/first/alien,
		/atom/movable/screen/inventory/swap/second/alien,
		/atom/movable/screen/resist,
	)
	init_screens(types)

	if(isxenohunter(mymob))
		add_leap_icon()

	if(locate(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin) in mymob.verbs)
		add_neurotoxin_icon()

	add_throw_icon()
	add_plasma_display()
