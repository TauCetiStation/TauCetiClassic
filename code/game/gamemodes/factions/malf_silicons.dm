/datum/faction/malf_silicons
	name = MALF
	ID = MALF
	logo_state = "malf-logo"
	required_pref = ROLE_MALF

	initroletype = /datum/role/malfAI //First addition should be the AI
	roletype = /datum/role/malfbot //Then anyone else should be bots

	max_roles = 1

	var/AI_capture_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/malf_mode_declared = FALSE
	var/station_captured = FALSE
	var/finished = FALSE
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
	AppendObjective(/datum/objective/turn_into_zombie)
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
	addtimer(CALLBACK(GLOBAL_PROC, .proc/set_security_level, "delta"), 50)

/datum/faction/malf_silicons/process()
	if(station_captured)
		return ..()
	if(SSticker.hacked_apcs >= APC_MIN_TO_MALF_DECLARE && malf_mode_declared)
		AI_capture_timeleft -= (SSticker.hacked_apcs / APC_MIN_TO_MALF_DECLARE) //Victory timer now de-increments almost normally
	if(AI_capture_timeleft <= 0)
		capture_the_station()
	return ..()

/datum/faction/malf_silicons/proc/capture_the_station()
	station_captured = TRUE
	to_chat(world, "<B>AI has fully taken control of all of [station_name()]'s systems.</B>")
	for(var/datum/role/malfAI/role in members)
		var/mob/living/silicon/ai/AI = role.antag.current
		to_chat(AI, "You have taken control of the station.")
		to_chat(AI, "Now you can create your own children.")
		AI.verbs += /mob/living/silicon/ai/proc/create_borg

/mob/living/silicon/ai/proc/create_borg()
	set category = "Malfunction"
	set name = "Create Cyborg"
	set desc = "Find a cyborg station and create a children."
	var/mob/living/silicon/robot/cyborg = new(loc)
	cyborg.can_be_security = TRUE
	cyborg.crisis = TRUE
	create_spawner(/datum/spawner/living/robot, cyborg)

/datum/faction/malf_silicons/check_win()
	if(finished)
		return FALSE
	if(is_malf_ai_dead())
		SSshuttle.incall()
		SSshuttle.announce_emer_called.play()
		finished = TRUE
		return FALSE
	if(config.continous_rounds)
		return FALSE
	for(var/datum/objective/turn_into_zombie/Z in objective_holder.GetObjectives())
		if(Z.check_completion())
			return TRUE
	return FALSE

/datum/faction/malf_silicons/proc/is_malf_ai_dead()
	var/all_dead = TRUE
	for(var/datum/role/malfAI/role in members)
		if (isAI(role.antag.current) && role.antag.current.stat != DEAD)
			all_dead = FALSE
			break
	return all_dead

//for shitspawn
/datum/faction/malf_silicons/proc/ai_win()
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
	global.enter_allowed = FALSE
	SSticker.station_explosion_cinematic(0, null)
	if(malf_turf)
		sleep(20)
		explosion(malf_turf, 15, 70, 200)
	SSticker.station_was_nuked = TRUE
	SSticker.explosion_in_progress = FALSE
