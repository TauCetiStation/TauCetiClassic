/mob/living/carbon/xenomorph/humanoid/maid
	name = "lusty alien maid"
	caste = "m"
	maxHealth = 160
	health = 160
	icon_state = "alienm_s"
	plasma_rate = 15
	alien_spells = list(/obj/effect/proc_holder/spell/no_target/weeds,
						/obj/effect/proc_holder/spell/targeted/xeno_whisp,
						/obj/effect/proc_holder/spell/targeted/transfer_plasma,
						/obj/effect/proc_holder/spell/no_target/resin,
						/obj/effect/proc_holder/spell/no_target/air_plant,
                        )


/mob/living/carbon/xenomorph/humanoid/maid/atom_init()
	var/datum/reagents/R = new/datum/reagents(100)
	reagents = R
	R.my_atom = src
	name = "alien maid ([rand(1, 1000)])"
	real_name = name
	verbs.Add(/mob/living/carbon/xenomorph/humanoid/proc/corrosive_acid)
	alien_list[ALIEN_MAID] += src
	. = ..()

/mob/living/carbon/xenomorph/humanoid/maid/Destroy()
	alien_list[ALIEN_MAID] -= src
	return ..()

/mob/living/carbon/xenomorph/humanoid/maid/movement_delay()
	return(1 + move_delay_add + config.alien_delay)

/mob/living/carbon/xenomorph/humanoid/maid/can_pickup(obj/O)
	if((istype(O, /obj/item/weapon/reagent_containers/spray)) || (istype(O, /obj/item/weapon/mop)) || (istype(O, /obj/item/weapon/storage/bag/trash)) || (istype(O, /obj/item/device/lightreplacer)) || (istype(O, /obj/item/weapon/reagent_containers/glass/bucket)) || (istype(O, /obj/item/weapon/reagent_containers/glass/rag)))
		return TRUE
	return FALSE
