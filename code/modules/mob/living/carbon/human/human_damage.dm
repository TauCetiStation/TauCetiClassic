//Updates the mob's health from bodyparts and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = maxHealth
		stat = CONSCIOUS
		return

	var/total_burn = 0
	var/total_brute = 0
	for(var/obj/item/organ/external/BP in bodyparts) // hardcoded to streamline things a bit
		if(BP.is_robotic() && !BP.vital)
			continue // *non-vital* robot limbs don't count towards shock and crit
		total_brute += BP.brute_dam
		total_burn += BP.burn_dam

	health = maxHealth - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute

	//TODO: fix husking
	if( ((maxHealth - total_burn) < config.health_threshold_dead) && stat == DEAD)
		ChangeToHusk()
	return

/mob/living/carbon/human/apply_effect(effect = 0, effecttype = STUN, blocked = 0)
	if((effecttype == AGONY || effecttype == STUTTER) && species && species.flags[NO_PAIN])
		return FALSE
	return ..()

// =============================================

/mob/living/carbon/human/getBrainLoss()
	if(status_flags & GODMODE)
		return 0

	if(species.brain_mod == 0 || !should_have_organ(O_BRAIN))
		return 0

	var/res = brainloss
	var/obj/item/organ/internal/brain/IO = organs_by_name[O_BRAIN]

	if(!IO)
		return maxHealth * 2
	if(IO.is_bruised())
		res += 20
	if(IO.is_broken())
		res += 50

	res = min(res, maxHealth * 2)

	return res

/mob/living/carbon/human/adjustBrainLoss(amount)
	if(species.brain_mod == 0 || !should_have_organ(O_BRAIN))
		brainloss = 0
	else
		amount = amount * species.brain_mod
		..(amount)

/mob/living/carbon/human/setBrainLoss(amount)
	if(species.brain_mod == 0 || !should_have_organ(O_BRAIN))
		brainloss = 0
	else
		..()

// =============================================

//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_robotic() && !BP.vital)
			continue // robot limbs don't count towards shock and crit
		amount += BP.brute_dam
	return round(amount, 0.01)

/mob/living/carbon/human/adjustBruteLoss(amount)
	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)

// =============================================

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_robotic() && !BP.vital)
			continue // robot limbs don't count towards shock and crit
		amount += BP.burn_dam
	return round(amount, 0.01)

/mob/living/carbon/human/adjustFireLoss(amount)
	if(amount > 0)
		if(RESIST_HEAT in mutations)
			return
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)

// =============================================

/mob/living/carbon/human/getToxLoss()
	if(species.tox_mod == 0 || species.flags[NO_BLOOD])
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(amount)
	if(species.tox_mod == 0 || species.flags[NO_BLOOD])
		toxloss = 0
	else
		amount = amount * species.tox_mod
		..(amount)

/mob/living/carbon/human/setToxLoss(amount)
	if(species.tox_mod == 0 || species.flags[NO_BLOOD])
		toxloss = 0
	else
		..()

// =============================================

/mob/living/carbon/human/getOxyLoss()
	if(species.oxy_mod == 0 || !should_have_organ(O_LUNGS))
		oxyloss = 0
	return ..()

/mob/living/carbon/human/adjustOxyLoss(amount)
	if(species.oxy_mod == 0 || !should_have_organ(O_LUNGS))
		oxyloss = 0
	else
		amount = amount * species.oxy_mod
		..(amount)

/mob/living/carbon/human/setOxyLoss(amount)
	if(species.oxy_mod == 0 || !should_have_organ(O_LUNGS))
		oxyloss = 0
	else
		..()

// =============================================

/mob/living/carbon/human/adjustCloneLoss(amount)
	if(species.clone_mod == 0)
		cloneloss = 0
		return
	else
		amount = amount * species.clone_mod
		..(amount)

	if(species.flags[IS_SYNTHETIC])
		return

	time_of_last_damage = world.time

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss()+10)
	if (amount > 0)
		if (prob(mut_prob))
			var/list/candidates = list()
			for (var/obj/item/organ/external/BP in bodyparts)
				if(!(BP.status & ORGAN_MUTATED))
					candidates += BP
			if (candidates.len)
				var/obj/item/organ/external/BP = pick(candidates)
				BP.mutate()
				to_chat(src, "<span class = 'notice'>Something is not right with your [BP.name]...</span>")
				return
	else
		if (prob(heal_prob))
			for (var/obj/item/organ/external/BP in bodyparts)
				if (BP.status & ORGAN_MUTATED)
					BP.unmutate()
					to_chat(src, "<span class = 'notice'>Your [BP.name] is shaped normally again.</span>")
					return

	if (getCloneLoss() < 1)
		for (var/obj/item/organ/external/BP in bodyparts)
			if (BP.status & ORGAN_MUTATED)
				BP.unmutate()
				to_chat(src, "<span class = 'notice'>Your [BP.name] is shaped normally again.</span>")
	hud_updateflag |= 1 << HEALTH_HUD

// =============================================

/mob/living/carbon/human/Stun(amount, updating = 1, ignore_canstun = 0, lock = null)
	if(HULK in mutations)
		stunned = 0
	else
		..()

/mob/living/carbon/human/Weaken(amount)
	if(HULK in mutations)
		weakened = 0
	else
		..()

/mob/living/carbon/human/Paralyse(amount)
	if(HULK in mutations)
		paralysis = 0
	else
		..()

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/human/proc/get_damaged_bodyparts(brute, burn)
	var/list/parts = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if((brute && BP.brute_dam) || (burn && BP.burn_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/human/proc/get_damageable_bodyparts()
	var/list/parts = list()
	for(var/obj/item/organ/external/BP in bodyparts)
		if(BP.is_damageable())
			parts += BP
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_bodypart_damage(brute, burn)
	var/list/parts = get_damaged_bodyparts(brute, burn)
	if(!parts.len)
		return
	var/obj/item/organ/external/BP = pick(parts)
	if(BP.heal_damage(brute, burn))
		hud_updateflag |= 1 << HEALTH_HUD
	updatehealth()

//Damages ONE external organ, organ gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_bodypart_damage(brute, burn, sharp = 0, edge = 0)
	var/list/parts = get_damageable_bodyparts()
	if(!parts.len)
		return

	var/obj/item/organ/external/BP = pick(parts)
	var/damage_flags = (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

	if(BP.take_damage(brute, burn, damage_flags))
		hud_updateflag |= 1 << HEALTH_HUD
		updatehealth()
		speech_problem_flag = 1


//Heal MANY external bodyparts, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn)
	var/list/parts = get_damaged_bodyparts(brute, burn)
	while(parts.len && (brute > 0 || burn > 0))
		var/obj/item/organ/external/BP = pick(parts)
		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam
		BP.heal_damage(brute, burn)
		brute -= (brute_was - BP.brute_dam)
		burn -= (burn_was - BP.burn_dam)
		parts -= BP
	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD
	speech_problem_flag = 1


// damage MANY external bodyparts, in random order
/mob/living/carbon/human/take_overall_damage(brute, burn, sharp = 0, edge = 0, used_weapon = null)
	if(status_flags & GODMODE)
		return // godmode

	var/list/parts = get_damageable_bodyparts()
	if(!parts.len)
		return

	var/damage_flags = (sharp ? DAM_SHARP : 0) | (edge ? DAM_EDGE : 0)

	while(parts.len && (brute > 0 || burn > 0) )
		var/obj/item/organ/external/BP = pick(parts)

		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam

		BP.take_damage(brute, burn, damage_flags, used_weapon)
		brute -= (BP.brute_dam - brute_was)
		burn -= (BP.burn_dam - burn_was)

		parts -= BP

	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD


////////////////////////////////////////////

/*
This function restores the subjects blood to max.
*/
/mob/living/carbon/human/proc/restore_blood()
	if(!species.flags[NO_BLOOD])
		vessel.add_reagent("blood", 560 - vessel.total_volume)
		fixblood()


/*
This function restores all bodyparts.
*/
/mob/living/carbon/human/restore_all_bodyparts()
	for(var/obj/item/organ/external/BP in bodyparts)
		BP.rejuvenate()
	for(var/BP_ZONE in species.has_bodypart)
		if(!bodyparts_by_name[BP_ZONE])
			var/path = species.has_bodypart[BP_ZONE]
			new path(null, src)

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/organ/external/BP = get_bodypart(zone)
	if(istype(BP, /obj/item/organ/external))
		if(BP.heal_damage(brute, burn))
			hud_updateflag |= 1 << HEALTH_HUD
	else
		return 0

/mob/living/carbon/human/proc/get_bodypart(zone)
	if(!zone)
		zone = BP_CHEST
	if(zone in list(O_EYES , O_MOUTH))
		zone = BP_HEAD
	return bodyparts_by_name[zone]

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, obj/used_weapon = null)

	if(damagetype == HALLOSS && species && species.flags[NO_PAIN])
		return FALSE

	//Handle other types of damage or healing
	if(damage < 0 || !(damagetype in list(BRUTE, BURN)))
		..(damage, damagetype, def_zone, blocked)
		return TRUE

	handle_suit_punctures(damagetype, damage)

	if(blocked >= 100)
		return FALSE

	var/obj/item/organ/external/BP = null
	if(isbodypart(def_zone))
		BP = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		BP = get_bodypart(check_zone(def_zone))

	if(!BP)
		return FALSE

	if(blocked)
		damage *= blocked_mult(blocked)

	var/datum/wound/created_wound
	damageoverlaytemp = 20
	switch(damagetype)
		if(BRUTE)
			created_wound = BP.take_damage(damage, 0, damage_flags, used_weapon)
		if(BURN)
			created_wound = BP.take_damage(0, damage, damage_flags, used_weapon)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD

	return created_wound
