// the SMES
// stores power

#define SMESRATE 0.05 // Rate of internal charge to external power
#define SMES_EPS 0.0001 // Closest to zero value
#define SMES_START_CHARGE 0.2 // 20% of capacity


/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_NONE

	var/capacity = 0 // Maximum charge
	var/charge = 0 // Actual charge

	var/input_attempt = FALSE // Attempting to charge? (On / Off)
	var/inputting = FALSE // Actually inputting?
	var/input_level = 0 // Amount of power the SMES attempts to charge by
	var/input_level_max = 0 // Cap on input level
	var/input_available = 0 // Amount of charge available from input last tick

	var/output_attempt = TRUE // Attempting to output? (On / Off)
	var/outputting = FALSE // Actually outputting?
	var/output_level = 50000 // Amount of power the SMES attempts to output
	var/output_level_max = 0 // Cap on output level
	var/output_used = 0 // Amount of power actually outputted. May be less than output_level if the powernet returns excess power

	var/obj/machinery/power/terminal/terminal = null

/obj/machinery/power/smes/atom_init()
	. = ..()
	smes_list += src
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/smes(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	component_parts += new /obj/item/weapon/stock_parts/cell/high(null)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 5)
	var/map_capacity = capacity
	var/map_charge = charge
	var/map_max_input = input_level_max
	var/map_max_output = output_level_max
	
	RefreshParts()
	
	if(map_capacity)
		capacity = map_capacity
	if(map_charge)
		charge = map_charge
	else
		charge = capacity * SMES_START_CHARGE
	if(map_max_input)
		input_level_max = map_max_input
	if(map_max_output)
		output_level_max = map_max_output

	dir_loop:
		for(var/d in cardinal)
			var/turf/T = get_step(src, d)
			for(var/obj/machinery/power/terminal/term in T)
				if(term && term.dir == turn(d, 180))
					terminal = term
					break dir_loop

	if(!terminal)
		stat |= BROKEN
		return
	terminal.master = src

	if(!powernet)
		connect_to_network()
	update_icon()

/obj/machinery/power/smes/Destroy()
	smes_list -= src
	if(SSticker && SSticker.current_state == GAME_STATE_PLAYING)
		var/area/area = get_area(src)
		message_admins("SMES deleted at [area.name] [ADMIN_JMP(src)]")
		log_game("SMES deleted at ([area.name])")
		log_investigate("<font color='red'>deleted</font> at ([area.name])", INVESTIGATE_SINGULO)
	if(terminal)
		disconnect_terminal()
	return ..()

/obj/machinery/power/smes/proc/update_cells()
	for(var/obj/item/weapon/stock_parts/cell/cell in component_parts)
		cell.charge = cell.maxcharge * charge / capacity
		cell.updateicon()

/obj/machinery/power/smes/exchange_parts()
	update_cells()
	..()

/obj/machinery/power/smes/RefreshParts()
	if(power_fail_event)
		input_level_max = 0
		output_level_max = 0
	else
		var/IO = 0
		var/C = 0
		var/c = 0
		for(var/obj/item/weapon/stock_parts/capacitor/CP in component_parts)
			IO += CP.rating
		input_level_max = 200000 * IO
		output_level_max = 200000 * IO
		for(var/obj/item/weapon/stock_parts/cell/PC in component_parts)
			C += PC.maxcharge
			c += PC.charge
		capacity = C * 100
		charge = c * 100

/obj/machinery/power/smes/attackby(obj/item/I, mob/user)
	// opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return

	// changing direction using wrench
	if(default_change_direction_wrench(user, I))
		terminal = null
		var/turf/T = get_step(src, dir)
		for(var/obj/machinery/power/terminal/term in T)
			if(term && term.dir == turn(dir, 180))
				terminal = term
				terminal.master = src
				to_chat(user, "<span class='notice'>Terminal found.</span>")
				break
		if(!terminal)
			to_chat(user, "<span class='alert'>No power source found.</span>")
			return
		stat &= ~BROKEN
		update_icon()
		return

	// exchanging parts using the RPED
	if(exchange_parts(user, I))
		return

	// building and linking a terminal
	if(iscoil(I))
		var/dir = get_dir(user, src)
		if(dir & (dir - 1)) // we don't want diagonal click
			return

		if(terminal) // is there already a terminal ?
			to_chat(user, "<span class='warning'>This SMES already have a power terminal!</span>")
			return

		if(!panel_open) // is the panel open ?
			to_chat(user, "<span class='warning'>You must open the maintenance panel first!</span>")
			return

		var/turf/T = get_turf(user)
		if(T.intact) // is the floor plating removed ?
			to_chat(user, "<span class='warning'>You must first remove the floor plating!</span>")
			return

		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires!</span>")
			return

		if(user.is_busy())
			return

		to_chat(user, "<span class='notice'>You start building the power terminal...</span>")
		if(I.use_tool(src, user, 20, volume = 50) && C.get_amount() >= 10)
			var/obj/structure/cable/N = T.get_cable_node() // get the connecting node cable, if there's one
			if (prob(50) && electrocute_mob(usr, N, N)) // animate the electrocution if uncautious and unlucky
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return

			C.use(10)
			user.visible_message(\
				"[user.name] has built a power terminal.",\
				"<span class='notice'>You build the power terminal.</span>")

			// build the terminal and link it to the network
			make_terminal(T)
			terminal.connect_to_network()
		return

	// disassembling the terminal
	if(iswirecutter(I) && terminal && panel_open)
		terminal.dismantle(user)

	// crowbarring it!
	var/turf/T = get_turf(src)
	if(default_deconstruction_crowbar(I))
		message_admins("[src] has been deconstructed by [key_name_admin(user)] [ADMIN_QUE(user)] [ADMIN_FLW(user)] in [COORD(T)] - [ADMIN_JMP(T)]")
		log_game("[src] has been deconstructed by [key_name(user)]")
		log_investigate("SMES deconstructed by [key_name(user)]", INVESTIGATE_SINGULO)

/obj/machinery/power/smes/construction()
	charge = 0

/obj/machinery/power/smes/deconstruction()
	update_cells()

// create a terminal object pointing towards the SMES
// wires will attach to this
/obj/machinery/power/smes/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.set_dir(get_dir(T, src))
	terminal.master = src

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/smes/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount

/obj/machinery/power/smes/update_icon()
	cut_overlays()
	if(stat & BROKEN)
		return
	if(panel_open)
		cut_overlays()
		return

	add_overlay(image('icons/obj/power.dmi', "smes-op[output_attempt ? 1 : 0]"))

	if(inputting)
		add_overlay(image('icons/obj/power.dmi', "smes-oc1"))
	else
		if(input_attempt)
			add_overlay(image('icons/obj/power.dmi', "smes-oc0"))

	var/clevel = chargedisplay()
	if(clevel > 0)
		add_overlay(image('icons/obj/power.dmi', "smes-og[clevel]"))
	return

/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5 * charge / (capacity ? capacity : 5e6))

/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	// Store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_in = inputting
	var/last_out = outputting

	// Inputting, charging:
	if(terminal && input_attempt) // Input is On
		input_available = terminal.surplus()

		if(inputting) // Was charging - check if still do
			if(input_available > 0) // If there's power available, try to charge

				// Charge at set rate, limited to spare capacity:
				var/load = min(min((capacity - charge) / SMESRATE, input_level), input_available)

				charge += load * SMESRATE // Increase the charge

				add_load(load) // Add the load to the terminal side network

			else // If not enough capcity, stop
				inputting = FALSE

		else // Was not charging - check if can start
			if(input_available > 0 && input_level > 0)
				inputting = TRUE

	else // Input is Off or no input
		inputting = FALSE

	// Outputting, discharging:
	if(output_attempt) // Output is Off

		if(outputting) // Was discharging - check if still do
			output_used = min(charge / SMESRATE, output_level) // Limit output to that stored

			if(add_avail(output_used)) // Add output to powernet if it exists (smes side)
				charge -= output_used * SMESRATE // Reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < SMES_EPS) // Either no charge or output level set to 0
				outputting = FALSE
				//log_investigate("lost power and turned <font color='red'>off</font>", INVESTIGATE_SINGULO)

		else if((charge / SMESRATE) > output_level && output_level > 0)
			// Was not discharging - check if can start. First check is to prevent outputting flickering every tick
			outputting = TRUE

		else // Nothing to discharge
			output_used = 0

	else // Output is Off
		outputting = FALSE

	// Only update icon if state changed
	if(last_disp != chargedisplay() || last_in != inputting || last_out != outputting)
		update_icon()

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!outputting)
		output_used = 0
		return

	var/excess = powernet.netexcess // this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(output_used, excess) // clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity - charge) / SMESRATE, excess) // for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount:

	var/clev = chargedisplay()

	charge += excess * SMESRATE // restore unused power
	powernet.netexcess -= excess // remove the excess from the powernet, so later SMESes don't try to use it

	output_used -= excess

	if(clev != chargedisplay())
		update_icon()

/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)
	if(stat & BROKEN)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["nameTag"] = name_tag
	data["storedCapacity"] = round(100.0 * charge / capacity, 0.1)
	data["charging"] = inputting
	data["chargeMode"] = input_attempt
	data["chargeLevel"] = input_level
	data["chargeMax"] = input_level_max
	data["outputoutput_attempt"] = output_attempt
	data["outputLevel"] = output_level
	data["outputMax"] = output_level_max
	data["outputLoad"] = round(output_used)

	// update the ui if it exists, returns null if no ui is passed/found
	ui = nanomanager.try_update_ui(user, src, ui_key, ui, data)
	if (!ui)
		// the ui does not exist, so we'll create a new() one
        // for a list of parameters and their descriptions see the code docs in \code\modules\nano\nanoui.dm
		ui = new(user, src, ui_key, "smes.tmpl", "SMES Power Storage Unit", 540, 380)
		// when the ui is first opened this is the data it will use
		ui.set_initial_data(data)
		// open the new ui window
		ui.open()
		// auto update every Master Controller tick
		ui.set_auto_update(1)

/obj/machinery/power/smes/is_operational_topic()
	return !(stat & (BROKEN | EMPED))

/obj/machinery/power/smes/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	for(var/area/A in all_areas)
		A.powerupdate = 3

	if( href_list["cmode"] )
		input_attempt = !input_attempt
		update_icon()

	else if( href_list["output_attempt"] )
		output_attempt = !output_attempt
		update_icon()

	else if( href_list["input"] )
		switch( href_list["input"] )
			if("min")
				input_level = 0
			if("max")
				input_level = input_level_max
			if("set")
				input_level = input(usr, "Enter new input level (0-[input_level_max])", "SMES Input Power Control", input_level) as num
		input_level = clamp(input_level, 0, input_level_max)

	else if( href_list["output"] )
		switch( href_list["output"] )
			if("min")
				output_level = 0
			if("max")
				output_level = output_level_max
			if("set")
				output_level = input(usr, "Enter new output level (0-[output_level_max])", "SMES Output Power Control", output_level) as num
		output_level = clamp(output_level, 0, output_level_max)

	log_investigate("input/output: [input_level > output_level ? "<font color='green'>[input_level]/[output_level]</font>" : "<font color='red'>[input_level]/[output_level]</font>"] | Output-mode: [output_attempt ? "<font color='green'>on</font>" : "<font color='red'>off</font>"] | Input-mode: [input_attempt ? "<font color='green'>auto</font>" : "<font color='red'>off</font>"] by [key_name(usr)]", INVESTIGATE_SINGULO)

/obj/machinery/power/smes/proc/explode()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(3, 0, src.loc)
	smoke.attach(src)
	smoke.start()
	explosion(src.loc, -1, 0, 1, 3, 0)
	message_admins("SMES explosion in [src.loc.loc] [ADMIN_JMP(src)]")
	log_game("SMES explosion in [src.loc.loc]")
	qdel(src)

/obj/machinery/power/smes/proc/ion_act()
	if(is_station_level(z))
		if(prob(1)) // explosion
			audible_message("<span class='warning'>The [src.name] is making strange noises!</span>")
			var/time_left = 10 * pick(4, 5, 6, 7, 10, 14)
			addtimer(CALLBACK(src, .proc/explode), time_left)
			return

		if(prob(15)) // power drain
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
			message_admins("SMES power drain in [src.loc.loc] [ADMIN_JMP(src)]")
			log_game("SMES power drain in [src.loc.loc]")

		if(prob(5)) // smoke only
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			message_admins("SMES smoke in [src.loc.loc] [ADMIN_JMP(src)]")
			log_game("SMES smoke in [src.loc.loc]")

/obj/machinery/power/smes/proc/after_emp()
	input_attempt = rand(0, 1)
	output_attempt = rand(0, 1)
	input_level = rand(0, input_level_max)
	output_level = rand(0, output_level_max)

/obj/machinery/power/smes/emp_act(severity)
	input_attempt = FALSE
	output_attempt = FALSE
	input_level = 0
	output_level = 0
	charge -= 1e6 / severity
	if (charge < 0)
		charge = 0
	addtimer(CALLBACK(src, .proc/after_emp), 100)
	..()



/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

/obj/machinery/power/smes/magical/process()
	charge = capacity
	..()



/proc/rate_control(S, V, C, Min = 1, Max = 5, Limit = null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C ? C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit)
		return "[href]=-[Limit]'>-</A>" + rate + "[href]=[Limit]'>+</A>"
	return rate


#undef SMES_START_CHARGE
#undef SMES_EPS
#undef SMESRATE
