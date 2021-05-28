/datum/event_meta
	var/name        = ""
	var/enabled     = 1 // Whether or not the event is available for random selection at all
	var/weight      = 0 // The base weight of this event. A zero means it may never fire, but see get_weight()
	var/min_weight  = 0 // The minimum weight that this event will have. Only used if non-zero.
	var/max_weight  = 0 // The maximum weight that this event will have. Only use if non-zero.
	var/severity    = 0 // The current severity of this event
	var/one_shot    = 0 //If true, then the event will not be re-added to the list of available events
	var/list/role_weights = list()
	var/datum/event/event_type
	var/min_players = 0

/datum/event_meta/New(event_severity, event_name, datum/event/type, event_weight, list/job_weights, is_one_shot = 0, event_enabled = 1, min_event_players = 0, min_event_weight = 0, max_event_weight = 0)
	name = event_name
	severity = event_severity
	event_type = type
	one_shot = is_one_shot
	weight = event_weight
	min_weight = min_event_weight
	max_weight = max_event_weight
	if(job_weights)
		role_weights = job_weights
	min_players = min_event_players
	enabled = event_enabled

/datum/event_meta/proc/get_weight(list/active_with_role)
	if(!enabled)
		return 0
	if(player_list.len < min_players)
		return 0

	var/job_weight = 0
	for(var/role in role_weights)
		if(role in active_with_role)
			job_weight += active_with_role[role] * role_weights[role]

	var/total_weight = weight + job_weight

	// Only min/max the weight if the values are non-zero
	if(min_weight && total_weight < min_weight) total_weight = min_weight
	if(max_weight && total_weight > max_weight) total_weight = max_weight

	return total_weight

/datum/event_meta/alien/get_weight(list/active_with_role)
	if(aliens_allowed)
		return ..(active_with_role)
	return 0

/datum/event_meta/ninja/get_weight(list/active_with_role)
	if(toggle_space_ninja)
		return ..(active_with_role)
	return 0

/datum/event	//NOTE: Times are measured in master controller ticks!
	var/processing = TRUE
	var/datum/event_meta/event_meta = null

	var/startWhen		= 0	//When in the lifetime to call start().
	var/announceWhen	= 0	//When in the lifetime to call announce().
	var/endWhen			= 0	//When in the lifetime the event should end.

	var/severity		= 0 //Severity. Lower means less severe, higher means more severe. Does not have to be supported. Is set on New().
	var/activeFor		= 0	//How long the event has existed. You don't need to change this.
	var/isRunning		= FALSE //If this event is currently running. You should not change this. //its used for RoundEnd report
	var/startedAt		= 0 //When this event started.
	var/endedAt			= 0 //When this event ended.
	var/noAutoEnd       = 0 //Does the event end automatically after endWhen passes?

	var/datum/announcement/announcement
	var/datum/announcement/announcement_end

/datum/event/nothing

//Called first before processing.
//Allows you to setup your event, such as randomly
//setting the startWhen and or announceWhen variables.
//Only called once.
/datum/event/proc/setup()
	return

//Called when the tick is equal to the startWhen variable.
//Allows you to start before announcing or vice versa.
//Only called once.
/datum/event/proc/start()
	return

//Called when the tick is equal to the announceWhen variable.
//Allows you to announce before starting or vice versa.
//Only called once.
/datum/event/proc/announce()
	if(announcement)
		announcement.play()

//Called on or after the tick counter is equal to startWhen.
//You can include code related to your event or add your own
//time stamped events.
//Called more than once.
/datum/event/proc/tick()
	return

//Called on or after the tick is equal or more than endWhen
//You can include code related to the event ending.
//Do not place spawn() in here, instead use tick() to check for
//the activeFor variable.
//For example: if(activeFor == myOwnVariable + 30) doStuff()
//Only called once.
/datum/event/proc/end()
	if(announcement_end)
		announcement_end.play()

//Returns the latest point of event processing.
/datum/event/proc/lastProcessAt()
	return max(startWhen, max(announceWhen, endWhen))

//Do not override this proc, instead use the appropiate procs.
//This proc will handle the calls to the appropiate procs.
/datum/event/process()
	if(!processing)
		return

	if(activeFor == startWhen)
		isRunning = TRUE
		processing = FALSE
		start()
		processing = TRUE

	if(activeFor == announceWhen)
		processing = FALSE
		announce()
		processing = TRUE

	if(activeFor > startWhen && activeFor < endWhen || noAutoEnd)
		processing = FALSE
		tick()
		processing = TRUE

	if(activeFor == endWhen && !noAutoEnd)
		processing = FALSE
		isRunning = FALSE
		end()
		processing = TRUE

	// Everything is done, let's clean up.
	if(activeFor >= lastProcessAt() && !noAutoEnd)
		processing = FALSE
		kill()

	activeFor++

//Called when click "Stop" in Even Manager Panel
//Called when start(), announce() and end() has all been called.
/datum/event/proc/kill()
	// If this event was forcefully killed run end() for individual cleanup
	if(isRunning)
		isRunning = FALSE
		end()

	endedAt = world.time
	SSevents.active_events -= src
	SSevents.event_complete(src)

//Sets up the event then adds the event to the the list of active events
/datum/event/New(datum/event_meta/EM)
	if(!EM)
		EM = new /datum/event_meta(EVENT_LEVEL_MAJOR, "Unknown, Most likely admin called", src.type)

	event_meta = EM
	severity = event_meta.severity
	severity = clamp(severity, EVENT_LEVEL_ROUNDSTART, EVENT_LEVEL_MAJOR)

	startedAt = world.time

	setup()
	SSevents.active_events += src
	..()
