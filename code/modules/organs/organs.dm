/****************************************************
				INTERNAL ORGANS
****************************************************/
/mob/living/carbon/var/list/organs = list()
/mob/living/carbon/var/list/organs_by_name = list() // so internal organs have less ickiness too

/obj/item/organ
	name = "organ"
	var/mob/living/carbon/owner = null
	var/damage = 0 // amount of damage to the organ
	var/max_damage // Damage cap
	var/min_bruised_damage = 10
	var/min_broken_damage = 30
	var/organ_tag = null // Unique identifier
	var/parent_bodypart = null
	var/robotic = 0 //For being a robot
	var/status = 0
	var/vital = 0
	germ_level = 0 // INTERNAL germs inside the organ, this is BAD if it's greater than INFECTION_LEVEL_ONE


/obj/item/organ/New(loc, mob/living/carbon/C)
	if(!max_damage)
		max_damage = min_broken_damage * 2

	if(istype(C))
		owner = C
		//w_class = max(w_class + mob_size_difference(owner.mob_size, MOB_MEDIUM), 1) //smaller mobs have smaller organs.

		owner.organs += src
		owner.organs_by_name[organ_tag] = src

		var/obj/item/bodypart/BP = owner.bodyparts_by_name[parent_bodypart]
		if(!BP)
			CRASH("[src] spawned in [owner] without a parent bodypart: [parent_bodypart].")

		BP.organs += src
		if(BP.species.flags[IS_SYNTHETIC])
			src.mechanize()

	create_reagents(5 * (w_class-1)**2)
	reagents.add_reagent("nutriment", reagents.maximum_volume) // Bay12: protein

	return ..()

/obj/item/organ/Destroy()
	if(owner)
		var/obj/item/bodypart/BP = owner.bodyparts_by_name[parent_bodypart]
		if(BP)
			BP.organs -= src

		owner.organs_by_name[organ_tag] = null
		owner.organs_by_name -= organ_tag
		owner.organs -= src

		owner = null

	return ..()

/obj/item/organ/proc/removed(mob/living/user, detach = 1)
	if(!istype(owner))
		return

	owner.organs_by_name[organ_tag] = null
	owner.organs_by_name -= organ_tag
	owner.organs -= src

	if(detach)
		var/obj/item/bodypart/BP = owner.get_bodypart(parent_bodypart)
		if(BP)
			BP.organs -= src
			status |= ORGAN_CUT_AWAY
		forceMove(owner.loc) // dropInto(owner.loc)

	START_PROCESSING(SSobj, src)
	//rejecting = null
	if(robotic < ORGAN_ROBOT)
		var/datum/reagent/blood/organ_blood = locate(/datum/reagent/blood) in reagents.reagent_list //TODO fix this and all other occurences of locate(/datum/reagent/blood) horror
		if(!organ_blood || !organ_blood.data["blood_DNA"])
			owner.vessel.trans_to(src, 5, 1, 1)

	if(vital)
		if(user)
			user.attack_log += "\[[time_stamp()]\]<font color='red'>Removed a vital organ ([src]) from [owner.name] ([owner.ckey])</font>"
			owner.attack_log += "\[[time_stamp()]\]<font color='orange'>Had a vital organ ([src]) removed by [user.name] ([user.ckey])</font>"
			msg_admin_attack("[user.name] ([user.ckey]) removed a vital organ ([src]) from [owner.name] ([owner.ckey]) ([ADMIN_JMP(user)])")
		owner.death()

	owner = null

/obj/item/organ/process()
	//dead already, no need for more processing
	if(status & ORGAN_DEAD)
		return

	// Don't process if we're in a freezer, an MMI or a stasis bag.or a freezer or something I dunno
	if(istype(loc,/obj/item/device/mmi))
		return
	if(istype(loc,/obj/structure/closet/body_bag/cryobag) || istype(loc,/obj/structure/closet/crate/freezer) || istype(loc,/obj/structure/closet/secure_closet/freezer))
		return
	//Process infections
	if ((robotic >= 2) || (owner && owner.species && (owner.species.flags[IS_PLANT])))
		germ_level = 0
		return

	if(!owner && reagents)
		var/datum/reagent/blood/B = locate(/datum/reagent/blood) in reagents.reagent_list
		if(B && prob(40))
			reagents.remove_reagent("blood",0.1)
			blood_splatter(src, B, 1)
		damage = min(damage += rand(1,3), max_damage)
		germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_TWO)
			germ_level += rand(2,6)
		if(germ_level >= INFECTION_LEVEL_THREE)
			die()

	else if(owner && owner.bodytemperature >= 170)	//cryo stops germs from moving and doing their bad stuffs
		//** Handle antibiotics and curing infections
		handle_antibiotics()
		//handle_rejection() <- NOTE: blood rejection related
		handle_germ_effects()

	//check if we've hit max_damage
	if(damage >= max_damage)
		die()

/obj/item/organ/proc/die()
	if(robotic >= 2)
		return
	damage = max_damage
	status |= ORGAN_DEAD
	STOP_PROCESSING(SSobj, src)
	if(owner && vital)
		owner.death()

/obj/item/organ/proc/handle_germ_effects()
	//** Handle the effects of infections
	var/antibiotics = owner.reagents.get_reagent_amount("spaceacillin")

	if (germ_level > 0 && germ_level < INFECTION_LEVEL_ONE/2 && prob(30))
		germ_level--

	if (germ_level >= INFECTION_LEVEL_ONE/2)
		//aiming for germ level to go from ambient to INFECTION_LEVEL_TWO in an average of 15 minutes
		if(antibiotics < 5 && prob(round(germ_level/6)))
			germ_level++

	if(germ_level >= INFECTION_LEVEL_ONE)
		var/fever_temperature = (owner.species.heat_level_1 - owner.species.body_temperature - 5)* min(germ_level/INFECTION_LEVEL_TWO, 1) + owner.species.body_temperature
		owner.bodytemperature += between(0, (fever_temperature - T20C)/BODYTEMP_COLD_DIVISOR + 1, fever_temperature - owner.bodytemperature)

	if (germ_level >= INFECTION_LEVEL_TWO)
		var/obj/item/bodypart/parent = owner.get_bodypart(parent_bodypart)
		//spread germs
		if (antibiotics < 5 && parent.germ_level < germ_level && ( parent.germ_level < INFECTION_LEVEL_ONE*2 || prob(30) ))
			parent.germ_level++

		if (prob(3))	//about once every 30 seconds
			take_damage(1,silent=prob(30))

/obj/item/organ/proc/receive_chem(chemical)
	return 0

/obj/item/organ/proc/rejuvenate()
	damage = 0

/obj/item/organ/proc/is_bruised()
	return damage >= min_bruised_damage

/obj/item/organ/proc/is_broken()
	return damage >= min_broken_damage

/obj/item/organ/proc/take_damage(amount, silent=0)
	if(src.robotic == 2)
		src.damage += (amount * 0.8)
	else
		src.damage += amount

	var/obj/item/bodypart/parent = owner.get_bodypart(parent_bodypart)
	if (!silent)
		owner.custom_pain("Something inside your [parent.name] hurts a lot.", 1)

/obj/item/organ/emp_act(severity)
	if(!robotic)
		return

	switch(robotic)
		if(1)
			switch(severity)
				if(1)
					take_damage(20)
				if(2)
					take_damage(7)
				if(3)
					take_damage(3)
		if(2)
			switch(severity)
				if(1)
					take_damage(40)
				if(2)
					take_damage(15)
				if(3)
					take_damage(10)

/obj/item/organ/proc/mechanize() //Being used to make robutt hearts, etc
	robotic = 2

/obj/item/organ/proc/mechassist() //Used to add things like pacemakers, etc
	robotic = 1
	min_bruised_damage = 15
	min_broken_damage = 35

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
					custom_pain("You feel broken bones moving in your [BP.name]!", 1)
					IO.take_damage(rand(3,5))

				//Moving makes open wounds get infected much faster
				if (BP.wounds.len)
					for(var/datum/wound/W in BP.wounds)
						if (W.infection_check())
							W.germ_level += 1

			if(BP.name in list(BP_L_LEG, BP_R_LEG) && !lying)
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
	var/obj/item/bodypart/BP = bodyparts_by_name[BP_L_LEG]
	if(!BP || BP.is_stump())
		can_stand--

	BP = bodyparts_by_name[BP_R_LEG]
	if(!BP || BP.is_stump())
		can_stand--

/****************************************************
				INTERNAL ORGANS DEFINES
****************************************************/

/obj/item/organ/heart
	name = "heart"
	organ_tag = BP_HEART
	parent_bodypart = BP_CHEST


/obj/item/organ/lungs
	name = "lungs"
	organ_tag = BP_LUNGS
	parent_bodypart = BP_CHEST

/obj/item/organ/lungs/process()
	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(5))
			owner.emote("cough")		//respitory tract infection

	if(is_bruised())
		if(prob(2))
			owner.visible_message(
				"<B>\The [owner]</B> coughs up blood!",
				"<span class='warning'>You cough up blood!</span>",
				"You hear someone coughing!",
			)
			owner.drip(10)
		if(prob(4))
			owner.visible_message(
				"<B>\The [owner]</B> gasps for air!",
				"<span class='danger'>You can't breathe!</span>",
				"You hear someone gasp for air!",
			)
			owner.losebreath += 15

/obj/item/organ/liver
	name = "liver"
	organ_tag = BP_LIVER
	parent_bodypart = BP_CHEST
	var/process_accuracy = 10

/obj/item/organ/liver/process()
	..()

	if(!owner)
		return

	if (germ_level > INFECTION_LEVEL_ONE)
		if(prob(1))
			to_chat(owner, "<span class='danger'>Your skin itches.</span>")
	if (germ_level > INFECTION_LEVEL_TWO)
		if(prob(1))
			INVOKE_ASYNC(owner, /mob/living/carbon/human.proc/vomit)

	if(owner.life_tick % process_accuracy == 0)
		if(src.damage < 0)
			src.damage = 0

		//High toxins levels are dangerous
		if(owner.getToxLoss() >= 60 && !owner.reagents.has_reagent("anti_toxin"))
			//Healthy liver suffers on its own
			if (src.damage < min_broken_damage)
				src.damage += 0.2 * process_accuracy
			//Damaged one shares the fun
			else
				var/obj/item/organ/IO = pick(owner.organs)
				if(IO && IO.robotic < 2)
					IO.take_damage(0.2 * process_accuracy)

		//Detox can heal small amounts of damage
		if (src.damage && src.damage < src.min_bruised_damage && owner.reagents.has_reagent("anti_toxin"))
			src.damage = max(0, src.damage - 0.2 * process_accuracy)

		// Get the effectiveness of the liver.
		var/filter_effect = 3
		if(is_bruised())
			filter_effect -= 1
		if(is_broken())
			filter_effect -= 2

		// Do some reagent processing.
		if(filter_effect < 3)
			for(var/datum/reagent/R in owner.reagents.reagent_list)
				// Ethanol and all drinks are bad
				if(istype(R, /datum/reagent/ethanol))
					if(!filter_effect)
						owner.adjustToxLoss(0.1 * process_accuracy)
					else
						take_damage(0.1 * process_accuracy, prob(1))
				// Can't cope with toxins at all
				if(istype(R, /datum/reagent/toxin))
					if(!filter_effect)
						owner.adjustToxLoss(0.3 * process_accuracy)
					else
						take_damage(0.3 * process_accuracy, prob(1))

/*
	//Blood regeneration if there is some space
	var/blood_volume_raw = owner.vessel.get_reagent_amount("blood")
	if(blood_volume_raw < species.blood_volume)
		var/datum/reagent/blood/B = owner.get_blood(owner.vessel)
		B.volume += 0.1 // regenerate blood VERY slowly
		//if(CE_BLOODRESTORE in owner.chem_effects)
		//	B.volume += owner.chem_effects[CE_BLOODRESTORE]

	// Blood loss or liver damage make you lose nutriments
	var/blood_volume = owner.get_effective_blood_volume()
	if(blood_volume < BLOOD_VOLUME_SAFE || is_bruised())
		if(owner.nutrition >= 300)
			owner.nutrition -= 10
		else if(owner.nutrition >= 200)
			owner.nutrition -= 3
*/

/obj/item/organ/kidneys
	name = "kidneys"
	organ_tag = BP_KIDNEYS
	parent_bodypart = BP_CHEST

/obj/item/organ/brain
	name = "brain"
	organ_tag = BP_BRAIN
	parent_bodypart = BP_HEAD

/obj/item/organ/eyes
	name = "eyes"
	organ_tag = BP_EYES
	parent_bodypart = BP_HEAD

/obj/item/organ/eyes/process() //Eye damage replaces the old eye_stat var.
	..()
	if(is_bruised())
		owner.eye_blurry = 20
	if(is_broken())
		owner.eye_blind = 20
