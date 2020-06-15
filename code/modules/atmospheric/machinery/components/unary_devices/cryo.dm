/obj/machinery/atmospherics/components/unary/cryo_cell
	name = "cryo cell"
	icon = 'icons/obj/cryogenics.dmi'
	icon_state = "pod-off"

	layer = ABOVE_WINDOW_LAYER
	light_color = "#ffffff"
	density = TRUE
	anchored = TRUE
	state_open = 0

	var/on = 0
	var/current_heat_capacity = 50
	var/efficiency
	var/obj/item/weapon/reagent_containers/glass/beaker = null
	var/list/cryo_medicine = list("cryoxadone", "clonexadone")

/obj/machinery/atmospherics/components/unary/cryo_cell/atom_init()
	. = ..()

	icon = 'icons/obj/cryogenics_split.dmi'
	update_icon()

	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/cryo_tube(null)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/weapon/stock_parts/console_screen(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 1)
	RefreshParts()

/obj/machinery/atmospherics/components/unary/cryo_cell/RefreshParts()
	var/C
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		C += M.rating
	current_heat_capacity = 50 * C
	efficiency = C

/obj/machinery/atmospherics/components/unary/cryo_cell/Destroy()
	var/obj/item/weapon/reagent_containers/glass/B = beaker
	if(beaker)
		B.loc = get_step(loc, SOUTH) //Beaker is carefully ejected from the wreckage of the cryotube

	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/process()
	..()

	if(!on)
		updateUsrDialog()
		return

	var/datum/gas_mixture/air1 = AIR1

	if(air1.total_moles < 10)
		return
	if(occupant)
		if(occupant.stat == DEAD) // We don't bother with dead people.
			return

		if(air1.gas.len)
			if(occupant.bodytemperature < T0C && occupant.health < 100)
				occupant.SetSleeping(max(10 / efficiency, (1 / occupant.bodytemperature) * 4000 / efficiency) SECONDS)
				occupant.Paralyse(max(5/efficiency, (1 / occupant.bodytemperature)*3000/efficiency))

				if(air1.gas["oxygen"] > 2)
					if(occupant.getOxyLoss())
						occupant.adjustOxyLoss(-1)
				else
					occupant.adjustOxyLoss(-1)
				//severe damage should heal waaay slower without proper chemicals
				if(occupant.bodytemperature < 225)
					if (occupant.getToxLoss())
						occupant.adjustToxLoss(max(-efficiency, (-20*(efficiency ** 2)) / occupant.getToxLoss()))
					var/heal_brute = occupant.getBruteLoss() ? min(efficiency, 20*(efficiency**2) / occupant.getBruteLoss()) : 0
					var/heal_fire = occupant.getFireLoss() ? min(efficiency, 20*(efficiency**2) / occupant.getFireLoss()) : 0
					occupant.heal_bodypart_damage(heal_brute, heal_fire)

			var/occupant_has_cryo_medicine = FALSE
			for(var/M in cryo_medicine)
				if(occupant.reagents.get_reagent_amount(M) >= 1)
					occupant_has_cryo_medicine = TRUE
					break
			if(beaker && beaker.reagents && !occupant_has_cryo_medicine)
				var/initial_volume = beaker.reagents.total_volume
				for(var/datum/reagent/R in beaker.reagents.reagent_list)
					var/transfer_amt = 1 * R.volume / initial_volume
					if(R.id in cryo_medicine)
						beaker.reagents.trans_id_to(occupant, R.id, transfer_amt, 10)
					else
						beaker.reagents.trans_id_to(occupant, R.id, transfer_amt)
				beaker.reagents.reaction(occupant)

	updateUsrDialog()
	return 1

/obj/machinery/atmospherics/components/unary/cryo_cell/process_atmos()
	last_power_draw = 0
	last_flow_rate = 0

	if(!on)
		return

	var/datum/gas_mixture/air1 = AIR1

	if(!NODE1 || !AIR1 || !air1.gas.len || air1.gas["oxygen"] < 5) // Turn off if the machine won't work.
		on = FALSE
		update_icon()
		return

	if(occupant)
		occupant.bodytemperature += 2 * (air1.temperature - occupant.bodytemperature) * current_heat_capacity / (current_heat_capacity + air1.heat_capacity())
		occupant.bodytemperature = max(occupant.bodytemperature, air1.temperature) // this is so ugly i'm sorry for doing it i'll fix it later i promise

		/* heat_gas_contents */
		if(air1.total_moles < 1)
			return
		var/air_heat_capacity = air1.heat_capacity()
		var/combined_heat_capacity = current_heat_capacity + air_heat_capacity
		if(combined_heat_capacity > 0)
			var/combined_energy = T20C * current_heat_capacity + air_heat_capacity * air1.temperature
			air1.temperature = combined_energy / combined_heat_capacity


/obj/machinery/atmospherics/components/unary/cryo_cell/MouseDrop_T(mob/target, mob/user)
	if(user.incapacitated() || !Adjacent(user) || !target.Adjacent(user) || !iscarbon(target))
		return
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return
	close_machine(target)

/obj/machinery/atmospherics/components/unary/cryo_cell/allow_drop()
	return 0

/obj/machinery/atmospherics/components/unary/cryo_cell/relaymove(mob/user)
	container_resist(user)

/obj/machinery/atmospherics/components/unary/cryo_cell/container_resist(mob/user)
	if(user.is_busy(null, FALSE)) // prevents spam too.
		return

	to_chat(user, "<span class='notice'>You struggle inside the cryotube, kicking the release with your foot... (This will take around 30 seconds.)</span>")
	audible_message("<span class='notice'>You hear a thump from [src].</span>")
	if(do_after(user, 300, target = src))
		if(occupant == user) // Check they're still here.
			open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/verb/move_eject()
	set name = "Eject Cryo Cell"
	set desc = "Begin the release sequence inside the cryo tube."
	set category = "Object"
	set src in oview(1)
	if(usr == occupant || contents.Find(usr))	//If the user is inside the tube...
		if(usr.stat == DEAD)	//and he's not dead....
			return
		to_chat(usr, "<span class='notice'>Release sequence activated. This will take about a minute.</span>")
		sleep(600)
		if(!src || !usr || (!occupant && !contents.Find(usr)))	//Check if someone's released/replaced/bombed him already
			return
		open_machine()
		add_fingerprint(usr)
	else
		if(isobserver(usr) && !IsAdminGhost(usr))
			return
		open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/examine(mob/user)
	..()
	if(occupant)
		if(on)
			to_chat(user, "Someone's inside [src]!")
		else
			to_chat(user, "You can barely make out a form floating in [src].")
	else
		to_chat(user, "[src] seems empty.")

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
/obj/machinery/atmospherics/components/unary/cryo_cell/ui_interact(mob/user, ui_key = "main")
	if(user == occupant || (user.stat && !isobserver(user)) || panel_open)
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

	var/datum/gas_mixture/air1 = AIR1
	data["cellTemperature"] = round(air1.temperature)
	data["cellTemperatureStatus"] = "good"
	if(air1.temperature > T0C) // if greater than 273.15 kelvin (0 celcius)
		data["cellTemperatureStatus"] = "bad"
	else if(air1.temperature > 225)
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

/obj/machinery/atmospherics/components/unary/cryo_cell/CtrlClick(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	if(!user.incapacitated() && in_range(user, src))
		if(!state_open)
			on = !on
			update_icon()

/obj/machinery/atmospherics/components/unary/cryo_cell/AltClick(mob/user)
	if(!user.IsAdvancedToolUser())
		to_chat(user, "<span class='warning'>You can not comprehend what to do with this.</span>")
		return

	if(!user.incapacitated() && in_range(user, src))
		if(state_open)
			close_machine()
		else
			open_machine()

/obj/machinery/atmospherics/components/unary/cryo_cell/Topic(href, href_list)
	. = ..()
	if(!. || usr == occupant || panel_open)
		return FALSE // don't update UIs attached to this object

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

/obj/machinery/atmospherics/components/unary/cryo_cell/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/reagent_containers/glass))
		if(beaker)
			to_chat(user, "<span class='warning'>A beaker is already loaded into [src]!</span>")
			return
		if(!user.drop_item())
			return
		beaker = I
		I.forceMove(src)
		user.visible_message(
			"[user] places [I] in [src].",
			"<span class='notice'>You place [I] in [src].</span>")
		var/reagentlist = pretty_string_from_reagent_list(I.reagents.reagent_list)
		log_game("[key_name(user)] added an [I] to cryo containing [reagentlist]")
		return

	if(!(on || occupant || state_open))
		if(default_deconstruction_screwdriver(user, "pod-o", "pod-0", I))
			return
		if(exchange_parts(user, I))
			return

	if(default_change_direction_wrench(user, I))
		return
	if(default_pry_open(I))
		return
	if(default_deconstruction_crowbar(I))
		return

	return ..()

/obj/machinery/atmospherics/components/unary/cryo_cell/open_machine()
	if(!state_open && !panel_open)
		on = FALSE
		..()
		if(beaker)
			beaker.loc = src

/obj/machinery/atmospherics/components/unary/cryo_cell/close_machine(mob/living/carbon/user)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		return occupant

/obj/machinery/atmospherics/components/unary/cryo_cell/update_icon()
	cut_overlays()
	var/image/I

	if(panel_open)
		icon_state = "pod-o"

		I = image(icon, "pod-o_top")
		I.layer = 5 // this needs to be fairly high so it displays over most things, but it needs to be under lighting (at 10)
		I.pixel_z = 32
		add_overlay(I)

	else if(state_open)
		icon_state = "pod-open"

		I = image(icon, "pod-open_top")
		I.layer = 5
		I.pixel_z = 32
		add_overlay(I)
	else
		icon_state = "pod-[on]"

		I = image(icon, "pod-[on]_top")
		I.layer = 5
		I.pixel_z = 32
		add_overlay(I)

		if(occupant)
			var/image/pickle = image(occupant.icon, occupant.icon_state)
			pickle.copy_overlays(occupant)
			pickle.pixel_z = 20
			pickle.layer = 5
			add_overlay(pickle)

		I = image(icon, "lid-[on]")
		I.layer = 5
		add_overlay(I)

		I = image(icon, "lid-[on]_top")
		I.layer = 5
		I.pixel_z = 32
		add_overlay(I)

/obj/machinery/atmospherics/components/unary/cryo_cell/can_crawl_through()
	return //can't ventcrawl in or out of cryo.
