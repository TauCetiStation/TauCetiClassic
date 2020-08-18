//Used for all kinds of weather, ex. lavaland ash storms.
SUBSYSTEM_DEF(junkyard)
	name = "Junkyard"
	flags = SS_NO_FIRE
	var/list/junk = list()
	var/junkyard_initialised = 0

/datum/controller/subsystem/junkyard/Initialize(timeofday)
	..()
	load_stats()

/datum/controller/subsystem/junkyard/proc/save_stats()
	var/savefile/S = new /savefile("data/junkyard/stats.sav")
	S["junk"]	<< junk

/datum/controller/subsystem/junkyard/proc/load_stats()
	var/savefile/S = new /savefile("data/junkyard/stats.sav")
	S["junk"] 	>> junk
	if(isnull(junk))
		junk = new/list()

/datum/controller/subsystem/junkyard/proc/populate_junkyard()
	var/zlevel = SSmapping.level_by_trait(ZTRAIT_JUNKYARD)
	if(!zlevel)
		return

	var/list/turfs_to_init = block(locate(1, 1, zlevel), locate(world.maxx, world.maxy, zlevel))
	for(var/thing in turfs_to_init)
		var/turf/T = thing
		if(istype(T, /turf/simulated/mineral/airfull/junkyard))
			T.surround_by_scrap()
		if(istype(T, /turf/simulated/floor/plating/ironsand/junkyard))
			T.surround_by_scrap()
			T.resource_definition()
		CHECK_TICK
	junkyard_initialised = 1
	SSweather.eligible_zlevels.Add(zlevel) //junkyard

/datum/controller/subsystem/junkyard/proc/add_junk_to_stats(junktype)
	if(!junktype)
		return
	if(isnull(junk[junktype]))
		junk[junktype] = 1
	else
		junk[junktype] ++