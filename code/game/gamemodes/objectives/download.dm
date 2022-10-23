/datum/objective/download

/datum/objective/download/New()
	..()
	gen_amount_goal()

/datum/objective/download/proc/gen_amount_goal()
	target_amount = rand(10,20)
	explanation_text = "Download [target_amount] research levels."
	return target_amount

/datum/objective/download/check_completion()
	if(!ishuman(owner.current))
		return OBJECTIVE_LOSS
	if(!owner.current || owner.current.stat == DEAD)
		return OBJECTIVE_LOSS
	if(!(istype(owner.current:wear_suit, /obj/item/clothing/suit/space/space_ninja)&&owner.current:wear_suit:s_initialized))
		return OBJECTIVE_LOSS
	var/current_amount
	var/obj/item/clothing/suit/space/space_ninja/S = owner.current:wear_suit
	if(!S.stored_research.len)
		return OBJECTIVE_LOSS
	else
		for(var/datum/tech/current_data in S.stored_research)
			if(current_data.level>1)	current_amount+=(current_data.level-1)
	if(current_amount<target_amount)	return OBJECTIVE_LOSS
	return OBJECTIVE_WIN
