var/global/list/all_wormholes = list()// So we can pick wormholes to teleport to

/datum/event/wormholes
	announceWhen = 10
	endWhen      = 60

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 400

/datum/event/wormholes/setup()
	announceWhen = rand(0, 20)
	endWhen = rand(40, 80)

/datum/event/wormholes/announce()
	if(pick_turfs.len)
		command_alert("Space-time anomalies detected on the station. It is recommended to avoid suspicious things or phenomena. There is no additional data.", "Anomaly Alert", "wormholes")

/datum/event/wormholes/start()
	for(var/Z in SSmapping.levels_by_trait(ZTRAIT_STATION))
		for(var/turf/simulated/floor/T in block(locate(1, 1, Z), locate(world.maxx, world.maxy, Z)))
			pick_turfs += T

	for(var/i in 1 to number_of_wormholes)
		var/turf/T = pick(pick_turfs)
		wormholes += new /obj/effect/portal/wormhole(T, null, null, -1)

/datum/event/wormholes/tick()
	if(activeFor % shift_frequency == 0)
		for(var/obj/effect/portal/wormhole/O in wormholes)
			var/turf/T = pick(pick_turfs)
			if(T)
				O.loc = T

/datum/event/wormholes/end()
	QDEL_LIST(wormholes)
	wormholes.Cut()

/obj/effect/portal/wormhole
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	failchance = 0

/obj/effect/portal/wormhole/atom_init(mapload, turf/target, creator = null, lifespan = 0)
	. = ..()
	all_wormholes += src

/obj/effect/portal/wormhole/Destroy()
	. = ..()
	all_wormholes -= src

/obj/effect/portal/wormhole/can_teleport(atom/movable/M)
	. = ..()
	if(istype(M, /obj/singularity))
		return FALSE

/obj/effect/portal/wormhole/teleport(atom/movable/M)
	if(!can_teleport(M))
		return FALSE

	if(all_wormholes.len)
		var/obj/effect/portal/wormhole/P = pick(all_wormholes)
		if(P && isturf(P.loc))
			target = P.loc
	if(!target)
		return FALSE
	
	if(!do_teleport(M, target, 1, TRUE)) ///You will appear adjacent to the beacon
		return FALSE
	
	return TRUE
