/mob/living/simple_animal/ascendant_shadowling
	name = "ascendant shadowling"
	desc = "A large, floating eldritch horror. It has pulsing markings all about its body and large horns. It seems to be floating without any form of support."
	icon = 'icons/mob/shadowling.dmi'
	icon_state = "shadowling_ascended"
	icon_living = "shadowling_ascended"
	speak_emote = list("telepathically thunders", "telepathically booms")
	//force_threshold = INFINITY //Can't die by normal means
	health = 100000
	maxHealth = 100000
	speed = 0
	var/phasing = 0
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	w_class = SIZE_MASSIVE

	response_help   = "stares at"
	response_disarm = "flails at"
	response_harm   = "flails at"

	harm_intent_damage = 0
	melee_damage = 35
	attacktext = "claw"
	attack_sound = list('sound/weapons/slash.ogg')

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0

	minbodytemp = 0
	maxbodytemp = INFINITY
	environment_smash = 3

	faction = "faithless"

/mob/living/simple_animal/ascendant_shadowling/atom_init()
	. = ..()
	var/image/ascend = image(icon = 'icons/mob/shadowling.dmi', icon_state = "shadowling_ascended_ms", layer = ABOVE_LIGHTING_LAYER)
	ascend.plane = ABOVE_LIGHTING_PLANE
	add_overlay(ascend)

/mob/living/simple_animal/ascendant_shadowling/Life()
	..()
	if(pixel_y)
		pixel_y = 0
	else
		pixel_y = 1

//mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(movement_dir = 0)//TG
/mob/living/simple_animal/ascendant_shadowling/Process_Spacemove(movement_dir = 0)
	return TRUE //copypasta from carp code
