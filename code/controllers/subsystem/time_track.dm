SUBSYSTEM_DEF(time_track)
	name = "Time Tracking"
	wait = 100
	init_order = -8
	flags = SS_NO_INIT|SS_NO_TICK_CHECK

	var/time_dilation_current = 0

	var/time_dilation_avg_fast = 0
	var/time_dilation_avg = 0
	var/time_dilation_avg_slow = 0

	var/first_run = TRUE

	var/last_tick_realtime = 0
	var/last_tick_byond_time = 0
	var/last_tick_tickcount = 0

/datum/controller/subsystem/time_track/Initialize(start_timeofday)
	. = ..()
	global.perf_log = file("[global.log_debug_directory]/perf-[global.round_id ? global.round_id : "NULL"]-[SSmapping.config?.map_name].csv")
	log_perf(
		list(
			"time",
			"players",
			"tidi",
			"tidi_fastavg",
			"tidi_avg",
			"tidi_slowavg",
			"maptick",
			"num_timers",
			"air_turf_cost",
			"air_eg_cost",
			"air_hotspots_cost",
			"air_pipenets_cost",
			"air_turf_count",
			"air_eg_count",
			"air_hotspot_count",
			"air_network_count",
		)
	)

/datum/controller/subsystem/time_track/fire()

	var/current_realtime = REALTIMEOFDAY
	var/current_byondtime = world.time
	var/current_tickcount = world.time/world.tick_lag

	if (!first_run)
		var/tick_drift = max(0, (((current_realtime - last_tick_realtime) - (current_byondtime - last_tick_byond_time)) / world.tick_lag))

		time_dilation_current = tick_drift / (current_tickcount - last_tick_tickcount) * 100

		time_dilation_avg_fast = MC_AVERAGE_FAST(time_dilation_avg_fast, time_dilation_current)
		time_dilation_avg = MC_AVERAGE(time_dilation_avg, time_dilation_avg_fast)
		time_dilation_avg_slow = MC_AVERAGE_SLOW(time_dilation_avg_slow, time_dilation_avg)
		global.glide_size_multiplier = (current_byondtime - last_tick_byond_time) / (current_realtime - last_tick_realtime)
	else
		first_run = FALSE
	last_tick_realtime = current_realtime
	last_tick_byond_time = current_byondtime
	last_tick_tickcount = current_tickcount
	log_perf(
		list(
			world.time,
			length(global.clients),
			time_dilation_current,
			time_dilation_avg_fast,
			time_dilation_avg,
			time_dilation_avg_slow,
			MAPTICK_LAST_INTERNAL_TICK_USAGE,
			length(SStimer.timer_id_dict),
			SSair.cost_tiles_curr,
			SSair.cost_edges,
			SSair.cost_hotspots,
			SSair.cost_pipenets,
			length(SSair.active_fire_zones),
			length(SSair.active_edges),
			length(SSair.active_hotspots),
			length(SSair.networks),
		)
	)
