/obj/machinery/recharge_station
	name = "cyborg recharging station"
	icon = 'icons/obj/objects.dmi'
	icon_state = "borgcharger0"
	density = 0
	anchored = 1.0
	use_power = 1
	idle_power_usage = 50
	active_power_usage = 50
	var/max_internal_charge = 15000 		// Two charged borgs in a row with default cell
	var/current_internal_charge = 15000 	// Starts charged, to prevent power surges on round start
	var/charging_cap_active = 25000			// Active Cap - When cyborg is inside
	var/charging_cap_passive = 2500			// Passive Cap - Recharging internal capacitor when no cyborg is inside
	var/icon_update_tick = 0				// Used to update icon only once every 10 ticks
	var/construct_op = 0
	var/circuitboard = "/obj/item/weapon/circuitboard/cyborgrecharger"
	var/locked = 1
	var/open = 1
	req_access = list(access_robotics)
	var/recharge_speed
	var/repairs


/obj/machinery/recharge_station/New()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cyborgrecharger(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/cell/high(null)
	RefreshParts()
	build_icon()
	update_icon()

/obj/machinery/recharge_station/RefreshParts()
	recharge_speed = 0
	repairs = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		recharge_speed += C.rating * 100
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		repairs += M.rating - 1
	for(var/obj/item/weapon/cell/C in component_parts)
		recharge_speed *= C.maxcharge / 10000

/obj/machinery/recharge_station/process()
	if(stat & (BROKEN))
		return
	if((stat & (NOPOWER)) && !current_internal_charge) // No Power.
		return

	var/chargemode = 0
	if(src.occupant)
		process_occupant()
		chargemode = 1
	// Power Stuff

	if(stat & NOPOWER)
		current_internal_charge = max(0, (current_internal_charge - (50 * CELLRATE))) // Internal Circuitry, 50W load. No power - Runs from internal cell
		return // No external power = No charging

	if(max_internal_charge < current_internal_charge)
		current_internal_charge = max_internal_charge// Safety check if varedit adminbus or something screws up
	// Calculating amount of power to draw
	var/charge_diff = max_internal_charge - current_internal_charge // OK we have charge differences
	charge_diff = charge_diff / CELLRATE 							// Deconvert from Charge to Joules
	if(chargemode)													// Decide if use passive or active power
		charge_diff = between(0, charge_diff, charging_cap_active)	// Trim the values to limits
	else															// We should have load for this tick in Watts
		charge_diff = between(0, charge_diff, charging_cap_passive)

	charge_diff += 50 // 50W for circuitry

	if(idle_power_usage != charge_diff) // Force update, but only when our power usage changed this tick.
		idle_power_usage = charge_diff
		update_use_power(1,1)

	current_internal_charge = min((current_internal_charge + ((charge_diff - 50) * CELLRATE)), max_internal_charge)

	if(icon_update_tick >= 10)
		update_icon()
		icon_update_tick = 0
	else
		icon_update_tick++

	return 1


/obj/machinery/recharge_station/allow_drop()
	return 0

/obj/machinery/recharge_station/examine()
	usr << "The charge meter reads: [round(chargepercentage())]%"

/obj/machinery/recharge_station/proc/chargepercentage()
	return ((current_internal_charge / max_internal_charge) * 100)

/obj/machinery/recharge_station/relaymove(mob/user as mob)
	if(user.stat)
		return
	open_machine()

/obj/machinery/recharge_station/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return
	if(occupant)
		occupant.emp_act(severity)
	open_machine()
	..(severity)

/obj/machinery/recharge_station/attack_paw(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attack_ai(user as mob)
	return attack_hand(user)

/obj/machinery/recharge_station/attackby(obj/item/P as obj, mob/user as mob)
	if (istype(P, /obj/item/weapon/card/id/))
		if (construct_op == 0)
			if (src.allowed(user))
				if	(emagged == 0)
					if (locked == 1)
						user << "You turn off the ID lock."
						locked = 0
						return
					else if (locked == 0)
						user << "You turn on the ID lock."
						locked = 1
						return
				else
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(2, 1, src)
					s.start()
					user << "\red The ID lock is broken!"
					return
			return
		else
			user << "The ID lock can't be accessed in this state."
	else if (istype(P, /obj/item/weapon/card/emag))
		if (construct_op == 0)
			if (emagged == 0)
				emagged = 1
				locked = 0
				src.req_access = null
				user << "\red You break the ID lock on the [src]."
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(2, 1, src)
				s.start()
				return
		else
			user << "The ID lock can't be accessed in this state."

	if(locked == 0)
		if(open == 1)
			switch(construct_op)
				if(0)
					if(istype(P, /obj/item/weapon/screwdriver))
						user << "You open the circuit cover."
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
						icon_state = "borgdecon1"
						construct_op ++
				if(1)
					if(istype(P, /obj/item/weapon/screwdriver))
						user << "You close the circuit cover."
						playsound(src.loc, 'sound/items/Screwdriver.ogg', 50, 1)
						icon_state = "borgcharger0"
						construct_op --
					if(istype(P, /obj/item/weapon/wrench))
						user << "You dislodge the internal plating."
						playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
						icon_state = "borgdecon2"
						construct_op ++
				if(2)
					if(istype(P, /obj/item/weapon/wrench))
						user << "You secure the internal plating."
						playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
						icon_state = "borgdecon1"
						construct_op --
					if(istype(P, /obj/item/weapon/wirecutters))
						playsound(src.loc, 'sound/items/Wirecutter.ogg', 50, 1)
						user << "You remove the cables."
						icon_state = "borgdecon3"
						construct_op ++
						var/obj/item/weapon/cable_coil/A = new /obj/item/weapon/cable_coil( user.loc )
						A.amount = 5
						stat |= BROKEN // the machine's been borked!
				if(3)
					if(istype(P, /obj/item/weapon/cable_coil))
						var/obj/item/weapon/cable_coil/A = P
						if(A.amount >= 5)
							user << "You insert the cables."
							A.amount -= 5
							if(A.amount <= 0)
								user.drop_item()
								qdel(A)
							icon_state = "borgdecon2"
							construct_op --
							stat &= ~BROKEN // the machine's not borked anymore!
						else
							user << "You need more cable"
					if(istype(P, /obj/item/weapon/crowbar))
						user << "You begin prying out the circuit board and components..."
						playsound(src.loc, 'sound/items/Crowbar.ogg', 50, 1)
						if(do_after(user,60,target=src))
							user << "You finish prying out the components."

							// Drop all the component stuff
							if(contents.len > 0)
								for(var/obj/x in src)
									x.loc = user.loc
							else

								// If the machine wasn't made during runtime, probably doesn't have components:
								// manually find the components and drop them!
								var/newpath = text2path(circuitboard)
								var/obj/item/weapon/circuitboard/C = new newpath
								for(var/I in C.req_components)
									for(var/i = 1, i <= C.req_components[I], i++)
										newpath = text2path(I)
										var/obj/item/s = new newpath
										s.loc = user.loc
										if(istype(P, /obj/item/weapon/cable_coil))
											var/obj/item/weapon/cable_coil/A = P
											A.amount = 1

								// Drop a circuit board too
								C.loc = user.loc

							// Create a machine frame and delete the current machine
							var/obj/machinery/constructable_frame/machine_frame/F = new
							F.loc = src.loc
							qdel(src)
				else
					user << "This needs to be open first."
	else
		user << "This needs to be unlocked first."

/obj/machinery/recharge_station/attack_hand(mob/user)
	if(..())	return
	if(construct_op == 0)
		toggle_open()
	else
		user << "The recharger can't be closed in this state."
	add_fingerprint(user)

/obj/machinery/recharge_station/proc/toggle_open()
	if(open)
		close_machine()
	else
		open_machine()

/obj/machinery/recharge_station/open_machine()
	if(occupant)
		if (occupant.client)
			occupant.client.eye = occupant
			occupant.client.perspective = MOB_PERSPECTIVE
		occupant.forceMove(loc)
		occupant = null
		use_power = 1
	open = 1
	density = 0
	build_icon()

/obj/machinery/recharge_station/close_machine()
	for(var/mob/living/silicon/robot/R in loc)
		R.stop_pulling()
		if(R.client)
			R.client.eye = src
			R.client.perspective = EYE_PERSPECTIVE
		R.forceMove(src)
		occupant = R
		use_power = 2
		add_fingerprint(R)
		break
	open = 0
	density = 1
	build_icon()

/obj/machinery/recharge_station/update_icon()
	..()
	overlays.Cut()
	switch(round(chargepercentage()))
		if(1 to 20)
			overlays += image('icons/obj/objects.dmi', "statn_c0")
		if(21 to 40)
			overlays += image('icons/obj/objects.dmi', "statn_c20")
		if(41 to 60)
			overlays += image('icons/obj/objects.dmi', "statn_c40")
		if(61 to 80)
			overlays += image('icons/obj/objects.dmi', "statn_c60")
		if(81 to 98)
			overlays += image('icons/obj/objects.dmi', "statn_c80")
		if(99 to 110)
			overlays += image('icons/obj/objects.dmi', "statn_c100")

/obj/machinery/recharge_station/proc/build_icon()
	if(NOPOWER|BROKEN)
		if(open)
			icon_state = "borgcharger0"
		else
			if(occupant)
				icon_state = "borgcharger1"
			else
				icon_state = "borgcharger2"
	else
		icon_state = "borgcharger0"

/obj/machinery/recharge_station/proc/process_occupant()
	if(src.occupant)
		if (istype(occupant, /mob/living/silicon/robot))
			var/mob/living/silicon/robot/R = occupant
			if(R.module)
				R.module.respawn_consumable(R)
			if(repairs)
				R.heal_organ_damage(repairs, repairs - 1)
			if(!R.cell)
				return
			else if(R.cell.charge >= R.cell.maxcharge)
				var/diff = min(R.cell.maxcharge - R.cell.charge, 250) 	// Capped at 250 charge / tick
				diff = min(diff, current_internal_charge) 				// No over-discharging
				R.cell.give(diff)
				current_internal_charge -= diff
				return
			else
				R.cell.charge = min(R.cell.charge + recharge_speed, R.cell.maxcharge)
				return
