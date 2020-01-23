/mob/living/carbon/xenomorph/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 120
	health = 120
	icon_state = "aliend_s"
	plasma_rate = 15

/mob/living/carbon/xenomorph/humanoid/drone/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(src.name == "alien drone")
		src.name = text("alien drone ([rand(1, 1000)])")
	src.real_name = src.name
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/resin,/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)
	. = ..()

/mob/living/carbon/xenomorph/humanoid/drone/handle_hud_icons_health()
	if(healths)
		if (stat != DEAD)
			switch(health)
				if(120 to INFINITY)
					healths.icon_state = "health0"
				if(100 to 120)
					healths.icon_state = "health1"
				if(75 to 100)
					healths.icon_state = "health2"
				if(50 to 75)
					healths.icon_state = "health3"
				if(25 to 50)
					healths.icon_state = "health4"
				if(0 to 25)
					healths.icon_state = "health5"
				else
					healths.icon_state = "health6"
		else
			healths.icon_state = "health7"

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
		var/no_queen = 1
		for(var/mob/living/carbon/xenomorph/humanoid/queen/Q in queen_list)
			if(Q.stat == DEAD || !Q.key && Q.has_brain())
				continue
			no_queen = 0

		if(src.has_brain_worms())
			to_chat(src, "<span class='warning'>We cannot perform this ability at the present time!</span>")
			return

		if(no_queen)
			adjustToxLoss(-500)
			to_chat(src, "<span class='notice'>You begin to evolve!</span>")
			visible_message("<span class='notice'><B>[src] begins to twist and contort!</B></span>")
			var/mob/living/carbon/xenomorph/humanoid/queen/new_xeno = new (loc)
			mind.transfer_to(new_xeno)
			qdel(src)
		else
			to_chat(src, "<span class='notice'>We already have an alive queen.</span>")
	return

/mob/living/carbon/xenomorph/humanoid/drone/movement_delay()
	return(1 + move_delay_add + config.alien_delay)
