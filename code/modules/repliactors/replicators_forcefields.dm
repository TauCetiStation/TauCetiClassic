/turf/simulated/floor/plating/airless/catwalk/forcefield
	name = "forcefield"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "floor"
	airless = FALSE

/turf/simulated/floor/plating/airless/catwalk/forcefield/atom_init()
	. = ..()
	icon_state = "floor"

	if(prob(5))
		var/too_close = FALSE
		for(var/fn in global.forcefield_nodes)
			if(get_dist(src, fn) < 5)
				too_close = TRUE

		if(!too_close)
			var/obj/structure/forcefield_node/FN = new(src)
			FN.color = pick("#A8DFF0", "#F0A8DF", "#DFF0A8")

/turf/simulated/floor/plating/airless/catwalk/forcefield/update_icon(propogate=1)
	return


/obj/structure/inflatable/forcefield
	name = "forcefield"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "wall"
	density = TRUE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	max_integrity = 100
	resistance_flags = CAN_BE_HIT

/obj/structure/inflatable/forcefield/CanPass(atom/movable/mover, turf/target)
	if(mover && mover.invisibility > 0)
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

/obj/structure/forcefield_node/Crossed(atom/movable/AM)
	if(icon_state != "floor_node_free")
		return ..()

	if(AM.invisibility <= 0)
		return ..()

	if(!isreplicator(AM))
		return ..()

	var/mob/living/simple_animal/replicator/R = AM
	global.replicators_faction.adjust_compute(1, adjusted_by=R.last_controller_ckey)
	icon_state = "floor_node_captured"
	playsound(AM, 'sound/magic/heal.ogg', VOL_EFFECTS_MASTER)
