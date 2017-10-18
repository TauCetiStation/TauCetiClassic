/mob/living/carbon/human/movement_delay()

	if(mind && mind.changeling && mind.changeling.strained_muscles)
		if(!has_gravity(src))
			adjustStaminaLoss(0.25)
			return -3   // speed boost in space.
		else
			adjustStaminaLoss(0.25)
			return -2.5 // changeling ability also nulify any speed modifications and gives boost.

	if(!has_gravity(src))
		adjustStaminaLoss(0.5)
		return -1 // It's hard to be slowed down in space by... anything
	var/staminacost = 0
	var/tally = species.speed_mod

	if(RUN in mutations)
		tally -= 0.5
		staminacost -= 5

	if(crawling)
		tally += 7
		staminacost += 0.25

	if(embedded_flag)
		handle_embedded_objects() // Moving with objects stuck in you can cause bad times.

	var/health_deficiency = (100 - health + halloss)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)
		tally += (100-stamina)/25

	var/hungry = (500 - nutrition) / 5 // So overeat would be 100 and default level would be 80
	if(hungry >= 70)
		tally += hungry / 50

	if(istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
		for(var/bodypart_name in list(BP_L_HAND , BP_R_HAND , BP_L_ARM , BP_R_ARM))
			var/obj/item/organ/external/BP = bodyparts_by_name[bodypart_name]
			if(!BP || (BP.status & ORGAN_DESTROYED))
				tally += 4
			else if(BP.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(BP.status & ORGAN_BROKEN)
				tally += 1.5
	else
		var/chem_nullify_debuff = FALSE
		if(!species.flags[NO_BLOOD] && ( reagents.has_reagent("hyperzine") || reagents.has_reagent("nuka_cola") )) // hyperzine removes equipment slowdowns (no blood = no chemical effects).
			chem_nullify_debuff = TRUE

		if(wear_suit && wear_suit.slowdown && !(wear_suit.slowdown > 0 && chem_nullify_debuff))
			tally += wear_suit.slowdown
			staminacost += wear_suit.slowdown/10

		if(back && back.slowdown && !(back.slowdown > 0 && chem_nullify_debuff))
			tally += back.slowdown
			staminacost += back.slowdown/10

		if(shoes && shoes.slowdown && !(shoes.slowdown > 0 && chem_nullify_debuff))
			tally += shoes.slowdown
			staminacost += shoes.slowdown/10

		if(!chem_nullify_debuff)
			for(var/x in list(l_hand, r_hand))
				var/obj/item/O = x
				if(O && !(O.flags & ABSTRACT) && O.w_class >= ITEM_SIZE_NORMAL)
					tally += 0.5 * (O.w_class - 2) // (3 = 0.5) || (4 = 1) || (5 = 1.5)

		if(buckled) // so, if we buckled we have large debuff
			tally += 5.5

		for(var/bodypart_name in list(BP_L_FOOT , BP_R_FOOT , BP_L_LEG , BP_R_LEG))
			var/obj/item/organ/external/BP = bodyparts_by_name[bodypart_name]
			if(!BP || (BP.status & ORGAN_DESTROYED))
				tally += 4
			else if(BP.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(BP.status & ORGAN_BROKEN)
				tally += 1.5

	if(shock_stage >= 10)
		tally += round(log(3.5, shock_stage), 0.1) // (40 = ~3.0) and (starts at ~1.83)

	if(pull_debuff)
		tally += pull_debuff
		staminacost += pull_debuff

	if(FAT in mutations)
		tally += 1.5
		staminacost += 0.5

	if(bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(m_intent == "run")
		staminacost += 0.25
	else if(m_intent == "sprint")
		staminacost += 1.0

	if(staminacost>0)
		adjustStaminaLoss(staminacost)

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
	return shoes && shoes.negates_gravity()
