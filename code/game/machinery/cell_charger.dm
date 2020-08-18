/obj/machinery/cell_charger
	name = "cell charger"
	desc = "It charges power cells."
	icon = 'icons/obj/power.dmi'
	icon_state = "ccharger0"
	anchored = 1
	use_power = IDLE_POWER_USE
	idle_power_usage = 5
	active_power_usage = 60
	interact_offline = TRUE
	var/obj/item/weapon/stock_parts/cell/charging = null
	var/chargelevel = -1
	var/efficiency = 0.875	//<1.0 means some power is lost in the charging process, >1.0 means free energy.

/obj/machinery/cell_charger/proc/updateicon()
	icon_state = "ccharger[charging ? 1 : 0]"

	if(charging && !(stat & (BROKEN|NOPOWER)) )

		var/newlevel = 	round(charging.percent() * 4.0 / 99)
		//world << "nl: [newlevel]"

		if(chargelevel != newlevel)

			cut_overlays()
			add_overlay("ccharger-o[newlevel]")

			chargelevel = newlevel
	else
		cut_overlays()
/obj/machinery/cell_charger/examine(mob/user)
	..()
	to_chat(user, "There's [charging ? "a" : "no"] cell in the charger.")
	if(charging)
		to_chat(user, "Current charge: [charging.charge]")

/obj/machinery/cell_charger/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/stock_parts/cell) && anchored)
		if(charging)
			to_chat(user, "<span class='warning'>There is already a cell in the charger.</span>")
			return
		else
			var/area/a = loc.loc // Gets our locations location, like a dream within a dream
			if(!isarea(a))
				return
			if(a.power_equip == 0) // There's no APC in this area, don't try to cheat power!
				to_chat(user, "<span class='warning'>The [name] blinks red as you try to insert the cell!</span>")
				return

			user.drop_item()
			W.loc = src
			charging = W
			user.visible_message("[user] inserts a cell into the charger.", "You insert a cell into the charger.")
			chargelevel = -1
		updateicon()
	else if(iswrench(W))
		if(charging)
			to_chat(user, "<span class='warning'>Remove the cell first!</span>")
			return

		anchored = !anchored
		to_chat(user, "You [anchored ? "attach" : "detach"] the cell charger [anchored ? "to" : "from"] the ground")
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)

/obj/machinery/cell_charger/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(charging)
		usr.put_in_hands(charging)
		charging.add_fingerprint(user)
		charging.updateicon()

		charging = null
		user.visible_message("[user] removes the cell from the charger.", "You remove the cell from the charger.")
		chargelevel = -1
		updateicon()

/obj/machinery/cell_charger/attack_ai(mob/user)
	if(IsAdminGhost(user)) // why not?
		return ..()

/obj/machinery/cell_charger/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		return
	if(charging)
		charging.emplode(severity)
	..(severity)


/obj/machinery/cell_charger/process()
	//world << "ccpt [charging] [stat]"
	if(!charging || (stat & (BROKEN|NOPOWER)) || !anchored)
		return

	var/power_used = 100000	//for 200 units of charge. Yes, thats right, 100 kW. Is something wrong with CELLRATE?

	power_used = charging.give(power_used*CELLRATE*efficiency)
	use_power(power_used)

	updateicon()
