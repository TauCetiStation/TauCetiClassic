SUBSYSTEM_DEF(orbit)
	name = "Orbit"

	priority = SS_PRIORITY_ORBIT
	wait     = SS_WAIT_ORBIT

	flags = SS_NO_INIT | SS_TICKER

	var/list/currentrun = list()
	var/list/orbits     = list()

/datum/controller/subsystem/orbit/stat_entry()
	..("P:[orbits.len]")


/datum/controller/subsystem/orbit/fire(resumed = 0)
	if (!resumed)
		src.currentrun = orbits.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while (currentrun.len)
		var/datum/orbit/O = currentrun[currentrun.len]
		currentrun.len--
		if (!O)
			orbits -= O
			if (MC_TICK_CHECK)
				return
			continue
		if (!O.orbiter)
			qdel(O)
			if (MC_TICK_CHECK)
				return
			continue
		if (O.lastprocess >= world.time) // We already checked recently
			if (MC_TICK_CHECK)
				return
			continue
		var/targetloc = get_turf(O.orbiting)
		if (targetloc != O.lastloc || O.orbiter.loc != targetloc)
			O.Check(targetloc)
		if (MC_TICK_CHECK)
			return
