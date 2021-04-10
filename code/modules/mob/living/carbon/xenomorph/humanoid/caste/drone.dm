/mob/living/carbon/xenomorph/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 160
	health = 160
	icon_state = "aliend_s"
	plasma_rate = 15

/mob/living/carbon/xenomorph/humanoid/drone/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien drone ([rand(1, 1000)])"
	real_name = name
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/resin, /mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid, /mob/living/carbon/xenomorph/humanoid/proc/air_plant)
	alien_list[ALIEN_DRONE] += src
	. = ..()

/mob/living/carbon/xenomorph/humanoid/drone/Destroy()
	alien_list[ALIEN_DRONE] -= src
	return ..()

//Drones use the same base as generic humanoids.
//Drone verbs
/mob/living/carbon/xenomorph/humanoid/drone/verb/evolve() // -- TLE
	set name = "Evolve (500)"
	set desc = "Produce an interal egg sac capable of spawning children. Only one queen can exist at a time."
	set category = "Alien"

	if(!isturf(src.loc))
		to_chat(src, "<span class='warning'>You cannot evolve when you are inside something.</span>")//Silly aliens!
		return

	if(powerc(500))
		// Queen check
		var/no_queen = TRUE
		for(var/mob/living/carbon/xenomorph/humanoid/queen/Q in alien_list[ALIEN_QUEEN])
			if(Q.stat == DEAD || !Q.key)
				continue
			no_queen = FALSE

		if(src.has_brain_worms())
			to_chat(src, "<span class='warning'>We cannot perform this ability at the present time!</span>")
			return

		if(no_queen)
			to_chat(src, "<span class='notice'>You begin to evolve!</span>")
			visible_message("<span class='notice'><B>[src] begins to twist and contort!</B></span>")
			if(!do_after(src, 10 SECONDS, target = src))
				return
			adjustToxLoss(-500)
			var/mob/living/carbon/xenomorph/humanoid/queen/new_xeno = new (loc)
			mind.transfer_to(new_xeno)
			new_xeno.mind.name = new_xeno.real_name
			qdel(src)
		else
			to_chat(src, "<span class='notice'>We already have an alive queen.</span>")
	return

/mob/living/carbon/xenomorph/humanoid/drone/movement_delay()
	return(1 + move_delay_add + config.alien_delay)
