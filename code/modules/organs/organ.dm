/datum/organ
	var/name = "organ"
	var/mob/living/carbon/human/owner = null

	var/list/datum/autopsy_data/autopsy_data = list()
	var/list/trace_chemicals = list() // traces of chemicals in the organ,
									  // links chemical IDs to number of ticks for which they'll stay in the blood

	var/germ_level = 0		// INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE

	process()
		return 0

	proc/receive_chem(chemical)
		return 0

/datum/organ/proc/get_icon(icon/race_icon, icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")

//Germs
/datum/organ/proc/handle_antibiotics()
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (!germ_level || antibiotics < 5)
		return

	if (germ_level < INFECTION_LEVEL_ONE)
		germ_level = 0	//cure instantly
	else if (germ_level < INFECTION_LEVEL_TWO)
		germ_level -= 6	//at germ_level == 500, this should cure the infection in a minute
	else
		germ_level -= 2 //at germ_level == 1000, this will cure the infection in 5 minutes

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random bodyparts.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/datum/organ/external/BP = pick(bodyparts)
		BP.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/datum/organ/proc/add_autopsy_data(used_weapon, damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

/mob/living/carbon/human/var/list/bodyparts = list()
/mob/living/carbon/human/var/list/bodyparts_by_name = list() // map bodypart names to bodyparts
/mob/living/carbon/human/var/list/organs = list()
/mob/living/carbon/human/var/list/organs_by_name = list() // so organs have less ickiness too

// Takes care of bodypart and their organs related updates, such as broken and missing limbs
/mob/living/carbon/human/proc/handle_bodyparts()
	number_wounds = 0
	var/leg_tally = 2
	var/force_process = 0
	var/damage_this_tick = getBruteLoss() + getFireLoss() + getToxLoss()
	if(damage_this_tick > last_dam)
		force_process = 1
	last_dam = damage_this_tick
	if(force_process)
		bad_bodyparts.Cut()
		for(var/datum/organ/external/BP in bodyparts)
			bad_bodyparts += BP

	//processing organs is pretty cheap, do that first.
	for(var/datum/organ/internal/IO in organs)
		IO.process()

	if(!force_process && !bad_bodyparts.len)
		return

	for(var/datum/organ/external/BP in bad_bodyparts)
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
				if (BP.is_broken() && BP.bodypart_organs && prob(15))
					var/datum/organ/internal/IO = pick(BP.bodypart_organs)
					custom_pain("You feel broken bones moving in your [BP.name]!", 1)
					IO.take_damage(rand(3, 5))

				//Moving makes open wounds get infected much faster
				if (BP.wounds.len)
					for(var/datum/wound/W in BP.wounds)
						if (W.infection_check())
							W.germ_level += 1

			if((BP.body_zone in list(BP_L_LEG , BP_L_FOOT , BP_R_LEG , BP_R_FOOT)) && !lying)
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
	var/datum/organ/external/BP = bodyparts_by_name[BP_L_FOOT]
	if(BP.status & ORGAN_DESTROYED)
		can_stand--

	BP = bodyparts_by_name[BP_R_FOOT]
	if(BP.status & ORGAN_DESTROYED)
		can_stand--
