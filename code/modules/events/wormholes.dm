/datum/event/wormholes
	announceWhen = 10
	endWhen      = 120

	var/list/pick_turfs = list()

/datum/event/wormholes/announce()
	if(pick_turfs.len)
		command_alert("Space-time anomalies detected on the station. It is recommended to avoid suspicious things or phenomena. There is no additional data.", "Anomaly Alert", "wormholes")

/datum/event/wormholes/start()
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/simulated/floor/T in block(locate(1, 1, Z), locate(world.maxx, world.maxy, Z)))
			pick_turfs += T

/datum/event/wormholes/tick()
	if(!pick_turfs.len)
		return

	//get our enter and exit locations
	var/turf/simulated/floor/enter = pick(pick_turfs)
	pick_turfs -= enter //remove it from pickable turfs list
	if(!enter || !istype(enter)) //sanity
		return

	var/turf/simulated/floor/exit = pick(pick_turfs)
	pick_turfs -= exit
	if(!exit || !istype(exit)) //sanity
		return

	new/obj/effect/portal/wormhole(enter, exit, null, rand(300, 600))

/obj/effect/portal/wormhole
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	failchance = 0
