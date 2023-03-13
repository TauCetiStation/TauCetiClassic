/mob/living/carbon/xenomorph/add_to_hud(datum/hud/hud)
	hud.ui_style = 'icons/hud/screen1_xeno.dmi'

	..(hud, FALSE)

	hud.init_screen(/atom/movable/screen/xenomorph/nightvision)
	hud.init_screen(/atom/movable/screen/health/alien)

/mob/living/carbon/xenomorph/facehugger/add_to_hud(datum/hud/hud)
	..()
	hud.init_screen(/atom/movable/screen/inventory/tail)

/mob/living/carbon/xenomorph/larva/add_to_hud(datum/hud/hud)
	..()
	hud.init_screen(/atom/movable/screen/inventory/larva_mouth)

/mob/living/carbon/xenomorph/humanoid/add_to_hud(datum/hud/hud)
	..()

	hud.init_screens(list(
		/atom/movable/screen/inventory/hand/r,
		/atom/movable/screen/inventory/hand/l,
		/atom/movable/screen/drop,
		/atom/movable/screen/swap/first,
		/atom/movable/screen/swap/second,
		/atom/movable/screen/resist,
		/atom/movable/screen/xenomorph/plasma_display,
		/atom/movable/screen/throw,
	))

	if(locate(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin) in verbs)
		hud.init_screen(/atom/movable/screen/xenomorph/neurotoxin)

/mob/living/carbon/xenomorph/humanoid/hunter/add_to_hud(datum/hud/hud)
	..()
	hud.init_screen(/atom/movable/screen/xenomorph/leap)
