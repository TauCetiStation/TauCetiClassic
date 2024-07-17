/obj/machinery/door/unpowered
	autoclose = 0
	var/locked = 0

/obj/machinery/door/unpowered/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/melee/energy/blade))
		return
	return ..()

/obj/machinery/door/unpowered/emag_act(mob/user)
	return FALSE

/obj/machinery/door/unpowered/open_checks(forced)
	if(locked && !forced)
		return FALSE
	return ..()

/obj/machinery/door/unpowered/shuttle
	icon = 'icons/turf/shuttle.dmi'
	name = "door"
	cases = list("дверь", "двери", "двери", "дверь", "дверью", "двери")
	icon_state = "door1"
	opacity = 1
	density = TRUE
