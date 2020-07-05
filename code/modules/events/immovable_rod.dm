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
	var/turf/start
	var/turf/end
	var/startside = pick(cardinal)
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	start = spaceDebrisStartLoc(startside, z)
	end = spaceDebrisFinishLoc(startside, z)
	//rod time!
	var/obj/effect/immovable_rod/Imm = new(start, end)
	message_admins("Immovable Rod has spawned at [Imm.x],[Imm.y],[Imm.z] [ADMIN_JMP(Imm)] [ADMIN_FLW(Imm)].")


/obj/effect/immovable_rod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1

/obj/effect/immovable_rod/atom_init(mapload, turf/end)
	. = ..()
	INVOKE_ASYNC(src, .proc/check_location, end)

/obj/effect/immovable_rod/proc/check_location(turf/end)
	var/z_original = z
	if(end && end.z == z_original)
		walk_towards(src, end, 1)
	while(!QDELETED(src))
		if(loc == end || z != z_original)
			qdel(src)
			return
		sleep(1)

/obj/effect/immovable_rod/Bump(atom/clong)
	if(istype(clong, /turf/simulated/shuttle) || clong == src) //Skip shuttles without actually deleting the rod
		return
	audible_message("<span class='danger'>CLANG</span>", "You feel vibrations")
	playsound(src, 'sound/effects/bang.ogg', VOL_EFFECTS_MASTER)
	if((istype(clong, /turf/simulated) || isobj(clong)) && clong.density)
		clong.ex_act(2)
	else if(isliving(clong))
		var/mob/living/M = clong
		M.adjustBruteLoss(rand(10,40))
		if(prob(60))
			step(src, get_dir(src, M))
	else
		qdel(src)

/obj/effect/immovable_rod/ex_act(severity, target)
	return 0

/obj/effect/immovable_rod/Destroy()
	walk(src, 0) // Because we might have called walk_towards, we must stop the walk loop or BYOND keeps an internal reference to us forever.
	return ..()
