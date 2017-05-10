//Updates the mob's health from bodyparts and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	for(var/obj/item/bodypart/BP in bodyparts)	//hardcoded to streamline things a bit
		total_brute	+= BP.brute_dam
		total_burn	+= BP.burn_dam
	health = 100 - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	//TODO: fix husking
	if( ((100 - total_burn) < health_threshold_dead) && stat == DEAD) //100 only being used as the magic human max health number, feel free to change it if you add a var for it -- Urist
		ChangeToHusk()
	return

/mob/living/carbon/getBrainLoss()
	var/obj/item/organ/brain/IO = organs_by_name[BP_BRAIN]
	if(!IO)
		return 0
	var/res = IO.brainloss
	if (IO.is_bruised())
		res += 20
	if (IO.is_broken())
		res += 50
	res = min(res,maxHealth*2)
	return res

/mob/living/carbon/setBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	var/obj/item/organ/brain/IO = organs_by_name[BP_BRAIN]
	if(!IO)
		return 0
	IO.brainloss = amount

/mob/living/carbon/adjustBrainLoss(amount)
	if(status_flags & GODMODE)
		return 0
	var/obj/item/organ/brain/IO = organs_by_name[BP_BRAIN]
	if(!IO)
		return 0
	IO.brainloss = Clamp(IO.brainloss + amount, 0, maxHealth * 2)

//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP in bodyparts)
		amount += BP.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP in bodyparts)
		amount += BP.burn_dam
	return amount

/mob/living/carbon/human/getHalLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP in bodyparts)
		amount += BP.get_pain()
	return amount

/mob/living/carbon/human/setHalLoss(amount)
	adjustHalLoss(getHalLoss()-amount)

/mob/living/carbon/human/adjustHalLoss(amount)
	var/heal = (amount < 0)
	amount = abs(amount)
	var/list/pick_bodyparts = bodyparts.Copy()
	while(amount > 0 && pick_bodyparts.len)
		var/obj/item/bodypart/BP = pick(pick_bodyparts)
		pick_bodyparts -= BP
		if(!istype(BP))
			continue

		if(heal)
			amount -= BP.remove_pain(amount)
		else
			amount -= BP.add_pain(amount)
	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/adjustBruteLoss(amount)
	if(species && species.brute_mod)
		amount = amount*species.brute_mod

	if(amount > 0)
		take_overall_damage(amount, 0)
	else
		heal_overall_damage(-amount, 0)
	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/adjustFireLoss(amount)
	if(species && species.burn_mod)
		amount = amount*species.burn_mod

	if(amount > 0)
		take_overall_damage(0, amount)
	else
		heal_overall_damage(0, -amount)
	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/proc/adjustBruteLossByPart(amount, bodypart_name, obj/damage_source = null)
	if(species && species.brute_mod)
		amount = amount*species.brute_mod

	if (bodypart_name in bodyparts_by_name)
		var/obj/item/bodypart/BP = get_bodypart(bodypart_name)

		if(amount > 0)
			BP.take_damage(amount, 0, damage_source.damage_flags(), damage_source)
		else
			//if you don't want to heal robot bodyparts, they you will have to check that yourself before using this proc.
			BP.heal_damage(-amount, 0, internal=0, robo_repair=(BP.status & ORGAN_ROBOT))

	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/proc/adjustFireLossByPart(amount, bodypart_name, obj/damage_source = null)
	if(species && species.burn_mod)
		amount = amount*species.burn_mod

	if (bodypart_name in bodyparts_by_name)
		var/obj/item/bodypart/BP = get_bodypart(bodypart_name)

		if(amount > 0)
			BP.take_damage(0, amount, damage_source.damage_flags(), damage_source)
		else
			//if you don't want to heal robot bodyparts, they you will have to check that yourself before using this proc.
			BP.heal_damage(0, -amount, internal=0, robo_repair=(BP.status & ORGAN_ROBOT))

	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/Stun(amount)
	if(HULK in mutations)
		if(status_flags & CANSTUN)
			stunned = max(max(stunned,amount/2),0)
	else
		..()

/mob/living/carbon/human/Weaken(amount)
	if(HULK in mutations)
		if(status_flags & CANWEAKEN)
			weakened = max(amount/2,0)
			update_canmove()	//updates lying, canmove and icons	return
	else
		..()

/mob/living/carbon/human/Paralyse(amount)
	if(HULK in mutations)
		if(status_flags & CANPARALYSE)
			paralysis = max(max(paralysis,amount),0)
	else
		..()

/mob/living/carbon/human/getCloneLoss()
	var/amount = 0
	for(var/obj/item/bodypart/BP in bodyparts)
		amount += BP.get_genetic_damage()
	return amount

/mob/living/carbon/human/setCloneLoss(amount)
	adjustCloneLoss(getCloneLoss()-amount)

/mob/living/carbon/human/adjustCloneLoss(amount)
	var/heal = amount < 0
	amount = abs(amount)

	var/list/pick_bodyparts = bodyparts.Copy()
	while(amount > 0 && pick_bodyparts.len)
		var/obj/item/bodypart/BP = pick(pick_bodyparts)
		pick_bodyparts -= BP
		if(heal)
			amount -= BP.remove_genetic_damage(amount)
		else
			amount -= BP.add_genetic_damage(amount)
	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/adjustOxyLoss(amount)
	if(!should_have_organ(BP_LUNGS))
		oxyloss = 0
	else
		..(amount)

/mob/living/carbon/human/setOxyLoss(amount)
	if(!should_have_organ(BP_LUNGS))
		oxyloss = 0
	else
		..()

/mob/living/carbon/human/getToxLoss()
	if(isSynthetic())
		toxloss = 0
	return ..()

/mob/living/carbon/human/adjustToxLoss(amount)
	if(isSynthetic())
		toxloss = 0
	else
		..(amount)

/mob/living/carbon/human/setToxLoss(amount)
	if(isSynthetic())
		toxloss = 0
	else
		..()

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/human/proc/get_damaged_bodyparts(brute, burn)
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP in bodyparts)
		if((brute && BP.brute_dam) || (burn && BP.burn_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/human/proc/get_damageable_bodyparts()
	var/list/obj/item/bodypart/parts = list()
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.brute_dam + BP.burn_dam < BP.max_damage)
			parts += BP
	return parts

//Heals ONE bodypart, bodypart gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_bodypart_damage(brute, burn)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn)
	if(!parts.len)	return
	var/obj/item/bodypart/BP = pick(parts)
	if(BP.heal_damage(brute,burn))
		hud_updateflag |= 1 << HEALTH_HUD
	updatehealth()

//Damages ONE bodypart, bodypart gets randomly selected from damagable ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/take_bodypart_damage(brute, burn, damage_flags, used_weapon)
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts()
	if(!parts.len)	return
	var/obj/item/bodypart/BP = pick(parts)
	if(BP.take_damage(brute, burn, damage_flags))
		hud_updateflag |= 1 << HEALTH_HUD
	updatehealth()
	speech_problem_flag = 1


//Heal MANY external bodyparts, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn)
	var/list/obj/item/bodypart/parts = get_damaged_bodyparts(brute,burn)
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/bodypart/BP = pick(parts)
		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam
		BP.heal_damage(brute,burn)
		brute -= (brute_was-BP.brute_dam)
		burn -= (burn_was-BP.burn_dam)
		parts -= BP
	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD
	speech_problem_flag = 1


// damage MANY external bodyparts, in random order
/mob/living/carbon/human/take_overall_damage(brute, burn, damage_flags, used_weapon)
	if(status_flags & GODMODE)	return	//godmode
	var/list/obj/item/bodypart/parts = get_damageable_bodyparts()
	while(parts.len && (brute>0 || burn>0) )
		var/obj/item/bodypart/BP = pick(parts)
		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam
		BP.take_damage(brute, burn, damage_flags, used_weapon)
		brute	-= (BP.brute_dam - brute_was)
		burn	-= (BP.burn_dam - burn_was)
		parts -= BP
	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD


////////////////////////////////////////////

/*
This function restores all bodyparts.
*/
/mob/living/carbon/human/restore_all_bodyparts()
	for(var/obj/item/bodypart/BP in bodyparts)
		BP.rejuvenate()

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/obj/item/bodypart/BP = get_bodypart(zone)
	if(istype(BP, /obj/item/bodypart))
		if(BP.heal_damage(brute, burn))
			hud_updateflag |= 1 << HEALTH_HUD
	else
		return 0
	return


/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, damage_flags = 0, obj/used_weapon = null)
	//visible_message("Hit debug. [damage] | [damagetype] | [def_zone] | [blocked] | [damage_flags] | [used_weapon]")

	var/obj/item/bodypart/BP = null
	if(isBODYPART(def_zone))
		BP = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		BP = get_bodypart(check_zone(def_zone))
	if(!BP)
		return 0

	if( !(damagetype in list(BRUTE, BURN, HALLOSS, CLONE)) )
		..()
		return 1

	handle_suit_punctures(damagetype, damage)

	if(blocked >= 100)
		return 0

	if(blocked)
		damage *= blocked_mult(blocked)

	var/datum/wound/created_wound
	damageoverlaytemp = 20
	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(species && species.brute_mod)
				damage = damage*species.brute_mod
			created_wound = BP.take_damage(damage, 0, damage_flags, used_weapon)
		if(BURN)
			damageoverlaytemp = 20
			if(species && species.burn_mod)
				damage = damage*species.burn_mod
			created_wound = BP.take_damage(0, damage, damage_flags, used_weapon)

		if(HALLOSS)
			BP.add_pain(damage)
		if(CLONE)
			BP.add_genetic_damage(damage)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD

	return created_wound
