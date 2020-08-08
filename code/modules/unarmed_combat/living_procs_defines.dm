/mob/living
	// A bootleg so we don't populate a list of combos on mobs that don't process them.
	var/updates_combat = FALSE

	// /datum/combo_controller-s src is currently performing.
	var/list/combos_performed = list()
	// /datum/combo_controller that are  performed on src.
	var/list/combos_saved = list()

	var/attack_animation = FALSE
	var/combo_animation = FALSE

// Should be deprecated in favour of /datum/combo_moveset. ~Luduk
var/global/combos_cheat_sheet = ""

/mob/living/verb/read_possible_combos()
	set name = "Combos Cheat Sheet"
	set desc = "A list of all possible combos with rough descriptions."
	set category = "IC"

	if(!global.combos_cheat_sheet)
		var/dat = "<center><b>Combos Cheat Sheet</b></center>"
		for(var/CC_type in subtypesof(/datum/combat_combo))
			var/datum/combat_combo/CC = new CC_type
			dat += "<hr><p>"
			dat += "<b>Name:</b> <i>[CC.name]</i><br>"
			dat += "<b>Desc:</b> [CC.desc]<br>"
			dat += "<b>Combopoints cost:</b> [CC.fullness_lose_on_execute]%<br>"

			var/tz_txt = ""
			var/first = TRUE
			for(var/tz in CC.allowed_target_zones)
				switch(tz)
					if(BP_HEAD)
						tz = "head"
					if(BP_CHEST)
						tz = "chest"
					if(BP_GROIN)
						tz = "groin"
					if(BP_L_ARM)
						tz = "left arm"
					if(BP_R_ARM)
						tz = "right arm"
					if(BP_L_LEG)
						tz = "left leg"
					if(BP_R_LEG)
						tz = "right leg"
					if(O_EYES)
						tz = "eyes"
					if(O_MOUTH)
						tz = "mouth"
				if(first)
					tz_txt += capitalize(tz)
					first = FALSE
				else
					tz_txt += ", " + tz

			dat += "<b>Allowed target zones:</b> [tz_txt]<br>"

			var/combo_txt = ""
			for(var/c_el in CC.combo_elements)
				switch(c_el)
					if(INTENT_PUSH)
						c_el = "<font color='dodgerblue'>[capitalize(c_el)]</font>"
					if(INTENT_GRAB)
						c_el = "<font color='yellow'>[capitalize(c_el)]</font>"
					if(INTENT_HARM)
						c_el = "<font color='red'>[capitalize(c_el)]</font>"
					else
						c_el = "<font color='grey'>[c_el]</font>"
				combo_txt += c_el + " "

			dat += "<b>Combo required:</b> [combo_txt]<br>"
			var/notes = ""
			notes += CC.ignore_size ? "<font color='dodgerblue'><i>* Ignores opponent's size.</i></font><br>" : ""
			notes += CC.scale_damage_coeff != 0.0 || CC.scale_effect_coeff != 0.0 ? "<font color='red'><i>* Modified by your attack's base damage.</i></font><br>" : ""
			notes += CC.scale_size_exponent != 0.0 ? "<font color='red'><i>* Damage is amplified by difference in size.</i></font><br>" : ""
			notes += CC.armor_pierce ? "<font color='red'><i>* Ignores armor.</i></font><br>" : ""
			if(notes)
				dat += "<br>" + notes
			dat += "</p></hr>"

		global.combos_cheat_sheet = dat

	var/datum/browser/popup = new(usr, "combos_list", "Combos Cheat Sheet", 500, 350)
	popup.set_content(global.combos_cheat_sheet)
	popup.open()

// Should return /datum/unarmed_attack at some later time. ~Luduk
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
			if(stuttering < power)
				stuttering = power
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
	attacker.do_attack_animation(src)

	if(!anchored && !is_bigger_than(attacker) && src != attacker) // maxHealth is the current best size estimate.
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
	attacker.do_attack_animation(src)

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
		armor_block = run_armor_check(BP, "melee")

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
		CS.fullness += value

// Add combo points to all my combo-controllers.
/mob/living/proc/add_my_combo_value(value)
	for(var/datum/combo_handler/CS in combos_performed)
		CS.fullness += value

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
