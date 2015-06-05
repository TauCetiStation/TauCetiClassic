/datum/controller/process/machinery/setup()
	name = "machinery"
	schedule_interval = 20 // every 2 seconds

/datum/controller/process/machinery/doWork()
	//#ifdef PROFILE_MACHINES
	//machine_profiling.len = 0
	//#endif
	process_machines_process()
	process_machines_power()
	process_machines_rebuild()

/datum/controller/process/machinery/proc/process_machines_process()
	var/i = 1
	while(i<=machines.len)
		#ifdef PROFILE_MACHINES
		var/time_start = world.timeofday
		#endif

		var/obj/machinery/Machine = machines[i]
		if(Machine && !Machine.gc_destroyed)
			if(Machine.process() != PROCESS_KILL)
				if(Machine)
					i++
					continue
		machines.Cut(i,i+1)

		#ifdef PROFILE_MACHINES
		var/time_end = world.timeofday

		if(!(Machine.type in machine_profiling))
			machine_profiling[Machine.type] = 0

		machine_profiling[Machine.type] += (time_end - time_start)
		#endif

		scheck()

/datum/controller/process/machinery/proc/process_machines_power()
	var/i=1
	while(i<=active_areas.len)

		var/area/A = active_areas[i]
		if(A.powerupdate && A.master == A)
			A.powerupdate -= 1
			for(var/area/SubArea in A.related)
				for(var/obj/machinery/M in SubArea)
					if(M)
						if(M.use_power)
							M.auto_use_power()

		if(A.apc.len && A.master == A)
			i++
			continue

		A.powerupdate = 0
		active_areas.Cut(i,i+1)

		scheck()

/datum/controller/process/machinery/proc/process_machines_rebuild()
	controller_iteration++
	if(controller_iteration % 150 == 0)	//Every 300 seconds we retest every area/machine
		for(var/area/A in all_areas)
			if(A == A.master)
				A.powerupdate += 1
				active_areas |= A

		scheck()


/datum/controller/process/machinery/getStatName()
	return ..()+"([machines.len])"
