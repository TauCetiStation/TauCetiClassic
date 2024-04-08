// the SMES
// stores power

#define SMESRATE 0.05 // Rate of internal charge to external power
#define SMES_EPS 0.0001 // Closest to zero value
#define SMES_START_CHARGE 0.25 // 25% of capacity


/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = TRUE
	anchored = TRUE
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_NONE

	process_last = TRUE

	required_skills = null

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
	var/output_load = 0 // Powernet load change after returning excess power

	var/obj/machinery/power/terminal/terminal = null
	var/power_failure = FALSE

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

	update_icon()

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
	connect_to_network()

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
	..()

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
				to_chat(user, "<span class='notice'>Terminal found.</span>")
				break
		if(!terminal)
			stat |= BROKEN
			to_chat(user, "<span class='alert'>No power source found.</span>")
			return
		terminal.master = src
		stat &= ~BROKEN
		connect_to_network()
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
		if(T.underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
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
	if(iscutter(I) && terminal && panel_open)
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

// Sequence of events:
// 1. process() - from SSmachines
// 2. waiting...
// 3. restore() - from powernet/reset()
/obj/machinery/power/smes/process()
	if(stat & BROKEN)
		return

	// Store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_in = inputting
	var/last_out = outputting

	// Inputting, charging:
	if(terminal && input_attempt && !power_failure) // Input is On
		input_available = terminal.surplus()

		if(inputting) // Was charging - check if still do
			if(input_available > 0) // If there's power available, try to charge

				// Charge at set rate, limited to spare capacity:
				var/load = min((capacity - charge) / SMESRATE, input_level, input_available)

				charge += load * SMESRATE // Increase the charge

				terminal.add_load(load) // Add the load to the terminal side network

			else // If not enough capcity, stop
				inputting = FALSE

		else // Was not charging - check if can start
			if(input_available > 0 && input_level > 0)
				inputting = TRUE

	else // Input is Off or no input
		inputting = FALSE

	// Outputting, discharging:
	if(output_attempt && !power_failure) // Output is Off

		if(outputting) // Was discharging - check if still do
			output_used = min(charge / SMESRATE, output_level) // Limit output to that stored

			if(add_avail(output_used)) // Add output to powernet if it exists (smes side)
				charge -= output_used * SMESRATE // Reduce the storage (may be recovered in /restore() if excessive)
			else
				outputting = FALSE

			if(output_used < SMES_EPS) // Either no charge or output level set to 0
				outputting = FALSE

		else if((charge / SMESRATE) >= output_level && output_level > 0)
			// Was not discharging - check if can start. First check is to prevent outputting flickering every tick
			outputting = TRUE
			output_used = 0

		else // Nothing to discharge
			output_used = 0
			output_load = 0

	else // Output is Off
		outputting = FALSE
		output_used = 0
		output_load = 0

	// Only update icon if state changed
	if(last_disp != chargedisplay() || last_in != inputting || last_out != outputting)
		update_icon()

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick
// returns excess power removed from powernet
/obj/machinery/power/smes/proc/restore(netexcess)
	if(stat & BROKEN)
		return 0

	if(!outputting)
		output_used = 0
		output_load = 0
		return 0

	if(netexcess < 100)
		output_load = output_used
		return 0

	var/excess = netexcess // this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	var/excess_unlim = min(output_used, excess) // clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity - charge) / SMESRATE, excess_unlim) // for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount:

	var/clev = chargedisplay()

	charge += excess * SMESRATE // restore unused power

	output_used -= excess_unlim
	output_load = output_used

	if(clev != chargedisplay())
		update_icon()

	return excess


// UI stuff ////////////////////

/obj/machinery/power/smes/is_operational()
	return !(stat & (BROKEN | EMPED)) && !power_failure

/obj/machinery/power/smes/tgui_state(mob/user)
	return global.machinery_state

/obj/machinery/power/smes/ui_interact(mob/user)
	tgui_interact(user)

/obj/machinery/power/smes/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Smes", name)
		ui.open()

/obj/machinery/power/smes/tgui_data(mob/user)
	var/list/data = list(
		"capacityPercent" = round(100 * charge / capacity, 0.1),
		"charge" = charge,
		"inputAttempt" = input_attempt,
		"inputting" = inputting,
		"inputLevel" = input_level,
		"inputLevelMax" = input_level_max,
		"inputAvailable" = max(input_available, 0),
		"outputAttempt" = output_attempt,
		"outputting" = outputting,
		"outputLevel" = output_level,
		"outputLevelMax" = output_level_max,
		"outputUsed" = output_load,
	)
	return data

/obj/machinery/power/smes/proc/log_smes(mob/user)
	log_investigate("input/output: [input_level > output_level ? "<font color='green'>[input_level]/[output_level]</font>" : "<font color='red'>[input_level]/[output_level]</font>"] | Output-mode: [output_attempt ? "<font color='green'>on</font>" : "<font color='red'>off</font>"] | Input-mode: [input_attempt ? "<font color='green'>auto</font>" : "<font color='red'>off</font>"] by [key_name(user)]", INVESTIGATE_SINGULO)

/obj/machinery/power/smes/tgui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("tryinput")
			input_attempt = !input_attempt
			log_smes(usr)
			update_icon()
			. = TRUE
		if("tryoutput")
			output_attempt = !output_attempt
			log_smes(usr)
			update_icon()
			. = TRUE
		if("input")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = input_level_max
				. = TRUE
			else if(adjust)
				target = input_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				input_level = clamp(target, 0, input_level_max)
				log_smes(usr)
		if("output")
			var/target = params["target"]
			var/adjust = text2num(params["adjust"])
			if(target == "min")
				target = 0
				. = TRUE
			else if(target == "max")
				target = output_level_max
				. = TRUE
			else if(adjust)
				target = output_level + adjust
				. = TRUE
			else if(text2num(target) != null)
				target = text2num(target)
				. = TRUE
			if(.)
				output_level = clamp(target, 0, output_level_max)
				log_smes(usr)

////////////////////////////////


/obj/machinery/power/smes/proc/explode()
	var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
	smoke.set_up(3, 0, src.loc)
	smoke.attach(src)
	smoke.start()
	explosion(src.loc, -1, 0, 1, 3, adminlog = FALSE)
	message_admins("SMES explosion in [src.loc.loc] [ADMIN_JMP(src)]")
	log_game("SMES explosion in [src.loc.loc]")
	qdel(src)

/obj/machinery/power/smes/proc/ion_act()
	if(is_station_level(z))
		if(prob(1)) // explosion
			audible_message("<span class='warning'>The [src.name] is making strange noises!</span>")
			var/time_left = 10 * pick(4, 5, 6, 7, 10, 14)
			addtimer(CALLBACK(src, PROC_REF(explode)), time_left)
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

/obj/machinery/power/smes/emp_act(severity)
	input_attempt = FALSE
	output_attempt = FALSE
	input_level = 0
	output_level = 0
	charge -= 1e6 / severity
	if (charge < 0)
		charge = 0
	stat |= EMPED
	addtimer(CALLBACK(src, PROC_REF(after_emp)), 150 / severity)
	..()

/obj/machinery/power/smes/proc/after_emp()
	input_attempt = prob(50) ? TRUE : FALSE
	output_attempt = prob(50) ? TRUE : FALSE
	input_level = rand(0, input_level_max)
	output_level = rand(0, output_level_max)
	stat &= ~EMPED



/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

/obj/machinery/power/smes/magical/process()
	charge = capacity
	..()

/obj/machinery/power/smes/inputting
	input_attempt = TRUE
	input_level = 50000

/obj/machinery/power/smes/fullcharge

/obj/machinery/power/smes/fullcharge/atom_init()
	. = ..()
	charge = capacity

/obj/machinery/power/smes/fullcharge/not_outputting
	input_attempt = FALSE
	output_attempt = FALSE
	input_level = 0
	output_level = 0

/proc/rate_control(S, V, C, Min = 1, Max = 5, Limit = null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C ? C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit)
		return "[href]=-[Limit]'>-</A>" + rate + "[href]=[Limit]'>+</A>"
	return rate


#undef SMES_START_CHARGE
#undef SMES_EPS
#undef SMESRATE
