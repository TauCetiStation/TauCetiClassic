/datum/objective/cult

/datum/objective/cult/sacrifice/find_target()
	var/datum/faction/cult/C = faction
	if(istype(C))
		C.find_sacrifice_target()
		if(C.sacrifice_target)
			explanation_text = "Принесите в жертву [C.sacrifice_target.name], [C.sacrifice_target.assigned_role]."
		else
			explanation_text = "Свободная задача."

/datum/objective/cult/sacrifice/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C))
		if(C.sacrifice_target in C.sacrificed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/recruit
	var/acolytes_needed

/datum/objective/cult/recruit/New()
	acolytes_needed = max(4, round(player_list.len * 0.1))
	explanation_text = "Убедитесь, что хотя бы [acolytes_needed] [pluralize_russian(acolytes_needed, "культист", "культиста", "культистов")] улетят на шаттле, чтобы продолжить исследования на других станциях."
	..()

/datum/objective/cult/recruit/find_target()
	return

/datum/objective/cult/recruit/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.get_cultists_out() >= acolytes_needed)
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

/datum/objective/cult/capture_areas
	var/need_capture = 4 // areas
	explanation_text = "Захватите не менее 4 отсеков станции с помощью руны захвата зон."

/datum/objective/cult/capture_areas/New()
	need_capture = max(4, round(player_list.len * 0.1) + 1)
	explanation_text = "Захватите не менее [need_capture] отсеков станции с помощью руны захвата зон."
	..()

/datum/objective/cult/capture_areas/find_target()
	return

/datum/objective/cult/capture_areas/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.religion.captured_areas.len - C.religion.area_types.len >= need_capture)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
