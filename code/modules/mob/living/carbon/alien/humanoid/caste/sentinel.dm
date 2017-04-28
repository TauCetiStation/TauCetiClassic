/mob/living/carbon/alien/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 150
	health = 150

	//icon_state = "aliens_s"

/mob/living/carbon/alien/humanoid/sentinel/New(loc, new_species = S_XENO_SENTINEL)
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	if(name == "alien sentinel")
		name = text("alien sentinel ([rand(1, 1000)])")
	real_name = name

	AddAbility(new /obj/effect/proc_holder/alien/sneak)

	//verbs.Add(/mob/living/carbon/alien/humanoid/proc/corrosive_acid,/mob/living/carbon/alien/humanoid/proc/neurotoxin)
	..()

/mob/living/carbon/alien/humanoid/sentinel/handle_hud_icons_health()
	if (healths)
		if (stat != DEAD)
			switch(health)
				if(125 to INFINITY)
					healths.icon_state = "health0"
				if(100 to 125)
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
