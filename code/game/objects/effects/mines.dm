/obj/effect/mine
	name = "Mine"
	desc = "I Better stay away from that thing."
	density = 1
	anchored = 1
	layer = 3
	icon = 'icons/obj/weapons.dmi'
	icon_state = "uglymine"
	var/triggered = 0

/obj/effect/mine/atom_init()
	. = ..()
	icon_state = "uglyminearmed"

/obj/effect/mine/Crossed(atom/movable/AM)
	. = ..()
	Bumped(AM)

/obj/effect/mine/Bumped(mob/M)

	if(triggered) return

	if(istype(M, /mob/living/carbon/human) || istype(M, /mob/living/carbon/monkey))
		for(var/mob/O in viewers(world.view, src.loc))
			to_chat(O, "<font color='red'>[M] triggered the [bicon(src)] [src]</font>")
		triggered = 1
		trigger_act(M)

/obj/effect/mine/proc/trigger_act(obj)
	explosion(loc, 0, 1, 2, 3)
	spawn(0)
		qdel(src)

/obj/effect/mine/dnascramble
	name = "Radiation Mine"
	icon_state = "uglymine"

/obj/effect/mine/dnascramble/trigger_act(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()
	obj:radiation += 50
	randmutb(obj)
	domutcheck(obj,null)
	spawn(0)
		qdel(src)

/obj/effect/mine/phoron
	name = "Phoron Mine"
	icon_state = "uglymine"

/obj/effect/mine/phoron/trigger_act(obj)
	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)

			target.assume_gas("phoron", 30)

			target.hotspot_expose(1000, CELL_VOLUME)

	spawn(0)
		qdel(src)

/obj/effect/mine/kick
	name = "Kick Mine"
	icon_state = "uglymine"

/obj/effect/mine/kick/trigger_act(obj)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()
	del(obj:client)
	spawn(0)
		qdel(src)

/obj/effect/mine/n2o
	name = "N2O Mine"
	icon_state = "uglymine"

/obj/effect/mine/n2o/trigger_act(obj)
	//note: im lazy

	for (var/turf/simulated/floor/target in range(1,src))
		if(!target.blocks_air)
			target.assume_gas("sleeping_agent", 30)

	spawn(0)
		qdel(src)

/obj/effect/mine/stun
	name = "Stun Mine"
	icon_state = "uglymine"

/obj/effect/mine/stun/trigger_act(obj)
	if(ismob(obj))
		var/mob/M = obj
		M.Stun(30)
	var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
	s.set_up(3, 1, src)
	s.start()
	spawn(0)
		qdel(src)
