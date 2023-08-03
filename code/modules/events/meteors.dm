#define MAP_EDGE_PAD 5

// Meteors probability of spawning during a given wave
// for normal meteor event
var/global/list/obj/effect/meteor/meteors_normal = list(
	/obj/effect/meteor/dust = 25,
	/obj/effect/meteor/medium = 65,
	/obj/effect/meteor/big   = 10
	)
// for threatening meteor event
var/global/list/obj/effect/meteor/meteors_threatening = list(
	/obj/effect/meteor/medium = 4,
	/obj/effect/meteor/big = 8,
	)
// for catastrophic meteor event
var/global/list/obj/effect/meteor/meteors_catastrophic = list(
	/obj/effect/meteor/medium = 1,
	/obj/effect/meteor/big = 4,
	)
// for space dust event
var/global/list/obj/effect/meteor/meteors_dust = list(
	/obj/effect/meteor/dust = 1
	)


//cael - two events here

//meteor storms are much heavier
/datum/event/meteor_wave
	startWhen		= 6
	endWhen			= 33
	announcement = new /datum/announcement/centcomm/meteor_wave
	announcement_end = new /datum/announcement/centcomm/meteor_wave_passed

/datum/event/meteor_wave/setup()
	endWhen = rand(10,25) * 3

/datum/event/meteor_wave/tick()
	if(IS_MULTIPLE(activeFor, 3))
		spawn_meteors(rand(2,5), get_meteors())

//
/datum/event/meteor_shower
	startWhen		= 5
	endWhen 		= 7
	announcement = new /datum/announcement/centcomm/meteor_shower
	announcement_end = new /datum/announcement/centcomm/meteor_shower_passed
	var/next_meteor = 6
	var/waves = 1

/datum/event/meteor_shower/setup()
	waves = rand(1,4)

//meteor showers are lighter and more common,
/datum/event/meteor_shower/tick()
	if(activeFor >= next_meteor)
		spawn_meteors(rand(1,4), get_meteors())
		next_meteor += rand(20,100)
		waves--
		if(waves <= 0)
			endWhen = activeFor + 1
		else
			endWhen = next_meteor + 1

/datum/event/proc/get_meteors()
	if(severity == EVENT_LEVEL_MAJOR)
		return meteors_catastrophic
	else
		if(prob(50))
			return meteors_threatening
		return meteors_normal

///////////////////////////////
//Meteor spawning global procs
///////////////////////////////
/proc/get_random_station_turf()
	var/area/A = get_area_by_type(pick(global.the_station_areas))
	var/list/turfs = get_area_turfs(A)
	if(turfs.len)
		return pick(turfs)

/proc/spawn_meteors(number = 10, list/meteortypes = meteors_normal)
	for(var/i in 1 to number)
		spawn_meteor(meteortypes)

/proc/spawn_meteor(list/meteortypes)
	var/turf/pickedstart
	var/turf/pickedgoal
	var/z = pick(SSmapping.levels_by_trait(ZTRAIT_STATION))
	var/max_i = 10 // number of tries to spawn meteor.
	while(!isenvironmentturf(pickedstart))
		var/startSide = pick(cardinal)
		pickedstart = spaceDebrisStartLoc(startSide, z)
		pickedgoal = spaceDebrisFinishLoc(startSide, z)
		max_i--
		if(max_i <= 0)
			return
	var/Me = pickweight(meteortypes)
	var/obj/effect/meteor/M = new Me(pickedstart)
	M.dest = pickedgoal
	//message_admins("[M] has spawned at [COORD(M)] [ADMIN_JMP(M)] [ADMIN_FLW(M)].")
	spawn(0)
		walk_towards(M, M.dest, 1)
	return

/proc/spaceDebrisStartLoc(startSide, Z)
	var/starty
	var/startx
	switch(startSide)
		if(NORTH)
			starty = world.maxy - (TRANSITIONEDGE + MAP_EDGE_PAD)
			startx = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxx - (TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			starty = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxy - (TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = world.maxx - (TRANSITIONEDGE + MAP_EDGE_PAD)
		if(SOUTH)
			starty = TRANSITIONEDGE + MAP_EDGE_PAD
			startx = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxx - (TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			starty = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxy - (TRANSITIONEDGE + MAP_EDGE_PAD))
			startx = TRANSITIONEDGE + MAP_EDGE_PAD
	return locate(startx, starty, Z)

/proc/spaceDebrisFinishLoc(startSide, Z)
	var/endy
	var/endx
	switch(startSide)
		if(NORTH)
			endy = TRANSITIONEDGE + MAP_EDGE_PAD
			endx = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxx - (TRANSITIONEDGE + MAP_EDGE_PAD))
		if(EAST)
			endy = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxy - (TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = TRANSITIONEDGE + MAP_EDGE_PAD
		if(SOUTH)
			endy = world.maxy - (TRANSITIONEDGE + MAP_EDGE_PAD)
			endx = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxx - (TRANSITIONEDGE + MAP_EDGE_PAD))
		if(WEST)
			endy = rand(TRANSITIONEDGE + MAP_EDGE_PAD, world.maxy - (TRANSITIONEDGE + MAP_EDGE_PAD))
			endx = world.maxx - (TRANSITIONEDGE + MAP_EDGE_PAD)
	return locate(endx, endy, Z)

///////////////////////
//The meteor effect
//////////////////////

/obj/effect/meteor
	name = "the concept of meteor"
	desc = "You should probably run instead of gawking at this."
	icon = 'icons/obj/meteor.dmi'
	icon_state = "smallf"
	density = TRUE
	anchored = TRUE
	var/hits = 1
	var/hitpwr = 2 //Level of ex_act to be called on hit.
	var/dest
	pass_flags = PASSTABLE
	var/heavy = FALSE
	var/meteorsound = 'sound/effects/meteorimpact.ogg'
	var/z_original

	var/meteordrop = /obj/item/weapon/ore/iron
	var/dropamt = 2

/obj/effect/meteor/atom_init()
	. = ..()
	z_original = loc.z

/obj/effect/meteor/Move()
	if(z != z_original || loc == dest)
		qdel(src)
		return

	. = ..() //process movement...

	if(.)//.. if did move, ram the turf we get in
		var/turf/T = get_turf(loc)

		ram_turf(T)

		if(prob(10) && !isenvironmentturf(T))//randomly takes a 'hit' from ramming
			get_hit()

/obj/effect/meteor/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/weapon/pickaxe))
		make_debris()
		qdel(src)
		return
	return ..()

/obj/effect/meteor/Destroy()
	walk(src,0) // this cancels the walk_towards() proc
	return ..()

/obj/effect/meteor/Bump(atom/A)
	if(A)
		var/turf/T = get_turf(A)
		var/area/T_area = get_area(T)
		//message_admins("<span class='warning'>[src] hit [A] in [T_area] [ADMIN_JMP(T)].</span>")
		log_game("[src] hit [A] [COORD(T)] in [T_area].")
		if(ismob(A))
			visible_message("<span class='red'>[A] has been hit by [src].</span>")
		ram_turf(get_turf(A))
		playsound(src, 'sound/effects/meteorimpact.ogg', VOL_EFFECTS_MASTER)
		get_hit()

/obj/effect/meteor/proc/ram_turf(turf/T)
	//first bust whatever is in the turf
	for(var/obj/structure/window/W in T)	// window protects grille
		W.ex_act(hitpwr)
		if(!QDELETED(W))
			return
		break
	for(var/atom/A in T.contents - src)
		if(!istype(A, /obj/machinery/power/emitter) && !istype(A, /obj/machinery/field_generator)) //Protect the singularity from getting released every round!
			A.ex_act(hitpwr) //Changing emitter/field gen ex_act would make it immune to bombs and C4

	//then, ram the turf if it still exists
	if(T)
		T.ex_act(hitpwr)

//process getting 'hit' by colliding with a dense object
//or randomly when ramming turfs
/obj/effect/meteor/proc/get_hit()
	hits--
	if(hits == 0)
		make_debris()
		meteor_effect()
		qdel(src)

/obj/effect/meteor/proc/meteor_effect()
	if(heavy)
		for(var/mob/M in player_list)
			var/turf/T = get_turf(M)
			if(!T || T.z != src.z)
				continue
			shake_camera(M, 3, get_dist(M.loc, src.loc) > 20 ? 1 : 3)
			playsound(src, meteorsound, VOL_EFFECTS_MASTER)

/obj/effect/meteor/proc/make_debris()
	for(var/throws in 1 to dropamt)
		new meteordrop(get_turf(src))

/obj/effect/meteor/ex_act()
	return

///////////////////////
//Meteor types
///////////////////////

//Dust
/obj/effect/meteor/dust
	name = "space dust"
	desc = "Dust in space."
	icon_state = "space_dust"
	pass_flags = PASSTABLE | PASSGRILLE
	hits = 1
	hitpwr = 3

	meteordrop = /obj/item/weapon/ore/glass
	dropamt = 2

/obj/effect/meteor/dust/make_debris()
	if(prob(33))
		dropamt = 1
	..()

//Medium-sized
/obj/effect/meteor/medium
	name = "meteor"
	dropamt = 3

/obj/effect/meteor/medium/meteor_effect()
	..()
	explosion(src.loc, 0, 1, 2, 3, adminlog = FALSE)

//Large-sized
/obj/effect/meteor/big
	name = "big meteor"
	icon_state = "flaming"
	hits = 6
	heavy = TRUE
	dropamt = 4

/obj/effect/meteor/big/meteor_effect()
	..()
	explosion(src.loc, 1, 2, 3, 4, adminlog = FALSE)

#undef MAP_EDGE_PAD
