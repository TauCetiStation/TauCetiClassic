//Updates the mob's health from bodyparts and mob damage variables
/mob/living/carbon/human/updatehealth()
	if(status_flags & GODMODE)
		health = 100
		stat = CONSCIOUS
		return
	var/total_burn	= 0
	var/total_brute	= 0
	for(var/datum/organ/external/BP in bodyparts)	//hardcoded to streamline things a bit
		total_brute	+= BP.brute_dam
		total_burn	+= BP.burn_dam
	health = 100 - getOxyLoss() - getToxLoss() - getCloneLoss() - total_burn - total_brute
	//TODO: fix husking
	if( ((100 - total_burn) < config.health_threshold_dead) && stat == DEAD) //100 only being used as the magic human max health number, feel free to change it if you add a var for it -- Urist
		ChangeToHusk()
	return

/mob/living/carbon/human/getBrainLoss()
	var/res = brainloss
	var/datum/organ/internal/brain/IO = organs_by_name[O_BRAIN]
	if(!IO)
		return 0
	if (IO.is_bruised())
		res += 20
	if (IO.is_broken())
		res += 50
	res = min(res,maxHealth*2)
	return res

//These procs fetch a cumulative total damage from all bodyparts
/mob/living/carbon/human/getBruteLoss()
	var/amount = 0
	for(var/datum/organ/external/BP in bodyparts)
		amount += BP.brute_dam
	return amount

/mob/living/carbon/human/getFireLoss()
	var/amount = 0
	for(var/datum/organ/external/BP in bodyparts)
		amount += BP.burn_dam
	return amount


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
		var/datum/organ/external/BP = bodyparts_by_name[bodypart_name]

		if(amount > 0)
			BP.take_damage(amount, 0, sharp = is_sharp(damage_source), edge = has_edge(damage_source), used_weapon = damage_source)
		else
			//if you don't want to heal robot bodyparts, they you will have to check that yourself before using this proc.
			BP.heal_damage(-amount, 0, internal = 0, robo_repair = (BP.status & ORGAN_ROBOT))

	hud_updateflag |= 1 << HEALTH_HUD

/mob/living/carbon/human/proc/adjustFireLossByPart(amount, bodypart_name, obj/damage_source = null)
	if(species && species.burn_mod)
		amount = amount*species.burn_mod

	if (bodypart_name in bodyparts_by_name)
		var/datum/organ/external/BP = bodyparts_by_name[bodypart_name]

		if(amount > 0)
			BP.take_damage(0, amount, sharp = is_sharp(damage_source), edge = has_edge(damage_source), used_weapon = damage_source)
		else
			//if you don't want to heal robot bodyparts, they you will have to check that yourself before using this proc.
			BP.heal_damage(0, -amount, internal = 0, robo_repair = (BP.status & ORGAN_ROBOT))

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

/mob/living/carbon/human/adjustCloneLoss(amount)
	..()

	if(species.flags[IS_SYNTHETIC])
		return

	var/heal_prob = max(0, 80 - getCloneLoss())
	var/mut_prob = min(80, getCloneLoss()+10)
	if (amount > 0)
		if (prob(mut_prob))
			var/list/candidates = list()
			for (var/datum/organ/external/BP in bodyparts)
				if(!(BP.status & ORGAN_MUTATED))
					candidates += BP
			if (candidates.len)
				var/datum/organ/external/BP = pick(candidates)
				BP.mutate()
				to_chat(src, "<span class = 'notice'>Something is not right with your [BP.name]...</span>")
				return
	else
		if (prob(heal_prob))
			for (var/datum/organ/external/BP in bodyparts)
				if (BP.status & ORGAN_MUTATED)
					BP.unmutate()
					to_chat(src, "<span class = 'notice'>Your [BP.name] is shaped normally again.</span>")
					return

	if (getCloneLoss() < 1)
		for (var/datum/organ/external/BP in bodyparts)
			if (BP.status & ORGAN_MUTATED)
				BP.unmutate()
				to_chat(src, "<span class = 'notice'>Your [BP.name] is shaped normally again.</span>")
	hud_updateflag |= 1 << HEALTH_HUD

////////////////////////////////////////////

//Returns a list of damaged bodyparts
/mob/living/carbon/human/proc/get_damaged_bodyparts(brute, burn)
	var/list/parts = list()
	for(var/datum/organ/external/BP in bodyparts)
		if((brute && BP.brute_dam) || (burn && BP.burn_dam))
			parts += BP
	return parts

//Returns a list of damageable bodyparts
/mob/living/carbon/human/proc/get_damageable_bodyparts()
	var/list/parts = list()
	for(var/datum/organ/external/BP in bodyparts)
		if(BP.brute_dam + BP.burn_dam < BP.max_damage)
			parts += BP
	return parts

//Heals ONE external organ, organ gets randomly selected from damaged ones.
//It automatically updates damage overlays if necesary
//It automatically updates health status
/mob/living/carbon/human/heal_bodypart_damage(brute, burn)
	var/list/parts = get_damaged_bodyparts(brute, burn)
	if(!parts.len)
		return
	var/datum/organ/external/BP = pick(parts)
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
	var/datum/organ/external/BP = pick(parts)
	if(BP.take_damage(brute, burn, sharp, edge))
		hud_updateflag |= 1 << HEALTH_HUD
	updatehealth()
	speech_problem_flag = 1


//Heal MANY external bodyparts, in random order
/mob/living/carbon/human/heal_overall_damage(brute, burn)
	var/list/parts = get_damaged_bodyparts(brute, burn)
	while(parts.len && (brute > 0 || burn > 0))
		var/datum/organ/external/BP = pick(parts)
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
	while(parts.len && (brute > 0 || burn > 0) )
		var/datum/organ/external/BP = pick(parts)
		var/brute_was = BP.brute_dam
		var/burn_was = BP.burn_dam
		BP.take_damage(brute, burn, sharp, edge, used_weapon)
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
		var/blood_volume = vessel.get_reagent_amount("blood")
		vessel.add_reagent("blood",560.0-blood_volume)


/*
This function restores all bodyparts.
*/
/mob/living/carbon/human/restore_all_bodyparts()
	for(var/datum/organ/external/BP in bodyparts)
		BP.rejuvenate()

/mob/living/carbon/human/proc/HealDamage(zone, brute, burn)
	var/datum/organ/external/BP = get_bodypart(zone)
	if(istype(BP, /datum/organ/external))
		if(BP.heal_damage(brute, burn))
			hud_updateflag |= 1 << HEALTH_HUD
	else
		return 0

/mob/living/carbon/human/proc/get_external_organ_from_def_zone_list(list/def_zone_list)
	var/datum/organ/external/BP = null
	while(def_zone_list)
		var/def_zone = pick(def_zone_list)

		BP = get_bodypart(def_zone)

		if(BP.status & ORGAN_DESTROYED)
			def_zone_list -= def_zone
		else
			break
	if(!BP)
		return 0
	else
		return BP

/mob/living/carbon/human/proc/get_bodypart(zone)
	if(!zone)
		zone = BP_CHEST
	if(zone in list(O_EYES , O_MOUTH))
		zone = BP_HEAD
	return bodyparts_by_name[zone]

/mob/living/carbon/human/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, sharp = 0, edge = 0, obj/used_weapon = null)
//	visible_message("Hit debug. [damage] | [damagetype] | [def_zone] | [blocked] | [sharp] | [used_weapon]")
	if((damagetype != BRUTE) && (damagetype != BURN))
		..(damage, damagetype, def_zone, blocked)
		return 1



	var/datum/organ/external/BP = null
	if(isbodypart(def_zone))
		BP = def_zone
	else
		if(!def_zone)
			def_zone = ran_zone(def_zone)
		BP = get_bodypart(check_zone(def_zone))
	if(!BP)
		return 0

	if(istype(used_weapon, /obj/item/projectile))
		damage = (damage - blocked)
	else
		blocked = (100-blocked)/100
		if(blocked <= 0)
			return 0
		damage = (damage * blocked)

	switch(damagetype)
		if(BRUTE)
			damageoverlaytemp = 20
			if(species && species.brute_mod)
				damage = damage*species.brute_mod
			BP.take_damage(damage, 0, sharp, edge, used_weapon)
		if(BURN)
			damageoverlaytemp = 20
			if(species && species.burn_mod)
				damage = damage*species.burn_mod
			BP.take_damage(0, damage, sharp, edge, used_weapon)

	handle_suit_punctures(damagetype, damage)

	// Will set our damageoverlay icon to the next level, which will then be set back to the normal level the next mob.Life().
	updatehealth()
	hud_updateflag |= 1 << HEALTH_HUD

	//Embedded object code.
	if(!BP)
		return
	if(istype(used_weapon, /obj/item))
		var/obj/item/W = used_weapon
		if(!W.can_embed)
			return
		if(!W.is_robot_module())
			//blunt objects should really not be embedding in things unless a huge amount of force is involved
			var/embed_chance = sharp? damage/W.w_class : damage/(W.w_class*3)
			var/embed_threshold = sharp? 5*W.w_class : 15*W.w_class

			//Sharp objects will always embed if they do enough damage.
			//Thrown objects have some momentum already and have a small chance to embed even if the damage is below the threshold
			if((sharp && damage > (10*W.w_class)) || (sharp && !ismob(W.loc) && prob(damage/(10*W.w_class)*100)) || (damage > embed_threshold && prob(embed_chance)))
				BP.embed(W)
	return 1
