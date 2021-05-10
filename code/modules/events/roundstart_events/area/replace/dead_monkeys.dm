/mob/living/carbon/monkey/dead
	stat = DEAD
	health = 0

/datum/event/roundstart/area/replace/dead_monkeys
	special_area_types = list(/area/station/medical/virology, /area/station/rnd/xenobiology, /area/asteroid/research_outpost/hallway)
	rand_special_area = TRUE

	replace_types = list(/mob/living/carbon/monkey = /mob/living/carbon/monkey/dead)
