var/datum/subsystem/mapping/SSmapping

/datum/subsystem/mapping
	name = "Mapping"

	init_order = SS_INIT_MAPPING

	flags = SS_NO_FIRE

	var/const/max_secret_rooms = 3

/datum/subsystem/mapping/New()
	NEW_SS_GLOBAL(SSmapping)

/datum/subsystem/mapping/Initialize(timeofday)

	// Generate mining.
	make_mining_asteroid_secrets()
	populate_distribution_map()
	populate_junkyard()
	// Load templates
	preloadTemplates()
	..()

/datum/subsystem/mapping/proc/make_mining_asteroid_secrets()
	for(var/i in 1 to max_secret_rooms)
		make_mining_asteroid_secret()

/datum/subsystem/mapping/proc/populate_distribution_map()
	var/datum/ore_distribution/distro = new
	distro.populate_distribution_map()

/datum/subsystem/mapping/proc/populate_junkyard()
	var/list/turfs_to_init = block(locate(1, 1, 1), locate(world.maxx, world.maxy, world.maxz))
	/turf/simulated/mineral/airfull/junkyard
	for(var/thing in turfs_to_init)
		var/turf/T = thing
		if(istype(T, /turf/simulated/mineral/airfull/junkyard))
			T.surround_by_scrap()
		if(istype(T, /turf/simulated/floor/plating/ironsand/junkyard))
			T.surround_by_scrap()
		CHECK_TICK


/datum/subsystem/mapping/Recover()
	flags |= SS_NO_INIT