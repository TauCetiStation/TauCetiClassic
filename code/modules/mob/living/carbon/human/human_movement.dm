/mob/living/carbon/human/movement_delay()
	var/tally = 0
	var/nullify_debuffs = FALSE

	if(ischangeling(src))
		var/datum/role/changeling/C = mind.GetRoleByType(/datum/role/changeling)
		if(C.strained_muscles)
			tally -= 2.5
			nullify_debuffs = TRUE

	if(!has_gravity(src) && !lying)
		return tally - 1 // It's hard to be slowed down in space by... anything

	if(iszombie(src))
		nullify_debuffs = TRUE

	tally += species.speed_mod

	if(RUN in mutations)
		tally -= 0.5

	if(lying)
		tally += 7
	if(m_intent == MOVE_INTENT_WALK && HAS_TRAIT(src, TRAIT_FAST_WALKER))
		tally -= 1.5

	if(!nullify_debuffs)
		if(is_type_organ(O_HEART, /obj/item/organ/internal/heart/ipc)) // IPC's heart is a servomotor, damaging it influences speed.
			var/obj/item/organ/internal/IO = organs_by_name[O_HEART]
			tally += IO ? IO.damage / 5 : 20 // If it's servomotor somehow is missing, it's absence should be treated as 100 damage to it.

		if(HAS_TRAIT(src, TRAIT_FAT))
			tally += 1.5

		if(embedded_flag)
			handle_embedded_objects() // Moving with objects stuck in you can cause bad times.

		var/health_deficiency = (100 - health + halloss)
		if(health_deficiency >= 40)
			tally += health_deficiency / 25

		var/hungry = 500 - get_satiation()
		if(hungry >= 350) // Slow down if nutrition <= 150
			tally += hungry / 250 // 1,4 - 2

		if(shock_stage >= 10)
			tally += round(log(3.5, shock_stage), 0.1) // (40 = ~3.0) and (starts at ~1.83)

		if(bodytemperature < species.cold_level_1)
			tally += 1.75 * (species.cold_level_1 - bodytemperature) / 10

	var/list/moving_bodyparts
	if(buckled) // so, if we buckled we have large debuff
		tally += 5.5
		if(istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
			moving_bodyparts = list(BP_L_ARM , BP_R_ARM)

	if(!moving_bodyparts)
		if(lying)
			moving_bodyparts = list(BP_L_LEG , BP_R_LEG, BP_L_ARM , BP_R_ARM)
		else
			moving_bodyparts = list(BP_L_LEG , BP_R_LEG)

	// Movement delay coming from heavy items being carried.
	var/weight_tally = 0
	// So you can have items causing you to go faster, and thus we need a seperate counter of weight negation
	// to not negate weight that is not there. ~Luduk
	var/weight_negation = 0

	var/bp_tally = 0
	var/bp_weight_negation = 0
	for(var/bodypart_name in moving_bodyparts)
		var/obj/item/organ/external/BP = bodyparts_by_name[bodypart_name]
		if(!BP?.is_usable())
			bp_tally += 12
		else if(BP.status & ORGAN_SPLINTED)
			bp_tally += 1.6
		else if(BP.status & ORGAN_BROKEN)
			bp_tally += 6
		else if(BP.pumped)
			bp_weight_negation += BP.pumped * 0.0072

	tally += bp_tally / moving_bodyparts.len
	weight_negation += bp_weight_negation / moving_bodyparts.len

	// cola removes equipment slowdowns (no blood = no chemical effects).
	var/chem_nullify_debuff = nullify_debuffs
	if(!species.flags[NO_BLOOD] && (reagents.has_reagent("hyperzine") || reagents.has_reagent("nuka_cola")))
		chem_nullify_debuff = TRUE

	// Currently there is a meme that `slowdown` var is not really weight, it's just a speed modifier
	var/item_slowdown = wear_suit?.slowdown
	if(item_slowdown)
		if(item_slowdown < 0)
			tally += item_slowdown
		else if(!chem_nullify_debuff)
			weight_tally += item_slowdown

	item_slowdown = back?.slowdown
	if(item_slowdown)
		if(item_slowdown < 0)
			tally += item_slowdown
		else if(!chem_nullify_debuff)
			weight_tally += item_slowdown

	if(shoes)
		item_slowdown = shoes.slowdown
		if(item_slowdown)
			if(item_slowdown < 0)
				tally += item_slowdown
			else if(!chem_nullify_debuff)
				weight_tally += item_slowdown
	else
		tally += species.speed_mod_no_shoes

	if(weight_tally > weight_negation)
		tally += weight_tally - weight_negation

	tally += count_pull_debuff()

	if(!chem_nullify_debuff)
		for(var/x in list(l_hand, r_hand))
			var/obj/item/I = x
			if(I && !(I.flags & ABSTRACT))
				if(I.w_class >= SIZE_NORMAL)
					tally += 0.25 * (I.w_class - 2) // (3 = 0.25) || (4 = 0.5) || (5 = 0.75)
				if(HAS_TRAIT(I, TRAIT_DOUBLE_WIELDED))
					tally += 0.25
				var/obj/item/weapon/shield/shield = I
				//give them debuff to speed for better combat stance control
				if(istype(shield) && shield.wall_of_shield_on)
					tally += 2

	var/turf/T = get_turf(src)
	if(T && (get_species() != SKRELL || shoes))
		tally += T.get_fluid_depth() * 0.0075 // in basic, waterpool have 800 depth
	if(T.slowdown)
		tally += T.slowdown

	if(get_species() == UNATHI && bodytemperature > species.body_temperature)
		tally -= min((bodytemperature - species.body_temperature) / 10, 1) //will be on the border of heat_level_1

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
