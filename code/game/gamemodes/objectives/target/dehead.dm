/datum/objective/target/dehead
	conflicting_types = list(
		/datum/objective/target/protect,
		/datum/objective/target/dehead
	)

/datum/objective/target/dehead/format_explanation()
	return "Put the head of [target.current.real_name] in biogel can and steal it."

/datum/objective/target/dehead/check_completion()
	if(!target)//If it's a free objective.
		return OBJECTIVE_WIN
	if( !owner.current || owner.current.stat==DEAD )//If you're otherwise dead.
		return OBJECTIVE_LOSS
	var/list/all_items = owner.current.GetAllContents()
	for(var/obj/item/device/biocan/B in all_items)
		if(B.brainmob && B.brainmob == target.current)
			return OBJECTIVE_WIN
		return OBJECTIVE_LOSS
	return OBJECTIVE_LOSS

/datum/objective/target/dehead/equip_tools()
	if(!owner)
		return
	var/mob/living/carbon/human/mob = owner.current
	var/obj/item/device/biocan/B = new (mob.loc)
	var/list/slots = list(
		"backpack" = SLOT_IN_BACKPACK,
		"left hand" = SLOT_L_HAND,
		"right hand" = SLOT_R_HAND,
	)
	var/where = mob.equip_in_one_of_slots(B, slots)
	mob.update_icons()
	if (!where)
		to_chat(mob, "You were unfortunately unable to provide with the brand new can for storing heads.")
	else
		to_chat(mob, "The biogel-filled can in your [where] will help you to steal you target's head alive and undamaged.")
