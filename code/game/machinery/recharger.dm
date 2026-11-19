/obj/machinery/recharger
	name = "recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "recharger0"
	desc = "A charging dock for energy based weaponry."
	anchored = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 4
	active_power_usage = 250
	interact_offline = TRUE
	var/obj/item/weapon/charging = null
	var/recharge_coeff = 1
	var/static/list/allowed_items = list(
                                        /obj/item/weapon/gun/energy,
                                        /obj/item/weapon/melee/baton,
                                        /obj/item/weapon/shockpaddles/standalone,
                                        /obj/item/ammo_box/magazine/plasma
                                    )
	var/base_icon_state = "recharger"

	plug = /datum/plug/energy/male

/obj/machinery/recharger/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/recharger()
	component_parts += new /obj/item/weapon/stock_parts/capacitor()
	RefreshParts()

/obj/machinery/recharger/RefreshParts()
	..()

	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_coeff = C.rating

/obj/machinery/recharger/attackby(obj/item/weapon/G, mob/user)
	if(issilicon(user) && is_type_in_list(G, allowed_items))
		return

	if(iswrenching(G))
		if(plug && plug.connected)
			to_chat(user, "<span class='warning'>Remove the plug first!</span>")
			return
		anchored = !anchored
		to_chat(user, "You [anchored ? "attached" : "detached"] the recharger.")
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
	if (anchored && plug && !plug.connected)
		if(default_deconstruction_screwdriver(user, istype(src, /obj/machinery/recharger/wallcharger) ? "wrechargeropen" : "rechargeropen", istype(src, /obj/machinery/recharger/wallcharger) ? "wrecharger0" : "recharger0", G))
			return

		if(panel_open && isprying(G))
			default_deconstruction_crowbar(G)
			return

/obj/machinery/recharger/attack_ai(mob/user)
	if(IsAdminGhost(user))
		return ..()
	return 1

/obj/machinery/recharger/process()
	if(stat & (NOPOWER|BROKEN) || !anchored)
		return

	if(plug && plug.connected)
		set_power_use(ACTIVE_POWER_USE)

		if(istype(plug.connected.master, /obj/item/weapon/gun/energy))
			var/obj/item/weapon/gun/energy/E = plug.connected.master
			if(E.power_supply.charge < E.power_supply.maxcharge)
				//E.power_supply.give(E.power_supply.chargerate * recharge_coeff)
				E.power_supply.give(100 * recharge_coeff)
				icon_state = "[base_icon_state]1"
				use_power(250 * recharge_coeff)
				E.update_icon()
			else
				icon_state = "[base_icon_state]2"
			return
		if(istype(plug.connected.master, /obj/item/weapon/melee/baton))
			var/obj/item/weapon/melee/baton/B = plug.connected.master
			//if(B.bcell.give(B.bcell.chargerate * recharge_coeff))
			if(B.charges < initial(B.charges))
				B.charges++
				icon_state = "[base_icon_state]1"
				use_power(200 * recharge_coeff)
				B.update_icon()
			else
				icon_state = "[base_icon_state]2"
			return
		if(istype(plug.connected.master, /obj/item/weapon/shockpaddles/standalone))
			var/obj/item/weapon/shockpaddles/standalone/D = plug.connected.master
			if(D.charges < initial(D.charges))
				D.charges++
				icon_state = "[base_icon_state]1"
				use_power(200 * recharge_coeff)
				D.update_icon()
			else
				icon_state = "[base_icon_state]2"
			return
		if(istype(plug.connected.master, /obj/item/ammo_box/magazine/plasma))
			var/obj/item/ammo_box/magazine/plasma/M = plug.connected.master
			if(M.power_supply.charge < M.power_supply.maxcharge)
				M.power_supply.give(2000 * recharge_coeff) // fast charge (and yes, this can be abused to charge cells faster, but it means that you need a free magazine for that purpose).
				icon_state = "[base_icon_state]1"
				use_power(5000 * recharge_coeff)
				M.update_icon()
			else
				icon_state = "[base_icon_state]2"
	else
		update_icon()

/obj/machinery/recharger/emp_act(severity)
	if(stat & (NOPOWER|BROKEN) || !anchored)
		..(severity)
		return

	if(!plug || !plug.connected)
		return ..(severity)

	if(istype(plug.connected.master,  /obj/item/weapon/gun/energy))
		var/obj/item/weapon/gun/energy/E = plug.connected.master
		if(E.power_supply)
			E.power_supply.emplode(severity)

	else if(istype(plug.connected.master, /obj/item/weapon/melee/baton))
		var/obj/item/weapon/melee/baton/B = plug.connected.master
		B.charges = 0
	..(severity)

/obj/machinery/recharger/update_icon()	//we have an update_icon() in addition to the stuff in process to make it feel a tiny bit snappier.
	if(stat & (NOPOWER|BROKEN) || !anchored)
		icon_state = "[base_icon_state]off"
	else if(panel_open)
		icon_state = "[base_icon_state]open"
	else if(plug && plug.connected)
		icon_state = "[base_icon_state]1"
	else
		icon_state = "[base_icon_state]0"

/obj/machinery/recharger/wallcharger
	name = "wall recharger"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "wrecharger0"

	base_icon_state = "wrecharger"
