/datum/objective/target/dehead
	required_equipment = /obj/item/device/biocan

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
