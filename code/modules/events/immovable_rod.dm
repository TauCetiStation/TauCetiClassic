/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/event/immovable_rod
	announceWhen = 5

/datum/event/immovable_rod/announce()
	command_alert("What the fuck was that?!", "General Alert")

/datum/event/immovable_rod/start()
	var/startside = pick(cardinal)
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/turf/startT = spaceDebrisStartLoc(startside, z)
	var/turf/endT = spaceDebrisFinishLoc(startside, z)
	//rod time!
	new /obj/effect/immovable_rod(startT, endT)

/obj/effect/immovable_rod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1
	var/z_original = 0
	var/destination
	var/notify = TRUE
	var/bumped = FALSE

/obj/effect/immovable_rod/atom_init(mapload, turf/end)
	. = ..()
	if(notify)
		message_admins("[src] has spawned at [src.x],[src.y],[src.z] [ADMIN_JMP(src)] [ADMIN_FLW(src)].")
	poi_list += src
	z_original = z
	destination = end
	if(end && end.z == z_original)
		walk_towards(src, destination, 1)

/obj/effect/immovable_rod/Moved()
	if(z != z_original || loc == destination)
		qdel(src)
	return ..()

/obj/effect/immovable_rod/Destroy()
	poi_list -= src
	walk(src,0) //this cancels the walk_towards() proc
	return ..()

/obj/effect/immovable_rod/Bump(atom/clong)
	if(!bumped)
		bumped = TRUE
		var/turf/T = get_turf(clong)
		var/area/T_area = get_area(T)
		message_admins("<span class='warning'>[src] hit [clong] in [T_area] [ADMIN_JMP(T)] [ADMIN_FLW(src)].</span>")

	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
		audible_message("<span class='danger'>CLANG</span>", "You feel vibrations")

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if((istype(clong, /turf/simulated) || isobj(clong)) && clong.density)
		clong.ex_act(2)

	if(istype(clong, /turf/simulated/shuttle) || clong == src) //Skip shuttles without actually deleting the rod
		return

	else if(ismob(clong))
		if(ishuman(clong))
			var/mob/living/carbon/human/H = clong
			H.visible_message("<span class='danger'>[H.name] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
			H.adjustBruteLoss(160)
		if(clong.density || prob(10))
			clong.ex_act(2)
	else if(istype(clong, type))
		var/obj/effect/immovablerod/other = clong
		visible_message("<span class='danger'>[src] collides with [other]!</span>")
		var/datum/effect/effect/system/smoke_spread/smoke = new
		smoke.set_up(2, get_turf(src))
		smoke.start()
		qdel(src)
		qdel(other)

/obj/effect/immovable_rod/ex_act(severity, target)
	return 0

/obj/effect/immovablerod/singularity_act()
	return

/obj/effect/immovablerod/singularity_pull()
	return
