//obj/screen
//	plane = GUI_PLANE // Needs to render over the top of darkness.

/obj/item/atom_init()
	. = ..()
	update_plane()

/obj/item/Move()
	. = ..()
	if(.) update_plane()

/obj/item/forceMove()
	var/lastloc = loc
	. = ..()
	if(loc != lastloc)
		update_plane()

/obj/proc/update_plane()
	return

/obj/item/update_plane()
	if(istype(loc, /turf))
		plane = initial(plane)
	else
		plane = HUD_LAYER

/obj/item/clothing/under/update_plane()
	. = ..()
	for(var/atom/movable/thing in contents)
		thing.plane = plane
