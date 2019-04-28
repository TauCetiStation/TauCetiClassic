/datum/catastrophe_event
	var/name = "Unknown event"

	var/event_type // help, neutral, harmful, evacuation

	// The whole tags system could be used to filter out events that are impossible under current conditions
	var/list/required_tags = list() // what tags are required for this event to trigger
	var/list/bad_tags = list() // what tags prevent this event from triggering even if requirements are met
	var/list/adds_tags = list() // what tags does this event adds if it triggers
	var/list/removes_tags = null // what tags does this event removes after it ends

	var/done = FALSE
	var/starttime

	var/weight = 100 // how likely that this event will be choosen
	var/steps // how many steps are there
	var/step_variation = 10
	var/event_duration_min = 1 // a value from 0 to 1, these variables define how much remaining round time event will take, for example 1 means event will run until the end
	var/event_duration_max = 1 // a value from 0 to 1
	var/event_min_space_required = 0 // value from 0 to 1 describing how much time until the round end is required, value of 0.5 will require 45 mins minimum to start for example

	var/step = 0
	var/next_step
	var/event_selected_duration

	var/one_time_event = FALSE // Can this event run multiply times?
	var/manual_stop = FALSE // By default stop() is called after last step
	var/datum/catastrophe_director/director

/datum/catastrophe_event/proc/start()
	message_admins( "[name] has started")
	starttime = world.time
	event_selected_duration = event_duration_min + (event_duration_max - event_duration_min) * rand(0, 1000) / 1000

/datum/catastrophe_event/proc/on_step()
	return

/datum/catastrophe_event/proc/process_event()
	if(steps && world.time > next_step)
		step += 1
		if(step >= steps) // just to avoid division by zero
			next_step = world.time + 10 * 60 * 10
		else
			next_step = world.time + (director.end_time - world.time) * event_selected_duration / (steps + 1 - step) + rand(-step_variation, step_variation) * 10
		on_step()

		if(step == steps && !manual_stop)
			stop()

// only use this proc to stop the event
/datum/catastrophe_event/proc/stop()
	if(done)
		return FALSE

	done = TRUE
	message_admins("[name] has ended")
	return TRUE

// just some utility procs
/datum/catastrophe_event/proc/time_passed(t)
	return world.time > (starttime + t)

/datum/catastrophe_event/proc/announce(what, who = "")
	command_alert(what, who)

/datum/catastrophe_event/proc/find_random_floor(area/A, check_mob = FALSE)
	var/list/turfs = get_area_turfs(A)
	if(!turfs.len)
		return null

	var/list/possible = list()
	for(var/turf/simulated/floor/T in turfs)
		if(check_mob && (locate(/mob) in T))
			continue

		possible += T

	if(!possible.len)
		return null

	return pick(possible)