/datum/objective/target/harm
	var/already_completed = 0

/datum/objective/target/harm/format_explanation()
	return "Make an example of [target.current.real_name], the [target.assigned_role]. Break one of their bones, detach one of their limbs or disfigure their face. Make sure they're alive when you do it."

/datum/objective/target/harm/check_completion()
	if(already_completed)
		return OBJECTIVE_WIN

	if(target && target.current && ishuman(target.current))
		if(target.current.stat == DEAD)
			return OBJECTIVE_LOSS

		var/mob/living/carbon/human/H = target.current
		for(var/obj/item/organ/external/BP in H.bodyparts)
			if(BP.status & ORGAN_BROKEN)
				already_completed = 1
				return OBJECTIVE_WIN
			if(BP.is_stump)
				already_completed = 1
				return OBJECTIVE_WIN

		var/obj/item/organ/external/head/BP = H.bodyparts_by_name[BP_HEAD]
		if(BP.disfigured)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
