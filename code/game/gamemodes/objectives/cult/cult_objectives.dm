/datum/objective/cult

/datum/objective/cult/escape
	var/acolytes_needed

/datum/objective/cult/escape/New()
	acolytes_needed = max(5, round(player_list.len * 0.04))
	explanation_text = "Убедитесь, что хотя бы [acolytes_needed] [pluralize_russian(acolytes_needed, "культист", "культиста", "культистов")] улетят живыми на шаттле, чтобы продолжить исследования на других станциях."
	..()

/datum/objective/cult/escape/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.get_cultists_out() >= acolytes_needed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/recruit
	var/acolytes_needed

/datum/objective/cult/recruit/New()
	acolytes_needed = max(5, round(player_list.len * 0.3))
	explanation_text = "Заполучите [acolytes_needed] [pluralize_russian(acolytes_needed, "человека", "человека", "человек")] в подчинение культа, живыми или мёртвыми."
	..()

/datum/objective/cult/recruit/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.members.len >= acolytes_needed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/survive
	var/acolytes_needed

/datum/objective/cult/survive/New()
	acolytes_needed = max(5, round(player_list.len * 0.15))
	explanation_text = "Должно дожить не менее [acolytes_needed] [pluralize_russian(acolytes_needed, "последователя", "последователей", "последователей")] до конца этой смены."
	..()

/datum/objective/cult/survive/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C))
		var/alive = 0
		for(var/datum/role/I in C.members)
			var/mob/M = I.antag.current
			if(M.stat != DEAD)
				alive++
		if(alive >= acolytes_needed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/summon_narsie
	explanation_text = "Призовите Нар-Си с помощью ритуала с пьедесталами на станции."

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

/datum/objective/cult/capture_areas/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.religion.captured_areas.len - C.religion.area_types.len >= need_capture)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
