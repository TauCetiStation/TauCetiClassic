//Terribly sorry for the code doubling, but things go derpy  otherwise.
/obj/machinery/door/airlock/multi_tile
	dir = EAST
	width = 2

/obj/machinery/door/airlock/multi_tile/attackby(C, mob/user)
	if(istype(C, /obj/item/weapon/airlock_painter))
		to_chat(user, "\red This airlock cannot be painted.")//because we don't have sprites

	else
		..()
	return

/obj/machinery/door/airlock/multi_tile/glass
	name = "Glass Airlock"
	icon = 'icons/obj/doors/Door2x1glass.dmi'
	opacity = 0
	glass = 1
	assembly_type = "obj/structure/door_assembly/multi_tile"

/obj/machinery/door/airlock/multi_tile/metal
	name = "Metal Airlock"
	icon = 'icons/obj/doors/Door2x1metal.dmi'
	opacity = 1
	glass = 0
	assembly_type = "obj/structure/door_assembly/multi_tile"
