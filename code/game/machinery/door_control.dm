/obj/machinery/door_control
	name = "remote door-control"
	desc = "It controls doors, remotely."
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "doorctrl0"
	desc = "A remote control-switch for a door."
	power_channel = ENVIRON
	anchored = TRUE
	use_power = 1
	idle_power_usage = 2
	active_power_usage = 4
	var/id = null
	var/range = 10
	var/normaldoorcontrol = FALSE
	var/desiredstate = 0 // Zero is closed, 1 is open.
	var/specialfunctions = 1

/obj/machinery/door_control/allowed_fail(mob/user)
	playsound(src, 'sound/items/buttonswitch.ogg', 20, 1, 1)
	flick("doorctrl-denied",src)

/obj/machinery/door_control/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	if(istype(W, /obj/item/weapon/card/emag))
		req_access = list()
		user.SetNextMove(CLICK_CD_INTERACT)
		req_one_access = list()
		playsound(src.loc, "sparks", 100, 1)
	return src.attack_hand(user)

/obj/machinery/door_control/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_INTERACT)
	playsound(src, 'sound/items/buttonswitch.ogg', 20, 1, 1)
	use_power(5)
	icon_state = "doorctrl1"

	if(normaldoorcontrol)
		for(var/obj/machinery/door/airlock/D in range(range))
			if(D.id_tag == src.id)
				if(specialfunctions & OPEN)
					if (D.density)
						spawn(0)
							D.open()
							return
					else
						spawn(0)
							D.close()
							return
				if(desiredstate == 1)
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 1
					if(specialfunctions & BOLTS)
						D.bolt()
					if(specialfunctions & SHOCK)
						D.secondsElectrified = -1
					if(specialfunctions & SAFE)
						D.safe = 0
				else
					if(specialfunctions & IDSCAN)
						D.aiDisabledIdScanner = 0
					if(specialfunctions & BOLTS)
						if(!D.isAllPowerCut() && D.hasPower())
							D.unbolt()
					if(specialfunctions & SHOCK)
						D.secondsElectrified = 0
					if(specialfunctions & SAFE)
						D.safe = 1

	else
		for(var/obj/machinery/door/poddoor/M in poddoor_list)
			if (M.id == src.id)
				if (M.density)
					spawn( 0 )
						M.open()
						return
				else
					spawn( 0 )
						M.close()
						return

	desiredstate = !desiredstate
	spawn(15)
		if(!(stat & NOPOWER))
			icon_state = "doorctrl0"

/obj/machinery/door_control/power_change()
	..()
	if(stat & NOPOWER)
		icon_state = "doorctrl-p"
	else
		icon_state = "doorctrl0"

/obj/machinery/driver_button/attackby(obj/item/weapon/W, mob/user)

	if(istype(W, /obj/item/device/detective_scanner))
		return
	return src.attack_hand(user)

/obj/machinery/driver_button/attack_hand(mob/user)
	if(..() || active)
		return 1

	use_power(5)
	user.SetNextMove(CLICK_CD_INTERACT)

	active = 1
	icon_state = "launcheract"

	for(var/obj/machinery/door/poddoor/M in poddoor_list)
		if (M.id == src.id)
			spawn( 0 )
				M.open()
				return

	sleep(20)

	for(var/obj/machinery/mass_driver/M in mass_driver_list)
		if(M.id == src.id)
			M.drive()

	sleep(50)

	for(var/obj/machinery/door/poddoor/M in poddoor_list)
		if (M.id == src.id)
			spawn( 0 )
				M.close()
				return

	icon_state = "launcherbtt"
	active = 0
