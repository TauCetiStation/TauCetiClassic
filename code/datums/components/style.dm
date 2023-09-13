#define CLUSMY_STYLE "clumsy_set"

/datum/component/style
	var/style_amount = 0
	var/style_in_desired = 0
	var/list/desired_slots
	var/style_set = ""

/datum/component/style/Initialize(style_initial, amount_in_desired, slot_initial, style_set_initial)
	. = ..()
	style_amount = style_initial
	style_in_desired = amount_in_desired
	style_set = style_set_initial
	if(islist(slot_initial))
		var/list/L = slot_initial
		desired_slots = L
	else
		var/list/L = list(slot_initial)
		desired_slots = L
	RegisterSignal(parent, COMSIG_PROJECTILE_STYLE_DODGE, PROC_REF(mod_misschance))

/datum/component/style/proc/meet_set_requirments(datum/source, list/reflist)
	var/datum/affected_by_style = reflist[3]
	var/bonus_amount = 0
	switch(style_set)
		if(CLUSMY_STYLE)
			if(istype(affected_by_style) && HAS_TRAIT(affected_by_style, TRAIT_CLUMSY))
				bonus_amount += 5
	return bonus_amount

/datum/component/style/proc/is_slot_desired(datum/source, mob/living/carbon/user)
	if(!desired_slots)
		return FALSE
	if(!iscarbon(user))
		return FALSE
	for(var/i in desired_slots)
		if(user.get_slot_ref(i) == parent)
			return TRUE
	return FALSE

/datum/component/style/proc/is_armorsuit(item)
	if(istype(item, /obj/item/clothing/suit/armor))
		return TRUE
	if(istype(item, /obj/item/clothing/suit/storage/flak))
		return TRUE
	return FALSE

/datum/component/style/proc/is_backpack_equipped(mob/living/user)
	if(istype(user.back, /obj/item/weapon/storage/backpack))
		return TRUE
	return FALSE

/datum/component/style/proc/mod_misschance(datum/source, list/reflist)
	SIGNAL_HANDLER
	//Destroy most style points if player has wear armor with many additional slots from backpack
	if(is_armorsuit(source))
		if(is_backpack_equipped(reflist[3]))
			reflist[1] -= 100
	if(style_set)
		var/set_bonus = meet_set_requirments(source, reflist)
		if(set_bonus)
			reflist[1] += set_bonus
	if(is_slot_desired(source, reflist[3]))
		reflist[1] += style_in_desired
		return
	reflist[1] += style_amount

/datum/component/style/Destroy()
	UnregisterSignal(parent, COMSIG_PROJECTILE_STYLE_DODGE)
	return ..()
