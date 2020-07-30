var/list/net_announcer_secret = list()

/datum/configuration
	var/name = "Configuration"			// datum name

	var/server_name = null				// server name (for world name / status)
	var/server_suffix = 0				// generate numeric suffix based on server port

	var/log_ooc = 0						// log OOC channel
	var/log_access = 0					// log login/logout
	var/log_say = 0						// log client say
	var/log_admin = 0					// log admin actions
	var/log_debug = 1					// log debug output
	var/log_game = 0					// log game events
	var/log_vote = 0					// log voting
	var/log_whisper = 0					// log client whisper
	var/log_emote = 0					// log emotes
	var/log_attack = 0					// log attack messages
	var/log_adminchat = 0				// log admin chat messages
	var/log_adminwarn = 0				// log warnings admins get about bomb construction and such
	var/log_pda = 0						// log pda messages
	var/log_fax = 0						// log fax messages
	var/log_hrefs = 0					// logs all links clicked in-game. Could be used for debugging and tracking down exploits
	var/log_runtime = 0					// logs runtimes to round log folder
	var/log_sql_error = 0				// same but for sql errors
	var/log_js_error = 0				   // same but for client side js errors
	var/log_initialization = 0			// same but for debug init logs
	var/log_qdel = 0						// same but for debug qdel logs
	var/sql_enabled = 0					// for sql switching
	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/allow_vote_restart = 0 			// allow votes to restart
	var/ert_admin_call_only = 0
	var/allow_vote_mode = 0				// allow votes to change mode
	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives
	var/vote_delay = 6000				// minimum time between voting sessions (deciseconds, 10 minute default)
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/vote_no_default = 0				// vote does not default to nochange/norestart (tbi)
	var/vote_no_dead = 0				// dead people can't vote (tbi)
//	var/enable_authentication = 0		// goon authentication
	var/del_new_on_log = 1				// del's new players if they log before they spawn in
	var/feature_object_spell_system = 0 //spawns a spellbook which gives object-type spells instead of verb-type spells for the wizard
	var/traitor_scaling = 0 			//if amount of traitors scales based on amount of players
	var/objectives_disabled = 0 			//if objectives are disabled or not
	var/protect_roles_from_antagonist = 0// If security and such can be traitor/cult/other
	var/continous_rounds = 1			// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
	var/allow_Metadata = 1				// Metadata is supported.
	var/fps = 20
	var/socket_talk	= 0					// use socket_talk to communicate with other processes
	var/list/resource_urls = null
	var/antag_hud_allowed = 0			// Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
	var/antag_hud_restricted = 0                    // Ghosts that turn on Antagovision cannot rejoin the round.
	var/list/mode_names = list()
	var/list/modes = list()				// allowed modes
	var/list/votable_modes = list()		// votable modes
	var/list/probabilities = list()		// relative probability of each mode
	var/humans_need_surnames = 0
	var/allow_random_events = 0			// enables random events mid-round when set to 1
	var/allow_ai = 1					// allow ai job
	var/hostedby = null
	var/respawn = 1
	var/guest_jobban = 1
	var/usewhitelist = 0
	var/serverwhitelist = 0
	var/serverwhitelist_message = "Sorry, you can't play on this server, because we use a whitelist.<br/>Please, visit another our server."
	var/mods_are_mentors = 0
	var/kick_inactive = 0				//force disconnect for inactive players
	var/afk_time_bracket = 6000 // 10 minutes
	var/load_jobs_from_txt = 0
	var/automute_on = 0					//enables automuting/spam prevention

	// If true - disable OOC for the duration of a round.
	var/ooc_round_only = FALSE

	var/registration_panic_bunker_age = null
	var/allowed_by_bunker_player_age = 60
	var/client_limit_panic_bunker_count = null
	var/client_limit_panic_bunker_link = null

	var/cult_ghostwriter = 1               //Allows ghosts to write in blood in cult rounds...
	var/cult_ghostwriter_req_cultists = 10 //...so long as this many cultists are active.

	var/max_maint_drones = 5				//This many drones can spawn,
	var/allow_drone_spawn = 1				//assuming the admin allow them to.
	var/drone_build_time = 1200				//A drone will become available every X ticks since last drone spawn. Default is 2 minutes.

	var/disable_player_mice = 0
	var/uneducated_mice = 0 //Set to 1 to prevent newly-spawned mice from understanding human speech

	var/rus_language = 0

	var/deathtime_required = 18000	//30 minutes

	var/usealienwhitelist = 0
	var/use_alien_job_restriction = 0
	var/limitalienplayers = 0
	var/alien_to_human_ratio = 0.5
	var/list/whitelisted_species_by_time = list()

	var/server
	var/banappeals
	var/wikiurl
	var/forumurl
	var/media_base_url = "http://example.org"
	var/server_rules_url
	var/discord_invite_url
	var/customitems_info_url

	// Changelog
	var/changelog_link = ""
	var/changelog_hash_link = ""

	var/repository_link = ""

	//Alert level description
	var/alert_desc_green = "All threats to the station have passed. Security may not have weapons visible, privacy laws are once again fully enforced."
	var/alert_desc_blue_upto = "The station has received reliable information about possible hostile activity on the station. Security staff may have weapons visible, random searches are permitted."
	var/alert_desc_blue_downto = "The immediate threat has passed. Security may no longer have weapons drawn at all times, but may continue to have them visible. Random searches are still allowed."
	var/alert_desc_red_upto = "There is an immediate serious threat to the station. Security may have weapons unholstered at all times. Random searches are allowed and advised."
	var/alert_desc_red_downto = "The self-destruct mechanism has been deactivated, there is still however an immediate serious threat to the station. Security may have weapons unholstered at all times, random searches are allowed and advised."
	var/alert_desc_delta = "The station's self-destruct mechanism has been engaged. All crew are instructed to obey all instructions given by heads of staff. Any violations of these orders can be punished by death. This is not a drill."

	var/forbid_singulo_possession = 0

	//game_options.txt configs

	var/health_threshold_softcrit = 0
	var/health_threshold_crit = 0
	var/health_threshold_dead = -100

	var/organ_health_multiplier = 1
	var/organ_regeneration_multiplier = 1

	var/revival_pod_plants = 1
	var/revival_cloning = 1
	var/revival_brain_life = -1

	//Used for modifying movement speed for mobs.
	//Unversal modifiers
	var/run_speed = 0
	var/walk_speed = 0

	//Mob specific modifiers. NOTE: These will affect different mob types in different ways
	var/human_delay = 0
	var/robot_delay = 0
	var/monkey_delay = 0
	var/alien_delay = 0
	var/slime_delay = 0
	var/animal_delay = 0

	// Event settings
	var/expected_round_length = 90 MINUTES
	// If the first delay has a custom start time
	// No custom time
	var/list/event_first_run = list(EVENT_LEVEL_MUNDANE = null,
									EVENT_LEVEL_MODERATE = null,
									EVENT_LEVEL_MAJOR = list("lower" = 80 MINUTES, "upper" = 100 MINUTES))
	// The lowest delay until next event
	var/list/event_delay_lower = list(EVENT_LEVEL_MUNDANE  = 10 MINUTES,
									  EVENT_LEVEL_MODERATE = 30 MINUTES,
									  EVENT_LEVEL_MAJOR    = 50 MINUTES)
	// The upper delay until next event
	var/list/event_delay_upper = list(EVENT_LEVEL_MUNDANE  = 15 MINUTES,
									  EVENT_LEVEL_MODERATE = 45 MINUTES,
									  EVENT_LEVEL_MAJOR    = 70 MINUTES)

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database
	var/use_ingame_minutes_restriction_for_jobs = 0 //Do jobs use in-game minutes instead account age for restrictions?

	var/add_player_age_value = 4320 //default minuts added with admin "Increase player age" button. 4320 minutes = 72 hours = 3 days

	var/byond_version_min = 0
	var/byond_version_recommend = 0

	var/simultaneous_pm_warning_timeout = 100

	var/assistant_maint = 0 //Do assistants get maint access?
	var/gateway_enabled = 0
	var/ghost_interaction = 0

	var/enter_allowed = 1

	var/python_path = "" //Path to the python executable.  Defaults to "python" on windows and "/usr/bin/env python2" on unix
	var/use_overmap = 0

	var/chat_bridge = 0
	var/antigrief_alarm_level = 1
	var/check_randomizer = 0

	var/guard_email = null
	var/guard_enabled = FALSE
	var/guard_autoban_treshhold = null
	var/guard_autoban_reason = "We think you are a bad guy and block you because of this."
	var/guard_autoban_sticky = FALSE
	var/guard_whitelisted_country_codes = list()

	var/allow_donators = 0
	var/allow_tauceti_patrons = 0
	var/allow_byond_membership = 0
	var/donate_info_url

	var/customitem_slot_by_time = 80000 // Gives one slot for fluff items after playing this much minutes

	// The object used for the clickable stat() button.
	var/obj/effect/statclick/statclick

	var/craft_recipes_visibility = FALSE // If false, then users won't see crafting recipes in personal crafting menu until they have all required components and then it will show up.
	var/starlight = FALSE	// Whether space turfs have ambient light or not
	var/nightshift = FALSE

	var/list/maplist = list()
	var/datum/map_config/defaultmap
	var/load_testmap = FALSE // swaps whatever.json with testmap.json in SSmapping init phase.

	var/record_replays = FALSE


	var/sandbox = FALSE
	var/list/net_announcers = list() // List of network announcers on

/datum/configuration/New()
	var/list/L = typesof(/datum/game_mode) - /datum/game_mode
	for (var/T in L)
		// I wish I didn't have to instance the game modes in order to look up
		// their information, but it is the only way (at least that I know of).
		var/datum/game_mode/M = new T()

		if (M.config_tag)
			if(!(M.config_tag in modes))		// ensure each mode is added only once
				log_misc("Adding game mode [M.name] ([M.config_tag]) to configuration.")
				if(M.playable_mode)
					src.modes += M.config_tag
					src.mode_names[M.config_tag] = M.name
					src.probabilities[M.config_tag] = M.probability
				if (M.votable)
					src.votable_modes += M.config_tag
		qdel(M)
	src.votable_modes += "secret"

/datum/configuration/proc/load(filename, type = "config") //the type can also be game_options, in which case it uses a different switch. not making it separate to not copypaste code - Urist
	var/list/Lines = file2list(filename)

	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		if(type == "config")
			switch (name)
				if ("resource_urls")
					config.resource_urls = splittext(value, " ")

				if ("admin_legacy_system")
					config.admin_legacy_system = 1

				if ("ban_legacy_system")
					config.ban_legacy_system = 1

				if ("byond_version_min")
					config.byond_version_min = text2num(value)

				if ("byond_version_recommend")
					config.byond_version_recommend = text2num(value)

				if ("use_age_restriction_for_jobs")
					config.use_age_restriction_for_jobs = 1

				if ("use_ingame_minutes_restriction_for_jobs")
					config.use_ingame_minutes_restriction_for_jobs = 1

				if ("add_player_age_value")
					config.add_player_age_value = text2num(value)

				if ("log_ooc")
					config.log_ooc = 1

				if ("log_access")
					config.log_access = 1

				if ("sql_enabled")
					config.sql_enabled = 1

				if ("log_say")
					config.log_say = 1

				if ("log_admin")
					config.log_admin = 1

				if ("log_debug")
					config.log_debug = text2num(value)

				if ("log_game")
					config.log_game = 1

				if ("log_vote")
					config.log_vote = 1

				if ("log_whisper")
					config.log_whisper = 1

				if ("log_attack")
					config.log_attack = 1

				if ("log_emote")
					config.log_emote = 1

				if ("log_adminchat")
					config.log_adminchat = 1

				if ("log_adminwarn")
					config.log_adminwarn = 1

				if ("log_pda")
					config.log_pda = 1

				if ("log_fax")
					config.log_fax = 1

				if ("log_hrefs")
					config.log_hrefs = 1

				if ("log_sql_error")
					config.log_sql_error = 1

				if ("log_js_error")
					config.log_js_error = 1

				if ("log_initialization")
					config.log_initialization = 1

				if ("log_qdel")
					config.log_qdel = 1

				if ("log_runtime")
					config.log_runtime = 1

				if ("mentors")
					config.mods_are_mentors = 1

				if("allow_admin_ooccolor")
					config.allow_admin_ooccolor = 1

				if ("allow_vote_restart")
					config.allow_vote_restart = 1

				if ("allow_vote_mode")
					config.allow_vote_mode = 1

				if ("allow_admin_jump")
					config.allow_admin_jump = 1

				if("allow_admin_rev")
					config.allow_admin_rev = 1

				if ("allow_admin_spawning")
					config.allow_admin_spawning = 1

				if ("no_dead_vote")
					config.vote_no_dead = 1

				if ("default_no_vote")
					config.vote_no_default = 1

				if ("vote_delay")
					config.vote_delay = text2num(value)

				if ("vote_period")
					config.vote_period = text2num(value)

				if("ert_admin_only")
					config.ert_admin_call_only = 1

				if ("allow_ai")
					config.allow_ai = 1

//				if ("authentication")
//					config.enable_authentication = 1

				if ("norespawn")
					config.respawn = 0

				if ("servername")
					config.server_name = value

				if ("serversuffix")
					config.server_suffix = 1

				if ("hostedby")
					config.hostedby = value

				if ("server")
					config.server = value

				if ("banappeals")
					config.banappeals = value

				if ("wikiurl")
					config.wikiurl = value

				if ("forumurl")
					config.forumurl = value

				if ("guest_jobban")
					config.guest_jobban = 1

				if ("guest_ban")
					guests_allowed = 0

				if ("usewhitelist")
					config.usewhitelist = 1

				if ("serverwhitelist")
					config.serverwhitelist = 1

				if("media_base_url")
					media_base_url = value

				if ("server_rules_url")
					server_rules_url = value

				if ("discord_invite_url")
					discord_invite_url = value

				if ("customitems_info_url")
					customitems_info_url = value

				if("serverwhitelist_message")
					config.serverwhitelist_message = value

				if ("feature_object_spell_system")
					config.feature_object_spell_system = 1

				if ("allow_metadata")
					config.allow_Metadata = 1

				if ("traitor_scaling")
					config.traitor_scaling = 1

				if ("objectives_disabled")
					config.objectives_disabled = 1

				if("protect_roles_from_antagonist")
					config.protect_roles_from_antagonist = 1

				if ("probability")
					var/prob_pos = findtext(value, " ")
					var/prob_name = null
					var/prob_value = null

					if (prob_pos)
						prob_name = lowertext(copytext(value, 1, prob_pos))
						prob_value = copytext(value, prob_pos + 1)
						if (prob_name in config.modes)
							config.probabilities[prob_name] = text2num(prob_value)
						else
							log_misc("Unknown game mode probability configuration definition: [prob_name].")
					else
						log_misc("Incorrect probability configuration definition: [prob_name]  [prob_value].")

				if("allow_random_events")
					config.allow_random_events = 1

				if("kick_inactive")
					config.kick_inactive = 1

				if ("afk_time_bracket")
					config.afk_time_bracket = (text2num(value) MINUTES)

				if("load_jobs_from_txt")
					load_jobs_from_txt = 1

				if("alert_red_upto")
					config.alert_desc_red_upto = value

				if("alert_red_downto")
					config.alert_desc_red_downto = value

				if("alert_blue_downto")
					config.alert_desc_blue_downto = value

				if("alert_blue_upto")
					config.alert_desc_blue_upto = value

				if("alert_green")
					config.alert_desc_green = value

				if("alert_delta")
					config.alert_desc_delta = value

				if("forbid_singulo_possession")
					forbid_singulo_possession = 1

				if("allow_holidays")
					Holiday = 1

				if("ticklag")
					var/ticklag = text2num(value)
					if(ticklag > 0)
						fps = 10 / ticklag

				if("fps")
					fps = text2num(value)

				if("allow_antag_hud")
					config.antag_hud_allowed = 1
				if("antag_hud_restricted")
					config.antag_hud_restricted = 1

				if("socket_talk")
					socket_talk = text2num(value)

				if("humans_need_surnames")
					humans_need_surnames = 1

				if("automute_on")
					automute_on = 1

				if("usealienwhitelist")
					usealienwhitelist = 1

				if("use_alien_job_restriction")
					config.use_alien_job_restriction = 1

				if("alien_available_by_time") //totally not copypaste from probabilities
					var/avail_time_sep = findtext(value, " ")
					var/avail_alien_name = null
					var/avail_alien_ingame_time = null

					if (avail_time_sep)
						avail_alien_name = lowertext(copytext(value, 1, avail_time_sep))
						avail_alien_ingame_time = text2num(copytext(value, avail_time_sep + 1))
						if (avail_alien_name in whitelisted_roles)
							config.whitelisted_species_by_time[avail_alien_name] = avail_alien_ingame_time
						else
							log_misc("Incorrect species whitelist for experienced players configuration definition, species missing in whitelisted_spedcies: [avail_alien_name].")
					else
						log_misc("Incorrect species whitelist for experienced players configuration definition: [value].")

				if("alien_player_ratio")
					limitalienplayers = 1
					alien_to_human_ratio = text2num(value)

				if("assistant_maint")
					config.assistant_maint = 1

				if("gateway_enabled")
					config.gateway_enabled = 1

				if("continuous_rounds")
					config.continous_rounds = 1

				if("ghost_interaction")
					config.ghost_interaction = 1

				if("disable_player_mice")
					config.disable_player_mice = 1

				if("uneducated_mice")
					config.uneducated_mice = 1

				if("python_path")
					if(value)
						config.python_path = value
					else
						if(world.system_type == UNIX)
							config.python_path = "/usr/bin/env python2"
						else //probably windows, if not this should work anyway
							config.python_path = "python"

				if("allow_cult_ghostwriter")
					config.cult_ghostwriter = 1

				if("req_cult_ghostwriter")
					config.cult_ghostwriter_req_cultists = text2num(value)

				if("deathtime_required")
					config.deathtime_required = text2num(value)

				if("rus_language")
					config.rus_language = 1

				if("allow_drone_spawn")
					config.allow_drone_spawn = text2num(value)

				if("drone_build_time")
					config.drone_build_time = text2num(value)

				if("max_maint_drones")
					config.max_maint_drones = text2num(value)

				if("expected_round_length")
					config.expected_round_length = text2num(value) MINUTES

				if("event_delay_lower")
					var/values = text2numlist(value, ";")
					config.event_delay_lower[EVENT_LEVEL_MUNDANE] = values[1] MINUTES
					config.event_delay_lower[EVENT_LEVEL_MODERATE] = values[2] MINUTES
					config.event_delay_lower[EVENT_LEVEL_MAJOR] = values[3] MINUTES

				if("event_delay_upper")
					var/values = text2numlist(value, ";")
					config.event_delay_upper[EVENT_LEVEL_MUNDANE] = values[1] MINUTES
					config.event_delay_upper[EVENT_LEVEL_MODERATE] = values[2] MINUTES
					config.event_delay_upper[EVENT_LEVEL_MAJOR] = values[3] MINUTES

				if("event_custom_start_mundane")
					var/values = text2numlist(value, ";")
					config.event_first_run[EVENT_LEVEL_MUNDANE] = list("lower" = values[1] MINUTES, "upper" = values[2] MINUTES)

				if("event_custom_start_moderate")
					var/values = text2numlist(value, ";")
					config.event_first_run[EVENT_LEVEL_MODERATE] = list("lower" = values[1] MINUTES, "upper" = values[2] MINUTES)

				if("event_custom_start_major")
					var/values = text2numlist(value, ";")
					config.event_first_run[EVENT_LEVEL_MAJOR] = list("lower" = values[1] MINUTES, "upper" = values[2] MINUTES)

				// Bay new things are below
				if("use_overmap")
					config.use_overmap = 1

				if("chat_bridge")
					config.chat_bridge = value

				if("antigrief_alarm_level")
					config.antigrief_alarm_level = value

				if("check_randomizer")
					config.check_randomizer = value

				if("guard_email")
					config.guard_email = value

				if("guard_enabled")
					config.guard_enabled = TRUE

				if("guard_autoban_treshhold")
					config.guard_autoban_treshhold = text2num(value)

				if("guard_autoban_reason")
					config.guard_autoban_reason = value

				if("guard_autoban_sticky")
					config.guard_autoban_sticky = TRUE

				if("guard_whitelisted_country_codes")
					config.guard_whitelisted_country_codes = splittext(value, ",")

				if("allow_donators")
					config.allow_donators = 1

				if("allow_tauceti_patrons")
					config.allow_tauceti_patrons = 1

				if("allow_byond_membership")
					config.allow_byond_membership = 1

				if("donate_info_url")
					config.donate_info_url = value

				if("customitem_slot_by_time")
					config.customitem_slot_by_time = text2num(value)

				if("changelog_link")
					config.changelog_link = value

				if("changelog_hash_link")
					config.changelog_hash_link = value

				if("repository_link")
					config.repository_link = value

				if("registration_panic_bunker_age")
					config.registration_panic_bunker_age = value

				if("allowed_by_bunker_player_age")
					config.allowed_by_bunker_player_age = value

				if("client_limit_panic_bunker_count")
					config.client_limit_panic_bunker_count = text2num(value)

				if("client_limit_panic_bunker_link")
					config.client_limit_panic_bunker_link = value

				if("summon_testmap")
					config.load_testmap = TRUE

				if("record_replays")
					config.record_replays = TRUE

				if("sandbox")
					config.sandbox = TRUE

				if("ooc_round_only")
					config.ooc_round_only = TRUE

				else
					log_misc("Unknown setting in configuration: '[name]'")

		else if(type == "game_options")
			if(!value)
				log_misc("Unknown value for setting [name] in [filename].")
			value = text2num(value)

			switch(name)
				if("health_threshold_crit")
					config.health_threshold_crit = value
				if("health_threshold_softcrit")
					config.health_threshold_softcrit = value
				if("health_threshold_dead")
					config.health_threshold_dead = value
				if("revival_pod_plants")
					config.revival_pod_plants = value
				if("revival_cloning")
					config.revival_cloning = value
				if("revival_brain_life")
					config.revival_brain_life = value
				if("run_speed")
					config.run_speed = value
				if("walk_speed")
					config.walk_speed = value
				if("human_delay")
					config.human_delay = value
				if("robot_delay")
					config.robot_delay = value
				if("monkey_delay")
					config.monkey_delay = value
				if("alien_delay")
					config.alien_delay = value
				if("slime_delay")
					config.slime_delay = value
				if("animal_delay")
					config.animal_delay = value
				if("organ_health_multiplier")
					config.organ_health_multiplier = value / 100
				if("organ_regeneration_multiplier")
					config.organ_regeneration_multiplier = value / 100
				if("craft_recipes_visibility")
					config.craft_recipes_visibility = TRUE
				if("starlight")
					config.starlight = TRUE
				if("nightshift")
					config.nightshift = TRUE
				else
					log_misc("Unknown setting in configuration: '[name]'")

	fps = round(fps)
	if(fps <= 0)
		fps = initial(fps)

/datum/configuration/proc/loadsql(filename)  // -- TLE
	var/list/Lines = file2list(filename)
	for(var/t in Lines)
		if(!t)	continue

		t = trim(t)
		if (length(t) == 0)
			continue
		else if (copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/name = null
		var/value = null

		if (pos)
			name = lowertext(copytext(t, 1, pos))
			value = copytext(t, pos + 1)
		else
			name = lowertext(t)

		if (!name)
			continue

		switch (name)
			if ("address")
				sqladdress = value
			if ("port")
				sqlport = value
			if ("database")
				sqldb = value
			if ("login")
				sqllogin = value
			if ("password")
				sqlpass = value
			if ("feedback_database")
				sqlfdbkdb = value
			if ("feedback_login")
				sqlfdbklogin = value
			if ("feedback_password")
				sqlfdbkpass = value
			else
				log_misc("Unknown setting in configuration: '[name]'")

/datum/configuration/proc/pick_mode(mode_name)
	// I wish I didn't have to instance the game modes in order to look up
	// their information, but it is the only way (at least that I know of).
	for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		if (M.config_tag && M.config_tag == mode_name)
			return M
		qdel(M)
	return new /datum/game_mode/extended()

/datum/configuration/proc/is_hidden_gamemode(g_mode)
	return (g_mode && (g_mode=="secret" || g_mode=="bs12" || g_mode=="tau classic"))

/datum/configuration/proc/is_modeset(g_mode)
	return (g_mode && (g_mode=="random" || g_mode=="secret" || g_mode=="bs12" || g_mode=="tau classic"))

/datum/configuration/proc/is_custom_modeset(g_mode)
	return (g_mode && (g_mode=="bs12" || g_mode=="tau classic"))

// As argument accpet config tag of gamemode, not name
/datum/configuration/proc/is_mode_allowed(g_mode_tag)
	return (g_mode_tag && (g_mode_tag in modes))

// check_ready - if true only ready players count
/datum/configuration/proc/get_runnable_modes(modeset="random", check_ready=TRUE)
	var/list/datum/game_mode/runnable_modes = new
	for (var/T in (typesof(/datum/game_mode) - /datum/game_mode))
		var/datum/game_mode/M = new T()
		M.modeset = modeset
		// log_debug("[T], tag=[M.config_tag], prob=[probabilities[M.config_tag]]")
		if (!is_mode_allowed(M.config_tag))
			qdel(M)
			continue
		if (is_custom_modeset(M.config_tag))
			qdel(M)
			continue
		if(!modeset || modeset == "random" || modeset == "secret")
			if(global.master_last_mode && global.secret_force_mode == "secret" && modeset == "secret")
				if(M.name != "AutoTraitor" && M.name == global.master_last_mode)
					qdel(M)
					continue
			if (probabilities[M.config_tag]<=0)
				qdel(M)
				continue
		else if (is_custom_modeset(modeset))
			switch(modeset)
				if("bs12")
					switch(M.config_tag)
						if("traitorchan","traitor","blob","gang","heist","infestation","meme","meteor","mutiny","ninja","rp-revolution","revolution","shadowling")
							qdel(M)
							continue
				if("tau classic")
					switch(M.config_tag)
						if("traitor","blob","extended","gang","heist","infestation","meme","meteor","mutiny","ninja","rp-revolution","revolution","shadowling")
							qdel(M)
							continue
		var/mod_prob = probabilities[M.config_tag]
		if (is_custom_modeset(modeset))
			mod_prob = 1
		if (((!check_ready) && M.potential_runnable()) || (check_ready && M.can_start()))
			runnable_modes[M] = mod_prob
			// log_debug("runnable_mode\[[runnable_modes.len]\] = [M.config_tag] [mod_prob]")
	return runnable_modes

/datum/configuration/proc/stat_entry()
	if(!statclick)
		statclick = new/obj/effect/statclick/debug(null, "Edit", src)

	stat("[name]:", statclick)

/datum/configuration/proc/loadmaplist(filename)
	var/list/Lines = file2list(filename)

	var/datum/map_config/currentmap = null
	for(var/t in Lines)
		if(!t)
			continue

		t = trim(t)
		if(length(t) == 0)
			continue
		else if(copytext(t, 1, 2) == "#")
			continue

		var/pos = findtext(t, " ")
		var/command = null
		var/data = null

		if(pos)
			command = lowertext(copytext(t, 1, pos))
			data = copytext(t, pos + 1)
		else
			command = lowertext(t)

		if(!command)
			continue

		if (!currentmap && command != "map")
			continue

		switch (command)
			if ("map")
				currentmap = load_map_config("maps/[data].json")
				if(currentmap.defaulted)
					error("Failed to load map config for [data]!")
					currentmap = null
			if ("minplayers","minplayer")
				currentmap.config_min_users = text2num(data)
			if ("maxplayers","maxplayer")
				currentmap.config_max_users = text2num(data)
			if ("default","defaultmap")
				defaultmap = currentmap
			if ("endmap")
				maplist[currentmap.map_name] = currentmap
				currentmap = null
			if ("disabled")
				currentmap = null
			else
				error("Unknown command in map vote config: '[command]'")

/datum/configuration/proc/load_list_without_comments(filename)
	// Loading text file to list and removing comments
	// Comment line can start with # or end with #
	// If line end with # before # place tab(s) or space(s)
	var/list/data = list()
	var/endline_comment = regex(@"\s+#")
	for(var/L in file2list(filename))
		if (copytext(L, 1, 2) == "#")
			continue
		var/cut_position = findtext(L, endline_comment)
		if(cut_position)
			L = trim(copytext(L, 1, cut_position))
		if (length(L))
			data += L
	return data

/datum/configuration/proc/load_announcer_config(config_path)
	// Loading config of network communication between servers
	// Server list loaded from serverlist.txt file. It's file with comments.
	// One line of file = one server. Format - byond://example.com:2506 = secret
	// First server must be self link for loading the secret
	//
	// In config file ban.txt load settings for ban announcer.
	// Format key = value
	var/restricted_chars_regex = regex(@"[;&]","g")
	for(var/L in load_list_without_comments("[config_path]/serverlist.txt"))
		var/delimiter_position = findtext(L,"=")
		var/key = trim(copytext(L, 1, delimiter_position))
		if(delimiter_position && length(key))
			// remove restricted chars
			L=replacetext(L, restricted_chars_regex, "")
			global.net_announcer_secret[key] = trim(copytext(L, delimiter_position+1))
	for(var/L in load_list_without_comments("[config_path]/ban.txt"))
		var/delimiter_position = findtext(L,"=")
		var/key = trim(copytext(L, 1, delimiter_position))
		if(delimiter_position && length(key))
			var/value = trim(copytext(L, delimiter_position+1))
			switch(lowertext(key))
				if ("receive")
					if (value && (lowertext(value) == "true" || lowertext(value) == "on"))
						net_announcers["ban_receive"] = TRUE
				if ("send")
					if (value && (lowertext(value) == "true" || lowertext(value) == "on"))
						net_announcers["ban_send"] = TRUE
