/mob/living/carbon/human/var/list/bodyparts = list()
/mob/living/carbon/human/var/list/bodyparts_by_name = list()
/mob/living/carbon/human/var/list/organs = list()
/mob/living/carbon/human/var/list/organs_by_name = list()

/obj/item/organ
	name = "organ"
	germ_level = 0

	// Strings.
	var/parent_bodypart                // Bodypart holding this object.

	// Status tracking.
	var/status = 0                     // Various status flags (such as robotic)
	var/vital                          // Lose a vital organ, die immediately.

	// Reference data.
	var/mob/living/carbon/human/owner  // Current mob owning the organ.
	var/list/autopsy_data = list()     // Trauma data for forensics.
	var/list/trace_chemicals = list()  // Traces of chemicals in the organ.
	var/obj/item/organ/external/parent // Master-limb.

	// Damage vars.
	var/min_broken_damage = 30         // Damage before becoming broken

/obj/item/organ/New(loc, mob/living/carbon/human/H)
	if(istype(H))
		insert_organ(H)

	return ..()

/obj/item/organ/proc/insert_organ(mob/living/carbon/human/H)
	STOP_PROCESSING(SSobj, src)

	loc = null
	owner = H

	if(parent_bodypart)
		parent = owner.bodyparts_by_name[parent_bodypart]

/obj/item/organ/process()
	return 0

/obj/item/organ/proc/receive_chem(chemical)
	return 0

/obj/item/organ/proc/get_icon(icon/race_icon, icon/deform_icon)
	return icon('icons/mob/human.dmi',"blank")

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

//Handles chem traces
/mob/living/carbon/human/proc/handle_trace_chems()
	//New are added for reagents to random bodyparts.
	for(var/datum/reagent/A in reagents.reagent_list)
		var/obj/item/organ/external/BP = pick(bodyparts)
		BP.trace_chemicals[A.name] = 100

//Adds autopsy data for used_weapon.
/obj/item/organ/proc/add_autopsy_data(used_weapon, damage)
	var/datum/autopsy_data/W = autopsy_data[used_weapon]
	if(!W)
		W = new()
		W.weapon = used_weapon
		autopsy_data[used_weapon] = W

	W.hits += 1
	W.damage += damage
	W.time_inflicted = world.time

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
		for(var/obj/item/organ/external/BP in bodyparts)
			bad_bodyparts += BP

	//processing organs is pretty cheap, do that first.
	for(var/obj/item/organ/internal/IO in organs)
		IO.process()

	if(!force_process && !bad_bodyparts.len)
		return

	for(var/obj/item/organ/external/BP in bad_bodyparts)
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
				if (BP.is_broken() && BP.bodypart_organs.len && prob(15))
					var/obj/item/organ/internal/IO = pick(BP.bodypart_organs)
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
	var/obj/item/organ/external/BP = bodyparts_by_name[BP_L_FOOT]
	if(BP.status & ORGAN_DESTROYED)
		can_stand--

	BP = bodyparts_by_name[BP_R_FOOT]
	if(BP.status & ORGAN_DESTROYED)
		can_stand--
