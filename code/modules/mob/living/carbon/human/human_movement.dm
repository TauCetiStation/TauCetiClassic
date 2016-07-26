/mob/living/carbon/human/movement_delay()
	var/tally = 0

	if(species && species.flags & IS_PLANT)
		tally = 7

	if(crawling)
		tally += 7
	else if((reagents.has_reagent("hyperzine")) && (src.get_species() != "Diona"))
		return -1

	if(istype(l_hand, /obj/item/weapon/gun))
		if(l_hand.w_class > 3)
			tally += 0.5
	if(istype(r_hand, /obj/item/weapon/gun))
		if(r_hand.w_class > 3)
			tally += 0.5

	if(!has_gravity(src))
		return -1 // It's hard to be slowed down in space by... anything

	if(embedded_flag)
		handle_embedded_objects() //Moving with objects stuck in you can cause bad times.

	if(reagents.has_reagent("nuka_cola"))
		return -1

	var/health_deficiency = (100 - health + halloss)
	if(health_deficiency >= 40)
		tally += (health_deficiency / 25)

	var/hungry = (500 - nutrition)/5 // So overeat would be 100 and default level would be 80
	if (hungry >= 70)
		tally += hungry/50

	if(wear_suit)
		tally += wear_suit.slowdown

	if(istype(buckled, /obj/structure/stool/bed/chair/wheelchair))
		for(var/organ_name in list("l_hand","r_hand","l_arm","r_arm"))
			var/datum/organ/external/E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				tally += 4
			else if(E.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(E.status & ORGAN_BROKEN)
				tally += 1.5
	else
		if(shoes)
			tally += shoes.slowdown

		if(buckled)	//so, if we buckled we have large debuff
			tally += 5.5

		for(var/organ_name in list("l_foot","r_foot","l_leg","r_leg"))
			var/datum/organ/external/E = get_organ(organ_name)
			if(!E || (E.status & ORGAN_DESTROYED))
				tally += 4
			else if(E.status & ORGAN_SPLINTED)
				tally += 0.5
			else if(E.status & ORGAN_BROKEN)
				tally += 1.5

	if(shock_stage >= 10)
		tally += 3

	if(pull_debuff)
		tally += pull_debuff

	if(FAT in src.mutations)
		tally += 1.5
	if (bodytemperature < 283.222)
		tally += (283.222 - bodytemperature) / 10 * 1.75

	if(RUN in src.mutations)
		tally = 0

	return (tally+config.human_delay)

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
