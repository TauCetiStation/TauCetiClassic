//*************-Pad-*************//

/obj/machinery/abductor/pad
	name = "alien telepad"
	desc = "Use this to transport to and from human habitat."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "alien-pad-idle"
	anchored = TRUE
	var/obj/machinery/abductor/console/console
	var/area/teleport_target
	var/turf/precise_teleport_target
	var/target_name

/obj/machinery/abductor/proc/TeleportToArea(mob/living/target, area/thearea)
	var/list/L = list()
	if(!thearea)
		return
	for(var/turf/T in get_area_turfs(thearea.type))
		if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
			continue
		if(!T.density)
			var/clear = 1
			for(var/obj/O in T)
				if(O.density)
					clear = 0
					break
			if(clear)
				L += T
	if(!L.len)
		return

	if(target && target.buckled)
		target.buckled.unbuckle_mob()

	var/list/tempL = L
	var/attempt = null
	var/success = 0
	while(tempL.len)
		attempt = pick(tempL)
		target.forceMove(attempt)
		if(get_turf(target) == attempt)
			success = 1
			break
		else
			tempL -= attempt
	if(!success)
		target.forceMove(pick(L))

/obj/machinery/abductor/pad/proc/Warp(mob/living/target)
	if(target)

		//prevent from teleporting victim though the grab on neck
		for(var/obj/item/weapon/grab/G in target.GetGrabs())
			if(G.state >= GRAB_PASSIVE)
				qdel(G)
		target.forceMove(loc)

/obj/machinery/abductor/pad/proc/Send()
	flick("alien-pad", src)
	for(var/mob/living/target in loc)
		TeleportToArea(target, teleport_target)
		spawn(0)
			anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)

/obj/machinery/abductor/pad/proc/Retrieve(mob/living/target)
	if(!target)
		return
	var/turf/T = get_turf(target)
	if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
		visible_message("<span class='warning'>WARNING! Bluespace interference has been detected in the location, preventing teleportation! Teleportation is canceled!</span>")
		return FALSE
	flick("alien-pad", src)
	spawn(0)
		anim(target.loc,target,'icons/mob/mob.dmi',,"uncloak",,target.dir)
	Warp(target)

/obj/machinery/abductor/pad/proc/MobToLoc(atom/movable/place, mob/living/target)
	var/turf/T = get_turf(place)
	if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
		visible_message("<span class='warning'>WARNING! Bluespace interference has been detected in the location, preventing teleportation! Teleportation is canceled!</span>")
		return FALSE
	new /obj/effect/temp_visual/teleport_abductor(place)
	addtimer(CALLBACK(src, PROC_REF(doMobToLoc), place, target), 80)

/obj/machinery/abductor/pad/proc/doMobToLoc(place, atom/movable/target)
	flick("alien-pad", src)
	target.forceMove(place)
	new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)

/obj/machinery/abductor/pad/proc/PadToLoc(atom/movable/place)
	var/turf/T = get_turf(place)
	if(SEND_SIGNAL(T, COMSIG_ATOM_INTERCEPT_TELEPORT))
		visible_message("<span class='warning'>WARNING! Bluespace interference has been detected in the location, preventing teleportation! Teleportation is canceled!</span>")
		return FALSE
	new /obj/effect/temp_visual/teleport_abductor(place)
	addtimer(CALLBACK(src, PROC_REF(doPadToLoc), place), 80)

/obj/machinery/abductor/pad/proc/doPadToLoc(place)
	flick("alien-pad", src)
	for(var/mob/living/target in get_turf(src))
		target.forceMove(place)
		new /obj/effect/temp_visual/dir_setting/ninja(get_turf(target), target.dir)

/obj/effect/temp_visual/teleport_abductor
	name = "Huh"
	icon = 'icons/obj/abductor.dmi'
	icon_state = "teleport"
	duration = 80

/obj/effect/temp_visual/teleport_abductor/atom_init()
	. = ..()
	var/datum/effect/effect/system/spark_spread/S = new
	S.set_up(10,0,loc)
	S.start()
