
/obj/machinery/portable_atmospherics
	name = "atmoalter"
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_TOPIC

	var/datum/gas_mixture/air_contents
	var/obj/machinery/atmospherics/components/unary/portables_connector/connected_port
	var/obj/item/weapon/tank/holding

	var/volume = 0

	var/start_pressure = ONE_ATMOSPHERE
	var/maximum_pressure = 90 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/atom_init()
	. = ..()
	SSair.atmos_machinery += src

	air_contents = new
	air_contents.volume = volume
	air_contents.temperature = T20C

/obj/machinery/portable_atmospherics/Destroy()
	SSair.atmos_machinery -= src

	disconnect()
	QDEL_NULL(air_contents)
	QDEL_NULL(holding)

	return ..()

/obj/machinery/portable_atmospherics/process_atmos()
	if(!connected_port) // Pipe network handles reactions if connected.
		air_contents.react()
	else
		update_icon()

/obj/machinery/portable_atmospherics/proc/StandardAirMix()
	return list(
		"oxygen" = O2STANDARD * MolesForPressure(),
		"nitrogen" = N2STANDARD *  MolesForPressure())

/obj/machinery/portable_atmospherics/proc/MolesForPressure(target_pressure = start_pressure)
	return (target_pressure * air_contents.volume) / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

/obj/machinery/portable_atmospherics/update_icon()
	return null

/obj/machinery/portable_atmospherics/proc/connect(obj/machinery/atmospherics/components/unary/portables_connector/new_port)
	//Make sure not already connected to something else
	if(connected_port || !new_port || new_port.connected_device)
		return FALSE

	//Make sure are close enough for a valid connection
	if(new_port.loc != loc)
		return FALSE

	//Perform the connection
	connected_port = new_port
	connected_port.connected_device = src
	var/datum/pipeline/connected_port_parent = connected_port.PARENT1

	if(connected_port_parent)                 // incase SSair isn't initialized (actally pipelines) ...
		connected_port_parent.reconcile_air() // ... this will be done when build_network() executed, so don't worry.

	anchored = TRUE // Prevent movement
	return TRUE

/obj/machinery/portable_atmospherics/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(.)
		disconnect()

/obj/machinery/portable_atmospherics/proc/disconnect()
	if(!connected_port)
		return FALSE
	anchored = FALSE
	connected_port.connected_device = null
	connected_port = null
	return TRUE

/obj/machinery/portable_atmospherics/portableConnectorReturnAir()
	return air_contents

/obj/machinery/portable_atmospherics/proc/update_connected_network()
	if(!connected_port)
		return

	var/datum/pipeline/connected_port_parent = connected_port.PARENT1
	connected_port_parent.update = 1

/obj/machinery/portable_atmospherics/attackby(obj/item/weapon/W, mob/user)
	if (istype(W, /obj/item/weapon/tank))
		if(!(stat & BROKEN))
			if (holding || !user.drop_item())
				return
			var/obj/item/weapon/tank/T = W
			T.forceMove(src)
			holding = T
			update_icon()
	else if (iswrench(W))
		if(!(stat & BROKEN))
			if(connected_port)
				disconnect()
				user.SetNextMove(CLICK_CD_RAPID)
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message(
					"[user] disconnects [src].",
					"<span class='notice'>You unfasten [src] from the port.</span>",
					"<span class='italics'>You hear a ratchet.</span>")
				update_icon()
			else
				var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate(/obj/machinery/atmospherics/components/unary/portables_connector) in loc
				if(!possible_port)
					to_chat(user, "<span class='notice'>Nothing happens.</span>")
					return
				if(!connect(possible_port))
					to_chat(user, "<span class='notice'>[name] failed to connect to the port.</span>")
					return
				user.SetNextMove(CLICK_CD_RAPID)
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message(
					"[user] connects [src].",
					"<span class='notice'>You fasten [src] to the port.</span>",
					"<span class='italics'>You hear a ratchet.</span>")
				update_icon()
	else if (istype(W, /obj/item/device/analyzer)) // Incase someone do something with this.
		return
	else
		return ..()

/obj/machinery/portable_atmospherics/return_air()
	return air_contents

/obj/machinery/portable_atmospherics/powered
	var/power_rating
	var/power_losses
	var/last_power_draw = 0
	var/obj/item/weapon/stock_parts/cell/cell

/obj/machinery/portable_atmospherics/powered/powered()
	if(use_power) //using area power
		return ..()
	if(cell && cell.charge)
		return TRUE
	return FALSE

/obj/machinery/portable_atmospherics/powered/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		if(cell)
			to_chat(user, "There is already a power cell installed.")
			return

		if(!user.drop_item())
			return

		var/obj/item/weapon/stock_parts/cell/C = I

		C.add_fingerprint(user)
		cell = C
		C.forceMove(src)
		user.visible_message("<span class='notice'>[user] opens the panel on [src] and inserts [C].</span>", "<span class='notice'>You open the panel on [src] and insert [C].</span>")
		power_change()
	else if(isscrewdriver(I))
		if(!cell)
			to_chat(user, "<span class='warning'>There is no power cell installed.</span>")
			return

		user.visible_message("<span class='notice'>[user] opens the panel on [src] and removes [cell].</span>", "<span class='notice'>You open the panel on [src] and remove [cell].</span>")
		cell.add_fingerprint(user)
		cell.forceMove(loc)
		cell = null
		power_change()
	else
		return ..()

/obj/machinery/portable_atmospherics/proc/log_open()
	if(air_contents.gas.len == 0)
		return

	var/gases = ""
	for(var/gas in air_contents.gas)
		if(gases)
			gases += ", [gas]"
		else
			gases = gas
	log_admin("[key_name(usr)] opened '[src.name]' containing [gases].")
	message_admins("[key_name_admin(usr)] opened '[src.name]' containing [gases]. [ADMIN_JMP(src)]")
