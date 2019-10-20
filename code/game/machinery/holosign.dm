////////////////////HOLOSIGN///////////////////////////////////////
/obj/machinery/holosign
	name = "holosign"
	desc = "Small wall-mounted holographic projector."
	icon = 'icons/obj/holosign.dmi'
	icon_state = "sign_off"
	layer = 4
	var/lit = 0
	var/id = null
	var/on_icon = "sign_on"

/obj/machinery/holosign/atom_init()
	. = ..()
	holosign_list += src

/obj/machinery/holosign/Destroy()
	holosign_list -= src
	return ..()

/obj/machinery/holosign/proc/toggle()
	if (stat & (BROKEN|NOPOWER))
		return
	lit = !lit
	update_icon()

/obj/machinery/holosign/update_icon()
	if (!lit)
		icon_state = "sign_off"
	else
		icon_state = on_icon

/obj/machinery/holosign/power_change()
	if (stat & NOPOWER)
		lit = 0
	update_icon()
	update_power_use()

/obj/machinery/holosign/surgery
	name = "surgery holosign"
	desc = "Small wall-mounted holographic projector. This one reads SURGERY."
	on_icon = "surgery"
////////////////////SWITCH///////////////////////////////////////

/obj/machinery/holosign_switch
	name = "holosign switch"
	icon = 'icons/obj/power.dmi'
	icon_state = "light1"
	desc = "A remote control switch for holosign."
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 2
	active_power_usage = 4
	var/id = null
	var/active = FALSE

/obj/machinery/holosign_switch/attackby(obj/item/weapon/W, mob/user)
	if(istype(W, /obj/item/device/detective_scanner))
		return
	return attack_hand(user)

/obj/machinery/holosign_switch/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	use_power(5)
	user.SetNextMove(CLICK_CD_INTERACT)

	active = !active
	if(active)
		icon_state = "light1"
	else
		icon_state = "light0"

	for(var/obj/machinery/holosign/M in holosign_list)
		if (M.id == src.id)
			spawn( 0 )
				M.toggle()
				return
