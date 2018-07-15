/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/obj/effect/immovablerod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1

/obj/effect/immovablerod/atom_init(mapload, turf/end)
	. = ..()
	INVOKE_ASYNC(src, .proc/check_location, end)

/obj/effect/immovablerod/proc/check_location(turf/end)
	var/z_original = z
	if(end && end.z == z_original)
		walk_towards(src, end, 1)
	while(!QDELETED(src))
		if(loc == end || z != z_original)
			qdel(src)
			return
		sleep(1)

/obj/effect/immovablerod/Bump(atom/clong)
	if(istype(clong, /turf/simulated/shuttle) || clong == src) //Skip shuttles without actually deleting the rod
		return
	audible_message("CLANG", "You feel vibrations")
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	if((istype(clong, /turf/simulated) || isobj(clong)) && clong.density)
		clong.ex_act(2)
	else if(isliving(clong))
		var/mob/living/M = clong
		M.adjustBruteLoss(rand(10,40))
		if(prob(60))
			step(src, get_dir(src, M))
	else if (istype(clong, /obj))
		if(clong.density)
			clong.ex_act(2)
	else
		qdel(src)
	
/obj/effect/immovablerod/ex_act(severity, target)
	return 0

/obj/effect/immovablerod/Destroy()
	walk(src, 0) // Because we might have called walk_towards, we must stop the walk loop or BYOND keeps an internal reference to us forever.
	return ..()

/proc/immovablerod()
	var/turf/start
	var/turf/end
	var/startside = pick(cardinal)
	switch(startside)
		if(NORTH)
			start = locate(rand(41, 199), 205, 1)
			end = locate(rand(41, 199), 38, 1)
		if(EAST)
			start = locate(199, rand(38, 205), 1)
			end = locate(41, rand(38, 205), 1)
		if(SOUTH)
			start = locate(rand(41, 199), 38, 1)
			end = locate(rand(41, 199), 205, 1)
		if(WEST)
			start = locate(41, rand(38, 205), 1)
			end = locate(199, rand(38, 205), 1)
	//rod time!
	var/obj/effect/immovablerod/Imm = new(start, end)
	message_admins("Immovable Rod has spawned at [Imm.x],[Imm.y],[Imm.z] [ADMIN_JMP(Imm)] [ADMIN_FLW(Imm)].")
	sleep(50)
	command_alert("What the fuck was that?!", "General Alert")
