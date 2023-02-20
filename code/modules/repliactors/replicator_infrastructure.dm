var/global/list/obj/machinery/bluespace_transponder/active_transponders = list()

/obj/machinery/bluespace_transponder
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_exit"
	name = "bluespace transponder"
	desc = "Huh."

	anchored = TRUE
	density = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 20000

/obj/machinery/bluespace_transponder/Crossed(atom/movable/AM)
	if(stat & NOPOWER)
		return ..()

	var/obj/structure/bluespace_corridor/BC = locate() in loc
	if(!BC)
		return ..()

	if(AM.invisibility > 0)
		return ..()

	var/see_invisible_level = 0
	if(ismob(AM))
		var/mob/M = AM
		see_invisible_level = M.see_invisible

	AM.AddElement(/datum/element/bluespace_move, AM.invisibility, see_invisible_level, AM.alpha)

/obj/machinery/bluespace_transponder/power_change()
	..()
	if(stat & NOPOWER)
		global.active_transponders -= src
		icon_state = "bhole3"
	else
		global.active_transponders += src
		icon_state = "bluespace_wormhole_exit"

/obj/machinery/bluespace_transponder/Destroy()
	global.active_transponders -= src
	return ..()

/obj/machinery/bluespace_transponder/process()
	if(prob(1))
		playsound(src, 'sound/machines/signal.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/bluespace_transponder/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	// if istype replicator disabler projectile
	return ..()


/obj/machinery/power/replicator_generator
	name = "bluespace generator"
	desc = "Huh."
	icon = 'icons/obj/objects.dmi'
	icon_state = "coolanttank"

	density = TRUE
	anchored = TRUE

	use_power = IDLE_POWER_USE
	idle_power_usage = 0

/obj/machinery/power/replicator_generator/atom_init()
	. = ..()
	new /obj/structure/cable/power_rune(loc)

/obj/machinery/power/replicator_generator/process()
	if(prob(1))
		playsound(src, 'sound/machines/signal.ogg', VOL_EFFECTS_MASTER)
	add_avail(20000)

/obj/machinery/power/replicator_generator/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	// if istype replicator disabler projectile
	return ..()


/obj/structure/cable/power_rune
	name = "rune"
	desc = "Huh."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "power_rune"

/obj/structure/cable/power_rune/atom_init()
	. = ..()
	icon_state = "power_rune_[rand(1, 3)]"

	color = pick("#A8DFF0", "#F0A8DF", "#DFF0A8")

	d1 = 0
	for(var/obj/structure/cable/C in get_turf(src))
		d2 = turn(C.d2, 180)
		break

	var/datum/powernet/PN = new
	PN.add_cable(src)

	mergeConnectedNetworks(d2) //merge the powernet with adjacents powernets
	mergeConnectedNetworksOnTurf() //merge the powernet with on turf powernets

/obj/structure/cable/power_rune/update_icon()
	return


/obj/structure/bluespace_corridor
	name = "rune"
	desc = "Huh."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "transit_rune"

/obj/structure/bluespace_corridor/atom_init()
	. = ..()
	color = pick("#A8DFF0", "#F0A8DF", "#DFF0A8")
	icon_state = "transit_rune_[rand(1, 3)]"
