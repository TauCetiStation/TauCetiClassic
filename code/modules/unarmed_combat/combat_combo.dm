var/global/list/combat_combos = list()
var/global/list/combat_combos_by_name = list()

/datum/combat_combo
	var/name = "Combat_Combo" // These are used as combo_elements...
	var/desc = "A move that does combo cool stuff."
	var/fullness_lose_on_execute = 50
	var/list/combo_elements = list()

	var/list/allowed_to_mob_types = list(/mob/living)
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

/datum/combat_combo/proc/can_execute(datum/combo_saved/CS, show_warning = FALSE)
	if(CS.attacker.incapacitated())
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while being incapacitated.</span>")
		return FALSE
	if(CS.attacker.is_busy(CS.victim))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while doing something else,</span>")
		return FALSE
	if(CS.attacker.attack_animation || CS.attacker.combo_animation)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while performing something else.</span>")
		return FALSE
	if(CS.victim.attack_animation || CS.victim.combo_animation)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>Can't perform <b>[name]</b> while [CS.victim] is performing something.</span>")
		return FALSE
	if(CS.attacker.small && !CS.victim.small)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>[CS.victim] is too big for you to perform <b>[name]</b>.</span>")
		return FALSE
	if(CS.victim.maxHealth > CS.attacker.maxHealth) // Current best size estimate.
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>[CS.victim] is too big for you to perform <b>[name]</b>.</span>")
		return FALSE
	if(CS.fullness < fullness_lose_on_execute)
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You don't have enough combopoints for <b>[name]</b>.</span>")
		return FALSE

	if(!is_type_in_list(CS.attacker, allowed_to_mob_types))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b>.</span>")
		return FALSE
	if(!is_type_in_list(CS.victim, allowed_on_mob_types))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim].</span>")
		return FALSE

	var/target_zone = CS.attacker.get_targetzone()

	if(!(target_zone in allowed_target_zones))
		if(show_warning)
			to_chat(CS.attacker, "<span class='notice'>You can't perform <b>[name]</b> on [CS.victim]'s [target_zone].</span>")
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
	attacker.emote("scream")

// Please remember, that the default animation of attack takes 3 ticks. So put at least sleep(3) here
// before anything.
/datum/combat_combo/proc/animate_combo(mob/living/victim, mob/living/attacker)
	return

// This is for technical stuff, such as fingerprints leaving, admin PM.
/datum/combat_combo/proc/pre_execute(mob/living/victim, mob/living/attacker)
	attacker.attack_log += text("\[[time_stamp()]\] <font color='red'>Used [name] on [victim.name] ([victim.ckey])</font>")
	victim.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [attacker.name]'s ([attacker.ckey]) [name]</font>")

	msg_admin_attack("[key_name(attacker)] used [name] on [victim.name] ([victim.ckey])", attacker)

	victim.add_fingerprint(attacker)

/datum/combat_combo/proc/execute(mob/living/victim, mob/living/attacker)
	return
