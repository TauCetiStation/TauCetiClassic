var/global/list/obj/machinery/bluespace_transponder/transponders = list()
var/global/list/obj/machinery/bluespace_transponder/active_transponders = list()

ADD_TO_GLOBAL_LIST(/obj/machinery/bluespace_transponder, transponders)

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
	return ..()


/turf/proc/get_untaken_replicator_color()
	var/list/possibilities = REPLICATOR_COLORS
	var/obj/structure/cable/power_rune/PR = locate() in src
	if(PR)
		possibilities -= PR.rune_color
	var/obj/structure/bluespace_corridor/BC = locate() in src
	if(BC)
		possibilities -= BC.rune_color
		possibilities -= BC.internal_rune_color
	return possibilities


/obj/structure/cable/power_rune
	name = "rune"
	desc = "Huh."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "power_rune"

	var/rune_color

/obj/structure/cable/power_rune/atom_init()
	. = ..()
	icon_state = "power_rune_[rand(1, 3)]"

	var/turf/my_turf = get_turf(src)

	rune_color = pick(my_turf.get_untaken_replicator_color())
	color = rune_color

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

	var/neighbor_count = 0

	var/rune_color
	var/internal_rune_color

	// Images don't have invisibility.
	var/obj/effect/overlay/internal_overlay

/obj/structure/bluespace_corridor/atom_init()
	. = ..()

	icon_state = "transit_rune_[rand(1, 3)]"

	var/turf/my_turf = get_turf(src)

	rune_color = pick(my_turf.get_untaken_replicator_color())
	color = rune_color

	internal_rune_color = pick(my_turf.get_untaken_replicator_color())

	internal_overlay = new
	internal_overlay.icon = icon
	internal_overlay.icon_state = "corridor_internal"
	internal_overlay.color = internal_rune_color
	internal_overlay.invisibility = INVISIBILITY_LEVEL_TWO
	internal_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	// Invisibility doesn't work with overlays
	vis_contents += internal_overlay

	neighbor_adjust_count(my_turf, 1)

/obj/structure/bluespace_corridor/Destroy()
	vis_contents -= internal_overlay
	QDEL_NULL(internal_overlay)

	var/turf/my_turf = get_turf(src)
	if(my_turf)
		neighbor_adjust_count(my_turf, -1)

	return ..()

/obj/structure/bluespace_corridor/Moved(atom/OldLoc, move_dir)
	var/turf/old_turf = get_turf(OldLoc)
	var/turf/my_turf = get_turf(src)

	if(old_turf)
		neighbor_adjust_count(old_turf, -1)
	if(my_turf)
		neighbor_adjust_count(my_turf, 1)

/obj/structure/bluespace_corridor/proc/neighbor_adjust_count(turf/T, value)
	for(var/card_dir in global.cardinal)
		var/turf/other = get_step(T, card_dir)
		var/obj/structure/bluespace_corridor/BC = locate(/obj/structure/bluespace_corridor) in other
		if(!BC)
			continue
		BC.neighbor_count += value
		neighbor_count += value
