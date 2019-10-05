/obj/item/weapon/pai_cable/afterattack(M, mob/user)
	if(!src.machine)
		if(is_type_in_list(M, list(/obj/machinery/door, /obj/machinery/camera, /obj/machinery/autolathe, /obj/machinery/newscaster, /obj/machinery/vending, /obj/machinery/alarm, /obj/machinery/space_heater, /obj/machinery/bot, /obj/item/device/pda, /obj/item/device/paicard)))
			user.visible_message("[user] inserts [src] into a data port on [M].", "You insert [src] into a data port on [M].", "You hear the satisfying click of a wire jack fastening into place.")
			user.drop_item()
			src.loc = M
			src.machine = M
		else
			user.visible_message("[user] dumbly fumbles to find a place on [M] to plug in [src].", "There aren't any ports on [M] that match the jack belonging to [src].")
	return

/obj/item/weapon/pai_cable/attack()
	return
