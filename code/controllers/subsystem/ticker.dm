var/round_start_time = 0
var/round_start_realtime = 0

SUBSYSTEM_DEF(ticker)
	name = "Ticker"

	priority = SS_PRIORITY_TICKER

	flags = SS_FIRE_IN_LOBBY | SS_KEEP_TIMING

	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_STARTUP

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	var/random_players = 0					// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list()	// list of traitor-compatible factions
	var/list/factions = list()				// list of all factions
	var/list/availablefactions = list()		// list of factions with openings

	var/list/reconverted_antags = list()

	var/delay_end = 0						//if set to nonzero, the round will not restart on it's own

	var/triai = 0							//Global holder for Triumvirate

	var/timeLeft = 1800						//pregame timer

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/obj/screen/cinematic = null

	var/force_ending = FALSE

/datum/controller/subsystem/ticker/PreInit()
	login_music = pick(\
	/*
	'sound/music/space.ogg',\
	'sound/music/clouds.s3m',\
	'sound/music/title1.ogg',\	//disgusting
	*/
	'sound/music/space_oddity.ogg',\
	'sound/music/b12_combined_start.ogg',\
	'sound/music/title2.ogg',\
	'sound/music/traitor.ogg',\
	'sound/lobby/sundown.ogg',\
	'sound/lobby/hanging_masses.ogg',\
	'sound/lobby/admiral-station-13.ogg',\
	'sound/lobby/robocop_gb_intro.ogg')


/datum/controller/subsystem/ticker/Initialize(timeofday)
	if(!syndicate_code_phrase)
		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()
	setupFactions()
	..()

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			timeLeft = initial(timeLeft)
			to_chat(world, "<b><font color='blue'>Welcome to the pre-game lobby!</font></b>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [timeLeft/10] seconds")
			current_state = GAME_STATE_PREGAME

			log_initialization() // need to dump cached log

		if(GAME_STATE_PREGAME)
			//lobby stats for statpanels
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/dead/new_player/player in player_list)
				++totalPlayers
				if(player.ready)
					++totalPlayersReady

			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 0)
				current_state = GAME_STATE_SETTING_UP

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)

			var/mode_finished = mode.check_finished() || (SSshuttle.location == 2 && SSshuttle.alert == 1) || force_ending
			if(!mode.explosion_in_progress && mode_finished)
				current_state = GAME_STATE_FINISHED
				declare_completion()
				spawn(50)
					for(var/client/C in clients)
						C.log_client_ingame_age_to_db()
					world.save_last_mode(SSticker.mode.name)

					if(blackbox)
						blackbox.save_all_data_to_sql()

					var/datum/game_mode/mutiny/mutiny = get_mutiny_mode()//why it is here?
					if(mutiny)
						mutiny.round_outcome()

					if(dbcon.IsConnected())
						var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET end_datetime = Now(), game_mode_result = '[sanitize_sql(mode.mode_result)]' WHERE id = [round_id]")
						query_round_game_mode.Execute()

					world.send2bridge(
						type = list(BRIDGE_ROUNDSTAT),
						attachment_title = "Round #[round_id] is over",
						attachment_color = BRIDGE_COLOR_ANNOUNCE,
					)

					drop_round_stats()

					if (mode.station_was_nuked)
						feedback_set_details("end_proper","nuke")
						if(!delay_end)
							to_chat(world, "<span class='notice'><B>Rebooting due to destruction of station in [restart_timeout/10] seconds</B></span>")
					else
						feedback_set_details("end_proper","proper completion")
						if(!delay_end)
							to_chat(world, "<span class='notice'><B>Restarting in [restart_timeout/10] seconds</B></span>")

					if(!delay_end)
						sleep(restart_timeout)
						if(!delay_end)
							world.Reboot(end_state = mode.station_was_nuked ? "nuke" : "proper completion") //Can be upgraded to remove unneded sleep here.
						else
							to_chat(world, "<span class='info bold'>An admin has delayed the round end</span>")
							world.send2bridge(
								type = list(BRIDGE_ROUNDSTAT),
								attachment_msg = "An admin has delayed the round end",
								attachment_color = BRIDGE_COLOR_ROUNDSTAT,
							)
					else
						to_chat(world, "<span class='info bold'>An admin has delayed the round end</span>")
						world.send2bridge(
							type = list(BRIDGE_ROUNDSTAT),
							attachment_msg = "An admin has delayed the round end",
							attachment_color = BRIDGE_COLOR_ROUNDSTAT,
						)

/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, "<span class='boldannounce'>Starting game...</span>")

	// Discuss your stuff after the round ends.
	if(config.ooc_round_only)
		to_chat(world, "<span class='warning bold'>The OOC channel has been globally disabled for the duration of the round!</span>")
		ooc_allowed = FALSE

	var/init_start = world.timeofday
	//Create and announce mode
	if(config.is_hidden_gamemode(master_mode))
		hide_mode = 1

	var/list/datum/game_mode/runnable_modes
	if (config.is_modeset(master_mode))
		runnable_modes = config.get_runnable_modes(master_mode)

		if (runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0

		// hiding forced gamemode in secret
		if(master_mode == "secret" && secret_force_mode != "secret")
			var/datum/game_mode/smode = config.pick_mode(secret_force_mode)
			smode.modeset = master_mode
			if(!smode.can_start())
				message_admins("<span class='notice'>Unable to force secret [secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.</span>")
			else
				mode = smode

		SSjob.ResetOccupations()
		if(!src.mode)
			src.mode = pickweight(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype
			src.mode.modeset = master_mode

	else
		// master_mode is config tag of gamemode
		src.mode = config.pick_mode(master_mode)

	// Before assign the crew setup antag roles without crew jobs
	if (!src.mode.assign_outsider_antag_roles())
		message_admins("<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed.")
		qdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		SSjob.ResetOccupations()
		return 0

	//Configure mode and assign player to special mode stuff
	SSjob.DivideOccupations() //Distribute jobs
	var/can_continue = src.mode.pre_setup()//Setup special modes
	if(!can_continue)
		message_admins("Preparation phase for [mode.name] has failed.")
		qdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		SSjob.ResetOccupations()
		return 0

	if(!hide_mode)
		src.mode.announce()

	current_state = GAME_STATE_PLAYING
	round_start_time = world.time
	round_start_realtime = world.realtime

	if(dbcon.IsConnected())
		var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET start_datetime = Now(), map_name = '[sanitize_sql(SSmapping.config.map_name)]' WHERE id = [round_id]")
		query_round_game_mode.Execute()

	setup_economy()
	setup_religions()

	//start_landmarks_list = shuffle(start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()

	spawn_empty_ai()

	Master.RoundStart()

	world.send2bridge(
		type = list(BRIDGE_ROUNDSTAT),
		attachment_title = "Round is started, gamemode - **[master_mode]**",
		attachment_msg = "Round #[round_id]; Join now: <[BYOND_JOIN_LINK]>",
		attachment_color = BRIDGE_COLOR_ANNOUNCE,
	)

	world.log << "Game start took [(world.timeofday - init_start)/10]s"

	to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/AI/enjoyyourstay.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, ignore_environment = TRUE)

	//Holiday Round-start stuff	~Carn
	Holiday_Game_Start()

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		for(var/mob/dead/new_player/N in new_player_list)
			if(N.client)
				N.new_player_panel_proc()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				qdel(S)
		if (length(SSvote.delay_after_start))
			for (var/DT in SSvote.delay_after_start)
				SSvote.last_vote_time[DT] = world.time

		//Print a list of antagonists to the server log
		antagonist_announce()

		/*var/admins_number = 0 //For slack maybe?
		for(var/client/C)
			if(C.holder)
				admins_number++
		if(admins_number == 0)
			send2adminirc("Round has started with no admins online.")*/

	return 1


//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/controller/subsystem/ticker/proc/station_explosion_cinematic(station_missed=0, override = null)
	if(cinematic)
		return

	var/screen = "intro_nuke"
	var/screen_time = 35
	var/explosion = "station_explode_fade_red"
	var/summary = "summary_selfdes"
	if(mode && !override)
		override = mode.name
	cinematic = new /obj/screen{icon='icons/effects/station_explosion.dmi';icon_state="station_intact";layer=21;mouse_opacity=0;screen_loc="1,0";}(src)
	for(var/mob/M in mob_list)	//nuke kills everyone on station z-level to prevent "hurr-durr I survived"
		if(M.client)
			M.client.screen += cinematic	//show every client the cinematic
		if(isliving(M))
			var/mob/living/L = M
			L.SetSleeping(1 MINUTE, TRUE, TRUE)

	switch(station_missed)
		if(0)	//station was destroyed
			if(override == "AI malfunction")
				screen = "intro_malf"
				screen_time = 76
				summary = "summary_malf"
			else if(override == "nuclear emergency")
				summary = "summary_nukewin"

			for(var/mob/M in mob_list)	//nuke kills everyone on station z-level to prevent "hurr-durr I survived"
				if(M.stat != DEAD)	//Just you wait for real destruction!
					var/turf/T = get_turf(M)
					if(T && is_station_level(T.z))
						M.death(0)	//No mercy

		if(1)	//nuke was nearby but (mostly) missed
			if(override == "nuclear emergency")
				explosion = "station_intact_fade_red"
				summary = "summary_nukefail"
			else
				explosion = null
				summary = null

		if(2)	//nuke was nowhere nearby	TODO: a really distant explosion animation
			screen = null
			screen_time = 50
			explosion = null
			summary = null

	if(screen)
		flick(screen, cinematic)
	addtimer(CALLBACK(src, .proc/station_explosion_effects, explosion, summary, cinematic), screen_time)

/datum/controller/subsystem/ticker/proc/station_explosion_effects(explosion, summary, /obj/screen/cinematic)
	for(var/mob/M in mob_list) //search any goodest
		M.playsound_local(null, 'sound/effects/explosionfar.ogg', VOL_EFFECTS_MASTER, vary = FALSE, ignore_environment = TRUE)
	if(explosion)
		flick(explosion,cinematic)
	if(summary)
		cinematic.icon_state = summary
	addtimer(CALLBACK(src, .proc/station_explosion_rollback_effects, cinematic), 10 SECONDS)

/datum/controller/subsystem/ticker/proc/station_explosion_rollback_effects(cinematic)
	for(var/mob/M in mob_list)
		if(M.client)
			M.client.screen -= cinematic
		if(isliving(M))
			var/mob/living/L = M
			L.SetSleeping(0, TRUE, TRUE)
	if(cinematic)
		qdel(cinematic)		//end the cinematic

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/dead/new_player/player in player_list)
		//sleep(1)//Maybe remove??
		if(player && player.ready && player.mind)
			joined_player_list += player.ckey
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			//else if(!player.mind.assigned_role)//Not sure if needed...
			//	continue
			else
				player.create_character()
				qdel(player)
		CHECK_TICK // comment/remove this and uncomment sleep, if crashes at round start will come back.

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/living/player in player_list)
		if(player.mind)
			SSticker.minds += player.mind


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/living/carbon/human/player in player_list)
		if(player && player.mind && player.mind.assigned_role && player.mind.assigned_role != "default")
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != "MODE")
				SSjob.EquipRank(player, player.mind.assigned_role, 0)
			if(ishuman(player))
				SSquirks.AssignQuirks(player, player.client, TRUE)
	if(captainless)
		for(var/mob/M in player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captainship not forced on anyone.")

//cursed code
/datum/controller/subsystem/ticker/proc/declare_completion()
	// Now you all can discuss the game.
	if(config.ooc_round_only)
		to_chat(world, "<span class='notice bold'>The OOC channel has been globally enabled!</span>")
		ooc_allowed = TRUE

	var/station_evacuated
	if(SSshuttle.location > 0)
		station_evacuated = 1
	var/num_survivors = 0
	var/num_escapees = 0

	to_chat(world, "<BR><BR><BR><FONT size=3><B>The round has ended.</B></FONT>")

	//Player status report
	for(var/mob/Player in mob_list)//todo: remove in favour of /game_mode/proc/declare_completion
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					var/turf/playerTurf = get_turf(Player)
					if(!is_centcom_level(playerTurf.z))
						to_chat(Player, "<font color='blue'><b>You managed to survive, but were marooned on [station_name()]...</b></FONT>")
					else
						num_escapees++
						to_chat(Player, "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></FONT>")
				else
					to_chat(Player, "<font color='green'><b>You managed to survive the events on [station_name()] as [Player.real_name].</b></FONT>")
			else
				to_chat(Player, "<font color='red'><b>You did not survive the events on [station_name()]...</b></FONT>")

	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(round( 100 * start_state.score(end_state), 0.1), 100)

	to_chat(world, "<BR>[TAB]Shift Duration: <B>[round(world.time / 36000)]:[add_zero("[world.time / 600 % 60]", 2)]:[add_zero("[world.time / 10 % 60]", 2)]</B>")
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[mode.station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	if(joined_player_list.len)
		to_chat(world, "<BR>[TAB]Total Population: <B>[joined_player_list.len]</B>")
		if(station_evacuated)
			to_chat(world, "<BR>[TAB]Evacuation Rate: <B>[num_escapees] ([round((num_escapees/joined_player_list.len)*100, 0.1)]%)</B>")
		to_chat(world, "<BR>[TAB]Survival Rate: <B>[num_survivors] ([round((num_survivors/joined_player_list.len)*100, 0.1)]%)</B>")
	to_chat(world, "<BR>")

	//Silicon laws report
	var/ai_completions = "<h1>Round End Information</h1><HR>"

	if(silicon_list.len)
		ai_completions += "<h2>Silicons Laws</h2>"
		ai_completions += "<div class='block'>"
		for (var/mob/living/silicon/ai/aiPlayer in ai_list)
			if(!aiPlayer)
				continue
			var/icon/flat = getFlatIcon(aiPlayer)
			end_icons += flat
			var/tempstate = end_icons.len
			var/aikey = aiPlayer.mind ? aiPlayer.mind.key : aiPlayer.key
			if (aiPlayer.stat != DEAD)
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [aiPlayer.name] (Played by: [aikey])'s laws at the end of the game were:</B>"}
			else
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [aiPlayer.name] (Played by: [aikey])'s laws when it was deactivated were:</B>"}
			ai_completions += "<BR>[aiPlayer.write_laws()]"

			if (aiPlayer.connected_robots.len)
				var/robolist = "<BR><B>The AI's loyal minions were:</B> "
				for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
					var/robokey = robo.mind ? robo.mind.key : robo.key
					robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robokey]), ":" (Played by: [robokey]), "]"
				ai_completions += "[robolist]"

		var/dronecount = 0

		for (var/mob/living/silicon/robot/robo in silicon_list)
			if(!robo)
				continue
			if(istype(robo,/mob/living/silicon/robot/drone))
				dronecount++
				continue
			var/icon/flat = getFlatIcon(robo,exact=1)
			end_icons += flat
			var/tempstate = end_icons.len
			var/robokey = robo.mind ? robo.mind.key : robo.key
			if (!robo.connected_ai)
				if (robo.stat != DEAD)
					ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Played by: [robokey]) survived as an AI-less borg! Its laws were:</B>"}
				else
					ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Played by: [robokey]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</B>"}
			else
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Played by: [robokey]) [robo.stat!=2?"survived":"perished"] as a cyborg slaved to [robo.connected_ai]! Its laws were:</B>"}
			ai_completions += "<BR>[robo.write_laws()]"

		if(dronecount)
			ai_completions += "<B>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] this round.</B>"

		ai_completions += "</div>"

	mode.declare_completion()//To declare normal completion.

	ai_completions += "<br><h2>Mode Result</h2>"

	if(mode.completion_text)//extendet has empty completion text
		ai_completions += "<div class='block'>[mode.completion_text]</div>"

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			ai_completions += "[call(mode, handler)()]"

	//Print a list of antagonists to the server log
	antagonist_announce()

	if(SSjunkyard)
		SSjunkyard.save_stats()

	scoreboard(ai_completions)

	//Ask the event manager to print round end information
	SSevents.RoundEnd()

	return 1

/datum/controller/subsystem/ticker/proc/achievement_declare_completion()
	var/text = "<br><FONT size = 5><b>Additionally, the following players earned achievements:</b></FONT>"
	var/icon/cup = icon('icons/obj/drinks.dmi', "golden_cup")
	end_icons += cup
	var/tempstate = end_icons.len
	for(var/winner in achievements)
		var/winner_text = "<b>[winner["key"]]</b> as <b>[winner["name"]]</b> won \"<b>[winner["title"]]</b>\"! \"[winner["desc"]]\""
		text += {"<br><img src="logo_[tempstate].png"> [winner_text]"}

	return text

/datum/controller/subsystem/ticker/proc/start_now()
	if(SSticker.current_state != GAME_STATE_PREGAME)
		return FALSE
	SSticker.can_fire = TRUE
	SSticker.timeLeft = 0
	return TRUE

/world/proc/has_round_started()
	return (SSticker && SSticker.current_state >= GAME_STATE_PLAYING)

/world/proc/has_round_finished()
	return (SSticker && SSticker.current_state >= GAME_STATE_FINISHED)

/world/proc/is_round_preparing()
	return (SSticker && SSticker.current_state == GAME_STATE_PREGAME)
