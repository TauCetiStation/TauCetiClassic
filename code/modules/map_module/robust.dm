/datum/map_module/robust
	name = MAP_MODULE_ROBUST

	default_event_name = "Robust"
	default_event_message = {"Межгалактический Турнир по Робасту!"}

	gamemode = "Extended"
	config_disable_random_events = TRUE
	config_use_spawners_lobby = TRUE
	disable_default_spawners = TRUE

	admin_verbs = list(
	)

	var/list/datum/spawner/robust/spawners = list()

/datum/map_module/robust/New()
	..()
	spawners["Robust Visitor"] = create_spawner(/datum/spawner/robust, src)
