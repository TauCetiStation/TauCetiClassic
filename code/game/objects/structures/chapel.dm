/obj/structure/stool/bed/chair/pew
	name = "pew"
	icon = 'icons/obj/structures/chapel.dmi'
	icon_state = "general_left"

	density = TRUE
	anchored = TRUE

	dir = NORTH

	// It's  a pew!
	layer = FLY_LAYER

	var/pew_icon = "general"
	var/append_icon_state = "_left"

/obj/structure/stool/bed/chair/pew/atom_init()
	. = ..()
	update_icon()

/obj/structure/stool/bed/chair/pew/post_buckle_mob(mob/living/M)
	return

/obj/structure/stool/bed/chair/pew/handle_rotation()
	if(buckled_mob)
		buckled_mob.dir = dir
		buckled_mob.update_canmove()

/obj/structure/stool/bed/chair/pew/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(istype(mover) && mover.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, loc) & dir)
		return !density
	return TRUE

/obj/structure/stool/bed/chair/pew/CanAStarPass(obj/item/weapon/card/id/ID, to_dir, caller)
	if(!density)
		return TRUE
	if(is_the_opposite_dir(dir, to_dir))
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/pew/CheckExit(atom/movable/O, target)
	if(istype(O) && O.checkpass(PASSTABLE))
		return TRUE
	if(get_dir(target, O.loc) == dir)
		return FALSE
	return TRUE

/obj/structure/stool/bed/chair/pew/update_icon()
	icon_state = pew_icon + append_icon_state

/obj/structure/stool/bed/chair/pew/left
	// For mappers.
	icon_state = "general_left"
	append_icon_state = "_left"

/obj/structure/stool/bed/chair/pew/right
	icon_state = "general_right"
	append_icon_state = "_right"
