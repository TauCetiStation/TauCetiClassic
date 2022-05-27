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
		new /datum/event_meta(EVENT_LEVEL_FEATURE, "Nothing",           /datum/event/nothing,           1100),

		)

/datum/event_container/mundane
	severity = EVENT_LEVEL_MUNDANE
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MUNDANE, "Nothing",           /datum/event/nothing,           1100),
		)

/datum/event_container/moderate
	severity = EVENT_LEVEL_MODERATE
	available_events = list(new /datum/event_meta(EVENT_LEVEL_MODERATE, "Nothing",           /datum/event/nothing,           1100),
	)

/datum/event_container/major
	severity = EVENT_LEVEL_MAJOR
	available_events = list(
		new /datum/event_meta(EVENT_LEVEL_MAJOR, "Nothing",                 /datum/event/nothing,           1320),
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
