/datum/objective/cult
	var/weight = 1.0

/datum/objective/cult/recruit
	var/acolytes_needed
	weight = 1.5

/datum/objective/cult/recruit/New()
	acolytes_needed = round(player_list.len * 0.08)
	explanation_text = "Убедитесь, что хотя бы [acolytes_needed] [pluralize_russian(acolytes_needed, "культист", "культиста", "культистов")] улетят живыми на шаттле, чтобы продолжить исследования на других станциях."
	..()

/datum/objective/cult/recruit/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.get_cultists_out() >= acolytes_needed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/convert
	var/acolytes_needed
	weight = 0.5

/datum/objective/cult/convert/New()
	acolytes_needed = max(5, round(player_list.len * 0.3))
	explanation_text = "Заполучите [acolytes_needed] [pluralize_russian(acolytes_needed, "человека", "человека", "человек")] в подчинение культа, живыми или мёртвыми."
	..()

/datum/objective/cult/convert/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.members.len >= acolytes_needed)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/survive
	var/acolytes_needed
	weight = 1.0

/datum/objective/cult/survive/New()
	acolytes_needed = max(5, round(player_list.len * 0.15))
	explanation_text = "Должно дожить не менее [acolytes_needed] [pluralize_russian(acolytes_needed, "последователя", "последователей", "последователей")] до конца этой смены."
	..()

/datum/objective/cult/survive/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C))
		var/alive = 0
		for(var/datum/role/I in C.members)
			if(I.antag.current?.stat != DEAD)
				alive++
		if(alive >= acolytes_needed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/summon_narsie
	explanation_text = "Призовите Нар-Си с помощью ритуала с пьедесталами на станции."
	weight = 2.0

/datum/objective/cult/summon_narsie/check_completion()
	if(SSticker.nar_sie_has_risen)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/capture_areas
	var/need_capture = 4 // areas
	explanation_text = "Захватите не менее 4 отсеков станции с помощью руны захвата зон."
	weight = 1.0

/datum/objective/cult/capture_areas/New()
	need_capture = max(4, round(player_list.len * 0.1) + 1)
	explanation_text = "Захватите не менее [need_capture] отсеков станции с помощью руны захвата зон."
	..()

/datum/objective/cult/capture_areas/check_completion()
	var/datum/faction/cult/C = faction
	if(istype(C) && C.religion.captured_areas.len - C.religion.area_types.len >= need_capture)
		return OBJECTIVE_WIN
	return OBJECTIVE_LOSS

/datum/objective/cult/job_convert
	var/convertees_needed
	var/datum/job/job
	weight = 1.0

/datum/objective/cult/job_convert/New()
	var/list/all_jobs = list() + engineering_positions + medical_positions + science_positions + civilian_positions - command_positions
	var/list/possible_jobs = list()
	for(var/I in all_jobs)
		var/datum/job/J = SSjob.GetJob(I)
		if(J.current_positions > 1)
			possible_jobs += I
	if(!possible_jobs.len)
		explanation_text = "Свободная задача"
		convertees_needed = 0
		return
	job = SSjob.GetJob(pick(possible_jobs))
	convertees_needed = rand(1, CEIL(job.current_positions / 2))
	explanation_text = "Культ нуждается в [convertees_needed] [pluralize_russian(convertees_needed, "последователе, являющемся", "последователях, являющихся", "последователях, являющихся")] [job.title]."
	..()

/datum/objective/cult/job_convert/check_completion()
	if(!convertees_needed)
		return OBJECTIVE_WIN

	var/datum/faction/cult/C = faction
	if(istype(C))
		var/convertees = 0
		for(var/datum/role/R in C.members)
			if(R.antag.assigned_job == job)
				convertees++
		if(convertees >= convertees_needed)
			return OBJECTIVE_WIN
	return OBJECTIVE_LOSS
