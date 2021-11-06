/mob/living/carbon/xenomorph/humanoid/sentinel
	name = "alien sentinel"
	caste = "s"
	maxHealth = 200
	health = 200
	storedPlasma = 150
	max_plasma = 300
	icon_state = "aliens_s"
	plasma_rate = 10

/mob/living/carbon/xenomorph/humanoid/sentinel/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien sentinel ([rand(1, 1000)])"
	real_name = name
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid, /mob/living/carbon/xenomorph/humanoid/proc/neurotoxin, /mob/living/carbon/xenomorph/humanoid/proc/air_plant)
	alien_list[ALIEN_SENTINEL] += src
	. = ..()

/mob/living/carbon/xenomorph/humanoid/sentinel/Destroy()
	alien_list[ALIEN_SENTINEL] -= src
	return ..()

/mob/living/carbon/xenomorph/humanoid/sentinel/movement_delay()
	return(1 + move_delay_add + config.alien_delay)
