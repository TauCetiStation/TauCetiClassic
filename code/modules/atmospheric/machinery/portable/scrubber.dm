/obj/machinery/portable_atmospherics/powered/scrubber
	name = "Portable Air Scrubber"

	icon = 'icons/obj/atmos.dmi'
	icon_state = "pscrubber:0"
	density = TRUE
	interact_offline = TRUE

	volume = 750

	power_rating = 7500 //7500 W ~ 10 HP
	power_losses = 150

	var/on = FALSE
	var/volume_rate = 800

	var/minrate = 0
	var/maxrate = 10 * ONE_ATMOSPHERE

	var/list/scrubbing_gas

/obj/machinery/portable_atmospherics/powered/scrubber/atom_init()
	. = ..()

	cell = new/obj/item/weapon/stock_parts/cell/apc(src)

/obj/machinery/portable_atmospherics/powered/scrubber/atom_init()
	. = ..()
	if(!scrubbing_gas)
		scrubbing_gas = list()
		for(var/g in gas_data.gases)
			if(g != "oxygen" && g != "nitrogen")
				scrubbing_gas += g

/obj/machinery/portable_atmospherics/powered/scrubber/emp_act(severity)
	if(stat & (BROKEN|NOPOWER))
		..(severity)
		return

	if(prob(50 / severity))
		on = !on
		update_icon()

	..(severity)

/obj/machinery/portable_atmospherics/powered/scrubber/update_icon()
	cut_overlays()

	if(on && cell && cell.charge)
		icon_state = "pscrubber:1"
	else
		icon_state = "pscrubber:0"

	if(holding)
		add_overlay("scrubber-open")

	if(connected_port)
		add_overlay("scrubber-connector")

/obj/machinery/portable_atmospherics/powered/scrubber/process_atmos()
	..()

	var/power_draw = -1

	if(on && cell && cell.charge)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/transfer_moles = min(1, volume_rate/environment.volume) * environment.total_moles

		power_draw = scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, power_rating)

	if (power_draw < 0)
		last_flow_rate = 0
		last_power_draw = 0
	else
		power_draw = max(power_draw, power_losses)
		cell.use(power_draw * CELLRATE)
		last_power_draw = power_draw

		update_connected_network()

		//ran out of charge
		if (!cell.charge)
			power_change()
			update_icon()

	updateDialog()

/obj/machinery/portable_atmospherics/powered/scrubber/ui_interact(mob/user, ui_key = "rcon", datum/nanoui/ui = null)
	var/list/data[0]
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() > 0 ? air_contents.return_pressure() : 0)
	data["rate"] = round(volume_rate)
	data["minrate"] = round(minrate)
	data["maxrate"] = round(maxrate)
	data["powerDraw"] = round(last_power_draw)
	data["cellCharge"] = cell ? cell.charge : 0
	data["cellMaxCharge"] = cell ? cell.maxcharge : 1
	data["on"] = on ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure() > 0 ? holding.air_contents.return_pressure() : 0))

	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		ui = new(user, src, ui_key, "portscrubber.tmpl", "Portable Scrubber", 480, 400)
		ui.set_initial_data(data)
		ui.open()
		ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/powered/scrubber/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["power"])
		on = !on
		update_icon()

	if (href_list["remove_tank"])
		if(holding)
			holding.forceMove(loc)
			holding = null
		update_icon()

	if (href_list["volume_adj"])
		var/diff = text2num(href_list["volume_adj"])
		volume_rate = clamp(volume_rate+diff, minrate, maxrate)
		update_icon()

//Huge scrubber
/obj/machinery/portable_atmospherics/powered/scrubber/huge
	name = "Huge Air Scrubber"
	icon_state = "scrubber:0"
	anchored = 1
	volume = 50000
	volume_rate = 5000

	use_power = IDLE_POWER_USE
	idle_power_usage = 500      //internal circuitry, friction losses and stuff
	active_power_usage = 100000 //100 kW ~ 135 HP

	var/static/gid = 1
	var/id = 0

/obj/machinery/portable_atmospherics/powered/scrubber/huge/atom_init()
	. = ..()
	scrubber_huge_list += src

	cell = null

	id = gid
	gid++

	name = "[name] (ID [id])"

/obj/machinery/portable_atmospherics/powered/scrubber/huge/Destroy()
	scrubber_huge_list -= src
	return ..()

/obj/machinery/portable_atmospherics/powered/scrubber/huge/attack_ghost(mob/user)
	return //Do not show anything

/obj/machinery/portable_atmospherics/powered/scrubber/huge/attack_hand(mob/user)
	to_chat(usr, "<span class='notice'>You can't directly interact with this machine. Use the area atmos computer.</span>")

/obj/machinery/portable_atmospherics/powered/scrubber/huge/update_icon()
	cut_overlays()

	if(on && !(stat & (NOPOWER | BROKEN)))
		icon_state = "scrubber:1"
	else
		icon_state = "scrubber:0"

/obj/machinery/portable_atmospherics/powered/scrubber/huge/power_change()
	var/old_stat = stat
	..()
	if (old_stat != stat)
		update_icon()

/obj/machinery/portable_atmospherics/powered/scrubber/huge/process_atmos()
	if(!on || (stat & (NOPOWER | BROKEN)))
		if(use_power)
			set_power_use(NO_POWER_USE)
		last_flow_rate = 0
		last_power_draw = 0
		return FALSE
	if(!use_power)
		set_power_use(IDLE_POWER_USE)

	var/power_draw = -1

	var/datum/gas_mixture/environment = loc.return_air()

	var/transfer_moles = min(1, volume_rate/environment.volume)*environment.total_moles

	power_draw = scrub_gas(src, scrubbing_gas, environment, air_contents, transfer_moles, active_power_usage)

	if (power_draw < 0)
		last_flow_rate = 0
		last_power_draw = 0
	else
		use_power(power_draw)
		update_connected_network()

/obj/machinery/portable_atmospherics/powered/scrubber/huge/attackby(obj/item/I, mob/user)
	if(iswrench(I))
		if(on)
			to_chat(user, "<span class='warning'>Turn \the [src] off first!</span>")
			return

		anchored = !anchored
		user.SetNextMove(CLICK_CD_INTERACT)
		playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
		to_chat(user, "<span class='notice'>You [anchored ? "wrench" : "unwrench"] \the [src].</span>")

		return

	//doesn't use power cells
	if(istype(I, /obj/item/weapon/stock_parts/cell))
		return
	if (isscrewdriver(I))
		return

	//doesn't hold tanks
	if(istype(I, /obj/item/weapon/tank))
		return

	..()


/obj/machinery/portable_atmospherics/powered/scrubber/huge/stationary
	name = "Stationary Air Scrubber"

/obj/machinery/portable_atmospherics/powered/scrubber/huge/stationary/attackby(obj/item/weapon/W, mob/user)
	if(iswrench(W))
		to_chat(user, "<span class='notice'>The bolts are too tight for you to unscrew!</span>")
		return

	..()
