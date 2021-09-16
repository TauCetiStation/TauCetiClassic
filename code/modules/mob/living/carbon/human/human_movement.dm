/mob/living/carbon/human/movement_delay()
	if(iszombie(src))
		return zombie_movement_delay()
	if(ischangeling(src))
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		if(C.strained_muscles)
			if(!has_gravity(src))
				return -3   // speed boost in space.
			else
				return -2.5 // changeling ability also nulify any speed modifications and gives boost.

	if(!has_gravity(src))
		return -1 // It's hard to be slowed down in space by... anything

	var/tally = species.speed_mod

	if(is_type_organ(O_HEART, /obj/item/organ/internal/heart/ipc)) // IPC's heart is a servomotor, damaging it influences speed.
		var/obj/item/organ/internal/IO = organs_by_name[O_HEART]
		if(!IO) // If it's servomotor somehow is missing, it's absence should be treated as 100 damage to it.
			tally += 20
		else
			tally += IO.damage/5

	if(RUN in mutations)
		tally -= 0.5

	if(HAS_TRAIT(src, TRAIT_FAT))
		tally += 1.5

	if(crawling)
		tally += 7

	if(embedded_flag)
		handle_embedded_objects() // Moving with objects stuck in you can cause bad times.

	var/health_deficiency = (100 - health + halloss)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	var/hungry = (500 - get_nutrition()) / 5
	if(hungry >= 70) // Slow down if nutrition <= 150
		tally += hungry / 50

	if(buckled) // so, if we buckled we have large debuff
		tally += 5.5

	var/hands_or_legs
	if(istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
		hands_or_legs = list(BP_L_ARM , BP_R_ARM)
	else
		hands_or_legs = list(BP_L_LEG , BP_R_LEG)

	for(var/bodypart_name in hands_or_legs)
		var/obj/item/organ/external/BP = bodyparts_by_name[bodypart_name]
		if(!BP || (BP.is_stump))
			tally += 6
		else if(BP.status & ORGAN_SPLINTED)
			tally += 0.8
		else if(BP.status & ORGAN_BROKEN)
			tally += 3

	// hyperzine removes equipment slowdowns (no blood = no chemical effects).
	var/chem_slowdown_coeff = 1.0
	if(!species.flags[NO_BLOOD])
		if(reagents.has_reagent("nuka_cola"))
			chem_slowdown_coeff = 0.0
		else
			var/datum/reagent/hyperzine/H = reagents.get_reagent("hyperzine")
			if(H)
				chem_slowdown_coeff = 1.0 - H.hyp_tol

	if(wear_suit && wear_suit.slowdown && !species.flags[IS_SYNTHETIC] && !(wear_suit.slowdown > 0 ))
		tally += wear_suit.slowdown*chem_slowdown_coeff

	if(back && back.slowdown && !(back.slowdown > 0 ))
		tally += back.slowdown*chem_slowdown_coeff

	if (shoes)
		if (shoes.slowdown && !(shoes.slowdown > 0 ))
			tally += shoes.slowdown*chem_slowdown_coeff
	else
		tally += species.speed_mod_no_shoes

	if(!chem_slowdown_coeff)
		for(var/x in list(l_hand, r_hand))
			var/obj/item/I = x
			if(I && !(I.flags & ABSTRACT) && I.w_class >= SIZE_SMALL)
				tally += 0.5 * (I.w_class - 2) // (3 = 0.5) || (4 = 1) || (5 = 1.5)

	if(shock_stage >= 10)
		tally += round(log(3.5, shock_stage), 0.1) // (40 = ~3.0) and (starts at ~1.83)

	if(pull_debuff)
		tally += pull_debuff

	if(bodytemperature < species.cold_level_1)
		tally += (species.cold_level_1 - bodytemperature) / 10 * 1.75

	var/turf/T = get_turf(src)
	if(T)
		tally += T.slowdown
		var/obj/effect/fluid/F = locate(/obj/effect/fluid) in T
		if(F)
			tally += F.fluid_amount * 0.005

	if(get_species() == UNATHI && bodytemperature > species.body_temperature)
		tally -= min((bodytemperature - species.body_temperature) / 10, 1) //will be on the border of heat_level_1

	tally += max(2 * stance_damage, 0) //damaged/missing feet or legs is slow

	tally += mood_additive_speed_modifier

	return (tally + config.human_delay)

/mob/living/carbon/human/Process_Spacemove(movement_dir = 0)

	if(..())
		return 1

	//Do we have a working jetpack
	if(istype(back, /obj/item/weapon/tank/jetpack) && isturf(loc)) //Second check is so you can't use a jetpack in a mech
		var/obj/item/weapon/tank/jetpack/J = back
		if((movement_dir || J.stabilization_on) && J.allow_thrust(0.01, src))
			return 1
	return 0

/mob/living/carbon/human/mob_has_gravity()
	. = ..()
	if(!.)
		if(mob_negates_gravity())
			. = 1

/mob/living/carbon/human/mob_negates_gravity()
	return ((shoes && shoes.negates_gravity()) || (wear_suit && wear_suit.negates_gravity()))
