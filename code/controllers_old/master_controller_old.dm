//simplified MC that is designed to fail when procs 'break'. When it fails it's just replaced with a new one.
//It ensures master_controller.process() is never doubled up by killing the MC (hence terminating any of its sleeping procs)
//WIP, needs lots of work still

var/global/datum/controller/game_controller/master_controller //Set in world.New()

var/global/controller_iteration = 0
var/global/last_tick_timeofday = world.timeofday
var/global/last_tick_duration = 0

var/global/air_processing_killed = 0
var/global/pipe_processing_killed = 0

/datum/controller/game_controller
	var/processing = 0
	var/breather_ticks = 2		//a somewhat crude attempt to iron over the 'bumps' caused by high-cpu use by letting the MC have a breather for this many ticks after every loop
	var/minimum_ticks = 20		//The minimum length of time between MC ticks

	var/events_cost		= 0
	var/ticker_cost		= 0
	var/total_cost		= 0
	var/gc_cost			= 0

	var/last_thing_processed
	var/rebuild_active_areas = 0

	var/datum/ore_distribution/asteroid_ore_map // For debugging and VV.


/datum/controller/game_controller/New()
	//There can be only one master_controller. Out with the old and in with the new.
	if(master_controller != src)
		log_debug("Rebuilding Master Controller")
		if(istype(master_controller))
			Recover()
			qdel(master_controller)
		master_controller = src

	if(!job_master)
		job_master = new /datum/controller/occupations()
		job_master.SetupOccupations()
		job_master.LoadJobs("config/jobs.txt")
		world << "\red \b Job setup complete"

	if(!syndicate_code_phrase)		syndicate_code_phrase	= generate_code_phrase()
	if(!syndicate_code_response)	syndicate_code_response	= generate_code_phrase()
	if(!emergency_shuttle)			emergency_shuttle = new /datum/shuttle_controller/emergency_shuttle()

/datum/controller/game_controller/proc/setup()
	if(!ticker)
		ticker = new /datum/controller/gameticker()

	setupfactions()
	setup_economy()
	SetupXenoarch()

	transfer_controller = new

	for(var/i=0, i<max_secret_rooms, i++)
		make_mining_asteroid_secret()

//Create the mining ore distribution map.
	asteroid_ore_map = new /datum/ore_distribution()
	asteroid_ore_map.populate_distribution_map()
	spawn(0)
		if(ticker)
			ticker.pregame()

/datum/controller/game_controller/process()
	processing = 1
	spawn(0)
		//set background = 1
		while(1)	//far more efficient than recursively calling ourself

			var/currenttime = world.timeofday
			last_tick_duration = (currenttime - last_tick_timeofday) / 10
			last_tick_timeofday = currenttime

			if(processing)
				var/timer
				var/start_time = world.timeofday
				controller_iteration++

				vote.process()
				transfer_controller.process()
				process_newscaster()

				//EVENTS
				timer = world.timeofday
				process_events()
				events_cost = (world.timeofday - timer) / 10

				//TICKER
				timer = world.timeofday
				last_thing_processed = ticker.type
				ticker.process()
				ticker_cost = (world.timeofday - timer) / 10

				//TIMING
				total_cost = events_cost + ticker_cost

				var/end_time = world.timeofday
				if(end_time < start_time)
					start_time -= 864000    //deciseconds in a day
				sleep( round(minimum_ticks - (end_time - start_time),1) )
			else
				sleep(10)

/datum/controller/game_controller/proc/process_events()
	last_thing_processed = /datum/event
	var/i = 1
	while(i<=events.len)
		var/datum/event/Event = events[i]
		if(Event)
			Event.process()
			i++
			continue
		events.Cut(i,i+1)
	checkEvent()

/datum/controller/game_controller/proc/Recover()		//Mostly a placeholder for now.
	var/msg = "## DEBUG: [time2text(world.timeofday)] MC restarted. Reports:\n"
	for(var/varname in master_controller.vars)
		switch(varname)
			if("tag","bestF","type","parent_type","vars")	continue
			else
				var/varval = master_controller.vars[varname]
				if(istype(varval,/datum))
					var/datum/D = varval
					msg += "\t [varname] = [D.type]\n"
				else
					msg += "\t [varname] = [varval]\n"
	world.log << msg
