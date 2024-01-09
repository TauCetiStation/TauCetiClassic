#define ASSIGNMENT_ANY       "Any"
#define ASSIGNMENT_AI        "AI"
#define ASSIGNMENT_CYBORG    "Cyborg"
#define ASSIGNMENT_ENGINEER  "Engineer"
#define ASSIGNMENT_BOTANIST  "Botanist"
#define ASSIGNMENT_JANITOR   "Janitor"
#define ASSIGNMENT_CLOWN     "Clown"
#define ASSIGNMENT_MEDICAL   "Medical"
#define ASSIGNMENT_SCIENTIST "Scientist"
#define ASSIGNMENT_SECURITY  "Security"

#define ONESHOT  1
#define DISABLED 0

var/global/list/severity_to_string = list(EVENT_LEVEL_FEATURE = "RoundStart", EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major")

/datum/event_container
	var/severity = -1
	var/delayed = 0
	var/delay_modifier = 1
	var/next_event_time = 0
	var/list/available_events
	var/list/last_event_time = list()
	var/datum/event_meta/next_event = null

	var/last_world_time = 0

/datum/event_container/process()
	if(!next_event_time)
		set_event_delay()

	if(delayed  || !config.allow_random_events)
		next_event_time += (world.time - last_world_time)
	else if(world.time > next_event_time)
		start_event()

	last_world_time = world.time

/datum/event_container/proc/start_event()
	if(!next_event)	// If non-one has explicitly set an event, randomly pick one
		next_event = acquire_event()

	// Has an event been acquired?
	if(next_event)
		// Set when the event of this type was last fired, and prepare the next event start
		last_event_time[next_event] = world.time
		set_event_delay()
		next_event.enabled = !next_event.one_shot	// This event will no longer be available in the random rotation if one shot

		new next_event.event_type(next_event)	// Events are added and removed from the processing queue in their New/kill procs

		log_debug("Starting event '[next_event.name]' of severity [severity_to_string[severity]].")
		if(next_event.name != "Nothing")
			message_admins("Starting event '[next_event.name]' of severity [severity_to_string[severity]].")
		next_event = null						// When set to null, a random event will be selected next time
	else
		// If not, wait for one minute, instead of one tick, before checking again.
		next_event_time =  world.time + 60 SECONDS


/datum/event_container/proc/acquire_event()
	if(available_events.len == 0)
		return
	var/list/active_with_role = number_active_with_role()

	var/list/possible_events = list()
	for(var/datum/event_meta/EM in available_events)
		var/event_weight = EM.get_weight(active_with_role)
		if(EM.enabled && event_weight)
			possible_events[EM] = event_weight

	for(var/event_meta in last_event_time)
		if(possible_events[event_meta])
			var/time_passed = world.time - last_event_time[event_meta]
			var/full_recharge_after = config.expected_round_length
			var/weight_modifier = max(0, (full_recharge_after - time_passed) / 300)
			var/new_weight = max(possible_events[event_meta] - weight_modifier, 0)

			if(new_weight)
				possible_events[event_meta] = new_weight
			else
				possible_events -= event_meta

	if(possible_events.len == 0)
		return null

	// Select an event and remove it from the pool of available events
	var/picked_event = pickweight(possible_events)
	available_events -= picked_event
	return picked_event

/datum/event_container/proc/set_event_delay()
	// If the next event time has not yet been set and we have a custom first time start
	if(next_event_time == 0 && config.event_first_run[severity])
		var/lower = config.event_first_run[severity]["lower"]
		var/upper = config.event_first_run[severity]["upper"]
		var/event_delay = rand(lower, upper)
		next_event_time = world.time + event_delay
	// Otherwise, follow the standard setup process
	else
		var/playercount_modifier = 1
		switch(player_list.len)
			if(0 to 10)
				playercount_modifier = 1.2
			if(11 to 15)
				playercount_modifier = 1.1
			if(16 to 25)
				playercount_modifier = 1
			if(26 to 35)
				playercount_modifier = 0.9
			if(36 to 50)
				playercount_modifier = 0.8
			if(50 to 80)
				playercount_modifier = 0.7
			if(80 to 10000)
				playercount_modifier = 0.6

		playercount_modifier = playercount_modifier * delay_modifier

		var/event_delay = rand(config.event_delay_lower[severity], config.event_delay_upper[severity]) * playercount_modifier
		if(HAS_ROUND_ASPECT(ROUND_ASPECT_MORE_RANDOM_EVENTS))
			event_delay /= 3
		next_event_time = world.time + event_delay

	log_debug("Next event of severity [severity_to_string[severity]] in [(next_event_time - world.time)/600] minutes.")

/datum/event_container/proc/SelectEvent()
	var/datum/event_meta/EM = input("Select an event to queue up.", "Event Selection", null) as null|anything in available_events
	if(!EM)
		return
	if(next_event)
		available_events += next_event
	available_events -= EM
	next_event = EM
	return EM

/datum/event_container/feature
	severity = EVENT_LEVEL_FEATURE
	available_events = list(
		// /datum/event_meta/New(event_severity, event_name, datum/event/type, event_weight, list/job_weights, is_one_shot = 0, event_enabled = 1, min_event_players = 0, min_event_weight = 0, max_event_weight = 0)
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Roundstart Nothing",      /datum/event/nothing, 1500),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Break Light",             /datum/event/feature/area/break_light,                        50, list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_JANITOR = 40)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Dirt Bay",                /datum/event/feature/area/dirt,                               10, list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Randomize Cargo Storage", /datum/event/feature/area/cargo_storage,                      10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Armory Mess",             /datum/event/feature/area/mess/armory,                        10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Bridge Mess",             /datum/event/feature/area/mess/bridge,                        10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Medical Mess",            /datum/event/feature/area/mess/med_storage,                   10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "MineField",               /datum/event/feature/area/minefield,                          5,  list(ASSIGNMENT_MEDICAL = 2), , list(ASSIGNMENT_SECURITY = 2)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Lasertag ED-209",         /datum/event/feature/area/lasertag_ed,                        10),list(ASSIGNMENT_ANY = 2),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Stolen First AID",        /datum/event/feature/area/replace/med_storage,                20, list(ASSIGNMENT_MEDICAL = 1)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Old Morgue",              /datum/event/feature/area/replace/med_morgue,                 10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Broken Airlocks",         /datum/event/feature/area/replace/airlock,                    10, list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Chewed Cables",           /datum/event/feature/area/replace/del_cable,                  10, list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Clondike",                /datum/event/feature/area/replace/vault_gold,                 10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Deathly Sec.",            /datum/event/feature/area/replace/deathly_sec,                10,  list(ASSIGNMENT_CLOWN = 50)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Surgeon Tools", /datum/event/feature/area/replace/del_surgeon_tools,          10, list(ASSIGNMENT_MEDICAL = 2)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Anti meat",               /datum/event/feature/area/replace/mice_attack,                 10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Invasion In Mainteance",  /datum/event/feature/area/maintenance_spawn/invasion,         10, list(ASSIGNMENT_SECURITY = 50)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Sign of Antagonists",     /datum/event/feature/area/maintenance_spawn/antag_meta,       10, list(ASSIGNMENT_SECURITY = 50)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Headset",       /datum/event/feature/headset,                                 10, list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Survival Box",  /datum/event/feature/survbox,                                 10, list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Fueltanks",     /datum/event/feature/fueltank,                                10, list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Watertanks",    /datum/event/feature/watertank,                               10, list(ASSIGNMENT_BOTANIST = 10)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Cleaners",      /datum/event/feature/cleaner,                                 10, list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Extinguishers", /datum/event/feature/extinguisher,                            10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Toilets",       /datum/event/feature/del_toilet,                              10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Leaked Pipe",             /datum/event/feature/leaked_pipe,                             10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Die Monkey",              /datum/event/feature/dead_monkeys,                            10, list(ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Engine Mess",             /datum/event/feature/PA,                                      10, list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgottens Tanks",        /datum/event/feature/tank_dispenser,                          10, list(ASSIGNMENT_ENGINEER = 5, ASSIGNMENT_SCIENTIST = 10)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Forgotten Sec. Equimp.",  /datum/event/feature/sec_equipment,                           10, list(ASSIGNMENT_SECURITY = 10)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Products Inflation",      /datum/event/feature/vending_products,                        10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "BlueScreen APC",          /datum/event/feature/apc,                                     10, list(ASSIGNMENT_ENGINEER = 5)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Accounting Got It Wrong", /datum/event/feature/salary,                                  10, list(ASSIGNMENT_ANY = 2)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Last Clown Jokes",        /datum/event/feature/airlock_joke,                            10, list(ASSIGNMENT_CLOWN = 50)),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Chiefs Animals",          /datum/event/feature/head_animals,                            10),
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Nuke Journey",            /datum/event/feature/bomb_journey,                            10),
	)

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Nothing",            /datum/event/nothing,                                 1100),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "PDA Spam",           /datum/event/pda_spam,                                0,    list(ASSIGNMENT_ANY = 4),       0, 1, 0, 25, 50),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Lotto",        /datum/event/money_lotto,                             0,    list(ASSIGNMENT_ANY = 1), ONESHOT, 1, 0,  5, 15),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Hacker",       /datum/event/money_hacker,                            0,    list(ASSIGNMENT_ANY = 4), ONESHOT, 1, 0, 10, 25),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Economic Event",     /datum/event/economic_event,                          300),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Trivial News",       /datum/event/trivial_news,                            400),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mundane News",       /datum/event/mundane_news,                            300),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Vermin Infestation", /datum/event/infestation,                             100,  list(ASSIGNMENT_JANITOR = 100)),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Wallrot",            /datum/event/wallrot,                                 0,    list(ASSIGNMENT_ENGINEER = 30, ASSIGNMENT_BOTANIST = 50)),
	new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Xenohive",           /datum/event/feature/area/maintenance_spawn/xenohive, 300),
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Nothing",                 /datum/event/nothing,                   1230),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Carp School",             /datum/event/carp_migration,            200,   list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_SECURITY = 20), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Rogue Drones",            /datum/event/rogue_drone,               0,     list(ASSIGNMENT_SECURITY = 20)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Space Vines",             /datum/event/spacevine,                 250,   list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Meteor Shower",           /datum/event/meteor_shower,             0,     list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Communication Blackout",  /datum/event/communications_blackout,   500,   list(ASSIGNMENT_AI = 150, ASSIGNMENT_SECURITY = 120)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Prison Break",            /datum/event/prison_break,              0,     list(ASSIGNMENT_SECURITY = 100)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "APC Damage",              /datum/event/apc_damage,                200,   list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Camera Damage",           /datum/event/camera_damage,             200,   list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Gravity Failure",         /datum/event/gravity,                   100),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Electrical Storm",        /datum/event/electrical_storm,          250,   list(ASSIGNMENT_ENGINEER = 20, ASSIGNMENT_JANITOR = 150)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Radiation Storm",         /datum/event/radiation_storm,           25,    list(ASSIGNMENT_MEDICAL = 50),  ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Spider Infestation",      /datum/event/spider_infestation,        100,   list(ASSIGNMENT_SECURITY = 30), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Ion Storm",               /datum/event/ionstorm,                  0,     list(ASSIGNMENT_AI = 50, ASSIGNMENT_CYBORG = 50, ASSIGNMENT_ENGINEER = 15, ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Borer Infestation",       /datum/event/borer_infestation,         40,    list(ASSIGNMENT_SECURITY = 30), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Immovable Rod",           /datum/event/immovable_rod,             0,     list(ASSIGNMENT_ENGINEER = 30), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Brand Intelligence",      /datum/event/brand_intelligence,        50,    list(ASSIGNMENT_ENGINEER = 25), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Space Dust",              /datum/event/space_dust,                50,    list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Grid Check",              /datum/event/grid_check,                0,     list(ASSIGNMENT_ENGINEER = 25), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Organ Failure",           /datum/event/organ_failure,             0,     list(ASSIGNMENT_MEDICAL = 150), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Pyro Anomaly",            /datum/event/anomaly/anomaly_pyro,      75,    list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Vortex Anomaly",          /datum/event/anomaly/anomaly_vortex,    75,    list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Bluespace Anomaly",       /datum/event/anomaly/anomaly_bluespace, 75,    list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Flux Anomaly",            /datum/event/anomaly/anomaly_flux,      75,    list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Gravitational Anomaly",   /datum/event/anomaly/anomaly_grav,      200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Viral Infection",         /datum/event/viral_infection,           0,     list(ASSIGNMENT_MEDICAL = 150), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Wormholes",               /datum/event/wormholes,                 50,    list(ASSIGNMENT_MEDICAL = 50),  ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Sandstorm",               /datum/event/sandstorm,                 0,     list(ASSIGNMENT_ENGINEER = 25), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Portal of Cult",          /datum/event/anomaly/cult_portal,       60,    list(ASSIGNMENT_SECURITY = 40), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Heist",                   /datum/event/heist,                     40,    list(ASSIGNMENT_SECURITY = 15, ASSIGNMENT_ENGINEER = 15), ONESHOT),
		new /datum/event_meta/alien(EVENT_LEVEL_MODERATE, "Alien Infestation", /datum/event/alien_infestation,         0,     list(ASSIGNMENT_SECURITY = 15, ASSIGNMENT_MEDICAL = 15), ONESHOT, 1, 35),
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Nothing",                 /datum/event/nothing,           1320),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Carp Migration",          /datum/event/carp_migration,    0, list(ASSIGNMENT_SECURITY = 10), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Blob",                    /datum/event/blob,              0, list(ASSIGNMENT_ENGINEER = 25), ONESHOT, 1, 25),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Wizard",          		/datum/event/wizard,   			0, list(ASSIGNMENT_SECURITY = 20), ONESHOT, 1, 20),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Meteor Wave",             /datum/event/meteor_wave,       0, list(ASSIGNMENT_ENGINEER = 10), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Lone Syndicate Agent",    /datum/event/lone_op,         100, list(ASSIGNMENT_SECURITY = 30), ONESHOT, 1, 35),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Abduction",               /datum/event/abduction,         0, list(ASSIGNMENT_SECURITY = 30), ONESHOT, 1, 35),
	)

#undef ASSIGNMENT_ANY
#undef ASSIGNMENT_AI
#undef ASSIGNMENT_CYBORG
#undef ASSIGNMENT_ENGINEER
#undef ASSIGNMENT_BOTANIST
#undef ASSIGNMENT_JANITOR
#undef ASSIGNMENT_MEDICAL
#undef ASSIGNMENT_SCIENTIST
#undef ASSIGNMENT_SECURITY

#undef ONESHOT
#undef DISABLED
