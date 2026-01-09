/obj/structure/static_portal
	name = "Teleport"
	icon = 'icons/obj/objects.dmi'
	icon_state = "bluespace_wormhole_enter"
	density = FALSE
	anchored = TRUE
	var/id = null
	var/obj/structure/static_portal/linked_portal
	var/list/sounds = list(
		'sound/effects/instagib/teleport D.ogg',
		'sound/effects/instagib/teleport E.ogg',
		'sound/effects/instagib/teleport F.ogg',
		'sound/effects/instagib/teleport G.ogg')

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

	AM.forceMove(get_step(linked_portal, linked_portal.dir))
	playsound(src, pick(sounds), VOL_EFFECTS_MASTER, 25)
	playsound(linked_portal, pick(sounds), VOL_EFFECTS_MASTER, 25)

/obj/structure/static_portal/proc/find_linked()
	if(linked_portal)
		return TRUE
	for(var/obj/structure/static_portal/SP in global.static_portal_list)
		if(SP.id == id)
			linked_portal = SP
			return TRUE
	return FALSE
