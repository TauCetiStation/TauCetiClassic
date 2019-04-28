/datum/catastrophe_stationdata
	var/aliveness // how alive is the crew, value from 0 to 1

/datum/catastrophe_director
	var/name = "error"

	var/list/events // running events
	var/list/event_pool // what events might happen

	var/list/tags // what tags are currently active

	var/datum/catastrophe_stationdata/data = null

	var/desired_length = 90 // typical length of the round
	var/calculate_data_timer
	var/end_time

	var/list/join_event_datums = list()

/datum/catastrophe_director/proc/pre_setup()
	events = list()
	event_pool = list()
	tags = list()
	calculate_data_timer = 10

	// getting all the event types that we can use
	for(var/e in subtypesof(/datum/catastrophe_event))
		var/datum/catastrophe_event/event = new e
		event_pool += event

/datum/catastrophe_director/proc/post_setup()
	end_time = world.time + 10 * 60 * desired_length
	calculate_data()
	start_story()

/datum/catastrophe_director/proc/start_story()
	return

/datum/catastrophe_director/proc/process_story()
	return

//calculates stuff that director uses to manage events
/datum/catastrophe_director/proc/calculate_data()
	var/datum/catastrophe_stationdata/d = new

	var/allhealth = 0
	var/allcount = 0
	for(var/mob/M in player_list)
		if(ishuman(M))
			var/mob/living/carbon/human/H = M
			allcount++
			allhealth += Clamp((H.health + 100) / 200, 0, 1)

	if(allcount <= 0)
		d.aliveness = 1
	else
		d.aliveness = allhealth/allcount

	data = d
	return d

/datum/catastrophe_director/proc/event_ispossible(datum/catastrophe_event/event)
	for(var/tag in event.bad_tags)
		if(tag in tags)
			return FALSE
	for(var/tag in event.required_tags)
		if(!(tag in tags))
			return FALSE

	var/event_requires_time = desired_length * event.event_min_space_required * 60 * 10
	var/time_left = end_time - world.time
	if(event_requires_time > 0 && time_left < event_requires_time)
		return FALSE

	return TRUE

// creates and runs a new event based on the required type
/datum/catastrophe_director/proc/generate_event(event_type)
	message_admins("Attempt to generate event with [event_type] type!")

	var/list/possible = list()
	for(var/datum/catastrophe_event/event in event_pool)
		if(event_ispossible(event) && event.event_type == event_type)
			possible[event] = event.weight

	if(!possible.len)
		return

	var/datum/catastrophe_event/event = pickweight(possible)
	if(!event)
		return
	tags |= event.adds_tags
	events += event
	event_pool -= event

	event.director = src
	event.start()

/datum/catastrophe_director/proc/process_director()
	for(var/datum/catastrophe_event/event in events)
		event.process_event()

		if(event.done)
			event.director = null
			events -= event
			if(event.removes_tags)
				tags -= event.removes_tags
			else
				tags -= event.adds_tags

			if(!event.one_time_event)
				event_pool += new event.type

	calculate_data_timer -= 1
	if(calculate_data_timer <= 0)
		calculate_data_timer = 10
		calculate_data()

	process_story()

/datum/catastrophe_director/proc/start_ghost_join_event(title, list/options, datum/callback/cb)
	join_event_datums += new /datum/catastrophe_join_event(title, options, cb)