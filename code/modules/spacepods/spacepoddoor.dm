/obj/machinery/door/spacepoddoor
	name = "blast door"
	desc = "A heavy duty blast door that opens mechanically."
	icon = 'icons/obj/doors/blast_door.dmi'
	icon_state = "closed"
	layer = BLASTDOOR_LAYER
	var/closingLayer = CLOSED_BLASTDOOR_LAYER
	var/safe = FALSE
	var/id_tag = 1.0
	var/protected = 1

/obj/machinery/door/spacepoddoor/preopen
	icon_state = "open"
	density = FALSE
	opacity = 0

/obj/machinery/door/spacepoddoor/Bumped(atom/AM)
	if(density)
		return
	else
		return 0

//"BLAST" doors are obviously stronger than regular doors when it comes to BLASTS.
/obj/machinery/door/spacepoddoor/ex_act(severity, target)
	if(severity == 3)
		return
	..()

/obj/machinery/door/spacepoddoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("opening", src)
			playsound(src, 'sound/machines/blast_door.ogg', 30, 1)
		if("closing")
			flick("closing", src)
			playsound(src, 'sound/machines/blast_door.ogg', 30, 1)

/obj/machinery/door/spacepoddoor/update_icon()
	if(density)
		icon_state = "open"
	else
		icon_state = "closed"

/*
/obj/machinery/door/spacepoddoor/interact(mob/user)
 	return
 */

/obj/machinery/door/spacepoddoor/attackby(obj/item/I, mob/user)
	if(iscrowbar(I) && !hasPower() && do_after(user,20, target = src) && !user.is_busy())
		open()

 // Whoever wrote the old code for multi-tile spesspod doors needs to burn in hell. - Unknown
 // Wise words. - Bxil
/obj/machinery/door/spacepoddoor/multi_tile
	name = "large pod door"
	layer = CLOSED_DOOR_LAYER
	closingLayer = CLOSED_DOOR_LAYER

/obj/machinery/door/spacepoddoor/multi_tile/New()
	. = ..()
	apply_opacity_to_my_turfs(opacity)

/obj/machinery/door/spacepoddoor/multi_tile/open()
	if(..())
		apply_opacity_to_my_turfs(opacity)


/obj/machinery/door/spacepoddoor/multi_tile/close()
	if(..())
		apply_opacity_to_my_turfs(opacity)

/obj/machinery/doors/spacepoddoor/multi_tile/Destroy()
	return ..()

//Multi-tile poddoors don't turn invisible automatically, so we change the opacity of the turfs below instead one by one.
/obj/machinery/door/spacepoddoor/multi_tile/proc/apply_opacity_to_my_turfs(var/new_opacity)
	for(var/turf/T in locs)
		T.opacity = new_opacity
		T.has_opaque_atom = new_opacity
		T.reconsider_lights()
	update_freelook_sight()

/obj/machinery/door/proc/update_freelook_sight()
	if(!glass && cameranet)
		cameranet.updateVisibility(src, 0)

/obj/machinery/doorr/spacepoddoor/multi_tile/four_tile_ver/
	icon = 'icons/obj/doors/1x4blast_vert.dmi'
	var/width = 4
	dir = NORTH

/obj/machinery/door/spacepoddoor/multi_tile/three_tile_ver/
	icon = 'icons/obj/doors/1x3blast_vert.dmi'
	var/width = 3
	dir = NORTH

/obj/machinery/door/spacepoddoor/multi_tile/two_tile_ver/
	icon = 'icons/obj/doors/1x2blast_vert.dmi'
	var/width = 2
	dir = NORTH

/obj/machinery/door/spacepoddoor/multi_tile/four_tile_hor/
	icon = 'icons/obj/doors/1x4blast_hor.dmi'
	var/width = 4
	dir = EAST

/obj/machinery/door/spacepoddoor/multi_tile/three_tile_hor/
	icon = 'icons/obj/doors/1x3blast_hor.dmi'
	var/width = 3
	dir = EAST

/obj/machinery/door/spacepoddoor/multi_tile/two_tile_hor/
	icon = 'icons/obj/doors/1x2blast_hor.dmi'
	var/width = 2
	dir = EAST