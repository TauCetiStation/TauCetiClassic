var/datum/subsystem/events/SSevent

var/list/allEvents = subtypesof(/datum/event)
var/list/potentialRandomEvents = subtypesof(/datum/event)

/datum/subsystem/events
	name = "Events"
	priority = 6

	var/list/control = list()	//list of all datum/round_event_control. Used for selecting events based on weight and occurrences.
	var/list/running = list()	//list of all existing /datum/round_event
	var/list/currentrun = list()

	var/eventTimeLower = 12000	//20 minutes
	var/eventTimeUpper = 24000	//40 minutes
	var/scheduledEvent = null


/datum/subsystem/events/New()
	NEW_SS_GLOBAL(SSevent)

/datum/subsystem/events/fire(resumed = 0)
	if(!resumed)
		checkEvent() //only check these if we aren't resuming a paused fire
		src.currentrun = running.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[1]
		currentrun.Cut(1, 2)
		if(thing)
			thing.process()
		else
			running.Remove(thing)
		if (MC_TICK_CHECK)
			return

//checks if we should select a random event yet, and reschedules if necessary
/datum/subsystem/events/proc/checkEvent()
	if(!scheduledEvent)
		//more players = more time between events, less players = less time between events
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
			if(36 to 100000)
				playercount_modifier = 0.8
		var/next_event_delay = rand(eventTimeLower, eventTimeUpper) * playercount_modifier
		scheduledEvent = world.timeofday + next_event_delay
		log_debug("Next event in [next_event_delay/600] minutes.")

	else if(world.timeofday > scheduledEvent)
		spawn_dynamic_event()

		scheduledEvent = null
		checkEvent()

//allows a client to trigger an event
//aka Badmin Central
/client/proc/forceEvent(type in allEvents)
	set name = "Trigger Event"
	set category = "Fun"

	if(!holder ||!check_rights(R_FUN))
		return

	if(ispath(type))
		new type
		message_admins("[key_name_admin(usr)] has triggered an event. ([type])", 1)
