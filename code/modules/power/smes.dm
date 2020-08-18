// the SMES
// stores power

/obj/machinery/power/smes
	name = "power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit."
	icon_state = "smes"
	density = 1
	anchored = 1
	use_power = NO_POWER_USE
	allowed_checks = ALLOWED_CHECK_NONE
	var/output = 50000
	var/lastout = 0
	var/loaddemand = 0
	var/capacity = 0
	var/charge = 0
	var/charging = 0
	var/chargemode = 0
	var/chargecount = 0
	var/chargelevel = 0
	var/online = 1
	var/name_tag = null
	var/obj/machinery/power/terminal/terminal = null
	var/max_input = 0
	var/max_output = 0
	var/last_charge = 0
	var/last_output = 0
	var/last_online = 0
	var/constructed = 0

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
	var/map_max_input = max_input
	var/map_max_output = max_output
	RefreshParts()
	if(map_capacity)
		capacity = map_capacity
	if(map_charge)
		charge = map_charge
	else
		charge = capacity * 0.2
	if(map_max_input)
		max_input = map_max_input
	if(map_max_output)
		max_output = map_max_output

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
		log_investigate("<font color='red'>deleted</font> at ([area.name])",INVESTIGATE_SINGULO)
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
		max_input = 0
		max_output = 0
	else
		var/IO = 0
		var/C = 0
		var/c = 0
		for(var/obj/item/weapon/stock_parts/capacitor/CP in component_parts)
			IO += CP.rating
		max_input = 200000 * IO
		max_output = 200000 * IO
		for(var/obj/item/weapon/stock_parts/cell/PC in component_parts)
			C += PC.maxcharge
			c += PC.charge
		capacity = C * 100
		charge = c * 100

/obj/machinery/power/smes/attackby(obj/item/I, mob/user)
	//opening using screwdriver
	if(default_deconstruction_screwdriver(user, "[initial(icon_state)]-o", initial(icon_state), I))
		update_icon()
		return

	//changing direction using wrench
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

	//exchanging parts using the RPED
	if(exchange_parts(user, I))
		return


	//building and linking a terminal
	if(iscoil(I))
		var/dir = get_dir(user,src)
		if(dir & (dir-1))//we don't want diagonal click
			return

		if(terminal) //is there already a terminal ?
			to_chat(user, "<span class='warning'>This SMES already have a power terminal!</span>")
			return

		if(!panel_open) //is the panel open ?
			to_chat(user, "<span class='warning'>You must open the maintenance panel first!</span>")
			return

		var/turf/T = get_turf(user)
		if(T.intact) //is the floor plating removed ?
			to_chat(user, "<span class='warning'>You must first remove the floor plating!</span>")
			return


		var/obj/item/stack/cable_coil/C = I
		if(C.get_amount() < 10)
			to_chat(user, "<span class='warning'>You need more wires!</span>")
			return
		if(user.is_busy()) return

		to_chat(user, "<span class='notice'>You start building the power terminal...</span>")
		if(I.use_tool(src, user, 20, volume = 50) && C.get_amount() >= 10)
			var/obj/structure/cable/N = T.get_cable_node() //get the connecting node cable, if there's one
			if (prob(50) && electrocute_mob(usr, N, N)) //animate the electrocution if uncautious and unlucky
				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()
				return

			C.use(10)
			user.visible_message(\
				"[user.name] has built a power terminal.",\
				"<span class='notice'>You build the power terminal.</span>")

			//build the terminal and link it to the network
			make_terminal(T)
			terminal.connect_to_network()
		return

	//disassembling the terminal
	if(iswirecutter(I) && terminal && panel_open)
		terminal.dismantle(user)

	//crowbarring it !
	var/turf/T = get_turf(src)
	if(default_deconstruction_crowbar(I))
		message_admins("[src] has been deconstructed by [key_name_admin(user)] [ADMIN_QUE(user)] [ADMIN_FLW(user)] in ([T.x],[T.y],[T.z]) - [ADMIN_JMP(T)]")
		log_game("[src] has been deconstructed by [key_name(user)]")
		log_investigate("SMES deconstructed by [key_name(user)]",INVESTIGATE_SINGULO)

/obj/machinery/power/smes/construction()
	charge = 0
	constructed = 1

/obj/machinery/power/smes/deconstruction()
	update_cells()

// create a terminal object pointing towards the SMES
// wires will attach to this
/obj/machinery/power/smes/make_terminal(turf/T)
	terminal = new/obj/machinery/power/terminal(T)
	terminal.dir = get_dir(T,src)
	terminal.master = src

/obj/machinery/power/smes/disconnect_terminal()
	if(terminal)
		terminal.master = null
		terminal = null

/obj/machinery/power/smes/update_icon()
	cut_overlays()
	if(stat & BROKEN)	return

	if(panel_open)
		cut_overlays()
		return


	add_overlay(image('icons/obj/power.dmi', "smes-op[online]"))

	if(charging)
		add_overlay(image('icons/obj/power.dmi', "smes-oc1"))
	else
		if(chargemode)
			add_overlay(image('icons/obj/power.dmi', "smes-oc0"))

	var/clevel = chargedisplay()
	if(clevel>0)
		add_overlay(image('icons/obj/power.dmi', "smes-og[clevel]"))
	return


/obj/machinery/power/smes/proc/chargedisplay()
	return round(5.5*charge/(capacity ? capacity : 5e6))

#define SMESRATE 0.05			// rate of internal charge to external power


/obj/machinery/power/smes/process()

	if(stat & BROKEN)	return

	//store machine state to see if we need to update the icon overlays
	var/last_disp = chargedisplay()
	var/last_chrg = charging
	var/last_onln = online

	if(terminal)
		var/excess = terminal.surplus()

		if(charging)
			if(excess >= 0)		// if there's power available, try to charge

				var/load = min((capacity-charge)/SMESRATE, chargelevel)		// charge at set rate, limited to spare capacity

				charge += load * SMESRATE	// increase the charge

				add_load(load)		// add the load to the terminal side network

			else					// if not enough capcity
				charging = 0		// stop charging
				chargecount  = 0

		else
			if(chargemode)
				if(chargecount > rand(3,6))
					charging = 1
					chargecount = 0

				if(excess > chargelevel)
					chargecount++
				else
					chargecount = 0
			else
				chargecount = 0

	if(online)		// if outputting
		lastout = min( charge/SMESRATE, output)		//limit output to that stored

		charge -= lastout*SMESRATE		// reduce the storage (may be recovered in /restore() if excessive)

		add_avail(lastout)				// add output to powernet (smes side)

		if(charge < 0.0001)
			online = 0
			loaddemand = 0					// stop output if charge falls to zero

	// only update icon if state changed
	if(last_disp != chargedisplay() || last_chrg != charging || last_onln != online)
		update_icon()

	return

// called after all power processes are finished
// restores charge level to smes if there was excess this ptick


/obj/machinery/power/smes/proc/restore()
	if(stat & BROKEN)
		return

	if(!online)
		loaddemand = 0
		return

	var/excess = powernet.netexcess		// this was how much wasn't used on the network last ptick, minus any removed by other SMESes

	excess = min(lastout, excess)				// clamp it to how much was actually output by this SMES last ptick

	excess = min((capacity-charge)/SMESRATE, excess)	// for safety, also limit recharge by space capacity of SMES (shouldn't happen)

	// now recharge this amount

	var/clev = chargedisplay()

	charge += excess * SMESRATE
	powernet.netexcess -= excess		// remove the excess from the powernet, so later SMESes don't try to use it

	loaddemand = lastout-excess

	if(clev != chargedisplay() )
		update_icon()
	return


/obj/machinery/power/smes/add_load(amount)
	if(terminal && terminal.powernet)
		terminal.powernet.newload += amount


/obj/machinery/power/smes/ui_interact(mob/user, ui_key = "main", datum/nanoui/ui = null)

	if(stat & BROKEN)
		return

	// this is the data which will be sent to the ui
	var/data[0]
	data["nameTag"] = name_tag
	data["storedCapacity"] = round(100.0 * charge / capacity, 0.1)
	data["charging"] = charging
	data["chargeMode"] = chargemode
	data["chargeLevel"] = chargelevel
	data["chargeMax"] = max_input
	data["outputOnline"] = online
	data["outputLevel"] = output
	data["outputMax"] = max_output
	data["outputLoad"] = round(loaddemand)

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
	return !(stat & (BROKEN|EMPED))

/obj/machinery/power/smes/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	//world << "[href] ; [href_list[href]]"

	for(var/area/A in all_areas)
		A.powerupdate = 3

	if( href_list["cmode"] )
		chargemode = !chargemode
		if(!chargemode)
			charging = 0
		update_icon()

	else if( href_list["online"] )
		online = !online
		update_icon()
	else if( href_list["input"] )
		switch( href_list["input"] )
			if("min")
				chargelevel = 0
			if("max")
				chargelevel = max_input		//30000
			if("set")
				chargelevel = input(usr, "Enter new input level (0-[max_input])", "SMES Input Power Control", chargelevel) as num
		chargelevel = max(0, min(max_input, chargelevel))	// clamp to range

	else if( href_list["output"] )
		switch( href_list["output"] )
			if("min")
				output = 0
			if("max")
				output = max_output		//30000
			if("set")
				output = input(usr, "Enter new output level (0-[max_output])", "SMES Output Power Control", output) as num
		output = max(0, min(max_output, output))	// clamp to range

	log_investigate("input/output; [chargelevel>output ? "<font color='green'>[chargelevel]/[output]</font>" : "<font color='red'>[chargelevel]/[output]</font>"] | Output-mode: [online?"<font color='green'>on</font>":"<font color='red'>off</font>"] | Input-mode: [chargemode?"<font color='green'>auto</font>":"<font color='red'>off</font>"] by [key_name(usr)]",INVESTIGATE_SINGULO)


/obj/machinery/power/smes/proc/ion_act()
	if(is_station_level(z))
		if(prob(1)) //explosion
			audible_message("<span class='warning'>The [src.name] is making strange noises!</span>")
			sleep(10*pick(4,5,6,7,10,14))
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			explosion(src.loc, -1, 0, 1, 3, 0)
			qdel(src)
			message_admins("SMES explosion in [src.loc.loc] [ADMIN_JMP(src)]")
			log_game("SMES explosion in [src.loc.loc]")
			return
		if(prob(15)) //Power drain
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(3, 1, src)
			s.start()
			if(prob(50))
				emp_act(1)
			else
				emp_act(2)
			message_admins("SMES power drain in [src.loc.loc] [ADMIN_JMP(src)]")
			log_game("SMES power drain in [src.loc.loc]")
		if(prob(5)) //smoke only
			var/datum/effect/effect/system/smoke_spread/smoke = new /datum/effect/effect/system/smoke_spread()
			smoke.set_up(3, 0, src.loc)
			smoke.attach(src)
			smoke.start()
			message_admins("SMES smoke in [src.loc.loc] [ADMIN_JMP(src)]")
			log_game("SMES smoke in [src.loc.loc]")


/obj/machinery/power/smes/emp_act(severity)
	online = 0
	charging = 0
	output = 0
	charge -= 1e6/severity
	if (charge < 0)
		charge = 0
	spawn(100)
		output = initial(output)
		charging = initial(charging)
		online = initial(online)
	..()



/obj/machinery/power/smes/magical
	name = "magical power storage unit"
	desc = "A high-capacity superconducting magnetic energy storage (SMES) unit. Magically produces power."

/obj/machinery/power/smes/magical/process()
	charge = capacity
	..()



/proc/rate_control(S, V, C, Min=1, Max=5, Limit=null)
	var/href = "<A href='?src=\ref[S];rate control=1;[V]"
	var/rate = "[href]=-[Max]'>-</A>[href]=-[Min]'>-</A> [(C?C : 0)] [href]=[Min]'>+</A>[href]=[Max]'>+</A>"
	if(Limit) return "[href]=-[Limit]'>-</A>"+rate+"[href]=[Limit]'>+</A>"
	return rate


#undef SMESRATE
