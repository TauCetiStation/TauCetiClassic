#define CLUMSY_STYLE "clumsy_set"
#define WITHOUT_BACKPACK_STYLE "without_backpack_set"
#define DETECTIVE_STYLE "detective_style"
#define GANG_STYLE "gang_style"

#define STYLE_TIP "It may affect your style."

/datum/mechanic_tip/style
	tip_name = STYLE_TIP

/datum/mechanic_tip/style/New(datum/component/style/S)
	var/output_information = ""
	//One slot can increase style, other can decrease
	if((S.style_amount > 0 || S.style_in_desired > 0) && (S.style_amount < 0 || S.style_in_desired < 0))
		output_information += "This may have a ambiguity impact on your style"
	//Very good stylish points
	else if(S.style_amount >= 5 || S.style_in_desired >= 5)
		output_information += "It can improve your style."
	//Only good stylish points
	else if(S.style_amount > 0 || S.style_in_desired > 0)
		output_information += "It might give you a little style."
	//Can decrease or increase style by special requirments
	else if(S.style_sets.len)
		output_information += "This may have a ambiguity impact on your style."
	//Negative stylish points
	else if(S.style_amount < 0 || S.style_in_desired < 0)
		output_information += "It might have a bad effect on your style"
	description = output_information

/datum/component/style
	var/style_amount = 0
	var/style_in_desired = 0
	var/list/desired_slots
	var/list/style_sets

/datum/component/style/Initialize(style_initial, amount_in_desired, slot_initial, style_set_initial)
	. = ..()
	style_amount = style_initial
	style_in_desired = amount_in_desired
	//Initialize Style Sets
	if(islist(style_set_initial))
		var/list/L = style_set_initial
		style_sets = L
	else if(!style_set_initial)
		style_sets = list()
	else
		var/list/L = list(style_set_initial)
		style_sets = L
	//Initialize Desired Slot
	if(islist(slot_initial))
		var/list/L = slot_initial
		desired_slots = L
	else
		var/list/L = list(slot_initial)
		desired_slots = L

	var/datum/mechanic_tip/style/style_tip = new(src)
	parent.AddComponent(/datum/component/mechanic_desc, list(style_tip))
	RegisterSignal(parent, COMSIG_PROJECTILE_STYLE_DODGE, PROC_REF(mod_misschance))

/datum/component/style/proc/is_backpack_equipped(mob/living/user)
	if(istype(user.back, /obj/item/weapon/storage/backpack))
		return TRUE
	return FALSE

/datum/component/style/proc/meet_set_requirments(datum/source, list/reflist)
	var/mob/M = reflist[3]
	var/bonus_amount = 0
	for(var/style_string in style_sets)
		switch(style_string)
			if(CLUMSY_STYLE)
				if(istype(M) && HAS_TRAIT(M, TRAIT_CLUMSY))
					bonus_amount += 5
			if(WITHOUT_BACKPACK_STYLE)
				//Destroy most style points if player has wear armor with many additional slots from backpack
				if(is_backpack_equipped(M))
					bonus_amount -= 100
			if(DETECTIVE_STYLE)
				var/datum/mind/mind = M.mind
				if(mind && mind.assigned_role == "detective")
					//Always increase style to 5 maximum
					bonus_amount += max(0, min(5, 5 - style_amount))
			if(GANG_STYLE)
				if(isanygangster(M))
					//Always increase style to 5 maximum
					bonus_amount += max(0, min(5, 5 - style_amount))
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

/datum/component/style/proc/mod_misschance(datum/source, list/reflist)
	SIGNAL_HANDLER
	if(style_sets.len)
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
