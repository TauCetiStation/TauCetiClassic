/datum/faction/malf_silicons
	name = MALF
	ID = MALF
	logo_state = "malf-logo"
	required_pref = ROLE_MALF

	initroletype = /datum/role/malfAI //First addition should be the AI
	roletype = /datum/role/malfbot //Then anyone else should be bots

	max_roles = 1

	var/AI_win_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/malf_mode_declared = FALSE
	var/station_captured = FALSE
	var/to_nuke_or_not_to_nuke = 0
	var/intercept_hacked = FALSE
	var/intercept_apcs = 4 //Bonus for the interception upgrade

/datum/faction/malf_silicons/can_join_faction(mob/P)
	if (!..())
		return FALSE
	if (config && !config.allow_ai)
		return FALSE
	var/datum/job/ai_job = SSjob.GetJob("AI")
	if (!ai_job || !ai_job.map_check())
		return FALSE
	for (var/lvl in 1 to 3)
		if(P.client.prefs.job_preferences[ai_job.title] == lvl && (!jobban_isbanned(P, ai_job.title)))
			return TRUE
	return FALSE

/datum/faction/malf_silicons/OnPostSetup()
	if(SSshuttle)
		SSshuttle.fake_recall = TRUE
	return ..()

/datum/faction/malf_silicons/proc/takeover()
	malf_mode_declared = TRUE
	for(var/datum/role/malfAI/role in members)
		var/mob/living/silicon/ai/cur_AI = role.antag.current
		var/datum/AI_Module/takeover_module = cur_AI.current_modules["System Override"]
		if(takeover_module)
			qdel(takeover_module)

	var/datum/announcement/centcomm/malf/declared/announce_declared = new
	announce_declared.play()
	addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(set_security_level), "delta"), 50)

/datum/faction/malf_silicons/process()
	if(SSticker.hacked_apcs >= APC_MIN_TO_MALF_DECLARE && malf_mode_declared)
		AI_win_timeleft -= (SSticker.hacked_apcs / APC_MIN_TO_MALF_DECLARE) //Victory timer now de-increments almost normally

	..()

/datum/faction/malf_silicons/proc/capture_the_station()
	to_chat(world, "<FONT size = 3><B>The AI has won!</B></FONT>")
	to_chat(world, "<B>It has fully taken control of all of [station_name()]'s systems.</B>")

	to_nuke_or_not_to_nuke = TRUE
	for(var/datum/role/malfAI/role in members)
		var/mob/living/silicon/ai/AI = role.antag.current
		to_chat(AI, "Congratulations you have taken control of the station.")
		to_chat(AI, "You may decide to blow up the station. You have 60 seconds to choose.")
		to_chat(AI, "You should have a new verb in the Malfunction tab. If you dont - rejoin the game.")
		new /datum/AI_Module/ai_win(AI)
	addtimer(CALLBACK(src, PROC_REF(remove_ai_win_verb)), 600)

/datum/faction/malf_silicons/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = TRUE
		capture_the_station()
		return TRUE
	if (station_captured && !to_nuke_or_not_to_nuke)
		return TRUE
	if (is_malf_ai_dead())
		if(config.continous_rounds)
			if(SSshuttle)
				SSshuttle.fake_recall = FALSE
			malf_mode_declared = FALSE
		else
			return TRUE
	return FALSE

/datum/faction/malf_silicons/proc/remove_ai_win_verb()
	to_nuke_or_not_to_nuke = FALSE
	for(var/datum/role/malfAI/role in members)
		var/mob/living/silicon/ai/cur_AI = role.antag.current
		var/datum/AI_Module/explode_module = cur_AI.current_modules["Explode"]
		if(explode_module)
			qdel(explode_module)

/datum/faction/malf_silicons/proc/is_malf_ai_dead()
	var/all_dead = TRUE
	for(var/datum/role/malfAI/role in members)
		if (isAI(role.antag.current) && role.antag.current.stat != DEAD)
			all_dead = FALSE
			break
	return all_dead

/datum/faction/malf_silicons/proc/ai_win()
	if (!to_nuke_or_not_to_nuke)
		return
	remove_ai_win_verb()
	var/turf/malf_turf
	for(var/datum/role/malfAI/role in members)
		var/mob/living/silicon/ai/cur_AI = role.antag.current
		cur_AI.client.screen.Cut()
		if(!malf_turf)
			malf_turf = get_turf(cur_AI)
	SSticker.explosion_in_progress = TRUE
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/AI/DeltaBOOM.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
	to_chat(world, "Self-destructing in 10")
	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, "[i]")
	sleep(10)
	SSlag_switch.set_measure(DISABLE_NON_OBSJOBS, TRUE)
	SSticker.station_explosion_cinematic(0, null)
	if(malf_turf)
		sleep(20)
		SSticker.station_explosion_detonation(malf_turf)
	SSticker.station_was_nuked = TRUE
	SSticker.explosion_in_progress = FALSE

/datum/faction/malf_silicons/custom_result()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (SSshuttle.location == SHUTTLE_AT_CENTCOM)
	var/dat = ""
	dat += "<h3>Malfunction mode resume:</h3>"

	if(station_captured &&						SSticker.station_was_nuked)
		dat += "<span class='red'>AI Victory!</span>"
		dat += "<br><b>Everyone was killed by the self-destruct!</b>"
		feedback_add_details("[ID]_success","SUCCESS")
		SSStatistics.score.roleswon++

	else if(station_captured && malf_dead &&	!SSticker.station_was_nuked)
		dat += "<span class='red'>Neutral Victory.</span>"
		dat += "<br><b>The AI has been killed!</b> The staff has lose control over the station."
		feedback_add_details("[ID]_success","HALF")

	else if(station_captured && !malf_dead &&	!SSticker.station_was_nuked)
		dat += "<span class='red'>AI Victory!</span>"
		dat += "<br><b>The AI has chosen not to explode you all!</b>"
		feedback_add_details("[ID]_success","SUCCESS")
		SSStatistics.score.roleswon++

	else if(!station_captured && SSticker.station_was_nuked)
		dat += "<span class='red'>Neutral Victory.</span>"
		dat += "<br><b>Everyone was killed by the nuclear blast!</b>"
		feedback_add_details("[ID]_success","HALF")

	else if(!station_captured && malf_dead &&	!SSticker.station_was_nuked)
		dat += "<span class='red'>Human Victory.</span>"
		dat += "<br><b>The AI has been killed!</b> The staff is victorious."
		feedback_add_details("[ID]_success","FAIL")

	else if(!station_captured && !malf_dead &&	!SSticker.station_was_nuked && crew_evacuated)
		dat += "<span class='red'>Neutral Victory.</span>"
		dat += "<br><b>The Corporation has lose [station_name()]! All survived personnel will be fired!</b>"
		feedback_add_details("[ID]_success","HALF")

	else if(!station_captured && !malf_dead &&	!SSticker.station_was_nuked && !crew_evacuated)
		dat += "<span class='red'>Neutral Victory.</span>"
		dat += "<br><b>Round was mysteriously interrupted!</b>"
		feedback_add_details("[ID]_success","HALF")

	return dat

/datum/faction/malf_silicons/GetScoreboard()
	var/dat = custom_result()
	dat += "<br><b>The malfunctioning AI were:</b>"

	for(var/datum/role/malfAI/role in members)
		var/mob/living/silicon/ai/cur_AI = role.antag.current
		if(cur_AI)
			var/icon/flat = getFlatIcon(cur_AI)
			end_icons += flat
			var/tempstate = end_icons.len
			dat += {"<br><img src="logo_[tempstate].png"> <b>[role.antag.key]</b> was <b>[role.antag.name]</b> ("}
			if(cur_AI.stat == DEAD)
				dat += "deactivated"
			else
				dat += "operational"
			if(cur_AI.real_name != role.antag.name)
				dat += " as [cur_AI.real_name]"
		else
			var/icon/sprotch = icon('icons/mob/robots.dmi', "gib7")
			end_icons += sprotch
			var/tempstate = end_icons.len
			dat += {"<br><img src="logo_[tempstate].png"> <b>[role.antag.key]</b> was <b>[role.antag.name]</b> ("}
			dat += "hardware destroyed"
		dat += ")"
	return dat
