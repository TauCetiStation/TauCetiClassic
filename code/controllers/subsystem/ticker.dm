var/round_start_time = 0
var/round_start_realtime = 0

SUBSYSTEM_DEF(ticker)
	name = "Ticker"

	priority = SS_PRIORITY_TICKER

	flags = SS_FIRE_IN_LOBBY | SS_KEEP_TIMING

	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_STARTUP

	var/datum/modesbundle/bundle = null
	var/datum/game_mode/mode = null

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list() //The people in the game. Used for objective tracking.

	var/random_players = 0					// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/delay_end = 0						//if set to nonzero, the round will not restart on it's own

	var/triai = 0							//Global holder for Triumvirate

	var/timeLeft = 1800						//pregame timer
	var/start_ASAP = FALSE					//the game will start as soon as possible, bypassing all pre-game nonsense

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/atom/movable/screen/cinematic = null
	var/datum/station_state/start_state = null

	var/station_was_nuked = FALSE //see nuclearbomb.dm and malfunction.dm
	var/explosion_in_progress = FALSE //sit back and relax
	var/nar_sie_has_risen = FALSE //check, if there is already one god in the world who was summoned (only for tomes)
	var/ert_call_in_progress = FALSE //when true players can join ERT
	var/list/hacked_apcs = list() //check the amount of hacked apcs either by a malf ai, or a traitor
	var/malf_announce_stage = 0//Used for announcement

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
	global.syndicate_code_phrase = generate_code_phrase()
	global.syndicate_code_response = generate_code_phrase()
	global.code_phrase_highlight_rule = generate_code_regex(global.syndicate_code_phrase, @"\u0430-\u0451") // Russian chars only
	global.code_response_highlight_rule = generate_code_regex(global.syndicate_code_response, @"\u0430-\u0451") // Russian chars only

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
			if(start_ASAP)
				start_now()

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

			var/mode_finished = mode.check_finished() || (SSshuttle.location == SHUTTLE_AT_CENTCOM && SSshuttle.alert == 1)
			if(!explosion_in_progress && mode_finished)
				current_state = GAME_STATE_FINISHED
				declare_completion()
				spawn(50)
					for(var/client/C in clients)
						C.log_client_ingame_age_to_db()
					world.save_last_mode(SSticker.mode.name)

					if(blackbox)
						blackbox.save_all_data_to_sql()

					if(establish_db_connection("erro_round"))
						var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET end_datetime = Now(), game_mode_result = '[sanitize_sql(mode.get_mode_result())]' WHERE id = [global.round_id]")
						query_round_game_mode.Execute()

					world.send2bridge(
						type = list(BRIDGE_ROUNDSTAT),
						attachment_title = "Round #[global.round_id] is over",
						attachment_color = BRIDGE_COLOR_ANNOUNCE,
					)

					drop_round_stats()

					if (station_was_nuked)
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
							world.Reboot(end_state = station_was_nuked ? "nuke" : "proper completion") //Can be upgraded to remove unneded sleep here.
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

	log_mode("Current master mode is [master_mode]")
	if(config.is_bundle_by_name(master_mode))
		//Create and announce mode
		bundle = config.get_bundle_by_name(master_mode)
		log_mode("Current bundle is [bundle.name]")

		var/list/datum/game_mode/runnable_modes = config.get_runnable_modes(bundle)
		if(!runnable_modes.len)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
			// Players can initiate gamemode vote again
			var/datum/poll/gamemode_vote = SSvote.votes[/datum/poll/gamemode]
			if(gamemode_vote)
				gamemode_vote.reset_next_vote()
			return 0

		// hiding forced gamemode in secret
		if(istype(bundle, /datum/modesbundle/all/secret) && secret_force_mode != "Secret")
			var/datum/game_mode/smode = config.pick_mode(secret_force_mode)
			if(!smode.can_start())
				var/datum/faction/type = smode.factions_allowed[1]
				message_admins("<span class='notice'>Unable to force secret [secret_force_mode]. [smode.minimum_player_count] players and [initial(type.min_roles)] eligible antagonists needed.</span>")
			else
				mode = smode

		SSjob.ResetOccupations()
		if(!mode)
			mode = pickweight(runnable_modes)
		if(mode)
			var/mtype = mode.type
			mode = new mtype

	else
		mode = config.pick_mode(master_mode)

	if (!mode.can_start())
		to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.minimum_player_count] players needed. Reverting to pre-game lobby.")
		QDEL_NULL(mode)
		current_state = GAME_STATE_PREGAME
		SSjob.ResetOccupations()
		return 0

	//Configure mode and assign player to special mode stuff
	SSjob.DivideOccupations() //Distribute jobs
	var/can_continue = mode.Setup() //Setup special modes
	if(!can_continue)
		global.modes_failed_start[mode.name] = TRUE
		current_state = GAME_STATE_PREGAME
		to_chat(world, "<B>Error setting up [master_mode].</B> Reverting to pre-game lobby.")
		log_admin("The gamemode setup for [mode.name] errored out.")
		world.log << "The gamemode setup for [mode.name] errored out."
		QDEL_NULL(mode)
		SSjob.ResetOccupations()
		return 0

	if(!bundle || !bundle.hidden)
		mode.announce()

	current_state = GAME_STATE_PLAYING
	round_start_time = world.time
	round_start_realtime = world.realtime

	if(establish_db_connection("erro_round"))
		var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET start_datetime = Now(), map_name = '[sanitize_sql(SSmapping.config.map_name)]' WHERE id = [global.round_id]")
		query_round_game_mode.Execute()

	setup_economy()
	create_religion(/datum/religion/chaplain)

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
		attachment_msg = "Round #[global.round_id]; Join now: <[BYOND_JOIN_LINK]>",
		attachment_color = BRIDGE_COLOR_ANNOUNCE,
	)

	world.log << "Game start took [(world.timeofday - init_start)/10]s"

	to_chat(world, "<FONT color='blue'><B>Enjoy the game!</B></FONT>")
	for(var/mob/M in player_list)
		M.playsound_local(null, 'sound/AI/enjoyyourstay.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

	if(length(SSholiday.holidays))
		to_chat(world, "<span clas='notice'>and...</span>")
		for(var/holidayname in SSholiday.holidays)
			var/datum/holiday/holiday = SSholiday.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.PostSetup()
		show_blurbs()

		SSevents.start_roundstart_event()

		for(var/mob/dead/new_player/N in new_player_list)
			if(N.client)
				N.show_titlescreen()
		//Cleanup some stuff
		for(var/obj/effect/landmark/start/S in landmarks_list)
			//Deleting Startpoints but we need the ai point to AI-ize people later
			if (S.name != "AI")
				qdel(S)

		//Print a list of antagonists to the server log
		antagonist_announce()

	return 1

/datum/controller/subsystem/ticker/proc/show_blurbs()
	for(var/datum/mind/M in SSticker.minds)
		show_location_blurb(M.current.client)

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
	cinematic = new /atom/movable/screen{icon='icons/effects/station_explosion.dmi';icon_state="station_intact";layer=21;mouse_opacity = MOUSE_OPACITY_TRANSPARENT;screen_loc="1,0";}(src)
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

/datum/controller/subsystem/ticker/proc/station_explosion_effects(explosion, summary, /atom/movable/screen/cinematic)
	for(var/mob/M in mob_list) //search any goodest
		M.playsound_local(null, 'sound/effects/explosionfar.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)
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
			if(ishuman(player))
				SSquirks.AssignQuirks(player, player.client, TRUE)
			if(player.mind.assigned_role != "MODE")
				SSjob.EquipRank(player, player.mind.assigned_role, 0)
	if(captainless)
		for(var/mob/M in player_list)
			if(!isnewplayer(M))
				to_chat(M, "Captainship not forced on anyone.")

/datum/controller/subsystem/ticker/proc/generate_scoreboard(mob/one_mob)
	var/completition = "<h1>Round End Information</h1><HR>"
	completition += get_ai_completition()
	completition += mode.declare_completion()
	scoreboard(completition, one_mob)

/datum/controller/subsystem/ticker/proc/get_ai_completition()
	var/ai_completions = ""
	if(silicon_list.len)
		ai_completions += "<h2>Silicons Laws</h2>"
		ai_completions += "<div class='Section'>"
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
			ai_completions += "<br><B>There [dronecount > 1 ? "were" : "was"] [dronecount] industrious maintenance [dronecount>1 ? "drones" : "drone"] this round.</B>"

		ai_completions += "</div>"
	return ai_completions

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
	for(var/mob/Player in mob_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					var/turf/playerTurf = get_turf(Player)
					// For some reason, player can be in null
					if(!playerTurf)
						continue
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
	to_chat(world, "<BR>[TAB]Station Integrity: <B>[station_was_nuked ? "<font color='red'>Destroyed</font>" : "[station_integrity]%"]</B>")
	if(joined_player_list.len)
		to_chat(world, "<BR>[TAB]Total Population: <B>[joined_player_list.len]</B>")
		if(station_evacuated)
			to_chat(world, "<BR>[TAB]Evacuation Rate: <B>[num_escapees] ([round((num_escapees/joined_player_list.len)*100, 0.1)]%)</B>")
		to_chat(world, "<BR>[TAB]Survival Rate: <B>[num_survivors] ([round((num_survivors/joined_player_list.len)*100, 0.1)]%)</B>")
	to_chat(world, "<BR>")

	//Print a list of antagonists to the server log
	antagonist_announce()

	generate_scoreboard()

	mode.ShuttleDocked(location)

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/hud in get_all_antag_huds())
		var/datum/atom_hud/antag/H = hud
		for(var/m in global.player_list)
			var/mob/M = m
			H.add_hud_to(M)

	teleport_players_to_eorg_area()

	if(SSjunkyard)
		SSjunkyard.save_stats()

	//Ask the event manager to print round end information
	SSevents.RoundEnd()

	return 1

/datum/controller/subsystem/ticker/proc/teleport_players_to_eorg_area()
	if(!config.deathmatch_arena)
		return
	for(var/mob/living/M in global.player_list)
		if(!M.client.prefs.eorg_enabled)
			continue
		var/mob/living/carbon/human/L = new(pick(eorgwarp))
		M.mind.transfer_to(L)
		L.playsound_local(null, 'sound/lobby/Thunderdome_cut.ogg', VOL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)
		L.equipOutfit(/datum/outfit/arena)
		L.name = "Gladiator ([rand(1, 1000)])"
		L.real_name = L.name
		to_chat(L, "<span class='warning'>Welcome to End of Round Deathmatch Arena! Go hog wild and let out some steam!.</span>")

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
