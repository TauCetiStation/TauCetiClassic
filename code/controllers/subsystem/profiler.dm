#define PROFILER_FILENAME "profiler.json"
#define INIT_PROFILE_NAME "init_profiler.json"
#define SENDMAPS_FILENAME "sendmaps.json"

SUBSYSTEM_DEF(profiler)
	name = "Profiler"
	init_order = SS_INIT_PROFILER
	runlevels = RUNLEVELS_DEFAULT | RUNLEVEL_LOBBY
	flags = SS_SHOW_IN_MC_TAB
	wait = 3000
	var/fetch_cost = 0
	var/write_cost = 0
	var/init_logs_dropped = FALSE

/datum/controller/subsystem/profiler/stat_entry(msg)
	msg += "F:[round(fetch_cost,1)]ms"
	msg += "|W:[round(write_cost,1)]ms"
	return ..()

/datum/controller/subsystem/profiler/Initialize()
	if(!config.auto_profile)
		StopProfiling() //Stop the early start profiler
		return

	StartProfiling()

	return ..()

/datum/controller/subsystem/profiler/fire()
	if(!init_logs_dropped) // first fire call in lobby after everything is initialized
		init_logs_dropped = TRUE
		DumpInitData()
		return

	DumpData()

/datum/controller/subsystem/profiler/Shutdown()
	if(config.auto_profile)
		DumpData(allow_yield = FALSE)
		world.Profile(PROFILE_CLEAR, type = "sendmaps")

	return ..()

/datum/controller/subsystem/profiler/proc/StartProfiling()
	info("Byond profiler is enabled.")

	world.Profile(PROFILE_START)
	world.Profile(PROFILE_START, type = "sendmaps")

	can_fire = TRUE

/datum/controller/subsystem/profiler/proc/StopProfiling()
	info("Byond profiler is disabled.")
	world.Profile(PROFILE_STOP)
	world.Profile(PROFILE_STOP, type = "sendmaps")
	can_fire = FALSE

/datum/controller/subsystem/profiler/proc/DumpInitData()
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	CHECK_TICK

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/prof_file = file("[global.log_debug_directory]/[INIT_PROFILE_NAME]")
	if(fexists(prof_file))
		fdel(prof_file)
	WRITE_FILE(prof_file, current_profile_data)
	world.Profile(PROFILE_CLEAR) //Now that we're written this data out, dump it. We don't want it getting mixed up with our current round data

/datum/controller/subsystem/profiler/proc/DumpData(allow_yield = TRUE)
	var/timer = TICK_USAGE_REAL
	var/current_profile_data = world.Profile(PROFILE_REFRESH, format = "json")
	var/current_sendmaps_data = world.Profile(PROFILE_REFRESH, type = "sendmaps", format="json")
	fetch_cost = MC_AVERAGE(fetch_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))
	if(allow_yield)
		CHECK_TICK

	if(!length(current_profile_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, profiling stopped manually before dump.")
	var/prof_file = file("[global.log_debug_directory]/[PROFILER_FILENAME]")
	if(fexists(prof_file))
		fdel(prof_file)
	if(!length(current_sendmaps_data)) //Would be nice to have explicit proc to check this
		stack_trace("Warning, sendmaps profiling stopped manually before dump.")
	var/sendmaps_file = file("[global.log_debug_directory]/[SENDMAPS_FILENAME]")
	if(fexists(sendmaps_file))
		fdel(sendmaps_file)

	timer = TICK_USAGE_REAL
	WRITE_FILE(prof_file, current_profile_data)
	WRITE_FILE(sendmaps_file, current_sendmaps_data)
	write_cost = MC_AVERAGE(write_cost, TICK_DELTA_TO_MS(TICK_USAGE_REAL - timer))

#undef PROFILER_FILENAME
#undef INIT_PROFILE_NAME
#undef SENDMAPS_FILENAME
