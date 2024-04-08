/datum/map_module
	var/name = "default"

	var/default_event_name
	var/default_event_message

	// list of additional verbs for players
	var/list/player_verbs
	// list of additional verbs for admins
	var/list/admin_verbs

	// gamemode name to force
	var/gamemode

	// todo: default stats

	// disables random events, most likely you need it
	var/config_disable_random_events = FALSE
	// enables alternative spawn menu for lobby through spawners
	var/config_use_spawners_lobby = FALSE

	// disable default mice/drone spawners
	var/disable_default_spawners = FALSE

/datum/map_module/New()
	SHOULD_CALL_PARENT(TRUE)

	. = ..()

	log_debug("Map module '[name]' loaded.")

	if(config_disable_random_events)
		config.allow_random_events = FALSE
		log_debug("Random events disabled by map module.")

	if(config_use_spawners_lobby)
		config.alt_lobby_menu = TRUE
		log_debug("Alternative event menu enabled.")

	if(disable_default_spawners) // need to rewrite configs, this is stupid
		config.disable_player_mice = TRUE
		config.allow_drone_spawn = FALSE

	if(gamemode)
		log_debug("[gamemode] mode forced.")
		master_mode = gamemode

	if(player_verbs)
		setup_temp_player_verbs(player_verbs, "Map")

	if(admin_verbs)
		setup_temp_admin_verbs(admin_verbs, "Map")

	if(default_event_message || default_event_name)
		SSevents.setup_custom_event(default_event_message, default_event_name)

/datum/map_module/proc/stat_entry(mob/M)
	return
