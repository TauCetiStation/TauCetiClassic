/obj/item/device/sensor_device
	name = "handheld crew monitor"
	cases = list("ручной монитор состояния экипажа","ручного монитора состояния экипажа","ручному монитору состояния экипажа","ручной монитор состояния экипажа","ручным монитором состояния экипажа","ручном мониторе состояния экипажа")
	desc = "Устройство для отслеживания экипажа на станции."
	icon = 'icons/obj/device.dmi'
	icon_state = "scanner"
	w_class = SIZE_TINY
	slot_flags = SLOT_FLAGS_BELT
	origin_tech = "programming=3;materials=3;magnets=3"
	var/obj/crew_monitor_module/crew_monitor

/obj/item/device/sensor_device/atom_init()
	crew_monitor = new(src)
	. = ..()

/obj/item/device/sensor_device/Destroy()
	qdel(crew_monitor)
	crew_monitor = null
	return ..()

/obj/item/device/sensor_device/attack_self(mob/user)
	tgui_interact(user)

/obj/item/device/sensor_device/tgui_interact(mob/user, datum/tgui/ui)
	crew_monitor.tgui_interact(user, ui)
