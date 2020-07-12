//Meteors probability of spawning during a given wave
//for normal meteor event
var/global/list/obj/effect/meteor/meteors_normal = list(
	/obj/effect/meteor/small = 4,
	/obj/effect/meteor       = 8,
	/obj/effect/meteor/big   = 3
	)
//for threatening meteor event
var/global/list/obj/effect/meteor/meteors_threatening = list(
	/obj/effect/meteor     = 4, 
	/obj/effect/meteor/big = 8,
	)
//for catastrophic meteor event
var/global/list/obj/effect/meteor/meteors_catastrophic = list(
	/obj/effect/meteor     = 1,
	/obj/effect/meteor/big = 4,
	)

///////////////////////////////
//Meteor spawning global procs
///////////////////////////////
/proc/spawn_meteors(number = 10, list/meteortypes)
	for(var/i in 1 to number)
		spawn_meteor(meteortypes)

/proc/spawn_meteor(list/meteortypes)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/max_i = 10 // number of tries to spawn meteor.
	while(!istype(pickedstart, /turf/space))
		var/startSide = pick(cardinal)
		pickedstart = spaceDebrisStartLoc(startSide, z)
		pickedgoal = spaceDebrisFinishLoc(startSide, z)
		max_i--
		if(max_i<=0)
			return
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart)
	M.dest = pickedgoal
	spawn(0)
		walk_towards(M, M.dest, 1)
	return

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy-(TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(EAST)
			starty = rand((TRANSITIONEDGE+1),world.maxy-(TRANSITIONEDGE+1))
			startx = world.maxx-(TRANSITIONEDGE+1)
		if(SOUTH)
			starty = (TRANSITIONEDGE+1)
			startx = rand((TRANSITIONEDGE+1), world.maxx-(TRANSITIONEDGE+1))
		if(WEST)
			starty = rand((TRANSITIONEDGE+1), world.maxy-(TRANSITIONEDGE+1))
			startx = (TRANSITIONEDGE+1)
	var/turf/T = locate(startx, starty, Z)
	return T

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(EAST)
			endy = rand(TRANSITIONEDGE, world.maxy-TRANSITIONEDGE)
			endx = TRANSITIONEDGE
		if(SOUTH)
			endy = world.maxy-TRANSITIONEDGE
			endx = rand(TRANSITIONEDGE, world.maxx-TRANSITIONEDGE)
		if(WEST)
			endy = rand(TRANSITIONEDGE,world.maxy-TRANSITIONEDGE)
			endx = world.maxx-TRANSITIONEDGE
	var/turf/T = locate(endx, endy, Z)
	return T

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "meteor"
	icon = 'icons/obj/meteor.dmi'
	icon_state = "flaming"
	density = TRUE
	anchored = TRUE
	var/hits = 1
	var/dest
	pass_flags = PASSTABLE

/obj/effect/meteor/small
	name = "small meteor"
	icon_state = "smallf"
	pass_flags = PASSTABLE | PASSGRILLE

/obj/effect/meteor/Destroy()
	walk(src,0) // this cancels the walk_towards() proc
	return ..()

/obj/effect/meteor/Bump(atom/A)
	if(A)
		var/turf/T = get_turf(A)
		var/area/T_area = get_area(T)
		message_admins("<span class='warning'>[src] hit [A] in [T_area] [ADMIN_JMP(T)].</span>")
		log_game("[src] hit [A] ([T.x], [T.y], [T.z]) in [T_area].")
		A.meteorhit(src)
		playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)
	if(--src.hits <= 0)

		// Prevent meteors from blowing up the singularity's containment.
		// Changing emitter and generator ex_act would result in them being bomb and C4 proof.
		if(!istype(A,/obj/machinery/power/emitter) && !istype(A,/obj/machinery/field_generator) && prob(15))
			explosion(src.loc, 4, 5, 6, 7, 0)
		qdel(src)
	return


/obj/effect/meteor/ex_act(severity)

	if (severity < 4)
		qdel(src)
	return

/obj/effect/meteor/big
	name = "big meteor"
	hits = 5

/obj/effect/meteor/big/ex_act(severity)
	return

/obj/effect/meteor/big/Bump(atom/A)
	// Prevent meteors from blowing up the singularity's containment.
	// Changing emitter and generator ex_act would result in them being bomb and C4 proof
	if(!istype(A, /obj/machinery/power/emitter) && !istype(A, /obj/machinery/field_generator))
		if(--src.hits <= 0)
			playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)
			qdel(src) // Dont blow up singularity containment if we get stuck there.
			return
	if(A)
		var/turf/F = get_turf(A)
		var/area/T_area = get_area(F)
		message_admins("<span class='warning'>[src] hit [A]  in [T_area] [ADMIN_JMP(F)].</span>")
		log_game("[src] hit [A] ([F.x], [F.y], [F.z]) in [T_area].")
		for(var/mob/M in player_list)
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			shake_camera(M, 3, get_dist(M.loc, src.loc) > 20 ? 1 : 3)
			playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)
		explosion(src.loc, 0, 1, 2, 3, 0)

	if(--src.hits <= 0)
		if(prob(15) && !istype(A, /obj/structure/grille))
			explosion(src.loc, 1, 2, 3, 4, 0)
		qdel(src)
	return

/obj/effect/meteor/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pickaxe))
		qdel(src)
		return
	..()
