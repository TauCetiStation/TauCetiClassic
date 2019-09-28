var/global/list/combat_combos = list()

// 'icons/mob/unarmed_combat_combos.dmi'

/datum/combat_combo
	var/name = "Combat_Combo" // These are used as combo_elements...
	var/fullness_lose_on_execute = 50
	var/list/combo_elements = list()

	var/list/allowed_to_mob_types = list(/mob/living/carbon)
	var/list/allowed_on_mob_types = list(/mob/living)

	var/combo_icon_state = "combo"

	var/list/allowed_target_zones = TARGET_ZONE_ALL

	var/needs_logging = TRUE // Do we need to PM admins about this combo?

/datum/combat_combo/proc/get_hash()
	. = list()
	for(var/TZ in allowed_target_zones)
		var/cur_hash = "[TZ]|"
		for(var/CE in combo_elements)
			cur_hash += "[CE]#"
		. += cur_hash

/datum/combat_combo/proc/can_execute(datum/combo_saved/CS)
	if(CS.attacker.incapacitated())
		return FALSE
	if(CS.fullness < fullness_lose_on_execute)
		return FALSE

	if(!is_type_in_list(CS.attacker, allowed_to_mob_types))
		return FALSE
	if(!is_type_in_list(CS.victim, allowed_on_mob_types))
		return FALSE
	var/target_zone
	if(CS.attacker.zone_sel)
		target_zone = CS.attacker.zone_sel
	else
		target_zone = ran_zone(BP_CHEST)
	if(!(target_zone in allowed_target_zones))
		return FALSE
	return TRUE

/datum/combat_combo/proc/get_combo_icon()
	var/image/I = image(icon='icons/mob/unarmed_combat_combos.dmi', icon_state=combo_icon_state)
	I.layer = ABOVE_HUD_LAYER
	I.plane = ABOVE_HUD_PLANE
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.pixel_x = 16
	I.pixel_y = 16
	return I

/datum/combat_combo/proc/on_ready(mob/living/victim, mob/living/attacker)
	/*
	do a scream()
	*/
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
