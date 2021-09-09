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

var/list/severity_to_string = list(EVENT_LEVEL_ROUNDSTART = "RoundStart", EVENT_LEVEL_MUNDANE = "Mundane", EVENT_LEVEL_MODERATE = "Moderate", EVENT_LEVEL_MAJOR = "Major")

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

/datum/event_container/roundstart
	severity = EVENT_LEVEL_ROUNDSTART
	available_events = list(
		// /datum/event_meta/New(event_severity, event_name, datum/event/type, event_weight, list/job_weights, is_one_shot = 0, event_enabled = 1, min_event_players = 0, min_event_weight = 0, max_event_weight = 0)
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Roundstart Nothing",      /datum/event/nothing, 1500),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Break Light",             /datum/event/roundstart/area/break_light,                        50, list(ASSIGNMENT_ENGINEER = 10, ASSIGNMENT_JANITOR = 40)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Dirt Bay",                /datum/event/roundstart/area/dirt,                               10, list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Randomize Cargo Storage", /datum/event/roundstart/area/cargo_storage,                      10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Armory Mess",             /datum/event/roundstart/area/armory_mess,                        10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "MineField",               /datum/event/roundstart/area/minefield,                          5,  list(ASSIGNMENT_MEDICAL = 2), , list(ASSIGNMENT_SECURITY = 2)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Lasertag ED-209",         /datum/event/roundstart/area/lasertag_ed,                        10),list(ASSIGNMENT_ANY = 2),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Stolen Weapon",           /datum/event/roundstart/area/replace/sec_weapons,                20, list(ASSIGNMENT_SECURITY = 5)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Stolen First AID",        /datum/event/roundstart/area/replace/med_storage,                10, list(ASSIGNMENT_MEDICAL = 1)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Old Morgue",              /datum/event/roundstart/area/replace/med_morgue,                 10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Broken Airlocks",         /datum/event/roundstart/area/replace/airlock,                    10, list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Chewed Cables",           /datum/event/roundstart/area/replace/del_cable,                  10, list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Clondike",                /datum/event/roundstart/area/replace/vault_gold,                 10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Deathly Sec.",            /datum/event/roundstart/area/replace/deathly_sec,                5,  list(ASSIGNMENT_CLOWN = 50)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Surgeon Tools", /datum/event/roundstart/area/replace/del_surgeon_tools,          10, list(ASSIGNMENT_MEDICAL = 2)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Anti meat",               /datum/event/roundstart/area/replace/mince_back,                 10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Invasion In Mainteance",  /datum/event/roundstart/area/maintenance_spawn/invasion,         10, list(ASSIGNMENT_SECURITY = 50)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Sign of Antagonists",     /datum/event/roundstart/area/maintenance_spawn/antag_meta,       10, list(ASSIGNMENT_SECURITY = 50)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Headset",       /datum/event/roundstart/headset,                                 10, list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Survival Box",  /datum/event/roundstart/survbox,                                 10, list(ASSIGNMENT_ANY = 5)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Fueltanks",     /datum/event/roundstart/fueltank,                                10, list(ASSIGNMENT_ENGINEER = 20)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Watertanks",    /datum/event/roundstart/watertank,                               10, list(ASSIGNMENT_BOTANIST = 10)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Cleaners",      /datum/event/roundstart/cleaner,                                 10, list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Extinguishers", /datum/event/roundstart/extinguisher,                            10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Scraps",        /datum/event/roundstart/del_scrap,                               10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Toilets",       /datum/event/roundstart/del_toilet,                              10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Leaked Pipe",             /datum/event/roundstart/leaked_pipe,                             10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Die Monkey",              /datum/event/roundstart/dead_monkeys,                            10, list(ASSIGNMENT_SCIENTIST = 5)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Engine Mess",             /datum/event/roundstart/PA,                                      10, list(ASSIGNMENT_ENGINEER = 10)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgottens Tanks",        /datum/event/roundstart/tank_dispenser,                          10, list(ASSIGNMENT_ENGINEER = 5, ASSIGNMENT_SCIENTIST = 10)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Forgotten Sec. Equimp.",  /datum/event/roundstart/sec_equipment,                           10, list(ASSIGNMENT_SECURITY = 10)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Products Inflation",      /datum/event/roundstart/vending_products,                        10),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "BlueScreen APC",          /datum/event/roundstart/apc,                                     1000000, list(ASSIGNMENT_ENGINEER = 5)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Accounting Got It Wrong", /datum/event/roundstart/salary,                                  10, list(ASSIGNMENT_ANY = 2)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Last Clown Jokes",        /datum/event/roundstart/airlock_joke,                            10, list(ASSIGNMENT_CLOWN = 50)),
		new /datum/event_meta(EVENT_LEVEL_ROUNDSTART, "Chiefs Animals",          /datum/event/roundstart/head_animals,                            10),
	)

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Nothing",           /datum/event/nothing,           1100),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "PDA Spam",          /datum/event/pda_spam,          0,    list(ASSIGNMENT_ANY = 4),       0, 1, 0, 25, 50),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Lotto",       /datum/event/money_lotto,       0,    list(ASSIGNMENT_ANY = 1), ONESHOT, 1, 0,  5, 15),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Money Hacker",      /datum/event/money_hacker,      0,    list(ASSIGNMENT_ANY = 4), ONESHOT, 1, 0, 10, 25),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Economic Event",    /datum/event/economic_event,    300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Trivial News",      /datum/event/trivial_news,      400),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Mundane News",      /datum/event/mundane_news,      300),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Vermin Infestation",/datum/event/infestation,       100,  list(ASSIGNMENT_JANITOR = 100)),
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Wallrot",           /datum/event/wallrot,           0,    list(ASSIGNMENT_ENGINEER = 30, ASSIGNMENT_BOTANIST = 50)),
	)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Nothing",                 /datum/event/nothing,                   1230),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Appendicitis",            /datum/event/spontaneous_appendicitis,  0,     list(ASSIGNMENT_MEDICAL = 10), ONESHOT),
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
		new /datum/event_meta/ninja(EVENT_LEVEL_MODERATE, "Space Ninja",       /datum/event/space_ninja,               0,     list(ASSIGNMENT_SECURITY = 15), ONESHOT, 1, 15),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Organ Failure",           /datum/event/organ_failure,             0,     list(ASSIGNMENT_MEDICAL = 150), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Pyro Anomaly",            /datum/event/anomaly/anomaly_pyro,      75,    list(ASSIGNMENT_ENGINEER = 60)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Vortex Anomaly",          /datum/event/anomaly/anomaly_vortex,    75,    list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Bluespace Anomaly",       /datum/event/anomaly/anomaly_bluespace, 75,    list(ASSIGNMENT_ENGINEER = 25)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Flux Anomaly",            /datum/event/anomaly/anomaly_flux,      75,    list(ASSIGNMENT_ENGINEER = 50)),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Gravitational Anomaly",   /datum/event/anomaly/anomaly_grav,      200),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Viral Infection",         /datum/event/viral_infection,           0,     list(ASSIGNMENT_MEDICAL = 150), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Sandstorm",               /datum/event/sandstorm,                 0,     list(ASSIGNMENT_ENGINEER = 25), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MODERATE, "Portal of Cult",          /datum/event/anomaly/cult_portal,       60,    list(ASSIGNMENT_SECURITY = 40), ONESHOT),
		new /datum/event_meta/alien(EVENT_LEVEL_MODERATE, "Alien Infestation", /datum/event/alien_infestation,         0,     list(ASSIGNMENT_SECURITY = 15, ASSIGNMENT_MEDICAL = 15), ONESHOT, 1, 35),
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Nothing",                 /datum/event/nothing,           1320),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Carp Migration",          /datum/event/carp_migration,    0, list(ASSIGNMENT_SECURITY = 10), ONESHOT),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Blob",                    /datum/event/blob,              0, list(ASSIGNMENT_ENGINEER = 25), ONESHOT, 1, 25),
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Meteor Wave",             /datum/event/meteor_wave,       0, list(ASSIGNMENT_ENGINEER = 10), ONESHOT),
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
