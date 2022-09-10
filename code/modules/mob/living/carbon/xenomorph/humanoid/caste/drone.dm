/mob/living/carbon/xenomorph/humanoid/drone
	name = "alien drone"
	caste = "d"
	maxHealth = 160
	health = 160
	icon_state = "aliend_s"
	plasma_rate = 15
	speed = 1
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds,
						/obj/effect/proc_holder/spell/targeted/xeno_whisp,
						/obj/effect/proc_holder/spell/targeted/transfer_plasma,
						/obj/effect/proc_holder/spell/no_target/resin,
						/obj/effect/proc_holder/spell/no_target/air_plant,
						/obj/effect/proc_holder/spell/no_target/xenowinds,
						/obj/effect/proc_holder/spell/no_target/evolve_to_queen)


/mob/living/carbon/xenomorph/humanoid/drone/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien drone ([rand(1, 1000)])"
	real_name = name
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)
	alien_list[ALIEN_DRONE] += src
	. = ..()

/mob/living/carbon/xenomorph/humanoid/drone/Destroy()
	alien_list[ALIEN_DRONE] -= src
	return ..()

/mob/living/carbon/xenomorph/humanoid/drone/can_pickup(obj/O)
	if(istype(O, /obj/item/clothing/mask/facehugger))
		return TRUE
	return FALSE
