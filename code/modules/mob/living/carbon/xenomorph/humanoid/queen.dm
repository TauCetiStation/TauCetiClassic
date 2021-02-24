/mob/living/carbon/xenomorph/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 400
	health = 400
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s"
	pixel_x = -16
	layer = FLY_LAYER
	status_flags = CANPARALYSE
	heal_rate = 4
	plasma_rate = 20
	neurotoxin_delay = 10
	ventcrawler = 0
	mob_size = MOB_LARGE


/mob/living/carbon/xenomorph/humanoid/queen/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien queen ([rand(1, 1000)])"
	real_name = name
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid,/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin,/mob/living/carbon/xenomorph/humanoid/proc/resin,/mob/living/carbon/xenomorph/humanoid/proc/screech)
	alien_list[ALIEN_QUEEN] += src
	. = ..()

/mob/living/carbon/xenomorph/humanoid/queen/Destroy()
	alien_list[ALIEN_QUEEN] -= src
	return ..()

//Queen verbs
/mob/living/carbon/xenomorph/humanoid/queen/verb/lay_egg()

	set name = "Lay Egg (75)"
	set desc = "Lay an egg to produce huggers to impregnate prey with."
	set category = "Alien"

	if(locate(/obj/structure/alien/egg) in get_turf(src))
		to_chat(src, "There's already an egg here.")
		return

	if(powerc(75,1))//Can't plant eggs on spess tiles. That's silly.
		adjustToxLoss(-75)
		visible_message("<span class='notice'><B>[src] has laid an egg!</B></span>")
		new /obj/structure/alien/egg(loc)
	return

/mob/living/carbon/xenomorph/humanoid/queen/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	cut_overlays()
	if(stat == DEAD)
		icon_state = "queen_dead"
	else if((stat == UNCONSCIOUS && !IsSleeping()) || weakened)
		icon_state = "queen_l"
	else if(lying || resting)
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"
	for(var/image/I in overlays_standing)
		add_overlay(I)

/mob/living/carbon/xenomorph/humanoid/queen/movement_delay()
	return(3 + move_delay_add + config.alien_delay)

/mob/living/carbon/xenomorph/humanoid/queen/can_inject(mob/user, def_zone, show_message = TRUE, penetrate_thick = FALSE)
	return FALSE

/mob/living/carbon/xenomorph/humanoid/queen/large
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s-old"
	pixel_x = -16

/mob/living/carbon/xenomorph/humanoid/queen/large/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	cut_overlays()
	if(stat == DEAD)
		icon_state = "queen_dead-old"
	else if((stat == UNCONSCIOUS && !IsSleeping()) || weakened)
		icon_state = "queen_l-old"
	else if(lying || resting)
		icon_state = "queen_sleep-old"
	else
		icon_state = "queen_s-old"
	for(var/image/I in overlays_standing)
		add_overlay(I)
