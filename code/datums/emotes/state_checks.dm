/proc/is_stat(stat, mob/M, intentional)
	if(M.stat > stat)
		if(intentional)
			to_chat(M, "<span class='notice'>You can't emote in this state.</span>")
		return FALSE

	return TRUE

/proc/is_stat_or_not_intentional(stat, mob/M, intentional)
	if(!intentional)
		return TRUE

	return is_stat(stat, M, intentional)

/proc/is_species_not_flag(flag, mob/M, intentional)
	var/datum/species/S = all_species[M.get_species()]
	if(!S)
		return TRUE

	if(S.flags[flag])
		if(intentional)
			to_chat(M, "<span class='notice'>Your species can't perform this emote.</span>")
		return FALSE

	return TRUE

/proc/is_intentional_or_species_no_flag(flag, mob/M, intentional)
	if(intentional)
		return TRUE

	return is_species_not_flag(flag, M, intentional)

/proc/is_one_hand_usable(mob/M, intentional)
	if(M.restrained())
		if(intentional)
			to_chat(M, "<span class='notice'>You can't perform this emote while being restrained.</span>")
		return FALSE

	if(!ishuman(M))
		return TRUE

	var/mob/living/carbon/human/H = M

	var/obj/item/organ/external/l_arm = H.get_bodypart(BP_L_ARM)
	var/obj/item/organ/external/r_arm = H.get_bodypart(BP_R_ARM)

	return (l_arm && l_arm.is_usable()) || (r_arm && r_arm.is_usable())

/proc/is_present_bodypart(zone, mob/M, intentional)
	if(!ishuman(M))
		return TRUE

	var/mob/living/carbon/human/H = M

	var/obj/item/organ/external/BP = H.get_bodypart(zone)
	if(!BP)
		if(intentional)
			to_chat(H, "<span class='notice'>You can't perform this emote without a [parse_zone(zone)]</span>")
		return FALSE

	return TRUE

/proc/is_not_species(species, mob/M, intentional)
	if(M.get_species() == species)
		if(intentional)
			to_chat(M, "<span class='notice'>Your species can't perform this emote.</span>")
		return FALSE

	return TRUE

/proc/has_robot_module(module_type, mob/M, intentional)
	if(!isrobot(M))
		return FALSE

	var/mob/living/silicon/robot/R = M
	if(!istype(R.module, module_type))
		if(intentional)
			to_chat(R, "<span class='notice'>You do not have the required module for this emote.</span>")
		return FALSE

	return TRUE
