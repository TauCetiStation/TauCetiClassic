/mob/living/carbon/xenomorph/humanoid/hunter/solo
	heal_rate = 2
	var/epoint = 0
	var/estage = 1

/mob/living/carbon/xenomorph/humanoid/hunter/solo/process(seconds_per_tick)
	. = ..()
	epoint += 1 * seconds_per_tick
	if(estage == 1 && epoint > 300)
		stage_two()
	if(estage == 2 && epoint > 600)
		stage_three()
	if(estage == 3 && epoint > 1200)
		stage_four()

/mob/living/carbon/xenomorph/humanoid/hunter/solo/proc/stage_two()
	estage = 2
	maxHealth = 240
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin)

/mob/living/carbon/xenomorph/humanoid/hunter/solo/proc/stage_three()
	estage = 3
	maxHealth = 300
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)

/mob/living/carbon/xenomorph/humanoid/hunter/solo/proc/stage_four(mob/user = usr)
	var/mob/living/carbon/xenomorph/humanoid/alien = /mob/living/carbon/xenomorph/humanoid/queen
	var/mob/new_xeno = new alien(user.loc)
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.real_name
	qdel(user)
