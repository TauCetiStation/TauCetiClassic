/mob/living/carbon/xenomorph/humanoid/hunter/alien
	icon = 'icons/mob/xenomorph_solo.dmi'
	icon_state = "alien_s"
	caste = ""
	pixel_x = -8
	heal_rate = 2
	var/epoint = 0
	var/estage = 1

/mob/living/carbon/xenomorph/humanoid/hunter/alien/atom_init()
	. = ..()
	name = "alien"
	real_name = name
	alien_list[ALIEN_HUNTER] += src

/mob/living/carbon/xenomorph/humanoid/hunter/alien/Life()
	epoint += 1
	if(estage == 1 && epoint > 300)
		stage_two()
	if(estage == 2 && epoint > 600)
		stage_three()
	if(estage == 3 && epoint > 1200)
		stage_four()
	. = ..()

/mob/living/carbon/xenomorph/humanoid/hunter/alien/proc/stage_two()
	estage = 2
	maxHealth = 240
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/neurotoxin)

/mob/living/carbon/xenomorph/humanoid/hunter/alien/proc/stage_three()
	estage = 3
	maxHealth = 300
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)

/mob/living/carbon/xenomorph/humanoid/hunter/alien/proc/stage_four(mob/user = usr)
	var/mob/living/carbon/xenomorph/humanoid/alien = /mob/living/carbon/xenomorph/humanoid/queen
	var/mob/new_xeno = new alien(user.loc)
	user.mind.transfer_to(new_xeno)
	new_xeno.mind.name = new_xeno.real_name
	qdel(user)
