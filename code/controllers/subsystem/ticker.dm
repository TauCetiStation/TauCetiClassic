var/global/round_start_time = 0
var/global/round_start_realtime = 0

SUBSYSTEM_DEF(ticker)
	name = "Ticker"

	priority = SS_PRIORITY_TICKER

	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME | SS_SHOW_IN_MC_TAB

	msg_lobby = "Запускаем сверхточные атомные часы..."

	var/const/restart_timeout = 600
	var/current_state = GAME_STATE_STARTUP

	var/datum/modesbundle/bundle = null
	var/datum/game_mode/mode = null

	var/login_music			// music played in pregame lobby

	var/list/datum/mind/minds = list() //The people in the game. Used for objective tracking.

	var/random_players = 0					// if set to nonzero, ALL players who latejoin or declare-ready join will have random appearances/genders

	var/admin_delayed = 0						//if set to nonzero, the round will not restart on it's own

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
	var/hacked_apcs = 0 //check the amount of hacked apcs either by a malf ai, or a traitor
	var/Malf_announce_stage = 0//Used for announcement

	var/force_end = FALSE // set TRUE to forse round end and show credits

	var/end_timer_id

/datum/controller/subsystem/ticker/PreInit()
	login_music = pick(\
	'sound/music/1.ogg',\
	'sound/music/space.ogg',\
	'sound/music/clouds.s3m',\
	'sound/music/title1.ogg',\
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
			to_chat(world, "<b><font color='blue'>Добро пожаловать в предыгровое лобби!</font></b>")
			to_chat(world, "Пожалуйста, настройте своего персонажа и нажмите на кнопку Ready. Игра начнется через [timeLeft/10] секунд.")
			current_state = GAME_STATE_PREGAME
			SEND_SIGNAL(src, COMSIG_TICKER_ENTER_PREGAME)

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
				Master.SetRunLevel(RUNLEVEL_SETUP)
				SEND_SIGNAL(src, COMSIG_TICKER_ENTER_SETTING_UP)

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				Master.SetRunLevel(RUNLEVEL_LOBBY)
				SEND_SIGNAL(src, COMSIG_TICKER_ERROR_SETTING_UP)

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)

			var/mode_finished = mode.check_finished() || (SSshuttle.location == SHUTTLE_AT_CENTCOM && SSshuttle.alert == 1) || force_end
			if(!explosion_in_progress && mode_finished && !SSrating.voting)

				if(!SSrating.already_started)
					start_rating_vote_if_unexpected_roundend()
					return

				current_state = GAME_STATE_FINISHED
				Master.SetRunLevel(RUNLEVEL_POSTGAME)
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
						attachment_title = "Раунд #[global.round_id] закончился",
						attachment_color = BRIDGE_COLOR_ANNOUNCE,
					)

					SSStatistics.drop_round_stats()

					SSmapping.autovote_next_map()

					if (station_was_nuked)
						feedback_set_details("end_proper","nuke")
						if(!admin_delayed)
							to_chat(world, "<span class='notice'><B>Рестарт из-за уничтожения станции через [restart_timeout/10] [pluralize_russian(restart_timeout/10, "секунда", "секунды", "секунд")].</B></span>")
					else
						feedback_set_details("end_proper","proper completion")
						if(!admin_delayed)
							to_chat(world, "<span class='notice'><B>Рестарт через [restart_timeout/10] [pluralize_russian(restart_timeout/10, "секунда", "секунды", "секунд")].</B></span>")

					end_timer_id = addtimer(CALLBACK(src, PROC_REF(try_to_end)), restart_timeout, TIMER_UNIQUE|TIMER_OVERRIDE)

/datum/controller/subsystem/ticker/proc/start_rating_vote_if_unexpected_roundend()
	to_chat(world, "<span class='info bold'><B>Конец раунда задержан из-за голосования.</B></span>")
	SSrating.start_rating_collection()

/datum/controller/subsystem/ticker/proc/try_to_end()
	var/delayed = FALSE

	var/static/admin_delay_announced = FALSE //announce reason only first time
	if(admin_delayed)
		if(!admin_delay_announced)
			to_chat(world, "<span class='info bold'>Рестарт отложен администратором.</span>")
			world.send2bridge(
				type = list(BRIDGE_ROUNDSTAT),
				attachment_msg = "Администратор отложил окончание раунда.",
				attachment_color = BRIDGE_COLOR_ROUNDSTAT,
			)
			admin_delay_announced = TRUE
		delayed = TRUE

	var/static/vote_delay_announced = FALSE
	if(SSvote.active_poll)
		if(!vote_delay_announced)
			to_chat(world, "<span class='info bold'>Рестарт задержан из-за голосования.</span>")
			vote_delay_announced = TRUE
		delayed = TRUE

	if(delayed)
		end_timer_id = addtimer(CALLBACK(src, PROC_REF(try_to_end)), 5 SECONDS, TIMER_UNIQUE|TIMER_OVERRIDE)
	else
		world.Reboot(end_state = station_was_nuked ? "nuke" : "proper completion")

/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, "<span class='boldannounce'>Игра начинается...</span>")

	// Discuss your stuff after the round ends.
	if(config.ooc_round_autotoggle)
		to_chat(world, "<span class='warning bold'>OOC-канал отключен для всех на время раунда!</span>")
		ooc_allowed = FALSE

	var/init_start = world.timeofday

	log_mode("Current master mode is [master_mode]")
	if(config.is_bundle_by_name(master_mode))
		//Create and announce mode
		bundle = config.get_bundle_by_name(master_mode)
		log_mode("Current bundle is [bundle.name]")

		var/list/datum/game_mode/runnable_modes = config.get_runnable_modes(bundle)
		if(!runnable_modes.len)
			runnable_modes = config.get_always_runnable_modes()

		if(!runnable_modes.len)
			current_state = GAME_STATE_PREGAME
			to_chat(world, "<B>Невозможно выбрать игровой режим.</B> Возвращение в предыгровое лобби.")
			// Players can initiate gamemode vote again
			var/datum/poll/gamemode_vote = SSvote.possible_polls[/datum/poll/gamemode]
			if(gamemode_vote)
				gamemode_vote.reset_next_vote()
			return FALSE

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
		return FALSE

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
		return FALSE

	if(!bundle || !bundle.hide_mode_announce)
		mode.announce()

	setup_economy()

	SEND_SIGNAL(src, COMSIG_TICKER_ROUND_STARTING)
	current_state = GAME_STATE_PLAYING
	round_start_time = world.time
	round_start_realtime = world.realtime

	if(establish_db_connection("erro_round"))
		var/DBQuery/query_round_game_mode = dbcon.NewQuery("UPDATE erro_round SET start_datetime = Now(), map_name = '[sanitize_sql(SSmapping.config.map_name)]' WHERE id = [global.round_id]")
		query_round_game_mode.Execute()

	create_religion(/datum/religion/chaplain)
	setup_hud_objects()

	create_characters() //Create player characters and transfer them
	collect_minds()
	equip_characters()
	data_core.manifest()

	spawn_empty_ai()

	update_station_head_portraits()

	CHECK_TICK

	for(var/mob/dead/new_player/player as anything in new_player_list)
		if(player.spawning)
			qdel(player)

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	world.send2bridge(
		type = list(BRIDGE_ROUNDSTAT),
		attachment_title = "Раунд начался, игровой режим - **[master_mode]**",
		attachment_msg = "Раунд #[global.round_id]; Присоединиться сейчас: <[BYOND_JOIN_LINK]>",
		attachment_color = BRIDGE_COLOR_ANNOUNCE,
	)

	world.log << "Game start took [(world.timeofday - init_start)/10]s"

	to_chat(world, "<FONT color='blue'><B>Приятной игры!</B></FONT>")
	for(var/mob/M as anything in player_list)
		M.playsound_local(null, 'sound/AI/enjoyyourstay.ogg', VOL_EFFECTS_VOICE_ANNOUNCEMENT, vary = FALSE, frequency = null, ignore_environment = TRUE)

	if(length(SSholiday.holidays))
		to_chat(world, "<span clas='notice'>и...</span>")
		for(var/holidayname in SSholiday.holidays)
			var/datum/holiday/holiday = SSholiday.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	spawn(0)//Forking here so we dont have to wait for this to finish
		mode.PostSetup()
		show_blurbs()
		populate_response_teams()

		SSevents.start_roundstart_event()
		SSqualities.give_all_qualities()

		for(var/mob/dead/new_player/N as anything in new_player_list)
			if(N.client)
				N.show_titlescreen()
		//Cleanup some stuff
		SSjob.fallback_landmark = null
		for(var/obj/effect/landmark/start/type as anything in subtypesof(/obj/effect/landmark/start))
			for(var/obj/effect/landmark/start/S as anything in landmarks_list[initial(type.name)])
				S.after_round_start()

		//Print a list of antagonists to the server log
		antagonist_announce()

		create_default_spawners()

	return TRUE

/datum/controller/subsystem/ticker/proc/show_blurbs()
	for(var/datum/mind/M as anything in SSticker.minds)
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
	cinematic = new /atom/movable/screen/nuke(src)
	for(var/mob/M as anything in mob_list)	//nuke kills everyone on station z-level to prevent "hurr-durr I survived"
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
			else if(override == "replicators")
				screen = "intro_malf"
				explosion = "station_swarmed"
				summary = "summary_replicators"
				screen_time = 76

			for(var/mob/M as anything in mob_list)	//nuke kills everyone on station z-level to prevent "hurr-durr I survived"
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
	addtimer(CALLBACK(src, PROC_REF(station_explosion_effects), explosion, summary, cinematic), screen_time)

/datum/controller/subsystem/ticker/proc/station_explosion_effects(explosion, summary, /atom/movable/screen/cinematic)
/*	for(var/mob/M as anything in mob_list) //search any goodest
		M.playsound_local(null, 'sound/effects/explosionfar.ogg', VOL_EFFECTS_MASTER, vary = FALSE, frequency = null, ignore_environment = TRUE)*/
	if(explosion)
		flick(explosion,cinematic)
	if(summary)
		cinematic.icon_state = summary
	addtimer(CALLBACK(src, PROC_REF(station_explosion_rollback_effects), cinematic), 10 SECONDS)

/datum/controller/subsystem/ticker/proc/station_explosion_rollback_effects(cinematic)
	for(var/mob/M as anything in mob_list)
		if(M.client)
			M.client.screen -= cinematic
		if(isliving(M))
			var/mob/living/L = M
			L.SetSleeping(0, TRUE, TRUE)
	if(cinematic)
		qdel(cinematic)		//end the cinematic

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/dead/new_player/player in player_list)
		if(player && player.ready && player.mind)
			joined_player_list += player.ckey
			if(player.mind.assigned_role=="AI")
				player.close_spawn_windows()
				player.AIize()
			//else if(!player.mind.assigned_role)//Not sure if needed...
			//	continue
			else
				player.create_character()
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/station_explosion_detonation(source)

	// unfortunately airnet and powernet don't have own SS, so we need to break them completly to make things less laggy
	// no one will notice anyway
	SSair.stop_airnet_processing = TRUE
	SSmachines.stop_powernet_processing = TRUE

	explosion(get_turf(source), 30, 60, 120, ignorecap = TRUE)


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
			SSquirks.AssignQuirks(player, player.client, TRUE)
			if(player.mind.assigned_role != "MODE")
				SSjob.EquipRank(player, player.mind.assigned_role, FALSE)
				player.PutDisabilityMarks()
	if(captainless)
		for(var/mob/M as anything in player_list)
			if(!isnewplayer(M))
				to_chat(M, "Капитаном никто не стал.")

/datum/controller/subsystem/ticker/proc/generate_scoreboard(mob/one_mob)
	var/completition = "<h1>Информация по окончании раунда</h1><HR>"
	completition += get_ai_completition()
	completition += mode.declare_completion()
	completition += get_ratings()
	scoreboard(completition, one_mob)

/datum/controller/subsystem/ticker/proc/get_ratings()
	var/dat = "<h2>Оценки раунда</h2>"
	dat += "<div class='Section'>"
	dat += SSrating.get_voting_results()
	dat += "</div>"
	return dat

/datum/controller/subsystem/ticker/proc/get_ai_completition()
	var/ai_completions = ""
	if(silicon_list.len)
		ai_completions += "<h2>Законы синтетиков:</h2>"
		ai_completions += "<div class='Section'>"
		for (var/mob/living/silicon/ai/aiPlayer as anything in ai_list)
			if(!aiPlayer)
				continue
			var/icon/flat = getFlatIcon(aiPlayer)
			end_icons += flat
			var/tempstate = end_icons.len
			var/aikey = aiPlayer.mind ? aiPlayer.mind.key : aiPlayer.key
			if (aiPlayer.stat != DEAD)
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [aiPlayer.name] (Игрок: [aikey]) Законы в конце игры были таковы:</B>"}
			else
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [aiPlayer.name] (Игрок: [aikey]) Законы на момент деактивации были таковы:</B>"}
			ai_completions += "<BR>[aiPlayer.write_laws()]"

			if (aiPlayer.connected_robots.len)
				var/robolist = "<BR><B>Верными приспешниками ИИ были:</B> "
				for(var/mob/living/silicon/robot/robo as anything in aiPlayer.connected_robots)
					var/robokey = robo.mind ? robo.mind.key : robo.key
					robolist += "[robo.name][robo.stat?" (Деактивированный) (Игрок: [robokey]), ":" (Игрок: [robokey]), "]"
				ai_completions += "[robolist]"

		var/dronecount = 0

		for (var/mob/living/silicon/robot/robo in silicon_list)
			if(!robo)
				continue
			if(isdrone(robo))
				dronecount++
				continue
			var/icon/flat = getFlatIcon(robo,exact=1)
			end_icons += flat
			var/tempstate = end_icons.len
			var/robokey = robo.mind ? robo.mind.key : robo.key
			if (!robo.connected_ai)
				if (robo.stat != DEAD)
					ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Игрок: [robokey]) выжил как непривязанный к ИИ киборг! Его законы были таковы:</B>"}
				else
					ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Игрок: [robokey]) не смог выдержать суровых условий жизни киборга без ИИ. Его законы были таковы:</B>"}
			else
				ai_completions += {"<BR><B><img src="logo_[tempstate].png"> [robo.name] (Игрок: [robokey]) [robo.stat!=2?"выжил":"уничтоженный"] как киборг, подчиненный [robo.connected_ai]! Его законы были таковы:</B>"}
			ai_completions += "<BR>[robo.write_laws()]"

		if(dronecount)
			ai_completions += "<br><B>В этом раунде [dronecount > 1 ? "было" : "был"] [dronecount] [dronecount > 1 ? "трудолюбивых" : "трудолюбивый"] [dronecount>1 ? "дронов" : "дрон"].</B>"

		ai_completions += "</div>"
	return ai_completions

//cursed code
/datum/controller/subsystem/ticker/proc/declare_completion()
	// Now you all can discuss the game.
	if(config.ooc_round_autotoggle)
		to_chat(world, "<span class='notice bold'>OOC-канал включен для всех!</span>")
		ooc_allowed = TRUE

	var/station_evacuated
	if(SSshuttle.location > 0)
		station_evacuated = 1
	var/num_survivors = 0
	var/num_escapees = 0

	to_chat(world, "<BR><BR><BR><FONT size=3><B>Раунд закончился.</B></FONT>")

	//Player status report
	for(var/mob/Player as anything in mob_list)
		if(Player.mind && !isnewplayer(Player))
			if(Player.stat != DEAD && !isbrain(Player))
				num_survivors++
				if(station_evacuated) //If the shuttle has already left the station
					var/turf/playerTurf = get_turf(Player)
					// For some reason, player can be in null
					if(!playerTurf)
						continue
					if(!is_centcom_level(playerTurf.z))
						to_chat(Player, "<font color='blue'><b>Вам удалось выжить, но вы были брошены на [station_name_ru()]...</b></FONT>")
					else
						num_escapees++
						to_chat(Player, "<font color='green'><b>Вам удалось пережить события на [station_name_ru()] как [Player.real_name].</b></FONT>")
				else
					to_chat(Player, "<font color='green'><b>Вам удалось пережить события на [station_name_ru()] как [Player.real_name].</b></FONT>")
			else
				to_chat(Player, "<font color='red'><b>Вы не пережили событий, произошедших на [station_name_ru()]...</b></FONT>")

	//Round statistics report
	var/datum/station_state/end_state = new /datum/station_state()
	end_state.count()
	var/station_integrity = min(round( 100 * start_state.score(end_state), 0.1), 100)

	to_chat(world, "<BR>[TAB]Продолжительность смены: <B>[round(world.time / 36000)]:[add_zero("[world.time / 600 % 60]", 2)]:[add_zero("[world.time / 10 % 60]", 2)]</B>")
	to_chat(world, "<BR>[TAB]Целостность станции: <B>[station_was_nuked ? "<font color='red'>Уничтожена</font>" : "[station_integrity]%"]</B>")
	if(joined_player_list.len)
		to_chat(world, "<BR>[TAB]Общая численность персонала: <B>[joined_player_list.len]</B>")
		if(station_evacuated)
			to_chat(world, "<BR>[TAB]Эвакуировалось: <B>[num_escapees] ([round((num_escapees/joined_player_list.len)*100, 0.1)]%)</B>")
		to_chat(world, "<BR>[TAB]Процент выживших: <B>[num_survivors] ([round((num_survivors/joined_player_list.len)*100, 0.1)]%)</B>")
	if(SSround_aspects.aspect)
		to_chat(world, "<BR>[TAB]Аспект Раунда: <B>[SSround_aspects.aspect_name].</B> [SSround_aspects.aspect.desc]")
	to_chat(world, "<BR>")

	//Print a list of antagonists to the server log
	antagonist_announce()

	generate_scoreboard()

	mode.ShuttleDocked(location)

	// Add AntagHUD to everyone, see who was really evil the whole time!
	for(var/hud in get_all_antag_huds())
		var/datum/atom_hud/antag/H = hud
		for(var/mob/M as anything in global.player_list)
			H.add_hud_to(M)

	teleport_players_to_eorg_area()

	if(SSjunkyard)
		SSjunkyard.save_stats()

	//Ask the event manager to print round end information
	SSevents.RoundEnd()

	return TRUE

/datum/controller/subsystem/ticker/proc/create_default_spawners()
	// infinity spawners
	if(!config.disable_player_mice)
		create_spawner(/datum/spawner/mouse)
	if(config.allow_drone_spawn)
		create_spawner(/datum/spawner/drone)

/datum/controller/subsystem/ticker/proc/teleport_players_to_eorg_area()
	if(!config.deathmatch_arena)
		return
	for(var/mob/living/M in global.player_list)
		if(!M.client.prefs.eorg_enabled)
			continue
		spawn_gladiator(M)

/datum/controller/subsystem/ticker/proc/spawn_gladiator(mob/M, transfer_mind = TRUE)
	var/mob/living/carbon/human/L = new(pick_landmarked_location("eorgwarp"))
	if(transfer_mind)
		M.mind.transfer_to(L)
	else
		L.key = M.key
	L.playsound_local(null, 'sound/lobby/Thunderdome.ogg', VOL_MUSIC, vary = FALSE, frequency = null, ignore_environment = TRUE)
	L.equipOutfit(/datum/outfit/arena)
	L.name = L.key
	L.real_name = L.name
	L.mind.skills.add_available_skillset(/datum/skillset/max)
	L.mind.skills.maximize_active_skills()
	to_chat(L, "<span class='warning'>Добро пожаловать на арену Смертельных игр! Разгуляйся, выпусти пар и покажи кто здесь батя!</span>")

/datum/controller/subsystem/ticker/proc/achievement_declare_completion()
	var/text = "<br><FONT size = 5><b>Кроме того, достижения получили следующие игроки:</b></FONT>"
	var/icon/cup = icon('icons/obj/drinks.dmi', "golden_cup")
	end_icons += cup
	var/tempstate = end_icons.len
	for(var/datum/stat/achievement/winner as anything in SSStatistics.achievements)
		var/winner_text = "<b>[winner.key]</b> as <b>[winner.name]</b> won \"<b>[winner.title]</b>\"! \"[winner.desc]\""
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
