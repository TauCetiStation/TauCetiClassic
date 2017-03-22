/mob/living/carbon/var/list/organs_by_name = list() // so internal organs have less ickiness too

/obj/item/organ
	name = "organ"
	var/mob/living/carbon/owner = null

	germ_level = 0		// INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE

/obj/item/organ/process()
	return 0

/obj/item/organ/proc/receive_chem(chemical)
	return 0

//Germs
/obj/item/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

// Takes care of organ related updates, such as broken and missing limbs
/mob/living/carbon/proc/handle_organs()
	number_wounds = 0
	var/leg_tally = 2
	var/force_process = 0
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick
	if(force_process)
		bad_bodyparts.Cut()
		for(var/obj/item/bodypart/BP in bodyparts)
			bad_bodyparts += BP

	//processing internal organs is pretty cheap, do that first.
	for(var/obj/item/organ/IO in organs)
		IO.process()

	if(!force_process && !bad_bodyparts.len)
		return

	for(var/obj/item/bodypart/BP in bad_bodyparts)
		if(!BP)
			continue
		if(!BP.need_process())
			bad_bodyparts -= BP
			continue
		else
			BP.process()
			number_wounds += BP.number_wounds

			if (!lying && world.time - l_move_time < 15)
			//Moving around with fractured ribs won't do you any good
				if (BP.is_broken() && BP.organs && prob(15))
					var/obj/item/organ/IO = pick(BP.organs)
					custom_pain("You feel broken bones moving in your [BP.display_name]!", 1)
					IO.take_damage(rand(3,5))

				//Moving makes open wounds get infected much faster
				if (BP.wounds.len)
					for(var/datum/wound/W in BP.wounds)
						if (W.infection_check())
							W.germ_level += 1

			if(BP.name in list("l_leg", "r_leg") && !lying)
				if (!BP.is_usable() || BP.is_malfunctioning() || (BP.is_broken() && !(BP.status & ORGAN_SPLINTED)))
					leg_tally--			// let it fail even if just foot&leg

	// standing is poor
	if(leg_tally <= 0 && !paralysis && !(lying || resting) && prob(5))
		if(species && species.flags[NO_PAIN])
			emote("scream",,, 1)
		emote("collapse")
		paralysis = 10

	//Check arms and legs for existence
	can_stand = 2 //can stand on both legs
	var/obj/item/bodypart/BP = bodyparts_by_name["l_leg"]
	if(BP.status & ORGAN_DESTROYED)
		can_stand--

	BP = bodyparts_by_name["r_leg"]
	if(BP.status & ORGAN_DESTROYED)
		can_stand--
