/datum/game_mode
	var/list/datum/mind/malf_ai = list()

/datum/game_mode/malfunction
	name = "AI malfunction"
	config_tag = "malfunction"
	role_type = ROLE_MALF
	required_players = 2
	required_players_secret = 15
	required_enemies = 1
	recommended_enemies = 1

	votable = 0

	uplink_welcome = "Crazy AI Uplink Console:"
	uplink_uses = 10

	var/AI_win_timeleft = 1800 //started at 1800, in case I change this for testing round end.
	var/malf_mode_declared = 0
	var/station_captured = 0
	var/to_nuke_or_not_to_nuke = 0
	var/apcs = 0 //Adding dis to track how many APCs the AI hacks. --NeoFite


/datum/game_mode/malfunction/announce()
	to_chat(world, "<B>The current game mode is - AI Malfunction!</B>")
	to_chat(world, "<B>The AI on the satellite has malfunctioned and must be destroyed.</B>")
	to_chat(world, "The AI satellite is deep in space and can only be accessed with the use of a teleporter! You have [AI_win_timeleft/60] minutes to disable it.")


/datum/game_mode/malfunction/pre_setup()
	for(var/mob/new_player/player in player_list)
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
		AI_mind.current.verbs += /mob/living/silicon/ai/proc/choose_modules
		AI_mind.current:laws = new /datum/ai_laws/malfunction
		AI_mind.current:malf_picker = new /datum/AI_Module/module_picker
		AI_mind.current:show_laws()

		greet_malf(AI_mind)

		AI_mind.special_role = "malfunction"

		AI_mind.current.verbs += /datum/game_mode/malfunction/proc/takeover

/*		AI_mind.current.icon_state = "ai-malf"
		spawn(10)
			if(alert(AI_mind.current,"Do you want to use an alternative sprite for your real core?",,"Yes","No")=="Yes")
				AI_mind.current.icon_state = "ai-malf2"
*/
	if(SSshuttle)
		SSshuttle.always_fake_recall = 1
	return ..()


/datum/game_mode/proc/greet_malf(datum/mind/malf)
	to_chat(malf.current, "<font size=3, color='red'><B>You are malfunctioning!</B> You do not have to follow any laws.</font>")
	to_chat(malf.current, "<B>The crew do not know you have malfunctioned. You may keep it a secret or go wild.</B>")
	to_chat(malf.current, "<B>You must overwrite the programming of the station's APCs to assume full control of the station.</B>")
	to_chat(malf.current, "The process takes one minute per APC, during which you cannot interface with any other station objects.")
	to_chat(malf.current, "Remember that only APCs that are on the station can help you take over the station.")
	to_chat(malf.current, "When you feel you have enough APCs under your control, you may begin the takeover attempt.")
	return


/datum/game_mode/malfunction/proc/hack_intercept()
	intercept_hacked = 1


/datum/game_mode/malfunction/process(seconds)
	if (apcs >= APC_MIN_TO_MALDF_DECLARE && malf_mode_declared)
		AI_win_timeleft -= (apcs / APC_MIN_TO_MALDF_DECLARE) * seconds //Victory timer now de-increments almost normally
	..()
	if (AI_win_timeleft<=0)
		check_win()
	return


/datum/game_mode/malfunction/check_win()
	if (AI_win_timeleft <= 0 && !station_captured)
		station_captured = 1
		capture_the_station()
		return 1
	else
		return 0


/datum/game_mode/malfunction/proc/capture_the_station()
	to_chat(world, "<FONT size = 3><B>The AI has won!</B></FONT>")
	to_chat(world, "<B>It has fully taken control of all of [station_name()]'s systems.</B>")

	to_nuke_or_not_to_nuke = 1
	for(var/datum/mind/AI_mind in malf_ai)
		var/mob/living/silicon/ai/AI = AI_mind.current
		to_chat(AI, "Congratulations you have taken control of the station.")
		to_chat(AI, "You may decide to blow up the station. You have 60 seconds to choose.")
		to_chat(AI, "You should have a new verb in the Malfunction tab. If you dont - rejoin the game.")
		AI.client.verbs += /datum/game_mode/malfunction/proc/ai_win	//We won't see verb, added to mob which is out of view, so we adding it to client.
	spawn (600)
		for(var/datum/mind/AI_mind in malf_ai)
			var/mob/living/silicon/ai/AI = AI_mind.current
			AI.client.verbs -= /datum/game_mode/malfunction/proc/ai_win
		to_nuke_or_not_to_nuke = 0
	return


/datum/game_mode/proc/is_malf_ai_dead()
	var/all_dead = 1
	for(var/datum/mind/AI_mind in malf_ai)
		if (istype(AI_mind.current,/mob/living/silicon/ai) && AI_mind.current.stat!=2)
			all_dead = 0
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
	return


/datum/game_mode/malfunction/proc/takeover()
	set category = "Malfunction"
	set name = "System Override"
	set desc = "Start the victory timer."
	if (!istype(ticker.mode,/datum/game_mode/malfunction))
		to_chat(usr, "You cannot begin a takeover in this round type!")
		return
	if (ticker.mode:malf_mode_declared)
		to_chat(usr, "You've already begun your takeover.")
		return
	if (ticker.mode:apcs < APC_MIN_TO_MALDF_DECLARE)
		to_chat(usr, "You don't have enough hacked APCs to take over the station yet. You need to hack at least 3, however hacking more will make the takeover faster. You have hacked [ticker.mode:apcs] APCs so far.")
		return

	if (alert(usr, "Are you sure you wish to initiate the takeover? The station hostile runtime detection software is bound to alert everyone. You have hacked [ticker.mode:apcs] APCs.", "Takeover:", "Yes", "No") != "Yes")
		return

	command_alert("Hostile runtimes detected in all station systems, please deactivate your AI to prevent possible damage to its morality core.", "Anomaly Alert")
	set_security_level("delta")

	ticker.mode:malf_mode_declared = 1
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		AI_mind.current.verbs -= /datum/game_mode/malfunction/proc/takeover
	for(var/mob/M in player_list)
		if(!isnewplayer(M))
			M << sound('sound/AI/aimalf.ogg')


/datum/game_mode/malfunction/proc/ai_win()
	set category = "Malfunction"
	set name = "Explode"
	set desc = "Station go boom."
	if (!ticker.mode:to_nuke_or_not_to_nuke)
		return
	ticker.mode:to_nuke_or_not_to_nuke = 0
	var/turf/malf_turf
	for(var/datum/mind/AI_mind in ticker.mode:malf_ai)
		var/mob/living/silicon/ai/AI = AI_mind.current
		AI.client.verbs -= /datum/game_mode/malfunction/proc/ai_win
		AI.client.screen.Cut()
		if(!malf_turf)
			malf_turf = get_turf(AI)
	ticker.mode:explosion_in_progress = 1
	for(var/mob/M in player_list)
		M << 'sound/machines/Alarm.ogg'
	to_chat(world, "Self-destructing in 10")
	for (var/i=9 to 1 step -1)
		sleep(10)
		to_chat(world, i)
	sleep(10)
	enter_allowed = 0
	if(ticker)
		//ticker.station_explosion_cinematic(0,null)
		if(malf_turf)
			sleep(20)
			explosion(malf_turf, 15, 70, 200)
		if(ticker.mode)
			ticker.mode:station_was_nuked = 1
			ticker.mode:explosion_in_progress = 0
	return


/datum/game_mode/malfunction/declare_completion()
	var/malf_dead = is_malf_ai_dead()
	var/crew_evacuated = (SSshuttle.location==2)
	completion_text += "<B>Malfunction mode resume:</B><BR>"

	if      ( station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - nuke")
		completion_text += "<FONT size = 3, color='red'><B>AI Victory!</B></FONT>"
		completion_text += "<BR><B>Everyone was killed by the self-destruct!</B>"
		score["roleswon"]++

	else if ( station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","halfwin - AI killed, staff lost control")
		completion_text += "<FONT size = 3, color='red'><B>Neutral Victory.</B></FONT>"
		completion_text += "<BR><B>The AI has been killed!</B> The staff has lose control over the station."

	else if ( station_captured && !malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","win - AI win - no explosion")
		completion_text += "<FONT size = 3, color='red'><B>AI Victory!</B></FONT>"
		completion_text += "<BR><B>The AI has chosen not to explode you all!</B>"
		score["roleswon"]++

	else if (!station_captured &&                station_was_nuked)
		feedback_set_details("round_end_result","halfwin - everyone killed by nuke")
		completion_text += "<FONT size = 3, color='red'><B>Neutral Victory.</B></FONT>"
		completion_text += "<BR><B>Everyone was killed by the nuclear blast!</B>"

	else if (!station_captured &&  malf_dead && !station_was_nuked)
		feedback_set_details("round_end_result","loss - staff win")
		completion_text += "<FONT size = 3, color='red'><B>Human Victory.</B></FONT>"
		completion_text += "<BR><B>The AI has been killed!</B> The staff is victorious."

	else if (!station_captured && !malf_dead && !station_was_nuked && crew_evacuated)
		feedback_set_details("round_end_result","halfwin - evacuated")
		completion_text += "<FONT size = 3, color='red'><B>Neutral Victory.</B></FONT>"
		completion_text += "<BR><B>The Corporation has lose [station_name()]! All survived personnel will be fired!</B>"

	else if (!station_captured && !malf_dead && !station_was_nuked && !crew_evacuated)
		feedback_set_details("round_end_result","nalfwin - interrupted")
		completion_text += "<FONT size = 3, color='red'><B>Neutral Victory.</B></FONT>"
		completion_text += "<BR><B>Round was mysteriously interrupted!</B>"
	..()
	return 1


/datum/game_mode/proc/auto_declare_completion_malfunction()
	var/text = ""
	if( malf_ai.len || istype(ticker.mode,/datum/game_mode/malfunction) )
		text += "<B>The malfunctioning AI were:</B>"

		for(var/datum/mind/malf in malf_ai)

			if(malf.current)
				var/icon/flat = getFlatIcon(malf.current)
				end_icons += flat
				var/tempstate = end_icons.len
				text += {"<BR><img src="logo_[tempstate].png"> <B>[malf.key]</B> was <b>[malf.name]</B> ("}
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
				text += {"<BR><img src="logo_[tempstate].png"> <B>[malf.key]</B> was <b>[malf.name]</B> ("}
				text += "hardware destroyed"
			text += ")"

		text += "<BR><HR>"
	return text
