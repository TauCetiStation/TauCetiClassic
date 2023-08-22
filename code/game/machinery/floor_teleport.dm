ADD_TO_GLOBAL_LIST(/obj/machinery/floor_teleport, floor_teleport_list)

/obj/machinery/floor_teleport
	name = "floor teleport"
	desc = "It's a teleport to travel around station's departments. Use it to send everything on it to another teleport with the same ID."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "floorpad"
	anchored = TRUE
	var/teleport_id = null
	var/teleport_to_id = null
	var/last_teleport_time = 0

/obj/machinery/floor_teleport/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	for(var/obj/machinery/floor_teleport/F in floor_teleport_list)
		if(F.teleport_id == teleport_to_id)
			for(var/obj/O in loc)
				O.forceMove(F.loc)