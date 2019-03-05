/obj/machinery/portable_atmospherics/canister
	name = "canister: \[CAUTION\]"
	desc = "Canister with fairly high gas pressure."
	icon = 'icons/obj/atmos.dmi'
	icon_state = "yellow"

	density = TRUE
	flags = CONDUCT
	use_power = 0

	var/valve_open = FALSE
	var/release_log = ""

	volume = 1000
	start_pressure = 45 * ONE_ATMOSPHERE
	var/gas_type = ""                                 // see xgm/gases.dm - id
	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)
	var/release_flow_rate = ATMOS_DEFAULT_VOLUME_PUMP // in L/s

	var/health = 100
	var/temperature_resistance = 1000 + T0C
	var/starter_temp

	var/canister_color = "yellow"
	var/can_label = 1
	var/update_flag = 0

/obj/machinery/portable_atmospherics/canister/sleeping_agent
	name = "Canister: \[N2O\]"
	icon_state = "redws"
	canister_color = "redws"
	gas_type = "sleeping_agent"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Canister: \[N2\]"
	icon_state = "red"
	canister_color = "red"
	gas_type = "nitrogen"

/obj/machinery/portable_atmospherics/canister/nitrogen/prechilled
	name = "Canister: \[N2 (Cooling)\]"
	starter_temp = 80

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Canister: \[O2\]"
	icon_state = "blue"
	canister_color = "blue"
	gas_type = "oxygen"

/obj/machinery/portable_atmospherics/canister/oxygen/prechilled
	name = "Canister: \[O2 (Cryo)\]"
	starter_temp = 80

/obj/machinery/portable_atmospherics/canister/phoron
	name = "Canister \[Phoron\]"
	icon_state = "orange"
	canister_color = "orange"
	gas_type = "phoron"

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Canister \[CO2\]"
	icon_state = "black"
	canister_color = "black"
	gas_type = "carbon_dioxide"

/obj/machinery/portable_atmospherics/canister/air // this one uses its own create_gas() proc.
	name = "Canister \[Air\]"
	icon_state = "grey"
	canister_color = "grey"

/obj/machinery/portable_atmospherics/canister/air/airlock
	start_pressure = 3 * ONE_ATMOSPHERE

/obj/machinery/portable_atmospherics/canister/empty
	start_pressure = 0
	var/obj/machinery/portable_atmospherics/canister/canister_type = /obj/machinery/portable_atmospherics/canister

/obj/machinery/portable_atmospherics/canister/empty/atom_init()
	name = initial(canister_type.name)
	icon_state = initial(canister_type.icon_state)
	canister_color = initial(canister_type.canister_color)
	. = ..()

/obj/machinery/portable_atmospherics/canister/empty/air
	icon_state = "grey"
	canister_type = /obj/machinery/portable_atmospherics/canister/air

/obj/machinery/portable_atmospherics/canister/empty/oxygen
	icon_state = "blue"
	canister_type = /obj/machinery/portable_atmospherics/canister/oxygen

/obj/machinery/portable_atmospherics/canister/empty/phoron
	icon_state = "orange"
	canister_type = /obj/machinery/portable_atmospherics/canister/phoron

/obj/machinery/portable_atmospherics/canister/empty/nitrogen
	icon_state = "red"
	canister_type = /obj/machinery/portable_atmospherics/canister/nitrogen

/obj/machinery/portable_atmospherics/canister/empty/carbon_dioxide
	icon_state = "black"
	canister_type = /obj/machinery/portable_atmospherics/canister/carbon_dioxide

/obj/machinery/portable_atmospherics/canister/empty/sleeping_agent
	icon_state = "redws"
	canister_type = /obj/machinery/portable_atmospherics/canister/sleeping_agent


/obj/machinery/portable_atmospherics/canister/atom_init()
	. = ..()
	create_gas()
	update_icon()

/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type && start_pressure)
		air_contents.adjust_gas(gas_type, MolesForPressure())

		if(starter_temp)
			air_contents.temperature = starter_temp

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	var/list/air_mix = StandardAirMix()
	air_contents.adjust_multi("oxygen", air_mix["oxygen"], "nitrogen", air_mix["nitrogen"])

#define HOLDING     1
#define CONNECTED   2
#define EMPTY       4
#define LOW         8
#define MEDIUM      16
#define FULL        32
#define DANGER      64
/*
update_flag
1 = holding
2 = connected_port
4 = tank_pressure < 10
8 = tank_pressure < ONE_ATMOS
16 = tank_pressure < 15*ONE_ATMOS
32 = tank_pressure go boom.
*/
/obj/machinery/portable_atmospherics/canister/update_icon()
	if(stat & BROKEN)
		overlays.Cut()
		src.icon_state = text("[]-1", src.canister_color)
		return

	if(icon_state != "[canister_color]")
		icon_state = "[canister_color]"

	var/last_update = update_flag
	update_flag = 0

	if(holding)
		update_flag |= HOLDING
	if(connected_port)
		update_flag |= CONNECTED

	var/tank_pressure = air_contents.return_pressure()
	if(tank_pressure < 10)
		update_flag |= EMPTY
	else if(tank_pressure < 5 * ONE_ATMOSPHERE)
		update_flag |= LOW
	else if(tank_pressure < 15 * ONE_ATMOSPHERE)
		update_flag |= MEDIUM
	else if(tank_pressure < 59 * ONE_ATMOSPHERE)
		update_flag |= FULL
	else
		update_flag |= DANGER

	if(update_flag == last_update)
		return

	overlays.Cut()

	if(update_flag & HOLDING)
		overlays += "can-open"
	if(update_flag & CONNECTED)
		overlays += "can-connector"
	if(update_flag & EMPTY)
		overlays += "can-o0"
	if(update_flag & LOW)
		overlays += "can-o1"
	else if(update_flag & MEDIUM)
		overlays += "can-o2"
	else if(update_flag & FULL)
		overlays += "can-o3"
	else if(update_flag & DANGER)
		overlays += "can-o4"

#undef HOLDING
#undef CONNECTED
#undef EMPTY
#undef LOW
#undef MEDIUM
#undef FULL
#undef DANGER

/obj/machinery/portable_atmospherics/canister/fire_act(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > temperature_resistance)
		take_damage(5)

/obj/machinery/portable_atmospherics/canister/proc/take_damage(amount)
	if((stat & BROKEN) || (flags & NODECONSTRUCT))
		return

	health = Clamp(health - amount, 0, initial(health))

	if(health <= 10)
		canister_break()

/obj/machinery/portable_atmospherics/canister/process_atmos()
	..()

	if(stat & BROKEN)
		return PROCESS_KILL

	if(valve_open)
		var/datum/gas_mixture/environment
		if(holding)
			environment = holding.air_contents
		else
			environment = loc.return_air()

		var/env_pressure = environment.return_pressure()
		var/pressure_delta = release_pressure - env_pressure

		if((air_contents.temperature > 0) && (pressure_delta > 0))
			var/transfer_moles = calculate_transfer_moles(air_contents, environment, pressure_delta)
			transfer_moles = min(transfer_moles, (release_flow_rate/air_contents.volume)*air_contents.total_moles) //flow rate limit

			var/returnval = pump_gas_passive(src, air_contents, environment, transfer_moles)
			if(returnval >= 0)
				src.update_icon()

	if(air_contents.return_pressure() < 1)
		can_label = 1
	else
		can_label = 0

	air_contents.react() //cooking up air cans - add phoron and oxygen, then heat above PHORON_MINIMUM_BURN_TEMPERATURE

/obj/machinery/portable_atmospherics/canister/proc/return_temperature()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume > 0)
		return GM.temperature
	return 0

/obj/machinery/portable_atmospherics/canister/proc/return_pressure()
	var/datum/gas_mixture/GM = src.return_air()
	if(GM && GM.volume > 0)
		return GM.return_pressure()
	return 0

/obj/machinery/portable_atmospherics/canister/blob_act()
	take_damage(200)

/obj/machinery/portable_atmospherics/canister/bullet_act(obj/item/projectile/Proj)
	if(!(Proj.damage_type == BRUTE || Proj.damage_type == BURN))
		return

	if(Proj.damage)
		take_damage(round(Proj.damage / 2))
	..()

/obj/machinery/portable_atmospherics/canister/meteorhit(obj/O)
	take_damage(health)

/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags & NODECONSTRUCT))
		if(!(stat & BROKEN))
			canister_break()
		if(disassembled)
			new /obj/item/stack/sheet/metal (loc, 10)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/attackby(obj/item/weapon/W, mob/user)
	if(user.a_intent != I_HURT && istype(W, /obj/item/weapon/weldingtool))
		if(user.is_busy()) return
		var/obj/item/weapon/weldingtool/WT = W
		if(stat & BROKEN)
			if(!WT.remove_fuel(0, user))
				return
			playsound(src, 'sound/items/Welder2.ogg', 40, 1)
			to_chat(user, "<span class='notice'>You begin cutting [src] apart...</span>")
			if(do_after(user, 30, target = src))
				deconstruct(TRUE)
		else
			to_chat(user, "<span class='notice'>You cannot slice [src] apart when it isn't broken.</span>")
		return 1

	if(!istype(W, /obj/item/weapon/wrench) && !istype(W, /obj/item/weapon/tank) && !istype(W, /obj/item/device/analyzer) && !istype(W, /obj/item/device/pda))
		visible_message("\red [user] hits the [src] with a [W]!")
		src.add_fingerprint(user)
		investigate_log("was smacked with \a [W] by [key_name(user)].", INVESTIGATE_ATMOS)
		user.SetNextMove(CLICK_CD_MELEE)
		take_damage(W.force)

	if(istype(user, /mob/living/silicon/robot) && istype(W, /obj/item/weapon/tank/jetpack))
		var/obj/item/weapon/tank/jetpack/J = W
		var/datum/gas_mixture/thejetpack = J.air_contents
		var/env_pressure = thejetpack.return_pressure()
		var/pressure_delta = min(10 * ONE_ATMOSPHERE - env_pressure, (air_contents.return_pressure() - env_pressure) / 2)
		//Can not have a pressure delta that would cause environment pressure > tank pressure
		var/transfer_moles = 0
		if((air_contents.temperature > 0) && (pressure_delta > 0))
			transfer_moles = pressure_delta*thejetpack.volume/(air_contents.temperature * R_IDEAL_GAS_EQUATION)//Actually transfer the gas
			var/datum/gas_mixture/removed = air_contents.remove(transfer_moles)
			thejetpack.merge(removed)
			to_chat(user, "You pulse-pressurize your jetpack from the tank.")
		return

	..()

	nanomanager.update_uis(src) // Update all NanoUIs attached to src

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()

	var/turf/T = get_turf(src)
	T.assume_air(air_contents)

	stat |= BROKEN
	density = FALSE
	playsound(src, 'sound/effects/spray.ogg', 10, 1, -3)
	update_icon()
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		holding.forceMove(T)
		holding = null

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(stat & BROKEN)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["name"] = name
	data["canLabel"] = can_label ? 1 : 0
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["minReleasePressure"] = round(can_min_release_pressure)
	data["maxReleasePressure"] = round(can_max_release_pressure)
	data["valveOpen"] = valve_open ? 1 : 0

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list("name" = holding.name, "tankPressure" = round(holding.air_contents.return_pressure()))

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "canister.tmpl", "Canister", 480, 400)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/portable_atmospherics/canister/is_operational_topic()
	return TRUE

/obj/machinery/portable_atmospherics/canister/Topic(href, href_list)
	. = ..()
	if(!. || issilicon(usr))
		return

	if(href_list["toggle"])
		var/logmsg
		valve_open = !valve_open

		if (valve_open)
			if (holding)
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the [holding]<br>"
			else
				release_log += "Valve was <b>closed</b> by [usr] ([usr.ckey]), stopping the transfer into the <font color='red'><b>air</b></font><br>"
		else
			if (holding)
				release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the [holding]<br>"
			else
				release_log += "Valve was <b>opened</b> by [usr] ([usr.ckey]), starting the transfer into the <font color='red'><b>air</b></font><br>"

		if (valve_open)
			logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
			if(!holding)
				var/list/danger = list()
				for(var/id in air_contents.gas)
					if(!gas_data.gases_dangerous[id])
						continue
					var/gas_moles = air_contents.gas[id]
					if(gas_moles > (gas_data.overlay_limit[id] || MOLES_PHORON_VISIBLE))
						danger[gas_data.name[id]] = gas_moles

				if(danger.len)
					message_admins("[ADMIN_LOOKUPFLW(usr)] opened a canister that contains the following: [ADMIN_JMP(src)]")
					log_admin("[key_name(usr)] opened a canister that contains the following at [COORD(src)]:")
					for(var/name in danger)
						var/msg = "[name]: [danger[name]] moles."
						log_admin(msg)
						message_admins(msg)
		else
			logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"

		investigate_log(logmsg, INVESTIGATE_ATMOS)
		release_log += logmsg

	if (href_list["remove_tank"])
		if(holding)
			if (valve_open)
				investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transferring into the <span class='boldannounce'>air</span><br>", INVESTIGATE_ATMOS)
			if(istype(holding, /obj/item/weapon/tank))
				holding.manipulated_by = usr.real_name
			holding.forceMove(get_turf(src))
			holding = null

	if (href_list["pressure_adj"])
		var/diff = text2num(href_list["pressure_adj"])
		release_pressure = Clamp(release_pressure + diff, can_min_release_pressure, can_max_release_pressure)
		investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)

	if (href_list["relabel"])
		if (can_label)
			var/list/colors = list(\
				"\[N2O\]" = "redws", \
				"\[N2\]" = "red", \
				"\[O2\]" = "blue", \
				"\[Toxin (Bio)\]" = "orange", \
				"\[CO2\]" = "black", \
				"\[Air\]" = "grey", \
				"\[CAUTION\]" = "yellow", \
			)
			var/label = input("Choose canister label", "Gas canister") as null|anything in colors
			if (label)
				src.canister_color = colors[label]
				src.icon_state = colors[label]
				src.name = "Canister: [label]"
	update_icon()

/obj/machinery/portable_atmospherics/canister/CanUseTopic()
	if(stat & BROKEN)
		return STATUS_CLOSE
	return ..()
