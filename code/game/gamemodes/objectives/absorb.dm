/datum/objective/absorb/New()
	..()
	gen_amount_goal(2, 3)

/datum/objective/absorb/proc/gen_amount_goal(lowbound = 4, highbound = 6)
	target_amount = rand (lowbound,highbound)
	if (SSticker)
		var/n_p = 1 //autowin
		if (SSticker.current_state == GAME_STATE_SETTING_UP)
			for(var/mob/dead/new_player/P as anything in new_player_list)
				if(P.client && P.ready && P.mind!=owner)
					n_p ++
		else if (SSticker.current_state == GAME_STATE_PLAYING)
			for(var/mob/living/carbon/human/P as anything in human_list)
				if(P.client && !ischangeling(P) && P.mind!=owner)
					n_p ++
		target_amount = min(target_amount, n_p)

	explanation_text = "Absorb [target_amount] compatible genomes."
	return target_amount

/datum/objective/absorb/check_completion()
	if(owner)
		var/datum/role/changeling/C = owner.GetRoleByType(/datum/role/changeling)
		if(C && C.absorbed_dna && (C.absorbedcount >= target_amount))
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
