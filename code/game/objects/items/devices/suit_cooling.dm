/obj/item/device/suit_cooling_unit
	name = "portable suit cooling unit"
	desc = "A portable heat sink and liquid cooled radiator that can be hooked up to a space suit's existing temperature controls to provide industrial levels of cooling."
	w_class = ITEM_SIZE_LARGE
	icon = 'icons/obj/device.dmi'
	icon_state = "suitcooler0"
	slot_flags = SLOT_FLAGS_BACK	//you can carry it on your back if you want, but it won't do anything unless attached to suit storage

	//copied from tank.dm
	flags = CONDUCT
	force = 5.0
	throwforce = 10.0
	throw_speed = 1
	throw_range = 4

	origin_tech = "magnets=2;materials=2"

	var/on = 0				//is it turned on?
	var/cover_open = 0		//is the cover open?
	var/obj/item/weapon/stock_parts/cell/cell
	var/max_cooling = 12				//in degrees per second - probably don't need to mess with heat capacity here
	var/charge_consumption = 16.6		//charge per second at max_cooling
	var/thermostat = T20C

	//TODO: make it heat up the surroundings when not in space

/obj/item/device/suit_cooling_unit/atom_init()
	. = ..()
	START_PROCESSING(SSobj, src)

	cell = new/obj/item/weapon/stock_parts/cell()	//comes with the crappy default power cell - high-capacity ones shouldn't be hard to find
	cell.loc = src

/obj/item/device/suit_cooling_unit/process()
	if (!on || !cell)
		return

	if (!ismob(loc))
		return

	if (!attached_to_suit(loc))		//make sure they have a suit and we are attached to it
		return

	var/mob/living/carbon/human/H = loc

	var/efficiency = H.get_pressure_protection()		//you need to have a good seal for effective cooling
	var/env_temp = get_environment_temperature()		//wont save you from a fire
	var/temp_adj = min(H.bodytemperature - max(thermostat, env_temp), max_cooling)

	if (temp_adj < 0.5)	//only cools, doesn't heat, also we don't need extreme precision
		return

	var/charge_usage = (temp_adj/max_cooling)*charge_consumption

	H.bodytemperature -= temp_adj*efficiency

	cell.use(charge_usage)

	if(cell.charge <= 0)
		turn_off()

/obj/item/device/suit_cooling_unit/proc/get_environment_temperature()
	if(ishuman(loc))
		var/mob/living/carbon/human/H = loc
		if(istype(H.loc, /obj/mecha))
			var/obj/mecha/M = H.loc
			return M.return_temperature()
		else if(istype(H.loc, /obj/machinery/atmospherics/components/unary/cryo_cell))
			var/obj/machinery/atmospherics/components/unary/cryo_cell/cryo = H.loc
			var/datum/gas_mixture/G = cryo.AIR1
			return G.temperature

	var/turf/T = get_turf(src)
	if(istype(T, /turf/space))
		return 0	//space has no temperature, this just makes sure the cooling unit works in space

	var/datum/gas_mixture/environment = T.return_air()
	if (!environment)
		return 0

	return environment.temperature

/obj/item/device/suit_cooling_unit/proc/attached_to_suit(mob/M)
	if (!ishuman(M))
		return 0

	var/mob/living/carbon/human/H = M

	if (!H.wear_suit || H.s_store != src)
		return 0

	return 1

/obj/item/device/suit_cooling_unit/proc/turn_on()
	if(!cell)
		return
	if(cell.charge <= 0)
		return

	on = 1
	updateicon()

/obj/item/device/suit_cooling_unit/proc/turn_off()
	if (ismob(src.loc))
		var/mob/M = src.loc
		M.show_message("\The [src] clicks and whines as it powers down.", SHOWMSG_AUDIO)
	on = 0
	updateicon()

/obj/item/device/suit_cooling_unit/attack_self(mob/user)
	if(cover_open && cell)
		if(ishuman(user))
			user.put_in_hands(cell)
		else
			cell.loc = get_turf(loc)

		cell.add_fingerprint(user)
		cell.updateicon()

		to_chat(user, "You remove the [src.cell].")
		src.cell = null
		updateicon()
		return

	//TODO use a UI like the air tanks
	if(on)
		turn_off()
	else
		turn_on()
		if (on)
			to_chat(user, "You switch on the [src].")

/obj/item/device/suit_cooling_unit/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		if(cover_open)
			cover_open = 0
			to_chat(user, "You screw the panel into place.")
		else
			cover_open = 1
			to_chat(user, "You unscrew the panel.")
		updateicon()
		return

	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(cover_open)
			if(cell)
				to_chat(user, "There is a [cell] already installed here.")
			else
				user.drop_from_inventory(I, src)
				cell = I
				to_chat(user, "You insert the [cell].")
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
			if (attached_to_suit(loc))
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
			to_chat(user, "The charge meter reads [round(cell.percent())]%.")
		else
			to_chat(user, "It doesn't have a power cell installed.")

/obj/item/device/suit_cooling_unit/miniature
	name = "Miniature suit cooling device"
	desc = "Minituarized heat sink that can be hooked up to a space suit's existing temperature controls to cool down the suit's internals. Weaker than it's bigger counterpart."
	w_class = ITEM_SIZE_SMALL
	icon = 'icons/obj/device.dmi'
	icon_state = "miniaturesuitcooler0"
	max_cooling = 8
	charge_consumption = 10

/obj/item/device/suit_cooling_unit/miniature/updateicon()
	if (cover_open)
		if (cell)
			icon_state = "miniaturesuitcooler1"
		else
			icon_state = "miniaturesuitcooler2"
	else
		icon_state = "miniaturesuitcooler0"
