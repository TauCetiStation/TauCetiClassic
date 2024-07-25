var/global/list/net_announcer_secret = list()
var/global/bridge_secret = null

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
	var/log_asset = 0
	var/log_tgui = 0
	var/sql_enabled = 0					// for sql switching
	var/allow_admin_ooccolor = 0		// Allows admins with relevant permissions to have their own ooc colour
	var/ert_admin_call_only = 0
	var/allow_admin_jump = 1			// allows admin jumping
	var/allow_admin_spawning = 1		// allows admin item spawning
	var/allow_admin_rev = 1				// allows admin revives
	var/vote_period = 600				// length of voting period (deciseconds, default 1 minute)
	var/del_new_on_log = 1				// del's new players if they log before they spawn in
	var/traitor_scaling = 1 			//if amount of traitors scales based on amount of players
	var/objectives_disabled = 0 		//if objectives are disabled or not
	var/protect_roles_from_antagonist = 0// If security and such can be traitor/cult/other
	var/continous_rounds = 0			// Gamemodes which end instantly will instead keep on going until the round ends by escape shuttle or nuke.
	var/fps = 20
	var/list/resource_urls = null
	var/antag_hud_allowed = 0			// Ghosts can turn on Antagovision to see a HUD of who is the bad guys this round.
	var/antag_hud_restricted = 0                    // Ghosts that turn on Antagovision cannot rejoin the round.
	var/list/mode_names = list()
	var/list/config_name_by_real = list()
	var/list/probabilities = list()		// relative probability of each mode
	var/humans_need_surnames = 0
	var/allow_random_events = 1			// enables random events mid-round when set to 1
	var/alt_lobby_menu = 0 // event lobby
	var/allow_ai = 1					// allow ai job
	var/hostedby = null
	var/respawn = 1
	var/usewhitelist = 0
	var/mods_are_mentors = 0
	var/kick_inactive = 0				//force disconnect for inactive players
	var/afk_time_bracket = 6000 // 10 minutes
	var/load_jobs_from_txt = 0
	var/automute_on = 0					//enables automuting/spam prevention

	// If true - disable OOC for the duration of a round.
	var/ooc_round_autotoggle = FALSE

	var/registration_panic_bunker_age = null
	var/allowed_by_bunker_player_age = 60
	var/client_limit_panic_bunker_count = null
	var/client_limit_panic_bunker_link = null
	var/client_limit_panic_bunker_mentor_pass_cap = 3

	var/bunker_ban_mode = 0
	var/bunker_ban_mode_message = "Sorry, you can't play on this server, we do not accept new players."

	var/cult_ghostwriter = 1               //Allows ghosts to write in blood in cult rounds...
	var/cult_ghostwriter_req_cultists = 9  //...so long as this many cultists are active.

	var/max_maint_drones = 5				//This many drones can spawn,
	var/allow_drone_spawn = 1				//assuming the admin allow them to.
	var/drone_build_time = 1200				//A drone will become available every X ticks since last drone spawn. Default is 2 minutes.

	var/disable_player_mice = 0
	var/uneducated_mice = 0 //Set to 1 to prevent newly-spawned mice from understanding human speech

	var/deathtime_required = 18000	//30 minutes

	var/usealienwhitelist = 0
	var/use_alien_job_restriction = 0
	var/list/whitelisted_species_by_time = list()

	var/server
	var/banappeals
	var/siteurl
	var/wikiurl
	var/forumurl
	var/media_base_url
	var/server_rules_url
	var/discord_invite_url
	var/customitems_info_url

	// Changelog
	var/changelog_link = ""
	var/changelog_hash_link = ""

	var/repository_link = ""

	var/github_repository_owner = ""
	var/github_repository_name = ""

	var/forbid_singulo_possession = 0

	var/allow_holidays = FALSE
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
	var/run_speed = 3
	var/walk_speed = 5

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
	var/list/event_first_run = list(EVENT_LEVEL_FEATURE = null,
									EVENT_LEVEL_MUNDANE = null,
									EVENT_LEVEL_MODERATE = null,
									EVENT_LEVEL_MAJOR = list("lower" = 50 MINUTES, "upper" = 70 MINUTES))
	// The lowest delay until next event
	var/list/event_delay_lower = list(EVENT_LEVEL_FEATURE = null,
									  EVENT_LEVEL_MUNDANE  = 10 MINUTES,
									  EVENT_LEVEL_MODERATE = 30 MINUTES,
									  EVENT_LEVEL_MAJOR    = 50 MINUTES)
	// The upper delay until next event
	var/list/event_delay_upper = list(EVENT_LEVEL_FEATURE = null,
									  EVENT_LEVEL_MUNDANE  = 15 MINUTES,
									  EVENT_LEVEL_MODERATE = 45 MINUTES,
									  EVENT_LEVEL_MAJOR    = 70 MINUTES)

	var/admin_legacy_system = 0	//Defines whether the server uses the legacy admin system with admins.txt or the SQL system. Config option in config.txt
	var/ban_legacy_system = 0	//Defines whether the server uses the legacy banning system with the files in /data or the SQL system. Config option in config.txt
	var/use_age_restriction_for_jobs = 0 //Do jobs use account age restrictions? --requires database
	var/use_ingame_minutes_restriction_for_jobs = 0 //Do jobs use in-game minutes instead account age for restrictions?

	var/add_player_age_value = 4320 //default minuts added with admin "Increase player age" button. 4320 minutes = 72 hours = 3 days

	var/byond_version_min = RECOMMENDED_VERSION
	var/byond_version_recommend = RECOMMENDED_VERSION

	var/simultaneous_pm_warning_timeout = 100

	var/assistant_maint = 0 //Do assistants get maint access?
	var/gateway_enabled = 0
	var/ghost_interaction = 0

	var/python_path = "" //Path to the python executable.  Defaults to "python" on windows and "/usr/bin/env python2" on unix
	var/github_token = "" // todo: move this to globals for security
	var/use_overmap = 0

	var/chat_bridge = 0
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
	var/nightshift = FALSE

	var/list/maplist = list()
	var/datum/map_config/defaultmap
	var/load_testmap = FALSE // swaps whatever.json with testmap.json in SSmapping init phase.
	var/load_junkyard = TRUE
	var/load_mine = TRUE
	var/load_space_levels = TRUE

#ifdef EARLY_PROFILE
	var/auto_profile = TRUE
#else
	var/auto_profile = FALSE
#endif

	var/auto_lag_switch_pop = FALSE

	var/record_replays = FALSE

	var/use_persistent_cache = FALSE

	var/reactionary_explosions = TRUE

	var/sandbox = FALSE
	var/list/net_announcers = list() // List of network announcers on

	var/minutetopiclimit = 100
	var/secondtopiclimit = 10

	var/deathmatch_arena = TRUE

	var/ghost_max_view = 10 // 21x21
	var/ghost_max_view_supporter = 13 // 27x27

	var/hard_deletes_overrun_threshold = 0.5
	var/hard_deletes_overrun_limit = 0

/datum/configuration/New()
	for (var/type in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = type
		if(initial(M.name) && !(initial(M.name) in mode_names))
			log_misc("Adding game mode [initial(M.name)] to configuration.")
			mode_names += initial(M.name)
			config_name_by_real[initial(M.config_name)] = initial(M.name)
			probabilities[initial(M.config_name)] = initial(M.probability)

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

				if ("log_asset")
					config.log_asset = 1

				if ("log_tgui")
					config.log_tgui = 1

				if ("log_runtime")
					config.log_runtime = 1

				if ("mentors")
					config.mods_are_mentors = 1

				if("allow_admin_ooccolor")
					config.allow_admin_ooccolor = 1

				if ("allow_admin_jump")
					config.allow_admin_jump = 1

				if("allow_admin_rev")
					config.allow_admin_rev = 1

				if ("allow_admin_spawning")
					config.allow_admin_spawning = 1

				if ("vote_period")
					config.vote_period = text2num(value)

				if("ert_admin_only")
					config.ert_admin_call_only = 1

				if ("allow_ai")
					config.allow_ai = text2num(value)

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

				if ("siteurl")
					config.siteurl = value

				if ("forumurl")
					config.forumurl = value

				if ("guest_ban")
					guests_allowed = 0

				if ("usewhitelist")
					config.usewhitelist = 1

				if("media_base_url")
					media_base_url = value

				if ("server_rules_url")
					server_rules_url = value

				if ("discord_invite_url")
					discord_invite_url = value

				if ("customitems_info_url")
					customitems_info_url = value

				if ("traitor_scaling")
					config.traitor_scaling = text2num(value)

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
						if (prob_name in config.config_name_by_real)
							config.probabilities[prob_name] = text2num(prob_value)
						else
							log_misc("Unknown game mode probability configuration definition: [prob_name].")
					else
						log_misc("Incorrect probability configuration definition: [prob_name]  [prob_value].")

				if("allow_random_events")
					config.allow_random_events = text2num(value)

				if("kick_inactive")
					config.kick_inactive = 1

				if ("afk_time_bracket")
					config.afk_time_bracket = (text2num(value) MINUTES)

				if("load_jobs_from_txt")
					load_jobs_from_txt = 1

				if("forbid_singulo_possession")
					forbid_singulo_possession = 1

				if("allow_holidays")
					allow_holidays = TRUE

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

				if("github_token")
					config.github_token = value

				if("allow_cult_ghostwriter")
					config.cult_ghostwriter = 1

				if("req_cult_ghostwriter")
					config.cult_ghostwriter_req_cultists = text2num(value)

				if("ghost_max_view")
					config.ghost_max_view = text2num(value)

				if("ghost_max_view_supporter")
					config.ghost_max_view_supporter = text2num(value)

				if("deathtime_required")
					config.deathtime_required = text2num(value)

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
					var/repo_path = replacetext(config.repository_link, "https://github.com/", "")
					if(repo_path != config.repository_link)
						var/split = splittext(repo_path, "/")
						config.github_repository_owner = split[1]
						config.github_repository_name = split[2]

				if("registration_panic_bunker_age")
					config.registration_panic_bunker_age = value

				if("allowed_by_bunker_player_age")
					config.allowed_by_bunker_player_age = text2num(value)

				if("client_limit_panic_bunker_count")
					config.client_limit_panic_bunker_count = text2num(value)

				if("client_limit_panic_bunker_mentor_pass_cap")
					config.client_limit_panic_bunker_mentor_pass_cap = text2num(value)

				if("client_limit_panic_bunker_link")
					config.client_limit_panic_bunker_link = value

				if ("bunker_ban_mode")
					config.bunker_ban_mode = 1

				if("bunker_ban_mode_message")
					config.bunker_ban_mode_message = value

				if("summon_testmap")
					config.load_testmap = TRUE

				if("no_junkyard")
					config.load_junkyard = FALSE

				if("no_mine")
					config.load_mine = FALSE

				if("no_space_levels")
					config.load_space_levels = FALSE

				if("auto_profile")
					config.auto_profile = TRUE

				if("auto_lag_switch_pop")
					config.auto_lag_switch_pop = text2num(value)

				if("record_replays")
					config.record_replays = TRUE

				if("sandbox")
					config.sandbox = TRUE

				if("use_persistent_cache")
					config.use_persistent_cache = TRUE

				if("ooc_round_only") // todo: ambiguous old name, need to rename for ooc_round_autotoggle or something
					config.ooc_round_autotoggle = TRUE

				if("minute_topic_limit")
					config.minutetopiclimit = text2num(value)

				if("second_topic_limit")
					config.secondtopiclimit = text2num(value)

				if("hard_deletes_overrun_threshold")
					config.hard_deletes_overrun_threshold = text2num(value)

				if("hard_deletes_overrun_limit")
					config.hard_deletes_overrun_limit = text2num(value)

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
				if("nightshift")
					config.nightshift = TRUE
				if("deathmatch_arena")
					config.deathmatch_arena = text2num(value)
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
			else
				log_misc("Unknown setting in configuration: '[name]'")

/datum/configuration/proc/pick_mode(mode_name)
	for (var/type in subtypesof(/datum/game_mode))
		var/datum/game_mode/M = new type()
		if (M.name == mode_name)
			return M
	return new /datum/game_mode/extended()

/datum/configuration/proc/get_bundle_by_name(name)
	for(var/type in subtypesof(/datum/modesbundle))
		var/datum/modesbundle/M = type
		if(initial(M.name) == name)
			return new M
	return null

/datum/configuration/proc/is_bundle_by_name(name)
	for(var/type in subtypesof(/datum/modesbundle))
		var/datum/modesbundle/M = type
		if(initial(M.name) == name)
			return TRUE
	return FALSE

/datum/configuration/proc/get_runnable_modes(datum/modesbundle/bundle)
	var/list/datum/game_mode/runnable_modes = list()
	var/list/runnable_modes_names = list()
	for(var/type in bundle.possible_gamemodes)
		var/datum/game_mode/M = new type()
		if(!M.name || !(M.config_name in config_name_by_real))
			qdel(M)
			continue
		if(probabilities[M.config_name] <= 0)
			qdel(M)
			continue
		if(global.master_last_mode == M.name)
			qdel(M)
			continue
		if(global.modes_failed_start[M.name])
			qdel(M)
			continue
		var/mod_prob = probabilities[M.config_name]
		if(M.can_start())
			runnable_modes[M] = mod_prob
			runnable_modes_names += M.name
	log_mode("Current pool of gamemodes([runnable_modes.len]):")
	log_mode(get_english_list(runnable_modes_names))

	return runnable_modes

/datum/configuration/proc/get_always_runnable_modes()
	var/list/exactly_runnable_modes = list()
	var/list/runnable_modes_names = list()
	var/datum/modesbundle/run_anyway/bundle = new
	for(var/type in bundle.possible_gamemodes)
		var/datum/game_mode/M = new type()
		exactly_runnable_modes[M] = 1
		runnable_modes_names += M.name
	log_mode("Current pool of always runnable gamemodes([exactly_runnable_modes.len]):")
	log_mode(get_english_list(runnable_modes_names))
	return exactly_runnable_modes

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
			if ("votable")
				currentmap.votable = TRUE
			if ("voteweight")
				currentmap.voteweight = text2num(data)
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
