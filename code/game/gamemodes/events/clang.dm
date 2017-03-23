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
	var/z_original = 0
	var/turf/destination

/obj/effect/immovablerod/New(atom/start, atom/end)
	..()
	z_original = z
	destination = get_turf(end)
	if(end && end.z==z_original)
		walk_towards(src, destination, 1)
	QDEL_IN(src,20)

/obj/effect/immovablerod/Bump(atom/clong)
	if(istype(clong, /turf/simulated/shuttle)) //Skip shuttles without actually deleting the rod
		return
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	visible_message("<span class='danger'>CLANG</span>")
	if((istype(clong, /turf/simulated) || isobj(clong)) && clong.density)
		clong.ex_act(2)
	else if(ismob(clong))
		var/mob/living/M = clong
		M.adjustBruteLoss(rand(10,40))
	if(clong && prob(50))
		x = clong.x
		y = clong.y

/obj/effect/immovablerod/ex_act(severity, target)
	return 0

/proc/immovablerod()
	var/startx = 0
	var/starty = 0
	var/endy = 0
	var/endx = 0
	var/startside = pick(cardinal)

	switch(startside)
		if(NORTH)
			starty = 187
			startx = rand(41, 199)
			endy = 38
			endx = rand(41, 199)
		if(EAST)
			starty = rand(38, 187)
			startx = 199
			endy = rand(38, 187)
			endx = 41
		if(SOUTH)
			starty = 38
			startx = rand(41, 199)
			endy = 187
			endx = rand(41, 199)
		if(WEST)
			starty = rand(38, 187)
			startx = 41
			endy = rand(38, 187)
			endx = 199

	//rod time!
	var/obj/effect/immovablerod/immrod = new /obj/effect/immovablerod(locate(startx, starty, 1))
//	world << "Rod in play, starting at [start.loc.x],[start.loc.y] and going to [end.loc.x],[end.loc.y]"
	var/end = locate(endx, endy, 1)
	spawn(0)
		walk_towards(immrod, end,1)
	sleep(1)
	while (immrod)
		if (immrod.z != ZLEVEL_STATION)
			immrod.z = ZLEVEL_STATION
		if(immrod.loc == end)
			qdel(immrod)
		sleep(10)
	for(var/obj/effect/immovablerod/imm in world)
		return
	sleep(50)
	command_alert("What the fuck was that?!", "General Alert")
