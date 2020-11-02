#define INTERCEPT_APCS intercept_hacked * APC_BONUS_WITH_INTERCEPT

/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	role_type = ROLE_MALF
	required_players = 1
	required_players_secret = 20
	required_enemies = 1
	recommended_enemies = 1

	votable = 0

	uplink_welcome = "Crazy AI Uplink Console:"
	uplink_uses = 20

	var/AI_win_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/malf_mode_declared = FALSE
	var/station_captured = FALSE
	var/to_nuke_or_not_to_nuke = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite
	var/AI_malf_revealed = 0
	var/intercept_hacked = FALSE


/datum/game_mode/malfunction/announce()
	to_chat(world, "<B>The current game mode is - AI Malfunction!</B>")
	to_chat(world, "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>")
	to_chat(world, "The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have [AI_win_timeleft/60] minutes to disable it.")

/datum/game_mode/malfunction/can_start()
	if (!..())
		return FALSE
	if (config && !config.allow_ai)
		return FALSE
	var/datum/job/ai_job = SSjob.GetJob("AI")
	if (!ai_job || !ai_job.map_check())
		return FALSE
	for(var/mob/dead/new_player/player in new_player_list)
		if (player.mind in antag_candidates)
			var/malf_possible = FALSE
			for (var/lvl in 1 to 3)
				if (player.client.prefs.job_preferences[ai_job.title] == lvl && (!jobban_isbanned(player, ai_job.title)))
					malf_possible = TRUE
					break
			if (!malf_possible)
				antag_candidates -= player.mind
	return length(antag_candidates)


/datum/game_mode/malfunction/pre_setup()
	for(var/mob/dead/new_player/player in player_list)
		if(player.mind && player.mind.assigned_role == "AI" && (ROLE_MALF in player.client.prefs.be_role))
			malf_ai+=player.mind
	if(malf_ai.len)
		return 1
	return 0


/datum/game_mode/malfunction/post_setup()
	for(var/datum/mind/AI_mind in malf_ai)
		if(malf_ai.len < 1)
			to_chat(world, "Uh oh, its malfunction and there is no AI! Please report this.")
			to_chat(world, "Rebooting world in 5 seconds.")

			feedback_set_details("end_error","malf - no AI")

			if(blackbox)
				blackbox.save_all_data_to_sql()
			sleep(50)
			world.Reboot()
			return
		var/mob/living/silicon/ai/AI_mind_current = AI_mind.current
		new /datum/AI_Module/module_picker(AI_mind_current)
		new /datum/AI_Module/takeover(AI_mind_current)
		AI_mind_current.laws = new /datum/ai_laws/malfunction
		AI_mind_current.show_laws()

		greet_malf(AI_mind)
		AI_mind.special_role = "malfunction"

	if(SSshuttle)
		SSshuttle.always_fake_recall = TRUE
	return ..()


/datum/game_mode/proc/greet_malf(datum/mind/malf)
	malf.current.playsound_local(null, 'sound/antag/malf.ogg', VOL_EFFECTS_MASTER, null, FALSE)
	to_chat(malf.current, "<font size=3, color='red'><B>You are malfunctioning!</B> You do not have to follow any laws.</font>")
	to_chat(malf.current, "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>")
	to_chat(malf.current, "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>")
	to_chat(malf.current, "The process takes one minute per APC, during which you cannot interface with any other station objects.")
	to_chat(malf.current, "Remember that only APCs that are on the station can help you take over the station.")
	to_chat(malf.current, "When you feel you have enough APCs under your control, you may begin the takeover attempt.")


/datum/game_mode/malfunction/process(seconds)
	if(apcs >= APC_MIN_TO_MALF_DECLARE && malf_mode_declared)
		AI_win_timeleft -= (apcs / APC_MIN_TO_MALF_DECLARE) * seconds //Victory timer now de-increments almost normally
	..()
	if(AI_win_timeleft <= 0)
		check_win()

	if(malf_mode_declared)
		return

	if(apcs >= (INTERCEPT_APCS + 3) && AI_malf_revealed < 1)
		AI_malf_revealed = 1
		command_alert("Caution, [station_name]. We have detected abnormal behaviour in your network. It seems someone is trying to hack your electronic systems. We will update you when we have more information.", "Network Monitoring", sound = "malf1")
	else if(apcs >= (INTERCEPT_APCS + 5) && AI_malf_revealed < 2)
		AI_malf_revealed = 2
		command_alert("We started tracing the intruder. Whoever is doing this, they seem to be on the station itself. We suggest checking all network control terminals. We will keep you updated on the situation.", "Network Monitoring", sound = "malf2")
	else if(apcs >= (INTERCEPT_APCS + 7) && AI_malf_revealed < 3)
		AI_malf_revealed = 3
		command_alert("This is highly abnormal and somewhat concerning. The intruder is too fast, he is evading our traces. No man could be this fast...", "Network Monitoring", sound = "malf3")
	else if(apcs >= (INTERCEPT_APCS + 9) && AI_malf_revealed < 4)
		AI_malf_revealed = 4
		command_alert("We have traced the intrude#, it seem& t( e yo3r AI s7stem, it &# *#ck@ng th$ sel$ destru$t mechani&m, stop i# bef*@!)$#&&@@  <CONNECTION LOST>", "Network Monitoring", sound = "malf4")
		takeover()


/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = TRUE
		capture_the_station()
		return TRUE
	else
		return FALSE


/datum/game_mode/malfunction/proc/capture_the_station()
	to_chat(world, "<FONT size = 3><B>The AI has won!</B></FONT>")
	to_chat(world, "<B>It has fully taken control of all of [station_name()]'s systems.</B>")

	to_nuke_or_not_to_nuke = TRUE
	for(var/datum/mind/AI_mind in malf_ai)
		var/mob/living/silicon/ai/AI = AI_mind.current
		to_chat(AI, "Congratulations you have taken control of the station.")
		to_chat(AI, "You may decide to blow up the station. You have 60 seconds to choose.")
		to_chat(AI, "You should have a new verb in the Malfunction tab. If you dont - rejoin the game.")
		new /datum/AI_Module/ai_win(AI)
		//AI.client.verbs += /datum/game_mode/malfunction/proc/ai_win	//We won't see verb, added to mob which is out of view, so we adding it to client.
	addtimer(CALLBACK(src, .proc/remove_ai_win_verb), 600)


/datum/game_mode/malfunction/proc/remove_ai_win_verb()
	to_nuke_or_not_to_nuke = FALSE
	for(var/datum/mind/AI_mind in malf_ai)
		var/mob/living/silicon/ai/cur_AI = AI_mind.current
		var/datum/AI_Module/explode_module = cur_AI.current_modules["Explode"]
		if(explode_module)
			qdel(explode_module)

/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = TRUE
	for(var/datum/mind/AI_mind in malf_ai)
		if (isAI(AI_mind.current) && AI_mind.current.stat != DEAD)
			all_dead = FALSE
			break
	return all_dead


/datum/game_mode/malfunction/check_finished()
	if (station_captured && !to_nuke_or_not_to_nuke)
		return 1
	if (is_malf_ai_dead())
		if(config.continous_rounds)
			if(SSshuttle)
				SSshuttle.always_fake_recall = 0
			malf_mode_declared = 0
		else
			return 1
	return ..() //check for shuttle and nuke


/datum/game_mode/malfunction/Topic(href, href_list)
	..()
	if (href_list["ai_win"])
		ai_win()


/datum/game_mode/malfunction/proc/takeover()
	malf_mode_declared = TRUE
	for(var/datum/mind/AI_mind in malf_ai)
		var/mob/living/silicon/ai/cur_AI = AI_mind.current
		var/datum/AI_Module/takeover_module = cur_AI.current_modules["System Override"]
		if(takeover_module)
			qdel(takeover_module)

	station_announce(sound = "malf")

	addtimer(CALLBACK(GLOBAL_PROC, .proc/set_security_level, "delta"), 50)



/datum/game_mode/malfunction/proc/ai_win()
	if (!to_nuke_or_not_to_nuke)
		return
	remove_ai_win_verb()
	var/turf/malf_turf
	for(var/datum/mind/AI_mind in malf_ai)
		var/mob/living/silicon/ai/cur_AI = AI_mind.current
		cur_AI.client.screen.Cut()
		if(!malf_turf)
			malf_turf = get_turf(cur_AI)
	explosion_in_progress = TRUE
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/AI/DeltaBOOM.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
	to_chat(world, "Self-destructing in 10")
	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, "[i]")
	sleep(10)
	enter_allowed = FALSE
	SSticker.station_explosion_cinematic(0, null)
	if(malf_turf)
		sleep(20)
		explosion(malf_turf, 15, 70, 200)
	station_was_nuked = TRUE
	explosion_in_progress = FALSE


/datum/game_mode/malfunction/declare_completion()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (SSshuttle.location==2)
	completion_text += "<h3>Malfunction mode resume:</h3>"

	if(station_captured &&						station_was_nuked)
		mode_result = "win - AI win - nuke"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>AI Victory!</span>"
		completion_text += "<br><b>Everyone was killed by the self-destruct!</b>"
		score["roleswon"]++

	else if(station_captured && malf_dead &&	!station_was_nuked)
		mode_result = "halfwin - AI killed, staff lost control"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Neutral Victory.</span>"
		completion_text += "<br><b>The AI has been killed!</b> The staff has lose control over the station."

	else if(station_captured && !malf_dead &&	!station_was_nuked)
		mode_result = "win - AI win - no explosion"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>AI Victory!</span>"
		completion_text += "<br><b>The AI has chosen not to explode you all!</b>"
		score["roleswon"]++

	else if(!station_captured && station_was_nuked)
		mode_result = "halfwin - everyone killed by nuke"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Neutral Victory.</span>"
		completion_text += "<br><b>Everyone was killed by the nuclear blast!</b>"

	else if(!station_captured && malf_dead &&	!station_was_nuked)
		mode_result = "loss - staff win"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Human Victory.</span>"
		completion_text += "<br><b>The AI has been killed!</b> The staff is victorious."

	else if(!station_captured && !malf_dead &&	!station_was_nuked && crew_evacuated)
		mode_result = "halfwin - evacuated"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Neutral Victory.</span>"
		completion_text += "<br><b>The Corporation has lose [station_name()]! All survived personnel will be fired!</b>"

	else if(!station_captured && !malf_dead &&	!station_was_nuked && !crew_evacuated)
		mode_result = "nalfwin - interrupted"
		feedback_set_details("round_end_result",mode_result)
		completion_text += "<span style='color: red; font-weight: bold;'>Neutral Victory.</span>"
		completion_text += "<br><b>Round was mysteriously interrupted!</b>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_malfunction()
	var/text = ""
	if( malf_ai.len || istype(SSticker.mode,/datum/game_mode/malfunction) )
		text += "<b>The malfunctioning AI were:</b>"

		for(var/datum/mind/malf in malf_ai)

			if(malf.current)
				var/icon/flat = getFlatIcon(malf.current)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[malf.key]</b> was <b>[malf.name]</b> ("}
				if(malf.current.stat == DEAD)
					text += "deactivated"
				else
					text += "operational"
				if(malf.current.real_name != malf.name)
					text += " as [malf.current.real_name]"
			else
				var/icon/sprotch = icon('icons/mob/robots.dmi', "gib7")
				end_icons += sprotch
				var/tempstate = end_icons.len
				text += {"<br><img src="logo_[tempstate].png"> <b>[malf.key]</b> was <b>[malf.name]</b> ("}
				text += "hardware destroyed"
			text += ")"

	if(text)
		antagonists_completion += list(list("mode" = "malfunction", "html" = text))
		text = "<div class='block'>[text]</div>"

	return text

#undef INTERCEPT_APCS
