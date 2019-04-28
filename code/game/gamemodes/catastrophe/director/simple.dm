//this director is trying to help the crew if they are hurt
/datum/catastrophe_director/simple
	name = "Simple director"

	desired_length = 50 // set to 10 or something for quick rounds
	var/harm_events_count = 3 // spawns 3 bad events at the start and thats it

	var/next_harm_event
	var/help_event_timer
	var/neutral_event_timer

	var/evacuation = FALSE

/datum/catastrophe_director/simple/start_story()
	next_harm_event = world.time + 10 * 60 * (desired_length / 9) // ~10 mins of emptyness (if using desired_length value of 90)
	help_event_timer = desired_length * 60 / 2 // so we get 1-2 good events maximum if everything is good
	neutral_event_timer = rand(desired_length * 60 / 9, desired_length * 60 / 2) // from 10 to 45 minutes

/datum/catastrophe_director/simple/process_story()
	..()

	if(world.time >= next_harm_event && harm_events_count > 0)
		next_harm_event = world.time + 10 * 60 * (desired_length / 9) // then we spawn one bad event every 10 mins
		generate_event("harmful")
		harm_events_count -= 1

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