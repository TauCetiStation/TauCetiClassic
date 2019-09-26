var/global/list/combat_combos = list()

// 'icons/mob/unarmed_combat_combos.dmi'

/datum/combat_combo
	var/name = "Combat_Combo" // These are used as combo_elements...
	var/fullness_lose_on_execute = 50
	var/list/combo_elements = list()

	var/list/allowed_target_zones = TARGET_ZONE_ALL

	var/needs_logging = TRUE // Do we need to PM admins about this combo?

/datum/combat_combo/proc/get_hash()
	. = list()
	for(var/TZ in allowed_target_zones)
		var/cur_hash = "[TZ]|"
		for(var/CE in combo_elements)
			cur_hash += "[CE]#"
		. += cur_hash
		world.log << "[cur_hash] [name]"

/datum/combat_combo/proc/on_ready(mob/living/victim, mob/living/attacker)
	/*
	create icon above head()
	do a scream()
	*/
	var/image/I = image(icon='icons/mob/unarmed_combat_combos.dmi', icon_state="combo")
	I.loc = victim
	var/matrix/M = matrix()
	for(var/i in 1 to 3)
		M.Turn(pick(-15, 15))
		animate(I, transform=M, time=2)
		sleep(2)
		M = matrix()
		animate(I, transform=M, time=1)
		sleep(1)
	flick_overlay(I, clients, 13)
	attacker.emote("scream")

// Please remember, that the default animation of attack takes 3 ticks. So put at least sleep(2) here
// before anything.
/datum/combat_combo/proc/animate_combo(mob/living/victim, mob/living/attacker)
	return

// This is for technical stuff, such as fingerprints leaving, admin PM.
/datum/combat_combo/proc/pre_execute(mob/living/victim, mob/living/attacker)
	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [victim.name] ([victim.ckey])</font>")
	victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [attacker.name]'s ([attacker.ckey]) [name]</font>")

	msg_admin_attack("[key_name(attacker)] used [name] on [victim.name] ([victim.ckey])", attacker)

/datum/combat_combo/proc/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combat_combo/disarm
	name = "Weapon Disarm"
	fullness_lose_on_execute = 20
	combo_elements = list(I_DISARM, I_DISARM, I_DISARM, I_DISARM)

	allowed_target_zones = TARGET_ZONE_ALL

/datum/combat_combo/disarm/execute(mob/living/victim, mob/living/attacker)
	for(var/obj/item/weapon/gun/G in list(victim.get_active_hand(), victim.get_inactive_hand()))
		var/chance = 0
		if(victim.get_active_hand() == G)
			chance = 40
		else
			chance = 20

		if(prob(chance))
			victim.visible_message("<span class='danger'>[victim]'s [G] goes off during struggle!</span>")
			var/list/turfs = list()
			for(var/turf/T in view(7, victim))
				turfs += T
			var/turf/target = pick(turfs)
			return G.afterattack(target, victim)

	victim.drop_item()
	victim.visible_message("<span class='warning'><B>[attacker] has disarmed [victim]!</B></span>")



/datum/combat_combo/push
	name = "Push"
	fullness_lose_on_execute = 50
	combo_elements = list(I_DISARM, I_DISARM, I_DISARM, I_HURT)

	allowed_target_zones = TARGET_ZONE_ALL

/datum/combat_combo/push/execute(mob/living/victim, mob/living/attacker)
	var/target_zone
	if(attacker.zone_sel)
		target_zone = attacker.zone_sel.selecting
	else
		target_zone = ran_zone(BP_CHEST)

	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(target_zone)
		armor_check = victim.run_armor_check(BP, "melee")

	victim.apply_effect(3, WEAKEN, armor_check)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has pushed [victim] to the ground!</span>")



/datum/combat_combo/suplex
	name = "Suplex"
	fullness_lose_on_execute = 75
	combo_elements = list(I_HURT, I_HURT, I_HURT, I_GRAB)

	allowed_target_zones = list(BP_CHEST)

/datum/combat_combo/suplex/animate_combo(mob/living/victim, mob/living/attacker)
	sleep(3)
	var/DTM = get_dir(attacker, victim)
	var/victim_dir = get_dir(victim, attacker)
	var/shift_x = 0
	var/shift_y = 0
	switch(DTM)
		if(NORTH)
			shift_y = 32
		if(SOUTH)
			shift_y = -32
		if(WEST)
			shift_x = -32
		if(EAST)
			shift_x = 32
	var/prev_pix_x = attacker.pixel_x
	var/prev_pix_y = attacker.pixel_y

	victim.Paralyse(2)
	attacker.Paralyse(2) // So he doesn't do something funny during the trick.

	animate(attacker, pixel_x = attacker.pixel_x + shift_x, pixel_y = attacker.pixel_y + shift_y, time = 5)
	sleep(5)
	attacker.forceMove(victim.loc)
	attacker.pixel_x = prev_pix_x
	attacker.pixel_y = prev_pix_y

	var/matrix/M = matrix()
	M.Turn(pick(90, -90))
	var/matrix/victim_M = victim.transform
	prev_pix_x = victim.pixel_x
	prev_pix_y = victim.pixel_y
	animate(victim, transform = M, time = 2)
	sleep(2)
	animate(victim, pixel_y = victim.pixel_y + 15, time = 5)
	sleep(5)
	animate(victim, pixel_x = victim.pixel_x - shift_x, pixel_y = victim.pixel_y - 15 - shift_y, time = 2)
	sleep(2)
	victim.transform = victim_M
	victim.forceMove(get_step(victim, victim_dir))
	victim.pixel_x = prev_pix_x
	victim.pixel_y = prev_pix_y

	var/armor_check = 0
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		var/obj/item/organ/external/BP = H.get_bodypart(BP_CHEST)
		armor_check = victim.run_armor_check(BP, "melee")

	to_chat(world, "Armor check [armor_check]")
	victim.apply_effect(6, WEAKEN, armor_check)
	victim.adjustBruteLoss(20)

	playsound(victim, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
	victim.visible_message("<span class='danger'>[attacker] has thrown [victim] over their shoulder!</span>")

// We ought to execute the thing in animation, since it's very complex and so to not enter race conditions.
/datum/combat_combo/suplex/execute(mob/living/victim, mob/living/attacker)
	return



/datum/combo_saved
	var/fullness = 0
	var/datum/progressbar/progbar
	var/list/combo_elements = list()
	var/mob/living/carbon/human/attacker
	var/mob/living/carbon/human/victim
	var/datum/combat_combo/next_combo

	var/last_hand_hit = 0 // Switching hands doubles fullness gained.

/datum/combo_saved/New(mob/living/victim, mob/living/attacker, combo_element, combo_value)
	src.attacker = attacker
	src.victim = victim
	progbar = new(attacker, 100, victim)

/datum/combo_saved/proc/animate_attack(combo_element, combo_value)
	switch(combo_element)
		if(I_DISARM, I_HURT)
			var/matrix/saved_transform = attacker.transform
			var/matrix/M = matrix()
			if(attacker.hand)
				M.Turn(-combo_value)
			else
				M.Turn(combo_value)
			animate(attacker, transform=M, time=2)
			sleep(2)
			animate(attacker, transform=saved_transform, time=1)

/datum/combo_saved/proc/register_attack(combo_element, combo_value)
	var/target_zone
	if(attacker.zone_sel)
		target_zone = attacker.zone_sel.selecting
	else
		target_zone = ran_zone(BP_CHEST)

	if(combo_elements.len == 4)
		combo_elements.Cut(1, 2)
	if(attacker.hand != last_hand_hit)
		combo_value *= 2
		last_hand_hit = attacker.hand

	if(attacker.incapacitated())
		combo_value *= 0.5
	if(victim.incapacitated())
		combo_value *= 0.5

	combo_elements += combo_element
	fullness = min(100, fullness + combo_value)

	if(next_combo)
		var/datum/combat_combo/CC = next_combo
		if((target_zone in CC.allowed_target_zones) && fullness >= CC.fullness_lose_on_execute)
			next_combo = null
			INVOKE_ASYNC(CC, /datum/combat_combo.proc/animate_combo, victim, attacker)
			CC.pre_execute(victim, attacker)
			CC.execute(victim, attacker)
			fullness -= CC.fullness_lose_on_execute
			combo_elements = list()
			register_attack(CC.name, 0)
			return TRUE
		else
			next_combo = null
	else
		var/combo_hash = "[target_zone]|"
		for(var/CE in combo_elements)
			combo_hash += "[CE]#"

		to_chat(world, "[combo_hash]")

		var/datum/combat_combo/CC = combat_combos[combo_hash]
		if(CC && fullness >= CC.fullness_lose_on_execute)
			next_combo = combat_combos[combo_hash]
			to_chat(world, "[CC.name]")
			next_combo.on_ready(victim, attacker)

	return FALSE

/datum/combo_saved/proc/update()
	progbar.update(fullness)
	fullness--
	if(fullness < 0)
		attacker.combos_performed -= src
		victim.combos_saved -= src

		qdel(src)

/datum/combo_saved/Destroy()
	QDEL_NULL(progbar)
	victim = null
	attacker = null
	next_combo = null
	return ..()



/mob/living
	var/updates_combat = FALSE // A bootleg so we don't populate a list of combos on mobs that don't process them.

	var/list/combos_performed = list()
	var/list/combos_saved = list()

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
