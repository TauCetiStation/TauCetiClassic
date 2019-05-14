//this director is trying to help the crew if they are hurt
/datum/catastrophe_director/simple
	name = "Simple director"

	desired_length = 70 // set to 10 or something for quick rounds
	var/harm_events_count = 2 // spawns 2 bad events at the start and thats it

	var/next_harm_event
	var/help_event_timer
	var/neutral_event_timer

	var/datum/catastrophe_event/next_harm_event_object

	var/evacuation = FALSE
	var/last_event_progression // when last event progression happened
	var/event_progression_interval = 60 // how much seconds should we wait beetwen event progressions, so we dont accidentally spam with announces

/datum/catastrophe_director/simple/start_story()
	next_harm_event = world.time + 10 * 60 * (desired_length / 9) // ~10 mins of emptyness (if using desired_length value of 90)
	help_event_timer = desired_length * 60 / 2 // so we get 1-2 good events maximum if everything is good
	neutral_event_timer = rand(desired_length * 60 / 9, desired_length * 60 / 2) // from 10 to 45 minutes

	generate_harm_event()

/datum/catastrophe_director/simple/process_story()
	..()

	if(world.time >= next_harm_event && harm_events_count > 0)
		next_harm_event = world.time + 10 * 60 * (desired_length / 9) // then we spawn one bad event every 10 mins

		if(!next_harm_event_object)
			generate_event("harmful")
		else
			start_event(next_harm_event_object)

		harm_events_count -= 1
		if(harm_events_count > 0)
			generate_harm_event()

	if(prob(50))
		help_event_timer -= 1

	if(data && data.aliveness < 0.9)
		help_event_timer -= 2

	if(data && data.aliveness < 0.8)
		help_event_timer -= 3

	if(data && data.aliveness < 0.5)
		help_event_timer -= 3

	if(help_event_timer <= 0)
		help_event_timer = 200 + data.aliveness * 300 // ~10 minutes
		generate_event("help")

	if(!evacuation && world.time > end_time)
		evacuation = TRUE
		generate_event("evacuation")

	neutral_event_timer -= 1
	if(neutral_event_timer <= 0)
		neutral_event_timer = rand(desired_length * 60 / 6, desired_length * 60 / 2)
		generate_event("neutral")

/datum/catastrophe_director/simple/proc/generate_harm_event()
	next_harm_event_object = generate_event("harmful", start_now = FALSE)

	if(next_harm_event_object)
		var/minutes_until = (next_harm_event - world.time) / 600

		message_admins("Next harm event will start in <a href='?src=\ref[src];change_next_harm_event_time=1'>[round(minutes_until, 1)]</a> minutes and will be \"[next_harm_event_object.name]\" (<a href='?src=\ref[src];change_next_harm_event=1'>CHANGE</a>). <a href='?src=\ref[src];change_next_harm_event_ammount=1'>[harm_events_count]</a> harmful events will spawn")

// prevents announce spam
/datum/catastrophe_director/simple/can_progress_event(datum/catastrophe_event/event)
	if(event.event_type == "evacuation") // Evacuation events ignore this timer so they dont take more time than they should
		return TRUE

	if(world.time > (last_event_progression + event_progression_interval * 10))
		last_event_progression  = world.time
		return TRUE

	return FALSE

/datum/catastrophe_director/simple/Topic(href, href_list)
	. = ..()

	if(!check_rights(0))
		return

	if(href_list["change_next_harm_event"])
		var/list/possible = list()
		for(var/datum/catastrophe_event/event in event_pool)
			if(event_ispossible(event) && event.event_type == "harmful")
				possible += event

		if(!possible.len)
			return

		var/new_event = input("Select next harm event", "Selecting") as null|anything in possible
		if(new_event && (new_event in event_pool))
			next_harm_event_object = new_event
			message_admins("Next harm event was changed to \"[next_harm_event_object.name]\" by [usr.client]")

	if(href_list["change_next_harm_event_time"])
		var/new_event_time = input("Enter when to start next harm event (in minutes)", "Selecting", 8) as null|num

		if(new_event_time > 0)
			message_admins("Next harm event will start in [new_event_time] minutes. Changed by [usr.client]")
			next_harm_event = world.time + new_event_time * 600

	if(href_list["change_next_harm_event_ammount"])
		var/new_event_ammount = input("Enter the ammount of harm events that will spawn", "Selecting", harm_events_count) as num

		if(new_event_ammount >= 0 && new_event_ammount != harm_events_count)
			new_event_ammount = round(new_event_ammount)

			message_admins("[new_event_ammount] harmful events will spawn for the gamemode. Changed by [usr.client]")
			harm_events_count = new_event_ammount