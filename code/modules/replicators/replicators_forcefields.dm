/turf/proc/can_place_replicator_forcefield()
	if(locate(/obj/structure/replicator_forcefield) in src)
		return FALSE
	if(locate(/obj/structure/replicator_barricade) in src)
		return FALSE
	return TRUE


/turf/simulated/floor/plating/airless/catwalk/forcefield
	name = "forcefield"
	desc = "Distant stars under this crystallic floor are seemingly more blueish. Foreshadowing?!"
	icon = 'icons/mob/replicator.dmi'
	icon_state = "floor"
	airless = FALSE

/turf/simulated/floor/plating/airless/catwalk/forcefield/atom_init()
	. = ..()
	icon_state = "floor_new"
	color = "#a8dff0"

	underlays.Cut()
	var/image/I = SSenvironment.turf_image[z]
	underlays += I

/turf/simulated/floor/plating/airless/catwalk/forcefield/Destroy()
	// to-do: sound
	playsound(loc, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg', 'sound/machines/arcade/-mana1.ogg', 'sound/machines/arcade/-mana2.ogg'), VOL_EFFECTS_MASTER)

	var/obj/structure/forcefield_node/FN = locate() in src
	qdel(FN)

	return ..()

/turf/simulated/floor/plating/airless/catwalk/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>A crystallic field of flickering lights. Flowers, that grow no longer.</span>")

/turf/simulated/floor/plating/airless/catwalk/forcefield/update_icon(propogate=1)
	return

/turf/simulated/floor/plating/airless/catwalk/forcefield/ChangeTurf(newtype)
	. = ..()
	if(newtype != type)
		var/obj/structure/forcefield_node/FN = locate() in src
		qdel(FN)

/turf/simulated/floor/plating/airless/catwalk/forcefield/attackby(obj/item/C, mob/user)
	if(istype(C, /obj/item/stack/tile) && !user.is_busy() && do_skilled(user, src, SKILL_TASK_DIFFICULT, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), -0.2))
		ChangeTurf(/turf/simulated/floor/plating)
		return

	if(isscrewing(C))
		// Parent also has screwdriver disassembly so we ought to stop here...
		to_chat(user, "<span class='warning'>What would that do to a forcefield?</span>")
		return

	if(ispulsing(C) && !user.is_busy() && do_skilled(user, src, SKILL_TASK_DIFFICULT, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), -0.2))
		qdel(src)
		return

	return ..()


/obj/structure/replicator_forcefield
	name = "forcefield"
	desc = "Geometrically perfect walls of floating crystals."
	icon = 'icons/turf/walls/replicator_forcefield.dmi'
	icon_state = "box"
	density = TRUE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	max_integrity = 100
	resistance_flags = CAN_BE_HIT | FIRE_PROOF

	canSmoothWith = list(
		/obj/structure/replicator_forcefield
	)
	smooth = SMOOTH_TRUE

/obj/structure/replicator_forcefield/Destroy()
	// to-do: sound
	playsound(loc, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg', 'sound/machines/arcade/-mana1.ogg', 'sound/machines/arcade/-mana2.ogg'), VOL_EFFECTS_MASTER)
	if(!(locate(/obj/structure/stabilization_field) in loc))
		new /obj/structure/stabilization_field(loc)
	return ..()

/obj/structure/replicator_forcefield/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>Upon closer inspection you notice the link to the Web. You are certain you can construct a corridor over this field.</span>")

/obj/structure/replicator_forcefield/CanPass(atom/movable/mover, turf/target)
	if(!mover)
		return FALSE
	if(mover.invisibility > 0 && (locate(/obj/structure/bluespace_corridor) in loc))
		return TRUE
	return ..()

/obj/structure/replicator_forcefield/Bumped(AM)
	. = ..()
	if(!isreplicator(AM))
		return
	var/mob/living/simple_animal/replicator/R = AM
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	if(R.auto_construct_type != /obj/structure/bluespace_corridor || FR.materials < R.auto_construct_cost)
		return
	R.try_construct(get_turf(src))


/obj/structure/stabilization_field
	name = "stabilization field"
	desc = "This field stabilizes air inside of it via microscopic crystals."

	icon = 'icons/mob/replicator.dmi'
	icon_state = "stabillization_field"
	density = FALSE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	resistance_flags = FULL_INDESTRUCTIBLE

/obj/structure/stabilization_field/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>Ah, the trickster's greatest achivement. A wall that allows everything to pass through but the most tiny of things.</span>")

/obj/structure/stabilization_field/attackby(obj/item/C, mob/user)
	if(ispulsing(C) && !user.is_busy() && do_skilled(user, src, SKILL_TASK_DIFFICULT, list(/datum/skill/construction = SKILL_LEVEL_TRAINED), -0.2))
		// to-do: sound
		playsound(loc, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg', 'sound/machines/arcade/-mana1.ogg', 'sound/machines/arcade/-mana2.ogg'), VOL_EFFECTS_MASTER)
		qdel(src)
		return

	return ..()

/obj/structure/stabilization_field/CanPass(atom/movable/mover, turf/target)
	if(!mover)
		return FALSE
	return ..()


/obj/structure/replicator_barricade
	name = "forcefield barricade"
	desc = "Floating wall of crystals that shifts and moves in perfect harmony. You wonder what wonderful creature's the frequency dances to."

	icon = 'icons/mob/replicator.dmi'
	icon_state = "barricade"
	density = TRUE
	anchored = TRUE
	opacity = 0
	can_block_air = TRUE

	max_integrity = 35
	resistance_flags = CAN_BE_HIT | FIRE_PROOF

/obj/structure/replicator_barricade/Destroy()
	// to-do: sound
	playsound(loc, pick('sound/machines/arcade/gethit1.ogg', 'sound/machines/arcade/gethit2.ogg', 'sound/machines/arcade/-mana1.ogg', 'sound/machines/arcade/-mana2.ogg'), VOL_EFFECTS_MASTER)
	if(!(locate(/obj/structure/stabilization_field) in loc))
		new /obj/structure/stabilization_field(loc)
	return ..()

/obj/structure/replicator_barricade/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>Completely attuned to the resonance of it's dance, you are sure you can pass through it freely.</span>")

/obj/structure/replicator_barricade/CanPass(atom/movable/mover, turf/target)
	if(!mover)
		return FALSE
	if(istype(mover, /mob/living/simple_animal/replicator))
		return TRUE
	if(istype(mover, /obj/item/projectile/disabler))
		return TRUE
	if(istype(mover) && mover.throwing)
		return TRUE
	return ..()


var/global/list/forcefield_nodes = list()
var/global/list/area2free_forcefield_nodes = list()

ADD_TO_GLOBAL_LIST(/obj/structure/forcefield_node, forcefield_nodes)

/obj/structure/forcefield_node
	name = "forcefield node"
	desc = "The flow of bluespace seems to be more potent at these coordinates. If only there was a way to harness these energies..."
	icon = 'icons/mob/replicator.dmi'
	icon_state = "floor_node_free"
	layer = ABOVE_OBJ_LATER
	density = FALSE
	anchored = TRUE
	opacity = 0

/obj/structure/forcefield_node/atom_init()
	. = ..()
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.nodes_to_spawn -= 1

	add_area_node(src)

/obj/structure/forcefield_node/Destroy()
	// to-do: sound
	playsound(loc, 'sound/machines/arcade/heal2.ogg', VOL_EFFECTS_MASTER)
	var/datum/faction/replicators/FR = get_or_create_replicators_faction()
	FR.nodes_to_spawn += 1

	var/obj/machinery/power/replicator_generator/RG = locate() in loc
	if(RG)
		FR.adjust_materials(REPLICATOR_COST_GENERATOR)
		qdel(RG)

	remove_area_node(src)
	return ..()

/obj/structure/forcefield_node/examine(mob/living/user)
	. = ..()
	if(!isreplicator(user))
		return

	to_chat(user, "<span class='notice'>Don't waste a good Node extracting energy you don't need.</span>")

/obj/structure/forcefield_node/Moved(atom/OldLoc, moveddir)
	. = ..()

	remove_area_node(OldLoc)
	add_area_node(src)

/obj/structure/forcefield_node/Crossed(atom/movable/AM)
	if(captured())
		return ..()

	if(AM.invisibility <= 0)
		return ..()

	if(!isreplicator(AM))
		return ..()

	if(!(locate(/obj/structure/bluespace_corridor) in loc))
		return ..()

	icon_state = "floor_node_captured"
	playsound(AM, 'sound/magic/heal.ogg', VOL_EFFECTS_MASTER)

/obj/structure/forcefield_node/proc/captured()
	return icon_state == "floor_node_captured"

/obj/structure/forcefield_node/proc/add_area_node(atom/node_loc)
	var/area/A = get_area(node_loc)
	if(!A)
		return

	if(!global.area2free_forcefield_nodes[A.name])
		global.area2free_forcefield_nodes[A.name] = 0
	global.area2free_forcefield_nodes[A.name] += 1

/obj/structure/forcefield_node/proc/remove_area_node(atom/node_loc)
	var/area/A = get_area(node_loc)
	if(!A)
		return

	global.area2free_forcefield_nodes[A.name] -= 1
	if(global.area2free_forcefield_nodes[A.name] <= 0)
		global.area2free_forcefield_nodes -= A.name
