/mob/living/carbon/alien/humanoid/queen
	name = "alien queen"
	caste = "q"
	maxHealth = 300
	health = 300
	//icon = 'icons/mob/alienqueen.dmi'
	//icon_state = "queen_s"
	//pixel_x = -16
	status_flags = CANPARALYSE
	ventcrawler = 0


/mob/living/carbon/alien/humanoid/queen/New(loc, new_species = S_XENO_QUEEN)
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src

	//there should only be one queen
	for(var/mob/living/carbon/alien/humanoid/queen/Q in living_mob_list)
		if(Q == src)		continue
		if(Q.stat == DEAD)	continue
		if(Q.client)
			name = "alien princess ([rand(1, 999)])"	//if this is too cutesy feel free to change it/remove it.
			break

	real_name = src.name
	//verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin,/mob/living/carbon/alien/humanoid/proc/resin)
	..()


/mob/living/carbon/alien/humanoid/queen/handle_hud_icons_health()
	if (src.healths)
		if (src.stat != DEAD)
			switch(health)
				if(250 to INFINITY)
					src.healths.icon_state = "health0"
				if(200 to 250)
					src.healths.icon_state = "health1"
				if(150 to 200)
					src.healths.icon_state = "health2"
				if(100 to 150)
					src.healths.icon_state = "health3"
				if(50 to 100)
					src.healths.icon_state = "health4"
				if(0 to 50)
					src.healths.icon_state = "health5"
				else
					src.healths.icon_state = "health6"
		else
			src.healths.icon_state = "health7"


//Queen verbs
/*/mob/living/carbon/alien/humanoid/queen/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "queen_dead"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "queen_sleep"
	else
		icon_state = "queen_s"
	for(var/image/I in overlays_standing)
		overlays += I*/


/mob/living/carbon/alien/humanoid/queen/large
	icon = 'icons/mob/alienqueen.dmi'
	icon_state = "queen_s-old"
	pixel_x = -16

/*/mob/living/carbon/alien/humanoid/queen/large/update_icons()
	update_hud()		//TODO: remove the need for this to be here
	overlays.Cut()
	if(stat == DEAD)
		icon_state = "queen_dead-old"
	else if(stat == UNCONSCIOUS || lying || resting)
		icon_state = "queen_sleep-old"
	else
		icon_state = "queen_s-old"
	for(var/image/I in overlays_standing)
		overlays += I*/

/obj/effect/proc_holder/alien/lay_egg
	name = "Lay Egg"
	desc = "Lay an egg to produce huggers to impregnate prey with."
	plasma_cost = 75
	check_turf = 1
	action_icon_state = "alien_egg"

/obj/effect/proc_holder/alien/lay_egg/fire(mob/living/carbon/user)
	if(locate(/obj/effect/alien/egg) in get_turf(user))
		user << "There's already an egg here."
		return 0
	user.visible_message("<span class='alertalien'>[user] has laid an egg!</span>")
	new /obj/effect/alien/egg(user.loc)
	return 1
