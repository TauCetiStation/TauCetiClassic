/mob/living
	var/updates_combat = FALSE // A bootleg so we don't populate a list of combos on mobs that don't process them.

	var/list/combos_performed = list()
	var/list/combos_saved = list()

/mob/living/proc/get_unarmed_attack()
	var/retDam = 2
	var/retDamType = BRUTE
	var/retFlags = 0
	var/retVerb = "attack"
	var/retSound = null
	var/retMissSound = 'sound/weapons/punchmiss.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/attack_hand(mob/living/carbon/human/attacker)
	return attack_unarmed(attacker)

/mob/living/attack_paw(mob/living/carbon/attacker)
	if(istype(attacker.wear_mask, /obj/item/clothing/mask/muzzle))
		return FALSE
	return attack_unarmed(attacker)

/mob/living/attack_animal(mob/living/simple_animal/attacker)
	if(attacker.melee_damage <= 0)
		attacker.emote("[attacker.friendly] [src]")
		return TRUE
	return attack_unarmed(attacker)

/mob/living/proc/attack_unarmed(mob/living/attacker)
	if(isturf(loc) && istype(loc.loc, /area/start))
		to_chat(attacker, "No attacking people at spawn, you jackass.")
		return

	if((attacker != src) && check_shields(0, attacker.name, get_dir(attacker, src)))
		visible_message("<span class='warning'><B>[attacker] attempted to touch [src]!</B></span>")
		return FALSE

	switch(attacker.a_intent)
		if(I_HELP)
			if(attacker.disengage_combat(src)) // We were busy disengaging.
				return TRUE
			return helpReaction(attacker)

		if(I_DISARM)
			var/combo_value = 3
			if(!anchored) // Just to be sure...
				var/turf/to_move = get_step(src, get_dir(attacker, src))
				var/atom/A = get_step_away(src, get_turf(attacker))
				if(A != to_move)
					adjustHalLoss(3)
					combo_value *= 2

			if(attacker.engage_combat(src, I_DISARM, combo_value)) // We did a combo-wombo of some sort.
				return
			return disarmReaction(attacker)

		if(I_GRAB)
			if(attacker.engage_combat(src, I_GRAB, 0))
				return TRUE
			return grabReaction(attacker)

		if(I_HURT)
			var/attack_obj = attacker.get_unarmed_attack()
			var/combo_value = attack_obj["damage"] * 2
			if(attacker.engage_combat(src, I_HURT, combo_value)) // We did a combo-wombo of some sort.
				return TRUE
			return hurtReaction(attacker)

/mob/living/proc/helpReaction(mob/living/carbon/human/attacker)
	return TRUE

/mob/living/proc/disarmReaction(mob/living/carbon/human/attacker)
	attacker.do_attack_animation(src)

	if(!anchored)
		step_away(src, get_turf(attacker))

	if(pulling)
		visible_message("<span class='warning'><b>[attacker] has broken [src]'s grip on [pulling]!</B></span>")
		stop_pulling()
	else
		//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
		for(var/obj/item/weapon/grab/G in GetGrabs())
			if(G.affecting)
				visible_message("<span class='warning'><b>[attacker] has broken [src]'s grip on [G.affecting]!</B></span>")
			qdel(G)
		//End BubbleWrap

	playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	visible_message("<span class='warning'><B>[attacker] pushed [src]!</B></span>")

/mob/living/proc/grabReaction(mob/living/carbon/human/attacker)
	attacker.Grab(src)
	return TRUE

/mob/living/proc/hurtReaction(mob/living/carbon/human/attacker)
	attacker.do_attack_animation(src)

	var/attack_obj = get_unarmed_attack()
	var/damage = attack_obj["damage"]
	var/damType = attack_obj["type"]
	var/damFlags = attack_obj["flags"]
	var/damVerb = attack_obj["verb"]
	var/damSound = attack_obj["sound"]
	var/damMissSound = attack_obj["miss_sound"]

	if(!damage)
		if(damMissSound)
			playsound(src, damMissSound, VOL_EFFECTS_MASTER)
		visible_message("<span class='warning'><B>[attacker] tried to [damVerb] [src]!</B></span>")
		return FALSE

	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>[damVerb]ed [src.name] ([src.ckey])</font>")
	attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [damVerb]ed by [attacker.name] ([attacker.ckey])</font>")
	msg_admin_attack("[key_name(attacker)] [damVerb]ed [key_name(src)]", attacker)

	var/armor_block = 0
	var/obj/item/organ/external/BP = ran_zone(attacker.zone_sel.selecting) // apply_damage accepts both the bodypart and the zone.
	if(ishuman(src)) // This is stupid. TODO: abstract get_armor() proc.
		var/mob/living/carbon/human/H = src
		BP = H.get_bodypart(ran_zone(attacker.zone_sel.selecting))
		armor_block = run_armor_check(BP, "melee")

	if(damSound)
		playsound(src, damSound, VOL_EFFECTS_MASTER)

	visible_message("<span class='warning'><B>[attacker] [damVerb]ed [src]!</B></span>")

	apply_damage(damage, damType, BP, armor_block, damFlags)

/mob/living/proc/handle_combat()
	updates_combat = TRUE
	for(var/datum/combo_saved/CS in combos_saved)
		CS.update()

/mob/living/proc/add_combo_value_all(value)
	for(var/datum/combo_saved/CS in combos_saved)
		CS.fullness += value

// Returns TRUE if a combo was used, so you can prevent grabbing/disarming/etc.
/mob/living/proc/engage_combat(mob/living/target, combo_element, combo_value)
	if(!updates_combat)
		return FALSE

	for(var/datum/combo_saved/CE in target.combos_saved)
		if(CE.attacker == src)
			INVOKE_ASYNC(CE, /datum/combo_saved.proc/animate_attack, combo_element, combo_value)
			return CE.register_attack(combo_element, combo_value, zone_sel ? ran_zone(BP_CHEST) : zone_sel.selecting)

	if(combo_value == 0) // We don't engage into combat with grabs.
		return FALSE

	var/datum/combo_saved/CS = new /datum/combo_saved(target, src, combo_element, combo_value)
	target.combos_saved += CS
	combos_performed += CS

	INVOKE_ASYNC(CS, /datum/combo_saved.proc/animate_attack, combo_element, combo_value)
	return CS.register_attack(combo_element, combo_value, zone_sel ? ran_zone(BP_CHEST) : zone_sel.selecting)

// Returns TRUE if combo-combat is disengaged.
/mob/living/proc/disengage_combat(mob/living/target, combo_element, combo_value)
	if(!updates_combat)
		return FALSE

	for(var/datum/combo_saved/CE in target.combos_saved)
		if(CE.attacker == src)
			qdel(CE)
			return TRUE

	return FALSE
