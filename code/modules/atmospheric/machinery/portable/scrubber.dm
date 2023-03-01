#define SCRUBBER_MAX_RATE (ONE_ATMOSPHERE * 10)
#define SCRUBBER_MIN_RATE 0
#define SCRUBBER_DEFAULT_RATE 800

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
	var/volume_rate = SCRUBBER_DEFAULT_RATE

	var/list/scrubbing_gas
	required_skills = list(/datum/skill/atmospherics = SKILL_LEVEL_TRAINED)

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


/obj/machinery/portable_atmospherics/powered/scrubber/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/portable_atmospherics/powered/scrubber/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PortableScrubber", name)
		ui.open()

/obj/machinery/portable_atmospherics/powered/scrubber/tgui_data()
	var/data = list()
	data["on"] = on
	data["connected"] = connected_port ? 1 : 0
	data["pressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["target_rate"] = round(volume_rate ? volume_rate : 0)
	data["default_rate"] = round(SCRUBBER_DEFAULT_RATE)
	data["min_rate"] = round(SCRUBBER_MIN_RATE)
	data["max_rate"] = round(SCRUBBER_MAX_RATE)
	data["power_draw"] = round(last_power_draw)
	data["cell_charge"] = cell ? cell.charge : 0
	data["cell_maxcharge"] = cell ? cell.maxcharge : 1

	if(holding)
		data["holding"] = list()
		data["holding"]["name"] = holding.name
		data["holding"]["pressure"] = round(holding.air_contents.return_pressure())
	else
		data["holding"] = null
	return data

/obj/machinery/portable_atmospherics/powered/scrubber/tgui_state(mob/user)
	return global.physical_state

/obj/machinery/portable_atmospherics/powered/scrubber/tgui_act(action, params)
	. = ..()

	if(.)
		return

	switch(action)
		if("power")
			on = !on
			. = TRUE
		if("rate")
			var/rate = params["rate"]
			if(rate == "reset")
				rate = SCRUBBER_DEFAULT_RATE
				. = TRUE
			else if(rate == "min")
				rate = SCRUBBER_MIN_RATE
				. = TRUE
			else if(rate == "max")
				rate = SCRUBBER_MAX_RATE
				. = TRUE
			else if(text2num(rate) != null)
				rate = text2num(rate)
				. = TRUE
			if(.)
				volume_rate = clamp(round(rate), SCRUBBER_MIN_RATE, SCRUBBER_MAX_RATE)
		if("eject")
			if(holding)
				holding.forceMove(loc)
				holding = null
				. = TRUE
	update_icon()

//Huge scrubber
/obj/machinery/portable_atmospherics/powered/scrubber/huge
	name = "Huge Air Scrubber"
	icon_state = "scrubber:0"
	anchored = TRUE
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
	if(iswrenching(I))
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
	if (isscrewing(I))
		return

	//doesn't hold tanks
	if(istype(I, /obj/item/weapon/tank))
		return

	..()


/obj/machinery/portable_atmospherics/powered/scrubber/huge/stationary
	name = "Stationary Air Scrubber"

/obj/machinery/portable_atmospherics/powered/scrubber/huge/stationary/attackby(obj/item/weapon/W, mob/user)
	if(iswrenching(W))
		to_chat(user, "<span class='notice'>The bolts are too tight for you to unscrew!</span>")
		return

	..()

#undef SCRUBBER_MAX_RATE
#undef SCRUBBER_MIN_RATE
#undef SCRUBBER_DEFAULT_RATE
