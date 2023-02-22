/turf/proc/can_place_replicator_forcefield()
	if(locate(/obj/structure/replicator_forcefield) in src)
		return FALSE
	if(locate(/obj/structure/replicator_barricade) in src)
		return FALSE
	return TRUE


/turf/simulated/floor/plating/airless/catwalk/forcefield
	name = "forcefield"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "floor"
	airless = FALSE

/turf/simulated/floor/plating/airless/catwalk/forcefield/atom_init()
	. = ..()
	icon_state = "floor"

/turf/simulated/floor/plating/airless/catwalk/forcefield/update_icon(propogate=1)
	return

/turf/simulated/floor/plating/airless/catwalk/forcefield/ChangeTurf(newtype)
	. = ..()
	if(newtype != type)
		var/obj/structure/forcefield_node/FN = locate() in src
		qdel(FN)


/obj/structure/replicator_forcefield
	name = "forcefield"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "wall"
	density = TRUE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/replicator_forcefield/CanPass(atom/movable/mover, turf/target)
	if(mover && mover.invisibility > 0 && (locate(/obj/structure/bluespace_corridor) in loc))
		return TRUE
	return ..()

/obj/structure/replicator_forcefield/Bumped(AM)
	. = ..()
	if(!isreplicator(AM))
		return
	var/mob/living/simple_animal/replicator/R = AM
	if(R.auto_construct_type != /obj/structure/bluespace_corridor || global.replicators_faction.materials < R.auto_construct_cost)
		return
	R.try_construct(get_turf(src))


/obj/structure/replicator_barricade
	name = "forcefield barricade"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "barricade"
	density = TRUE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	max_integrity = 10
	resistance_flags = CAN_BE_HIT

/obj/structure/replicator_barricade/CanPass(atom/movable/mover, turf/target)
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover, /obj/item/projectile/disabler))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()


var/global/list/forcefield_nodes = list()

ADD_TO_GLOBAL_LIST(/obj/structure/forcefield_node, forcefield_nodes)

/obj/structure/forcefield_node
	name = "forcefield node"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "floor_node_free"
	density = FALSE
	anchored = TRUE
	opacity = 0

/obj/structure/forcefield_node/atom_init()
	. = ..()
	global.replicators_faction.nodes_to_spawn -= 1

/obj/structure/forcefield_node/Destroy()
	global.replicators_faction.nodes_to_spawn += 1
	return ..()

/obj/structure/forcefield_node/Crossed(atom/movable/AM)
	if(captured())
		return ..()

	if(AM.invisibility <= 0)
		return ..()

	if(!isreplicator(AM))
		return ..()

	var/mob/living/simple_animal/replicator/R = AM
	global.replicators_faction.adjust_compute(1, adjusted_by=R.last_controller_ckey)
	icon_state = "floor_node_captured"
	playsound(AM, 'sound/magic/heal.ogg', VOL_EFFECTS_MASTER)

/obj/structure/forcefield_node/proc/captured()
	return icon_state == "floor_node_captured"
