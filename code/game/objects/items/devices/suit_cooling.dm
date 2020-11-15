/obj/item/device/suit_cooling_unit
	name = "portable suit cooling unit"
	desc = "A portable heat sink and liquid cooled radiator that can be hooked up to a space suit's existing temperature controls to provide industrial levels of cooling."
	w_class = ITEM_SIZE_LARGE
	icon = 'icons/obj/device.dmi'
	icon_state = "suitcooler0"
	slot_flags = SLOT_FLAGS_BACK  // you can carry it on your back if you want, but it won't do anything unless attached to suit storage

	flags = CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	origin_tech = "magnets=2;materials=2"

	var/on = FALSE
	var/cover_open = FALSE
	var/obj/item/weapon/stock_parts/cell/cell
	var/max_cooling = 18            // in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 22   // charge per second at max_cooling
	var/thermostat = T20C


	var/coolant_consumption = 0.1
	var/fresh_coolant = 0
	var/coolant_purity = 0
	var/datum/reagents/coolant_reagents
	var/list/coolant_reagents_purity = list()

	var/low_coolant_warning_threshold_percent = 5
	var/low_charge_warning_threshold_percent = 0.1
	var/last_low_charge_warning_msg = 0
	var/low_charge_warning_delay = 30 SECONDS

	// TODO: make it heat up the surroundings when not in space

/obj/item/device/suit_cooling_unit/atom_init()
	. = ..()
	create_reagents(100)
	cell = new/obj/item/weapon/stock_parts/cell() // comes with the crappy default power cell - high-capacity ones shouldn't be hard to find
	cell.loc = src

	coolant_reagents_purity["fuel"] = -0.5
	coolant_reagents_purity["whiskey"] = -0.2
	coolant_reagents_purity["patron"] = -0.2
	coolant_reagents_purity["rum"] = -0.2
	coolant_reagents_purity["gin"] = -0.2
	coolant_reagents_purity["tequilla"] = -0.2
	coolant_reagents_purity["nothing"] = 0
	coolant_reagents_purity["kvass"] = 0.1
	coolant_reagents_purity["pwine"] = 0.1
	coolant_reagents_purity["champagne"] = 0.2
	coolant_reagents_purity["vermouth"] = 0.2
	coolant_reagents_purity["thirteenloko"] = 0.3
	coolant_reagents_purity["spacemountainwind"] = 0.4
	coolant_reagents_purity["cola"] = 0.4
	coolant_reagents_purity["dr_gibb"] = 0.4
	coolant_reagents_purity["orangejuice"] = 0.4
	coolant_reagents_purity["space_up"] = 0.4
	coolant_reagents_purity["sodawater"] = 0.4
	coolant_reagents_purity["tonic"] = 0.4
	coolant_reagents_purity["grapejuice"] = 0.4
	coolant_reagents_purity["beer"] = 0.4
	coolant_reagents_purity["water"] = 0.5
	coolant_reagents_purity["holywater"] = 0.6
	coolant_reagents_purity["icecoffee"] = 0.6
	coolant_reagents_purity["icetea"] = 0.6
	coolant_reagents_purity["milkshake"] = 0.6
	coolant_reagents_purity["leporazine"] = 0.7
	coolant_reagents_purity["kelotane"] = 0.7
	coolant_reagents_purity["sterilizine"] = 0.7
	coolant_reagents_purity["dermaline"] = 0.7
	coolant_reagents_purity["hyperzine"] = 0.8
	coolant_reagents_purity["cryoxadone"] = 0.9
	coolant_reagents_purity["coolant"] = 1
	coolant_reagents_purity["adminordrazine"] = 2



/obj/item/device/suit_cooling_unit/Destroy()
	QDEL_NULL(cell)
	STOP_PROCESSING(SSobj, src)
	return ..()



/obj/item/device/suit_cooling_unit/proc/update_coolant()
	var/total_purity = 0
	fresh_coolant = 0
	coolant_purity = 0
	for (var/datum/reagent/current_reagent in src.reagents.reagent_list)
		if (!current_reagent)
			continue
		var/cur_purity = coolant_reagents_purity[current_reagent.id]
		if(!cur_purity)
			cur_purity = 0.1
		total_purity += cur_purity * current_reagent.volume
		fresh_coolant += current_reagent.volume
	if(total_purity && fresh_coolant)
		coolant_purity = total_purity / fresh_coolant

/obj/item/device/suit_cooling_unit/proc/turn_on()
	if (!cell || cell.charge <= 0)
		return

	visible_message("<span class='notice'>\The [src] starts to do a quiet buzzling as it powers up.</span>")
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	on = TRUE
	updateicon()

	START_PROCESSING(SSobj, src)

/obj/item/device/suit_cooling_unit/proc/turn_off()
	visible_message("<span class='notice'>\The [src] clicks and whines as it powers down.</span>")
	playsound(src, 'sound/machines/quite_beep.ogg', VOL_EFFECTS_MASTER)
	on = FALSE
	updateicon()

	STOP_PROCESSING(SSobj, src)

/obj/item/device/suit_cooling_unit/process()
	if (!on || !cell || !is_attached(loc))
		return

	var/mob/living/carbon/human/H = loc

	if (try_cool_user(H))
		check_charge_usage(H)

/obj/item/device/suit_cooling_unit/proc/is_attached(mob/living/carbon/human/user)
	return istype(user) && (user.s_store || user.belt || user.back) == src


/obj/item/device/suit_cooling_unit/proc/try_cool_user(mob/living/carbon/human/user)
	var/env_temp = get_environment_temperature(user)     // wont save you from a fire
	var/temp_adj = min(user.bodytemperature - max(thermostat, env_temp), max_cooling)

	if (temp_adj < 0.5) // only cools, doesn't heat, also we don't need extreme precision
		return FALSE
	
	var/charge_usage = (temp_adj / max_cooling) * charge_consumption 
	if (fresh_coolant > 0)
		fresh_coolant -= coolant_consumption 
		user.bodytemperature -= temp_adj * coolant_purity
	else
		user.bodytemperature -= temp_adj * 0.1

	cell.use(charge_usage)

	return TRUE

/obj/item/device/suit_cooling_unit/proc/get_environment_temperature(mob/living/carbon/human/user)
	if (istype(user.loc, /obj/mecha))
		var/obj/mecha/M = user.loc
		return M.return_temperature()
	else if (istype(user.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
		var/obj/machinery/atmospherics/components/unary/cryo_cell/cryo = user.loc
		var/datum/gas_mixture/G = cryo.AIR1
		return G.temperature

	var/turf/T = get_turf(user)

	if(istype(T, /turf/space))
		return 0 //space has no temperature, this just makes sure the cooling unit works in space

	var/datum/gas_mixture/environment = T.return_air()

	if (!environment)
		return 0

	return environment.temperature

/obj/item/device/suit_cooling_unit/proc/check_charge_usage(mob/living/carbon/human/user)
	if (cell.charge <= 0)
		turn_off()
		return
	
	if (cell.charge <= (cell.maxcharge * low_charge_warning_threshold_percent) && last_low_charge_warning_msg < world.time)
		to_chat(user, "<span class='warning'>Cooling unit charge is below [round(cell.percent())]%.</span>")
		playsound(user, 'sound/rig/shortbeep.ogg', VOL_EFFECTS_MASTER)
		last_low_charge_warning_msg = world.time + low_charge_warning_delay

	if (fresh_coolant < low_coolant_warning_threshold_percent && last_low_charge_warning_msg < world.time)
		to_chat(user, "<span class='warning'>Cooling unit coolant is below [round(fresh_coolant)]%.</span>")
		playsound(user, 'sound/rig/shortbeep.ogg', VOL_EFFECTS_MASTER)
		last_low_charge_warning_msg = world.time + low_charge_warning_delay


/obj/item/device/suit_cooling_unit/attack_self(mob/user)
	if (cover_open && cell)
		if (ishuman(user))
			user.put_in_hands(cell)
		else
			cell.forceMove(get_turf(loc))

		cell.add_fingerprint(user)
		cell.updateicon()
		cell = null

		to_chat(user, "<span class='info'>You remove \the [cell].</span>")
		updateicon()
		return

	//TODO use a UI like the air tanks
	if(on)
		turn_off()
	else
		turn_on()

/obj/item/device/suit_cooling_unit/attackby(obj/item/I, mob/user, params)

	if(istype(I, /obj/item/weapon/reagent_containers/))
		var/choice = alert("What do you want to do?","Cooling unit","Add coolant","Empty coolant")
		if(choice == "Add coolant")
			var/obj/item/weapon/reagent_containers/G = I
			var/amount_transferred = min(src.reagents.maximum_volume - src.reagents.total_volume, G.reagents.total_volume)
			G.reagents.trans_to(src, amount_transferred)
			to_chat(user, "<span class='info'>You empty [amount_transferred]u of coolant into [src].</span>")
			update_coolant()
			return

		else if(choice == "Empty coolant")
			var/obj/item/weapon/reagent_containers/G = I
			var/amount_transferred = min(G.reagents.maximum_volume - G.reagents.total_volume, src.reagents.total_volume)
			src.reagents.trans_to(G, amount_transferred)
			to_chat(user, "<span class='info'>You remove [amount_transferred]u of coolant from [src].</span>")
			update_coolant()
			return

	if (isscrewdriver(I))
		if (cover_open)
			cover_open = FALSE
			to_chat(user, "<span class='info'>You screw the panel into place.</span>")
		else
			cover_open = TRUE
			to_chat(user, "<span class='info'>You unscrew the panel.</span>")
		updateicon()
		return

	if (istype(I, /obj/item/weapon/stock_parts/cell))
		if (cover_open)
			if (cell)
				to_chat(user, "<span class='info'>There is a [cell] already installed here.<span>")
			else
				user.drop_from_inventory(I, src)
				cell = I
				to_chat(user, "<span class='info'>You insert the [cell].</span>")
		updateicon()
		return

	return ..()

/obj/item/device/suit_cooling_unit/proc/updateicon()
	if (cover_open)
		if (cell)
			icon_state = "suitcooler1"
		else
			icon_state = "suitcooler2"
	else
		icon_state = "suitcooler0"

/obj/item/device/suit_cooling_unit/examine(mob/user)
	..()
	if (src in view(1, user))
		if (on)
			if (is_attached(user))
				to_chat(user, "It's switched on and running.")
			else
				to_chat(user, "It's switched on, but not attached to anything.")
		else
			to_chat(user, "It is switched off.")

		if (cover_open)
			if(cell)
				to_chat(user, "The panel is open, exposing the [cell].")
			else
				to_chat(user, "The panel is open.")

		if (cell)
			to_chat(user, "The charge meter reads [round(cell.percent())]%. Coolant remaining [round(fresh_coolant)]%.")
		else
			to_chat(user, "It doesn't have a power cell installed. Coolant remaining [round(fresh_coolant)]%.")
		

/obj/item/device/suit_cooling_unit/miniature
	name = "Miniature suit cooling device"
	desc = "Minituarized heat sink that can be hooked up to a space suit's existing temperature controls to cool down the suit's internals. Weaker than it's bigger counterpart."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/device.dmi'
	icon_state = "miniaturesuitcooler0"
	slot_flags = SLOT_FLAGS_BELT
	max_cooling = 10
	charge_consumption = 14

/obj/item/device/suit_cooling_unit/miniature/updateicon()
	if (cover_open)
		if (cell)
			icon_state = "miniaturesuitcooler1"
		else
			icon_state = "miniaturesuitcooler2"
	else
		icon_state = "miniaturesuitcooler0"
