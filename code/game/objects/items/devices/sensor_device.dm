/obj/item/device/sensor_device
	name = "handheld crew monitor"
	desc = "A miniature machine that tracks suit sensors across the station."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = ITEM_SIZE_SMALL
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=3;materials=3;magnets=3"
	var/obj/nano_module/crew_monitor/crew_monitor

/obj/item/device/sensor_device/atom_init()
	crew_monitor = new(src)
	. = ..()

/obj/item/device/sensor_device/Destroy()
	qdel(crew_monitor)
	crew_monitor = null
	return ..()

/obj/item/device/sensor_device/attack_self(mob/user)
	ui_interact(user)

/obj/item/device/sensor_device/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null, force_open = 1)
	crew_monitor.ui_interact(user, ui_key, ui, force_open)
