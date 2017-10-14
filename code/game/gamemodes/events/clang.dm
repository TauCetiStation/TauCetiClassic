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

/obj/effect/immovablerod/atom_init(mapload, turf/start, turf/end)
	. = ..()
	INVOKE_ASYNC(src, .proc/check_location, start, end)

/obj/effect/immovablerod/proc/check_location(turf/start, turf/end)
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
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	visible_message("<span class='danger'>CLANG</span>")
	if((istype(clong, /turf/simulated) || isobj(clong)) && clong.density)
		clong.ex_act(2)
	else if(isliving(clong))
		var/mob/living/M = clong
		M.adjustBruteLoss(rand(10,40))
		if(prob(60))
			step(src, get_dir(src, M))

/obj/effect/immovablerod/ex_act(severity, target)
	return 0

/proc/immovablerod()
	var/turf/start
	var/turf/end
	var/startside = pick(cardinal)
	switch(startside)
		if(NORTH)
			start = locate(rand(41, 199), 187, 1)
			end = locate(rand(41, 199), 38, 1)
		if(EAST)
			start = locate(199, rand(38, 187), 1)
			end = locate(41, rand(38, 187), 1)
		if(SOUTH)
			start = locate(rand(41, 199), 38, 1)
			end = locate(rand(41, 199), 187, 1)
		if(WEST)
			start = locate(41, rand(38, 187), 1)
			end = locate(199, rand(38, 187), 1)
	//rod time!
	var/obj/effect/immovablerod/Imm = new(start, end)
	message_admins("Immovable Rod has spawned at [Imm.x],[Imm.y],[Imm.z] [ADMIN_JMP(Imm)] [ADMIN_FLW(Imm)].")
	sleep(50)
	command_alert("What the fuck was that?!", "General Alert")
