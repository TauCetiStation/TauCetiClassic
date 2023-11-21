/datum/map_module
	var/name = "default"

	var/default_event_message
	var/default_event_name

	// list of additional verbs for players
	var/list/player_verbs
	// list of additional verbs for admins
	var/list/admin_verbs

	// gamemode to force
	var/gamemode = "Extended"

	// todo: default stats

	// disables random events, most likely you need it
	var/config_disable_random_events = FALSE
	// enables alternative spawn menu for lobby through spawners
	var/config_use_spawners_lobby = FALSE

/datum/map_module/New()
	SHOULD_CALL_PARENT(TRUE)

	log_debug("Map module '[name]' loaded.")

	if(config_disable_random_events)
		config.allow_random_events = FALSE
		log_debug("Random events disabled by map module.")

	if(config_use_spawners_lobby)
		config.alt_lobby_menu = TRUE
		log_debug("Alternative event menu enabled.")

	if(player_verbs)
		setup_temp_player_verbs(player_verbs, "Map")

	if(admin_verbs)
		setup_temp_admin_verbs(admin_verbs, "Map")

	if(default_event_message || default_event_name)
		SSevents.setup_custom_event(default_event_message, default_event_name)
