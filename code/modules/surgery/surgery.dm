/* SURGERY STEPS */

/datum/surgery_step
	var/priority = 0	//steps with higher priority would be attempted first

	// type path referencing tools that can be used for this step, and how well are they suited for it
	var/list/allowed_tools = null
	// type paths referencing mutantraces that this step applies to.
	var/list/allowed_species = null
	var/list/disallowed_species = list(IPC)

	// duration of the step
	var/min_duration = 0
	var/max_duration = 0

	// evil infection stuff that will make everyone hate me
	var/can_infect = 0
	//How much blood this step can get on surgeon. 1 - hands, 2 - full body.
	var/blood_level = 0

	//Cloth check
	var/clothless = 1

// returns how well tool is suited for this step
/datum/surgery_step/proc/tool_quality(obj/item/tool)
	for (var/T in allowed_tools)
		if (istype(tool,T))
			return allowed_tools[T]
	return 0

// Checks if this step applies to the mutantrace of the user.
/datum/surgery_step/proc/is_valid_mutantrace(mob/living/carbon/human/target)

	if(!ishuman(target)) // Juuuuust making sure.
		return TRUE

	if(allowed_species)
		for(var/species in allowed_species)
			if(("exclude" in allowed_species) && target.species.name == species)
				return FALSE
			else if(target.species.name == species)
				return TRUE

	if(disallowed_species)
		for(var/species in disallowed_species)
			if(("exclude" in disallowed_species) && target.species.name == species)
				return TRUE
			else if(target.species.name == species)
				return FALSE

	return TRUE

// checks whether this step can be applied with the given user and target
/datum/surgery_step/proc/can_use(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return 0

// does stuff to begin the step, usually just printing messages. Moved germs transfering and bloodying here too
/datum/surgery_step/proc/begin_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	var/obj/item/organ/external/BP = target.get_bodypart(target_zone)
	if (can_infect && BP)
		spread_germs_to_organ(BP, user)
	if (ishuman(user) && prob(60))
		var/mob/living/carbon/human/H = user
		if (blood_level)
			H.bloody_hands(target,0)
		if (blood_level > 1)
			H.bloody_body(target,0)
	return

// does stuff to end the step, which is normally print a message + do whatever this step changes
/datum/surgery_step/proc/end_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return

// stuff that happens when the step fails
/datum/surgery_step/proc/fail_step(mob/living/user, mob/living/carbon/human/target, target_zone, obj/item/tool)
	return null

/proc/spread_germs_to_organ(obj/item/organ/external/BP, mob/living/carbon/human/user)
	if(!istype(user) || !istype(BP))
		return

	var/germ_level = user.germ_level
	if(user.gloves)
		germ_level = user.gloves.germ_level

	BP.germ_level = max(germ_level, BP.germ_level) //as funny as scrubbing microbes out with clean gloves is - no.
	if(BP.germ_level)
		BP.owner.bad_bodyparts |= BP

/proc/do_surgery(mob/living/carbon/M, mob/living/user, obj/item/tool)
	if(!istype(M))
		return 0
	if (user.a_intent == "hurt")	//check for Hippocratic Oath
		return 0
	var/target_zone = user.zone_sel.selecting
	if(target_zone in M.op_stage.in_progress)		//Can't operate on someone repeatedly.
		to_chat(user, "\red You can't operate on the patient while surgery is already in progress.")
		return 1

	for(var/datum/surgery_step/S in surgery_steps)
		//check, if target undressed for clothless operations
		if(ishuman(M))
			var/mob/living/carbon/human/T = M
			if(S.clothless)
				switch(target_zone)
					if(BP_CHEST , BP_GROIN , BP_L_LEG , BP_R_LEG , BP_R_ARM , BP_L_ARM)
						if(T.wear_suit || (T.w_uniform && !istype(T.w_uniform, /obj/item/clothing/under/patient_gown)))
							return 0
					if(BP_R_LEG , BP_L_LEG)
						if(T.shoes)
							return 0
					if(O_EYES)
						if(T.glasses)
							return 0
					if(BP_R_ARM , BP_L_ARM)
						if(T.gloves)
							return 0

		//check if tool is right or close enough and if this step is possible
		if( S.tool_quality(tool) && S.can_use(user, M, user.zone_sel.selecting, tool) && S.is_valid_mutantrace(M))
			M.op_stage.in_progress += target_zone						//begin step and...
			S.begin_step(user, M, user.zone_sel.selecting, tool)		//...start on it
			//We had proper tools! (or RNG smiled.) and User did not move or change hands.
			if( prob(S.tool_quality(tool)) &&  do_mob(user, M, rand(S.min_duration, S.max_duration)))
				S.end_step(user, M, user.zone_sel.selecting, tool)		//finish successfully
			else if((tool in user.contents) && user.Adjacent(M))		//or (also check for tool in hands and being near the target)
				S.fail_step(user, M, user.zone_sel.selecting, tool)		//malpractice~
			else	// this failing silently was a pain.
				to_chat(user, "\red You must remain close to your patient to conduct surgery.")
			M.op_stage.in_progress -= target_zone						//end step
			if (ishuman(M))
				var/mob/living/carbon/human/H = M
				H.update_surgery()										//shows surgery results
			return	1	  												//don't want to do weapony things after surgery
	return 0

/proc/sort_surgeries()
	var/gap = surgery_steps.len
	var/swapped = 1
	while (gap > 1 || swapped)
		swapped = 0
		if(gap > 1)
			gap = round(gap / 1.247330950103979)
		if(gap < 1)
			gap = 1
		for(var/i = 1; gap + i <= surgery_steps.len; i++)
			var/datum/surgery_step/l = surgery_steps[i]		//Fucking hate
			var/datum/surgery_step/r = surgery_steps[gap+i]	//how lists work here
			if(l.priority < r.priority)
				surgery_steps.Swap(i, gap + i)
				swapped = 1

/datum/surgery_status
	var/plasticsur = 0
	var/eyes = 0
	var/face = 0
	var/appendix = 0
	var/ribcage = 0
	var/list/in_progress = list()
