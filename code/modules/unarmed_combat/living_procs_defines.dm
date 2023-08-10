/mob/living
	// A bootleg so we don't populate a list of combos on mobs that don't process them.
	var/updates_combat = FALSE

	// Combos that src knows as pointers to singleton combat_combo objects associated
	// with a list of movesets that "teach" this combo to this mob.
	var/list/known_combos = list()
	// Combos that src can perform as pointers to singleton combat_combo objects
	// with a list of movesets that permit this combo to this mob.
	var/list/allowed_combos = list()
	// Assoc list of lists of movesets with keys being their source.
	var/list/movesets_by_source = list()

	// /datum/combo_controller-s src is currently performing.
	var/list/combos_performed = list()
	// /datum/combo_controller that are  performed on src.
	var/list/combos_saved = list()
	// /datum/combat_moveset-s src is capable of.
	var/list/combo_movesets = list()

	var/attack_animation = FALSE
	var/combo_animation = FALSE

	/// Override for the visual attack effect shown on 'do_attack_animation()'.
	var/attack_push_vis_effect
	var/attack_disarm_vis_effect

/mob/living/proc/read_possible_combos()
	set name = "Combos Cheat Sheet"
	set desc = "A list of all possible combos with rough descriptions."
	set category = "IC"

	var/dat = "<center><b>Combos Cheat Sheet</b></center>"
	for(var/datum/combat_combo/CC in allowed_combos)
		dat += "<hr><p>"
		dat += CC.full_desc

		var/combo_sources = ""
		var/first = TRUE
		for(var/datum/combat_moveset/moveset in allowed_combos[CC])
			if(!first)
				combo_sources += ", "
			combo_sources += moveset.name
			first = FALSE
		dat += "<span style='font-size: 8px'><i>(Permitted by: [combo_sources])</i></span>"

		dat += "</p></hr>"

	var/datum/browser/popup = new(usr, "combos_list", "Combos Cheat Sheet", 500, 350)
	popup.set_content(dat)
	popup.open()

// Should return /datum/unarmed_attack at some later time. ~Luduk
/mob/living/proc/get_unarmed_attack()
	var/retDam = 2
	var/retDamType = BRUTE
	var/retFlags = 0
	var/retVerb = "attack"
	var/retSound = null
	var/retMissSound = 'sound/effects/mob/hits/miss_1.ogg'

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
		attacker.me_emote("[attacker.friendly] [src]")
		return TRUE
	return attack_unarmed(attacker)

/mob/living/attack_alien(mob/living/carbon/xenomorph/attacker)
	return attack_unarmed(attacker)

/mob/living/attack_facehugger(mob/living/carbon/xenomorph/facehugger/attacker)
	return attack_unarmed(attacker)

/mob/living/attack_larva(mob/living/carbon/xenomorph/larva/attacker)
	return attack_unarmed(attacker)

/mob/living/attack_slime(mob/living/carbon/slime/attacker)
	if(attacker.Victim)
		return FALSE
	if(health <= -100)
		return FALSE
	attacker.attacked += 5

	if(attacker.powerlevel > 0)
		var/stunprob = 10
		var/power = attacker.powerlevel + rand(0,3)

		switch(attacker.powerlevel)
			if(1 to 2)
				stunprob = 20
			if(3 to 4)
				stunprob = 30
			if(5 to 6)
				stunprob = 40
			if(7 to 8)
				stunprob = 60
			if(9)
				stunprob = 70
			if(10)
				stunprob = 95

		if(prob(stunprob))
			attacker.powerlevel -= 3
			if(attacker.powerlevel < 0)
				attacker.powerlevel = 0

			visible_message("<span class='warning bold'>The [attacker] has shocked [src]!</span>")

			Weaken(power)
			Stuttering(power)
			Stun(power)

			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()

			flash_eyes(affect_silicon = TRUE)

			if(prob(stunprob) && attacker.powerlevel >= 8)
				adjustFireLoss(attacker.powerlevel * rand(6, 10))

	return attack_unarmed(attacker)

/// This proc checks whether src can be attacked by attacker at all.
/mob/living/proc/can_be_attacked(mob/living/attacker)
	// Why does this exist? ~Luduk
	if(isturf(loc) && istype(loc.loc, /area/start))
		to_chat(attacker, "<span class='warning'>No attacking people at spawn!</span>")
		return FALSE

	var/list/attack_obj = attacker.get_unarmed_attack()
	if((attacker != src) && check_shields(attacker, attack_obj["damage"], attacker.name, get_dir(attacker, src)))
		attacker.do_attack_animation(src)
		visible_message("<span class='warning bold'>[attacker] attempted to touch [src]!</span>")
		return FALSE

	return TRUE

/*
 * The running horse of current combo system.
 * Handles all unarmed attacks, to unite all the attack_paw, attack_slime, attack_human, etc procs.
 * If you want your mob with a special snowflake attack_*proc* to be able to do combos, it should
 * be calling this proc somewhere.
 *
 * Return TRUE if unarmed attack was "succesful".
 */
/mob/living/proc/attack_unarmed(mob/living/attacker)
	if(!can_be_attacked(attacker))
		return FALSE

	var/tz = attacker.get_targetzone()
	if(!can_hit_zone(attacker, tz))
		var/tz_txt = ""
		switch(tz)
			if(BP_HEAD)
				tz_txt = " head"
			if(BP_CHEST)
				tz_txt = " chest"
			if(BP_GROIN)
				tz_txt = " groin"
			if(BP_L_ARM)
				tz_txt = " left arm"
			if(BP_R_ARM)
				tz_txt = " right arm"
			if(BP_L_LEG)
				tz_txt = " left leg"
			if(BP_R_LEG)
				tz_txt = " right leg"
			if(O_EYES)
				tz_txt = " eyes"
			if(O_MOUTH)
				tz_txt = " mouth"

		to_chat(attacker, "<span class='danger'>What[tz_txt]?</span>")
		return

	switch(attacker.a_intent)
		if(INTENT_HELP)
			if(attacker.disengage_combat(src)) // We were busy disengaging.
				return TRUE
			return helpReaction(attacker)

		if(INTENT_PUSH)
			var/combo_value = 2
			if(!anchored && !is_bigger_than(attacker) && src != attacker)
				var/turf/to_move = get_step(src, get_dir(attacker, src))
				var/atom/A = get_step_away(src, get_turf(attacker))
				if(A != to_move)
					combo_value *= 2

			if(attacker.engage_combat(src, INTENT_PUSH, combo_value)) // We did a combo-wombo of some sort.
				return
			return disarmReaction(attacker)

		if(INTENT_GRAB)
			if(attacker.engage_combat(src, INTENT_GRAB, 0))
				return TRUE
			return grabReaction(attacker)

		if(INTENT_HARM)
			var/attack_obj = attacker.get_unarmed_attack()
			var/combo_value = attack_obj["damage"] * 2
			if(attacker.engage_combat(src, INTENT_HARM, combo_value)) // We did a combo-wombo of some sort.
				return TRUE
			return hurtReaction(attacker)

/mob/living/proc/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	return TRUE

/mob/living/proc/disarmReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	attacker.do_attack_animation(src, visual_effect_icon = attacker.attack_disarm_vis_effect)

	if(!anchored && !is_bigger_than(attacker) && src != attacker)
		var/turf/to_move = get_step(src, get_dir(attacker, src))
		step_away(src, get_turf(attacker))
		if(loc != to_move)
			adjustHalLoss(4)

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
	if(show_message)
		visible_message("<span class='warning'><B>[attacker] pushed [src]!</B></span>")

	return TRUE

/mob/living/proc/grabReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	return attacker.tryGrab(src)

/mob/living/proc/hurtReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	attacker.do_attack_animation(src, visual_effect_icon = attacker.attack_push_vis_effect)

	// terrible. deprecate in favour of a data-class handling all of this. ~Luduk
	var/attack_obj = attacker.get_unarmed_attack()
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

	log_combat(attacker, "[damVerb]ed")

	var/armor_block = 0
	var/obj/item/organ/external/BP = attacker.get_targetzone() // apply_damage accepts both the bodypart and the zone.
	if(ishuman(src)) // This is stupid. TODO: abstract get_armor() proc.
		var/mob/living/carbon/human/H = src
		BP = H.get_bodypart(ran_zone(BP))
		armor_block = run_armor_check(BP, MELEE)

	if(damSound)
		playsound(src, damSound, VOL_EFFECTS_MASTER)

	if(show_message)
		visible_message("<span class='warning'><B>[attacker] [damVerb]ed [src]!</B></span>")

	apply_damage(damage, damType, BP, armor_block, damFlags)
	return TRUE

// Add this proc to /Life() of any mob for it to be able to perform combos.
/mob/living/proc/handle_combat()
	updates_combat = TRUE
	for(var/datum/combo_handler/CS in combos_saved)
		CS.update()

// Add combo points to all attackers.
/mob/living/proc/add_combo_value_all(value)
	for(var/datum/combo_handler/CS in combos_saved)
		CS.points += value

// Add combo points to all my combo-controllers.
/mob/living/proc/add_my_combo_value(value)
	for(var/datum/combo_handler/CS in combos_performed)
		CS.points += value

// Returns TRUE if a combo was executed.
/mob/living/proc/try_combo(mob/living/target)
	for(var/datum/combo_handler/CS in combos_performed)
		if(CS.victim == target)
			return CS.activate_combo()
	return FALSE

// Try getting next combo, called on targetzone change.
/mob/living/proc/update_combos()
	for(var/datum/combo_handler/CS in combos_performed)
		CS.get_next_combo()

// Is used to more precisely pick a combo, removes first combo element.
/mob/living/proc/drop_combo_element()
	. = FALSE
	for(var/datum/combo_handler/CS in combos_performed)
		. = TRUE
		CS.drop_combo_element()

// Returns TRUE if a combo was used, so you can prevent grabbing/disarming/etc.
/mob/living/proc/engage_combat(mob/living/target, combo_element, combo_value)
	if(!updates_combat)
		return FALSE

	if(src == target)
		return FALSE

	for(var/datum/combo_handler/CE in target.combos_saved)
		if(CE.attacker == src)
			return CE.register_attack(combo_element, combo_value)

	if(combo_value == 0) // We don't engage into combat with grabs.
		return FALSE

	var/datum/combo_handler/CS = new /datum/combo_handler(target, src, combo_element, combo_value)
	target.combos_saved += CS
	combos_performed += CS

	return CS.register_attack(combo_element, combo_value)

// Returns TRUE if combo-combat is disengaged.
/mob/living/proc/disengage_combat(mob/living/target, combo_element, combo_value)
	if(!updates_combat)
		return FALSE

	for(var/datum/combo_handler/CE in target.combos_saved)
		if(CE.attacker == src)
			qdel(CE)
			return TRUE

	return FALSE

/mob/living/proc/learn_combo(datum/combat_combo/combo, datum/combat_moveset/moveset)
	var/is_known = (combo in known_combos)
	if(!is_known)
		known_combos[combo] = list()
		if(!(combo in allowed_combos))
			allowed_combos[combo] = list()
		allowed_combos[combo] += moveset

	known_combos[combo] += moveset

	SEND_SIGNAL(src, COMSIG_LIVING_LEARN_COMBO, combo, moveset)

/mob/living/proc/forget_combo(datum/combat_combo/combo, datum/combat_moveset/moveset)
	SEND_SIGNAL(src, COMSIG_LIVING_FORGET_COMBO, combo, moveset)

	known_combos[combo] -= moveset
	if(length(known_combos[combo]) == 0)
		known_combos -= combo

	if(combo in allowed_combos)
		allowed_combos[combo] -= moveset
		if(length(allowed_combos[combo]) == 0)
			allowed_combos -= combo

/mob/living/proc/add_moveset(datum/combat_moveset/moveset, source)
	moveset.apply(src, source)

/mob/living/proc/remove_moveset(datum/combat_moveset/moveset, source)
	moveset.remove(src, source)

/mob/living/proc/remove_moveset_source(source)
	for(var/datum/combat_moveset/moveset in movesets_by_source[source])
		remove_moveset(moveset, source)

/mob/living/turn_light_off()
	. = ..()
	for(var/obj/item/F in contents)
		F.turn_light_off()
