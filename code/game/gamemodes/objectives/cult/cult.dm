/datum/objective/cult

/datum/objective/cult/sacrifice/New()
	..()
	find_target()

/datum/objective/cult/proc/get_unconvertables()
	var/list/ucs = list()
	for(var/mob/living/carbon/human/player in human_list)
		if(!is_convertable_to_cult(player.mind))
			ucs += player.mind
	return ucs

/datum/objective/cult/proc/find_sacrifice_target()
	var/list/possible_targets = get_unconvertables()

	if(possible_targets.len)
		for(var/datum/mind/M in possible_targets)
			if(M.GetRole(CULTIST))
				possible_targets -= M

	var/sacrifice_target
	if(possible_targets.len)
		sacrifice_target = pick(possible_targets)

	return sacrifice_target

/datum/objective/cult/sacrifice/find_target()
	target = find_sacrifice_target()
	if(target)
		explanation_text = "Принесите в жертву [target.name], [target.assigned_role]."
	else
		explanation_text = "Свободная задача."

/datum/objective/cult/sacrifice/check_completion()
	var/datum/faction/cult/C = faction
	if(target in C.sacrificed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/recruit
	var/acolytes_needed

/datum/objective/cult/recruit/New()
	acolytes_needed = max(4, round(player_list.len * 0.1))
	explanation_text = "Убедитесь, что хотя бы [acolytes_needed] [russian_plural(acolytes_needed, "культист", "культиста", "культистов")] улетят на шаттле, чтобы продолжить исследования на других станциях."
	..()

/datum/objective/cult/recruit/find_target()
	return

/datum/objective/cult/recruit/check_completion()
	var/datum/faction/cult/C = faction
	if(C.get_cultists_out() >= acolytes_needed)
		return OBJECTIVE_WIN

	return OBJECTIVE_LOSS

/datum/objective/cult/summon_narsie
	explanation_text = "Призовите Нар-Си с помощью ритуала с пьедесталами на станции."

/datum/objective/cult/summon_narsie/find_target()
	return

/datum/objective/cult/summon_narsie/check_completion()
	if(SSticker.nar_sie_has_risen)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/* Uncommit after merge my cult
/datum/objective/cult/capture_areas
	var/need_capture = 4 // areas
	explanation_text = "Захватите не менее 4 отсеков станции с помощью руны захвата зон."

/datum/objective/cult/capture_areas/New()
	explanation_text = "Захватите не менее [need_capture] отсеков станции с помощью руны захвата зон."
	..()

/datum/objective/cult/capture_areas/find_target()
	return

/datum/objective/cult/capture_areas/check_completion()
	if(faction.religion.captured_areas.len - faction.religion.area_types.len >= need_capture)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS


/datum/objective/cult/save_piety
	var/piety_needed = 0
	explanation_text = "Накопите и сохраните 10000 piety"

/datum/objective/cult/save_piety/New()
	piety_needed = round(player_list.len * 10)
	explanation_text = "Накопите и сохраните [piety_needed] piety"
	..()

/datum/objective/cult/save_piety/find_target()
	return

/datum/objective/cult/save_piety/check_completion()
	if(faction.religion.piety >= piety_needed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
*/