//Anomalies, used for events. Note that these DO NOT work by themselves; their procs are called by the event datum.
//TG-stuff
/obj/effect/anomaly
	name = "anomaly"
	icon = 'icons/effects/anomalies.dmi'
	desc = "A mysterious anomaly, seen commonly only in the region of space that the station orbits..."
	icon_state = "vortex"
	unacidable = 1
	density = 0
	anchored = 1
	var/obj/item/device/assembly/signaler/anomaly/aSignal = null

/obj/effect/anomaly/atom_init()
	. = ..()
	poi_list += src
	set_light(3, 5, light_color)
	aSignal = new(src)
	aSignal.name = "[name] core"
	aSignal.code = rand(1,100)

	aSignal.frequency = rand(1200, 1599)
	if(IS_MULTIPLE(aSignal.frequency, 2))//signaller frequencies are always uneven!
		aSignal.frequency++

/obj/effect/anomaly/Destroy()
	poi_list -= src
	return ..()

/obj/effect/anomaly/proc/anomalyEffect()
	if(prob(50))
		step(src,pick(alldirs))


/obj/effect/anomaly/proc/anomalyNeutralize()
//	new /obj/effect/effect/bad_smoke(loc)

	for(var/atom/movable/O in src)
		O.loc = src.loc

	qdel(src)


/obj/effect/anomaly/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/device/analyzer))
		to_chat(user, "<span class='notice'>Analyzing... [src]'s unstable field is fluctuating along frequency [aSignal.code]:[format_frequency(aSignal.frequency)].</span>")

///////////////////////

/obj/effect/anomaly/grav
	name = "gravitational anomaly"
	icon_state = "grav"
	density = 1
	var/boing = 0

/obj/effect/anomaly/grav/atom_init()
	. = ..()
	aSignal.origin_tech = "magnets=8;powerstorage=4"

/obj/effect/anomaly/grav/anomalyEffect()
	..()

	boing = 1
	for(var/obj/O in orange(4, src))
		if(!O.anchored)
			step_towards(O,src)
	for(var/mob/living/M in orange(4, src))
		step_towards(M,src)

/obj/effect/anomaly/grav/Bump(mob/A)
	gravShock(A)
	return

/obj/effect/anomaly/grav/Bumped(mob/A)
	gravShock(A)
	return

/obj/effect/anomaly/grav/proc/gravShock(mob/A)
	if(boing && isliving(A) && !A.stat)
		A.Weaken(2)
		var/atom/target = get_edge_target_turf(A, get_dir(src, get_step_away(A, src)))
		A.throw_at(target, 5, 1)
		boing = 0
		return

/////////////////////

/obj/effect/anomaly/flux
	name = "flux wave anomaly"
	icon_state = "flux2"
	light_color = "#ffe194"

/obj/effect/anomaly/flux/atom_init()
	. = ..()
	aSignal.origin_tech = "powerstorage=8;programming=4;phorontech=4"

/////////////////////

/obj/effect/anomaly/bluespace
	name = "bluespace anomaly"
	icon_state = "bluespace"
	density = 1
	light_color = "#009eff"

/obj/effect/anomaly/bluespace/atom_init()
	. = ..()
	aSignal.origin_tech = "bluespace=8;magnets=5;powerstorage=3"

/obj/effect/anomaly/bluespace/Bumped(atom/A)
	if(isliving(A))
		do_teleport(A, locate(A.x, A.y, A.z), 10)
	return

/////////////////////

/obj/effect/anomaly/pyro
	name = "pyroclastic anomaly"
	icon_state = "pyro"

/obj/effect/anomaly/pyro/atom_init()
	. = ..()
	aSignal.origin_tech = "phorontech=8;powerstorage=4;biotech=6"

/obj/effect/anomaly/pyro/anomalyEffect()
	..()
	var/turf/simulated/T = get_turf(src)
	if(istype(T))
		T.assume_gas("phoron", 30)
		T.hotspot_expose(1000, CELL_VOLUME)


/obj/effect/anomaly/pyro/get_current_temperature()
	return 1000

/////////////////////

/obj/effect/anomaly/bhole
	name = "vortex anomaly"
	icon_state = "vortex"
	desc = "That's a nice station you have there. It'd be a shame if something happened to it."

/obj/effect/anomaly/bhole/atom_init()
	. = ..()
	aSignal.origin_tech = "materials=8;combat=4;engineering=4"

/obj/effect/anomaly/bhole/anomalyEffect()
	..()
	if(!isturf(loc)) //blackhole cannot be contained inside anything. Weird stuff might happen
		qdel(src)
		return

	grav(rand(0,3), rand(2,3), 50, 25)

	//Throwing stuff around!
	for(var/obj/O in orange(1,src))
		if(!O.anchored)
			var/mob/living/target = locate() in view(5,src)
			if(!target)
				return
			O.throw_at(target, 5, 10)
			return
		else
			O.ex_act(2)

/obj/effect/anomaly/bhole/proc/grav(r, ex_act_force, pull_chance, turf_removal_chance)
	for(var/t = -r, t < r, t++)
		affect_coord(x+t, y-r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-t, y+r, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x+r, y+t, ex_act_force, pull_chance, turf_removal_chance)
		affect_coord(x-r, y-t, ex_act_force, pull_chance, turf_removal_chance)
	return

/obj/effect/anomaly/bhole/proc/affect_coord(x, y, ex_act_force, pull_chance, turf_removal_chance)
	//Get turf at coordinate
	var/turf/T = locate(x, y, z)
	if(isnull(T))	return

	//Pulling and/or ex_act-ing movable atoms in that turf
	if(prob(pull_chance))
		for(var/obj/O in T.contents)
			if(O.anchored)
				O.ex_act(ex_act_force)
			else
				step_towards(O,src)
		for(var/mob/living/M in T.contents)
			step_towards(M,src)

	//Damaging the turf
	if( T && istype(T,/turf/simulated) && prob(turf_removal_chance) )
		T.ex_act(ex_act_force)
	return
