/obj/structure/static_portal
	name = "Teleport"
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_enter"
	density = FALSE
	anchored = TRUE
	var/id = null
	var/obj/structure/static_portal/linked_portal

/obj/structure/static_portal/atom_init()
	global.static_portal_list += src
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/structure/static_portal/Destroy()
	global.static_portal_list -= src
	return ..()

/obj/structure/static_portal/atom_init_late()
	find_linked()

/obj/structure/static_portal/Crossed(atom/movable/AM)
	. = ..()
	if(!find_linked())
		return

	AM.forceMove(get_step(linked_portal, AM.dir))
	playsound(src, 'sound/effects/static_portal.ogg', VOL_EFFECTS_MASTER)
	playsound(linked_portal, 'sound/effects/static_portal.ogg', VOL_EFFECTS_MASTER)

/obj/structure/static_portal/proc/find_linked()
	if(linked_portal)
		return TRUE
	for(var/obj/structure/static_portal/SP in global.static_portal_list)
		if(SP != src && SP.id == id)
			linked_portal = SP
			return TRUE
	return FALSE
