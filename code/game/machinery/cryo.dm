/obj/machinery/atmospherics/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-off"
	density = 1
	anchored = 1

	var/on = 0
	var/temperature_archived
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/current_heat_capacity = 50
	state_open = 0
	var/efficiency

	light_color = "#FFFFFF"

/obj/machinery/atmospherics/unary/cryo_cell/New()
	..()
	initialize_directions = dir
	initialize()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/cable_coil(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		C += M.rating
	current_heat_capacity = 50 * C
	efficiency = C

/obj/machinery/atmospherics/unary/cryo_cell/Destroy()
	var/turf/T = loc
	T.contents += contents
	var/obj/item/weapon/reagent_containers/glass/B = beaker
	if(beaker)
		B.loc = get_step(loc, SOUTH) //Beaker is carefully ejected from the wreckage of the cryotube
	return ..()

/obj/machinery/atmospherics/unary/cryo_cell/initialize()
	if(node) return
	var/node_connect = dir
	for(var/obj/machinery/atmospherics/target in get_step(src,node_connect))
		if(target.initialize_directions & get_dir(target,src))
			node = target
			break

/obj/machinery/atmospherics/unary/cryo_cell/process()
	..()
	if(!node)
		return
	if(!on)
		updateUsrDialog()
		return

	if(occupant)
		if(occupant.stat != DEAD)
			process_occupant()

	if(air_contents)
		temperature_archived = air_contents.temperature
		heat_gas_contents()
		expel_gas()

	if(abs(temperature_archived-air_contents.temperature) > 1)
		network.update = 1

	updateUsrDialog()
	return 1

/obj/machinery/atmospherics/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.stat || user.lying || !Adjacent(user) || !target.Adjacent(user) || !iscarbon(target))
		return
	close_machine(target)

/obj/machinery/atmospherics/unary/cryo_cell/allow_drop()
	return 0

/obj/machinery/atmospherics/unary/cryo_cell/relaymove(var/mob/user)
	container_resist(user)

/obj/machinery/atmospherics/unary/cryo_cell/container_resist(mob/user)
	user << "<span class='notice'>You struggle inside the cryotube, kicking the release with your foot... (This will take around 30 seconds.)</span>"
	//audible_message("<span class='notice'>You hear a thump from [src].</span>")
	if(do_after(user, 300, target = src))
		if(occupant == user) // Check they're still here.
			open_machine()

/obj/machinery/atmospherics/unary/cryo_cell/verb/move_eject()
	set name = "Eject Cryo Cell"
	set desc = "Begin the release sequence inside the cryo tube."
	set category = "Object"
	set src in oview(1)
	if(usr == occupant || contents.Find(usr))	//If the user is inside the tube...
		if(usr.stat == DEAD)	//and he's not dead....
			return
		usr << "<span class='notice'>Release sequence activated. This will take about a minute.</span>"
		sleep(600)
		if(!src || !usr || (!occupant && !contents.Find(usr)))	//Check if someone's released/replaced/bombed him already
			return
		open_machine()
		add_fingerprint(usr)
	else
		if(isobserver(usr))
			return
		open_machine()

/obj/machinery/atmospherics/unary/cryo_cell/examine()
	..()
	if(occupant)
		if(on)
			usr << "Someone's inside [src]!"
		else
			usr << "You can barely make out a form floating in [src]."
	else
		usr << "[src] seems empty."

/obj/machinery/atmospherics/unary/cryo_cell/attack_hand(mob/user)
	ui_interact(user)

 /**
  * The ui_interact proc is used to open and update Nano UIs
  * If ui_interact is not used then the UI will not update correctly
  * ui_interact is currently defined for /atom/movable (which is inherited by /obj and /mob)
  *
  * @param user /mob The mob who is interacting with this ui
  * @param ui_key string A string key to use for this ui. Allows for multiple unique uis on one obj/mob (defaut value "main")
  * @param ui /datum/nanoui This parameter is passed by the nanoui process() proc when updating an open ui
  *
  * @return nothing
  */
/obj/machinery/atmospherics/unary/cryo_cell/ui_interact(mob/user, ui_key = "main")
	if(user == occupant || user.stat || panel_open)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["isOperating"] = on
	data["hasOccupant"] = occupant ? 1 : 0

	var/occupantData[0]
	if (occupant)
		occupantData["name"] = occupant.name
		occupantData["stat"] = occupant.stat
		occupantData["health"] = occupant.health
		occupantData["maxHealth"] = occupant.maxHealth
		occupantData["minHealth"] = config.health_threshold_dead
		occupantData["bruteLoss"] = occupant.getBruteLoss()
		occupantData["oxyLoss"] = occupant.getOxyLoss()
		occupantData["toxLoss"] = occupant.getToxLoss()
		occupantData["fireLoss"] = occupant.getFireLoss()
		occupantData["bodyTemperature"] = occupant.bodytemperature
	data["occupant"] = occupantData;

	data["isOpen"] = state_open
	data["cellTemperature"] = round(air_contents.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air_contents.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air_contents.temperature > 225)
		data["cellTemperatureStatus"] = "average"

	data["isBeakerLoaded"] = beaker ? 1 : 0
	data["beakerLabel"] = null
	data["beakerVolume"] = 0
	if(beaker)
		data["beakerLabel"] = beaker.label_text ? beaker.label_text : null
		if (beaker.reagents && beaker.reagents.reagent_list.len)
			for(var/datum/reagent/R in beaker.reagents.reagent_list)
				data["beakerVolume"] += R.volume


	var/datum/nanoui/ui = nanomanager.get_open_ui(user, src, ui_key)
	if(!ui)
		// the ui does not exist, so we'll create a new one
		ui = new(user, src, ui_key, "cryo.tmpl", "Cryo Cell Control System", 520, 410)
		// When the UI is first opened this is the data it will use
		ui.set_initial_data(data)
		ui.open()
		// Auto update every Master Controller tick
		ui.set_auto_update(1)
	else
		// The UI is already open so push the new data to it
		ui.push_data(data)
		return

/obj/machinery/atmospherics/unary/cryo_cell/Topic(href, href_list)
	if(usr == occupant || panel_open)
		return 0 // don't update UIs attached to this object

	if(..())
		return 0 // don't update UIs attached to this object

	if(href_list["switchOn"])
		if(!state_open)
			on = 1

	if(href_list["open"])
		on = 0
		open_machine()

	if(href_list["close"])
		if(close_machine() == usr)
			var/datum/nanoui/ui = nanomanager.get_open_ui(usr, src, "main")
			ui.close()
			on = 1
	if(href_list["switchOff"])
		on = 0

	if(href_list["ejectBeaker"])
		if(beaker)
			beaker.loc = get_step(loc, SOUTH)
			beaker = null

	update_icon()
	add_fingerprint(usr)
	return 1 // update UIs attached to this object

/obj/machinery/atmospherics/unary/cryo_cell/attackby(var/obj/item/weapon/G as obj, var/mob/user as mob)
	if(istype(G, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			user << "\red A beaker is already loaded into the machine."
			return

		beaker =  G
		user.drop_item()
		G.loc = src
		user.visible_message("[user] adds \a [G] to \the [src]!", "You add \a [G] to \the [src]!")

	if(!(on || occupant || state_open))
		if(default_deconstruction_screwdriver(user, "pod-o", "pod-off", G))
			return

	if(default_change_direction_wrench(user, G))
		if(node)
			node.disconnect(src)
			disconnect(node)
		initialize_directions = dir
		initialize()
		build_network()
		if(node)
			node.initialize()
			node.build_network()
			node.update_icon()
		return

	if(exchange_parts(user, G))
		return

	default_deconstruction_crowbar(G)

/obj/machinery/atmospherics/unary/cryo_cell/open_machine()
	if(!state_open && !panel_open)
		on = FALSE
		..()
		if(beaker)
			beaker.loc = src

/obj/machinery/atmospherics/unary/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		return occupant

/obj/machinery/atmospherics/unary/cryo_cell/update_icon()
	overlays.Cut()
	if(occupant)
		var/image/pickle = image(occupant.icon, occupant.icon_state)
		pickle.overlays = occupant.overlays
		pickle.pixel_y = 20
		overlays += pickle
	if(panel_open)
		icon_state = "pod-o"
		overlays += "lid-off"
	else if(state_open)
		icon_state = "pod-open"
	else if(on && is_operational())
		icon_state = "pod-on"
		overlays += "lid-on"
	else
		icon_state = "pod-off"
		overlays += "lid-off"

/obj/machinery/atmospherics/unary/cryo_cell/proc/process_occupant()
	if(air_contents.total_moles() < 10)
		return
	if(occupant)
		if(occupant.stat == DEAD)
			return
		occupant.bodytemperature += 2*(air_contents.temperature - occupant.bodytemperature)*current_heat_capacity/(current_heat_capacity + air_contents.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air_contents.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise
		occupant.stat = UNCONSCIOUS
		if(occupant.bodytemperature < T0C && occupant.health < 100)
			occupant.sleeping = max(5/efficiency, (1 / occupant.bodytemperature)*2000/efficiency)
			occupant.Paralyse(max(5/efficiency, (1 / occupant.bodytemperature)*3000/efficiency))
			if(air_contents.oxygen > 2)
				if(occupant.getOxyLoss()) occupant.adjustOxyLoss(-1)
			else
				occupant.adjustOxyLoss(-1)
			//severe damage should heal waaay slower without proper chemicals
			if(occupant.bodytemperature < 225)
				if (occupant.getToxLoss())
					occupant.adjustToxLoss(max(-efficiency, (-20*(efficiency ** 2)) / occupant.getToxLoss()))
				var/heal_brute = occupant.getBruteLoss() ? min(efficiency, 20*(efficiency**2) / occupant.getBruteLoss()) : 0
				var/heal_fire = occupant.getFireLoss() ? min(efficiency, 20*(efficiency**2) / occupant.getFireLoss()) : 0
				occupant.heal_organ_damage(heal_brute,heal_fire)
		var/has_cryo = occupant.reagents.get_reagent_amount("cryoxadone") >= 1
		var/has_clonexa = occupant.reagents.get_reagent_amount("clonexadone") >= 1
		var/has_cryo_medicine = has_cryo || has_clonexa
		if(beaker && !has_cryo_medicine)
			beaker.reagents.trans_to(occupant, 1, 10)
			beaker.reagents.reaction(occupant)

/obj/machinery/atmospherics/unary/cryo_cell/proc/heat_gas_contents()
	if(air_contents.total_moles() < 1)
		return
	var/air_heat_capacity = air_contents.heat_capacity()
	var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
	if(combined_heat_capacity > 0)
		var/combined_energy = T20C*current_heat_capacity + air_heat_capacity*air_contents.temperature
		air_contents.temperature = combined_energy/combined_heat_capacity

/obj/machinery/atmospherics/unary/cryo_cell/proc/expel_gas()
	if(air_contents.total_moles() < 1)
		return

/obj/machinery/atmospherics/unary/cryo_cell/can_crawl_through()
	return //can't ventcrawl in or out of cryo.

