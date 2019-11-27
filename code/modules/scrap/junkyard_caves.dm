/obj/structure/junkyard_cave
	name = "cave"
	icon = 'icons/obj/structures/scrap/junkyard_caves.dmi'
	icon_state = "cave_labor_junkyard_center"
	opacity = TRUE
	density = FALSE
	anchored = TRUE
	var/obj/structure/junkyard_cave/target
	var/tag_cave = ""
	var/targeted = FALSE

/obj/structure/junkyard_cave/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/junkyard_cave/atom_init_late()
	var/area/awaymission/junkyard/A = get_area(src)
	if(istype(A, /area/awaymission/junkyard))
		LAZYADD(A.caves, src)

/obj/structure/junkyard_cave/Crossed(AM as mob|obj)
	if(!target)
		return
	if(istype(AM, /mob/living/carbon))
		var/atom/movable/M = AM
		M.loc = get_turf(target)
	if(istype(AM, /obj))
		var/obj/M = AM
		M.loc = get_turf(target)

/obj/structure/junkyard_cave/Bumped(mob/living/carbon/M)
	if(target)
		M.loc = get_turf(target)

/obj/structure/junkyard_cave/right
	icon_state = "cave_labor_junkyard_r"

/obj/structure/junkyard_cave/left
	icon_state = "cave_labor_junkyard_l"