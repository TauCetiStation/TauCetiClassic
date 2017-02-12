var/round_start_time = 0

var/datum/subsystem/ticker/ticker

/datum/subsystem/ticker
	name = "Ticker"
	priority = 0

	can_fire = 1 // This needs to fire before round start.

	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_STARTUP

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list()//The people in the game. Used for objective tracking.

	//These bible variables should be a preference
	var/Bible_icon_state					//icon_state the chaplain has chosen for his bible
	var/Bible_item_state					//item_state the chaplain has chosen for his bible
	var/Bible_name							//name of the bible
	var/Bible_deity_name					//name of chaplin's deity

	var/random_players = 0					// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/list/syndicate_coalition = list()	// list of traitor-compatible factions
	var/list/factions = list()				// list of all factions
	var/list/availablefactions = list()		// list of factions with openings

	var/delay_end = 0						//if set to nonzero, the round will not restart on it's own

	var/triai = 0							//Global holder for Triumvirate

	var/timeLeft = 1800						//pregame timer

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/obj/screen/cinematic = null


/datum/subsystem/ticker/New()
	NEW_SS_GLOBAL(ticker)

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


/datum/subsystem/ticker/Initialize(timeofday, zlevel)
	if (zlevel)
		return ..()
	if(!syndicate_code_phrase)
		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)
		syndicate_code_response	= generate_code_phrase()
	setupFactions()
	..()

/datum/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			timeLeft = initial(timeLeft)
			to_chat(world, "<b><font color='blue'>Welcome to the pre-game lobby!</font></b>")
			to_chat(world, "Please, setup your character and select ready. Game will start in [timeLeft/10] seconds")
			current_state = GAME_STATE_PREGAME

		if(GAME_STATE_PREGAME)
			//lobby stats for statpanels
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/new_player/player in player_list)
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

			var/mode_finished = mode.check_finished() || (SSshuttle.location == 2 && SSshuttle.alert == 1)
			if(!mode.explosion_in_progress && mode_finished)
				current_state = GAME_STATE_FINISHED
				declare_completion()
				spawn(50)
					for(var/client/C in clients)
						C.log_client_ingame_age_to_db()
					world.save_last_mode(ticker.mode.name)

					if(blackbox)
						blackbox.save_all_data_to_sql()

					var/datum/game_mode/mutiny/mutiny = get_mutiny_mode()
					if(mutiny)
						mutiny.round_outcome()

					slack_roundend()

					if (mode.station_was_nuked)
						feedback_set_details("end_proper","nuke")
						if(!delay_end)
							to_chat(world, "\blue <B>Rebooting due to destruction of station in [restart_timeout/10] seconds</B>")
					else
						feedback_set_details("end_proper","proper completion")
						if(!delay_end)
							to_chat(world, "\blue <B>Restarting in [restart_timeout/10] seconds</B>")

					if(!delay_end)
						sleep(restart_timeout)
						if(!delay_end)
							world.Reboot() //Can be upgraded to remove unneded sleep here.
						else
							to_chat(world, "\blue <B>An admin has delayed the round end</B>")
							send2slack_service("An admin has delayed the round end")
					else
						to_chat(world, "\blue <B>An admin has delayed the round end</B>")
						send2slack_service("An admin has delayed the round end")

/datum/subsystem/ticker/proc/setup()
	//Create and announce mode
	if(master_mode=="secret" || master_mode=="bs12" || master_mode=="tau classic")
		hide_mode = 1

	var/list/datum/game_mode/runnable_modes
	if(master_mode=="random" || master_mode=="secret")
		runnable_modes = config.get_runnable_modes()

		if (runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0

		if(secret_force_mode != "secret")
			var/datum/game_mode/smode = config.pick_mode(secret_force_mode)
			if(!smode.can_start())
				message_admins("\blue Unable to force secret [secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed.")
			else
				mode = smode

		SSjob.ResetOccupations()
		if(!src.mode)
			src.mode = pickweight(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype

	else if(master_mode=="bs12" || master_mode=="tau classic")
		runnable_modes = config.get_custom_modes(master_mode)
		if (runnable_modes.len==0)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			return 0
		SSjob.ResetOccupations()
		if(!src.mode)
			src.mode = pick(runnable_modes)
		if(src.mode)
			var/mtype = src.mode.type
			src.mode = new mtype

	else
		src.mode = config.pick_mode(master_mode)

	if (!src.mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players needed. Reverting to pre-game lobby.")
		qdel(mode)
		mode = null
		current_state = GAME_STATE_PREGAME
		SSjob.ResetOccupations()
		return 0

	//Configure mode and assign player to special mode stuff
	SSjob.DivideOccupations() //Distribute jobs
	var/can_continue = src.mode.pre_setup()//Setup special modes
	if(!can_continue)
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

	//start_landmarks_list = shuffle(start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()

	spawn_empty_ai()
	setup_economy()

	Master.RoundStart()

	slack_roundstart()

	to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
	world << sound('sound/AI/welcome.ogg')

	//Holiday Round-start stuff	~Carn
	Holiday_Game_Start()

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.post_setup()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				qdel(S)

		SSvote.started_time = world.time

		/*var/admins_number = 0 //For slack maybe?
		for(var/client/C)
			if(C.holder)
				admins_number++
		if(admins_number == 0)
			send2adminirc("Round has started with no admins online.")*/

	return 1


//Plus it provides an easy way to make cinematics for other events. Just use this as a template
/datum/subsystem/ticker/proc/station_explosion_cinematic(station_missed=0, override = null)
	if( cinematic )
		return	//already a cinematic in progress!

	//initialise our cinematic screen object
	cinematic = new /obj/screen{icon='icons/effects/station_explosion.dmi';icon_state="station_intact";layer=21;mouse_opacity=0;screen_loc="1,0";}(src)

	var/obj/structure/stool/bed/temp_buckle = new(src)
	//Incredibly hackish. It creates a bed within the gameticker (lol) to stop mobs running around
	if(station_missed)
		for(var/mob/M in mob_list)
			M.buckled = temp_buckle				//buckles the mob so it can't do anything
			if(M.client)
				M.client.screen += cinematic	//show every client the cinematic
	else	//nuke kills everyone on z-level 1 to prevent "hurr-durr I survived"
		for(var/mob/M in mob_list)
			M.buckled = temp_buckle
			if(M.client)
				M.client.screen += cinematic
			if(M.stat != DEAD)//Just you wait for real destruction!
				var/turf/T = get_turf(M)
				if(T && T.z==1)
					M.death(0) //no mercy

	//Now animate the cinematic
	switch(station_missed)
		if(1)	//nuke was nearby but (mostly) missed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke wasn't on station when it blew up
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					flick("station_intact_fade_red",cinematic)
					cinematic.icon_state = "summary_nukefail"
				else
					flick("intro_nuke",cinematic)
					sleep(35)
					world << sound('sound/effects/explosionfar.ogg')
					//flick("end",cinematic)


		if(2)	//nuke was nowhere nearby	//TODO: a really distant explosion animation
			sleep(50)
			world << sound('sound/effects/explosionfar.ogg')
		else	//station was destroyed
			if( mode && !override )
				override = mode.name
			switch( override )
				if("nuclear emergency") //Nuke Ops successfully bombed the station
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_nukewin"
				if("AI malfunction") //Malf (screen,explosion,summary)
					flick("intro_malf",cinematic)
					sleep(76)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_malf"
				if("blob") //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red",cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
				else //Station nuked (nuke,explosion,summary)
					flick("intro_nuke",cinematic)
					sleep(35)
					flick("station_explode_fade_red", cinematic)
					world << sound('sound/effects/explosionfar.ogg')
					cinematic.icon_state = "summary_selfdes"
	//If its actually the end of the round, wait for it to end.
	//Otherwise if its a verb it will continue on afterwards.
	spawn(300)
		if(cinematic)
			qdel(cinematic)		//end the cinematic
		if(temp_buckle)
			qdel(temp_buckle)	//release everybody
	return



/datum/subsystem/ticker/proc/create_characters()
	for(var/mob/new_player/player in player_list)
		sleep(1)//Maybe remove??
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


/datum/subsystem/ticker/proc/collect_minds()
	for(var/mob/living/player in player_list)
		if(player.mind)
			ticker.minds += player.mind


/datum/subsystem/ticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/living/carbon/human/player in player_list)
		if(player && player.mind && player.mind.assigned_role)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != "MODE")
				SSjob.EquipRank(player, player.mind.assigned_role, 0)
				EquipCustomItems(player)
	if(captainless)
		for(var/mob/M in player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captainship not forced on anyone.")


/datum/subsystem/ticker/proc/declare_completion()
	var/station_evacuated
	if(SSshuttle.location > 0)
		station_evacuated = 1
	var/num_survivors = 0
	var/num_escapees = 0

	to_chat(world, "<BR><BR><BR><FONT size=3><B>The round has ended.</B></FONT>")

	//Player status report
	for(var/mob/Player in mob_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					var/turf/playerTurf = get_turf(Player)
					if(playerTurf.z != ZLEVEL_CENTCOMM)
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

	var/ai_or_borgs_in_round = 0
	for (var/mob/living/silicon/silicon in mob_list)
		if(silicon)
			ai_or_borgs_in_round = 1
			break

	if(ai_or_borgs_in_round)
		ai_completions += "<H3>Silicons Laws</H3>"
		for (var/mob/living/silicon/ai/aiPlayer in mob_list)
			if(!aiPlayer)
				continue
			var/icon/flat = getFlatIcon(aiPlayer)
			end_icons += flat
			var/tempstate = end_icons.len
			if (aiPlayer.stat != DEAD)
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [aiPlayer.name] (Played by: [aiPlayer.key])'s laws at the end of the game were:</B>"}
			else
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [aiPlayer.name] (Played by: [aiPlayer.key])'s laws when it was deactivated were:</B>"}
			ai_completions += "<BR>[aiPlayer.write_laws()]"

			if (aiPlayer.connected_robots.len)
				var/robolist = "<BR><B>The AI's loyal minions were:</B> "
				for(var/mob/living/silicon/robot/robo in aiPlayer.connected_robots)
					robolist += "[robo.name][robo.stat?" (Deactivated) (Played by: [robo.key]), ":" (Played by: [robo.key]), "]"
				ai_completions += "[robolist]"

		var/dronecount = 0

		for (var/mob/living/silicon/robot/robo in mob_list)
			if(!robo)
				continue
			if(istype(robo,/mob/living/silicon/robot/drone))
				dronecount++
				continue
			var/icon/flat = getFlatIcon(robo,exact=1)
			end_icons += flat
			var/tempstate = end_icons.len
			if (!robo.connected_ai)
				if (robo.stat != DEAD)
					ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Played by: [robo.key]) survived as an AI-less borg! Its laws were:</B>"}
				else
					ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Played by: [robo.key]) was unable to survive the rigors of being a cyborg without an AI. Its laws were:</B>"}
			else
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Played by: [robo.key]) [robo.stat!=2?"survived":"perished"] as a cyborg slaved to [robo.connected_ai]! Its laws were:</B>"}
			ai_completions += "<BR>[robo.write_laws()]"

		if(dronecount)
			to_chat(ai_completions, "<B>There [dronecount>1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] this round.</B>")

		ai_completions += "<HR>"

	mode.declare_completion()//To declare normal completion.

	ai_completions += "<BR><h2>Mode Result</h2>"
	ai_completions += "[mode.completion_text]<HR>"

	//calls auto_declare_completion_* for all modes
	for(var/handler in typesof(/datum/game_mode/proc))
		if (findtext("[handler]","auto_declare_completion_"))
			ai_completions += "[call(mode, handler)()]"

	//Print a list of antagonists to the server log
	var/list/total_antagonists = list()
	//Look into all mobs in world, dead or alive
	for(var/datum/mind/Mind in minds)
		var/temprole = Mind.special_role
		if(temprole)							//if they are an antagonist of some sort.
			if(temprole in total_antagonists)	//If the role exists already, add the name to it
				total_antagonists[temprole] += ", [Mind.name]([Mind.key])"
			else
				total_antagonists.Add(temprole) //If the role doesnt exist in the list, create it and add the mob
				total_antagonists[temprole] += ": [Mind.name]([Mind.key])"

	//Now print them all into the log!
	log_game("Antagonists at round end were...")
	for(var/i in total_antagonists)
		log_game("[i]s[total_antagonists[i]].")

	//Adds the del() log to world.log in a format condensable by the runtime condenser found in tools
	if(SSgarbage.didntgc.len)
		var/dellog = ""
		for(var/path in SSgarbage.didntgc)
			dellog += "Path : [path] \n"
			dellog += "Failures : [SSgarbage.didntgc[path]] \n"
		world.log << dellog

	scoreboard(ai_completions)

	return 1

/datum/subsystem/ticker/proc/achievement_declare_completion()
	var/text = "<br><FONT size = 5><b>Additionally, the following players earned achievements:</b></FONT>"
	var/icon/cup = icon('icons/obj/drinks.dmi', "golden_cup")
	end_icons += cup
	var/tempstate = end_icons.len
	for(var/winner in achievements)
		text += {"<br><img src="logo_[tempstate].png"> [winner]"}

	return text
