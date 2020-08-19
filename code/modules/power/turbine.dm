/obj/machinery/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "compressor"
	anchored = 1
	density = 1
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0
	var/efficiency

/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon = 'icons/obj/pipes.dmi'
	icon_state = "turbine"
	anchored = 1
	density = 1
	var/obj/machinery/compressor/compressor
	var/turf/simulated/outturf
	var/lastgen
	var/productivity = 1

/obj/machinery/computer/turbine_computer
	name = "Gas turbine control computer"
	desc = "A computer to remotely control a gas turbine."
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel"
	circuit = /obj/item/weapon/circuitboard/turbine_control
	anchored = 1
	density = 1
	circuit = /obj/item/weapon/circuitboard/turbine_computer
	var/obj/machinery/compressor/compressor
	var/list/obj/machinery/door/poddoor/doors
	var/id = 0
	var/door_status = 0

// the inlet stage of the gas turbine electricity generator

/obj/machinery/compressor/atom_init()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/power_compressor(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/stack/cable_coil/red(null, 5)
	RefreshParts()
	gas_contained = new
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/compressor/atom_init_late()
	inturf = get_step(src, dir)

	turbine = locate() in get_step(src, get_dir(inturf, src))
	if(!turbine)
		stat |= BROKEN
	else
		turbine.stat &= !BROKEN
		turbine.compressor = src


#define COMPFRICTION 5e5
#define COMPSTARTERLOAD 2800

/obj/machinery/compressor/RefreshParts()
	var/E = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E / 6

/obj/machinery/compressor/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		turbine = null
		inturf = get_step(src, dir)
		turbine = locate() in get_step(src, get_dir(inturf, src))
		if(turbine)
			to_chat(user, "<span class='notice'>Turbine connected.</span>")
		else
			to_chat(user, "<span class='alert'>Turbine not connected.</span>")
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/compressor/process()
	if(!starter)
		return
	cut_overlays()
	if(stat & BROKEN)
		return
	if(!turbine)
		stat |= BROKEN
		return
	rpm = 0.9* rpm + 0.1 * rpmtarget
	var/datum/gas_mixture/environment = inturf.return_air()
	var/transfer_moles = environment.total_moles / 10
	//var/transfer_moles = rpm/10000*capacity
	var/datum/gas_mixture/removed = inturf.remove_air(transfer_moles)
	gas_contained.merge(removed)

	rpm = max(0, rpm - (rpm * rpm) / (COMPFRICTION / efficiency))


	if(starter && !(stat & NOPOWER))
		use_power(2800)
		if(rpm < 1000)
			rpmtarget = 1000
	else
		if(rpm < 1000)
			rpmtarget = 0



	if(rpm > 50000)
		add_overlay(image('icons/obj/pipes.dmi', "comp-o4", FLY_LAYER))
	else if(rpm > 10000)
		add_overlay(image('icons/obj/pipes.dmi', "comp-o3", FLY_LAYER))
	else if(rpm > 2000)
		add_overlay(image('icons/obj/pipes.dmi', "comp-o2", FLY_LAYER))
	else if(rpm > 500)
		add_overlay(image('icons/obj/pipes.dmi', "comp-o1", FLY_LAYER))
	 //TODO: DEFERRED

/obj/machinery/power/turbine/atom_init()
	..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/power_turbine(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
	component_parts += new /obj/item/stack/cable_coil/red(src, 5)
	RefreshParts()

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/turbine/atom_init_late()
	outturf = get_step(src, dir)

	compressor = locate() in get_step(src, get_dir(outturf, src))
	if(!compressor)
		stat |= BROKEN
	else
		compressor.stat &= !BROKEN
		compressor.turbine = src

/obj/machinery/power/turbine/RefreshParts()
	var/P = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		P += C.rating
	productivity = P / 6

#define TURBPRES 9000000
#define TURBGENQ 20000
#define TURBGENG 0.8

/obj/machinery/power/turbine/process()
	if(!compressor.starter)
		return
	cut_overlays()
	if(stat & BROKEN)
		return
	if(!compressor)
		stat |= BROKEN
		return
	lastgen = ((compressor.rpm / TURBGENQ) ** TURBGENG) * TURBGENQ * productivity

	add_avail(lastgen)
	var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles) / 4
	newrpm = max(0, newrpm)

	if(!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm

	if(compressor.gas_contained.total_moles>0)
		var/oamount = min(compressor.gas_contained.total_moles, (compressor.rpm + 100) / 35000 * compressor.capacity)
		var/datum/gas_mixture/removed = compressor.gas_contained.remove(oamount)
		outturf.assume_air(removed)

	if(lastgen > 100)
		add_overlay(image('icons/obj/pipes.dmi', "turb-o", FLY_LAYER))

/obj/machinery/power/turbine/attackby(obj/item/I, mob/user)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		compressor = null
		outturf = get_step(src, dir)
		compressor = locate() in get_step(src, get_dir(outturf, src))
		if(compressor)
			to_chat(user, "<span class='notice'>Compressor connected.</span>")
		else
			to_chat(user, "<span class='alert'>Compressor not connected.</span>")
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/power/turbine/ui_interact(mob/user)

	if ( !Adjacent(user) || (stat & (NOPOWER|BROKEN)) && !issilicon(user) && !isobserver(user) )
		user.unset_machine(src)
		user << browse(null, "window=turbine")
		return

	var/t = "<TT><B>Gas Turbine Generator</B><HR><PRE>"

	t += "Generated power : [round(lastgen)] W<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	user << browse(t, "window=turbine")
	onclose(user, "turbine")

/obj/machinery/power/turbine/Topic(href, href_list)
	if(href_list["close"])
		usr << browse(null, "window=turbine")
		usr.unset_machine(src)
		return FALSE

	. = ..()
	if(!.)
		return

	if(href_list["str"])
		compressor.starter = !compressor.starter

	updateUsrDialog()



/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



/obj/machinery/computer/turbine_computer/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/turbine_computer/atom_init_late()
	search_turbine()
	doors = new /list()
	for(var/obj/machinery/door/poddoor/P in poddoor_list)
		if(P.id == id)
			doors += P

/obj/machinery/computer/turbine_computer/proc/search_turbine()
	compressor = locate(/obj/machinery/compressor) in range(5)

/obj/machinery/computer/turbine_computer/ui_interact(mob/user)
	var/dat
	if(compressor && compressor.turbine)
		dat += {"<BR><B>Gas turbine remote control system</B><HR>
		\nTurbine status: [ src.compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]
		\n<BR>
		\nTurbine speed: [src.compressor.rpm]rpm<BR>
		\nPower currently being generated: [src.compressor.turbine.lastgen]W<BR>
		\nInternal gas temperature: [src.compressor.gas_contained.temperature]K<BR>
		\nVent doors: [ src.door_status ? "<A href='?src=\ref[src];doors=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='?src=\ref[src];doors=1'>Open</A>"]
		\n</PRE><HR><A href='?src=\ref[src];view=1'>View</A>
		\n</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>
		\n<BR>
		\n"}
	else
		dat += "<B>There is [!compressor ? "no compressor" : " compressor[!compressor.turbine ? " and no turbine" : ""]"].</B><BR>"
		if(!compressor)
			dat += "<A href='?src=\ref[src];search=1'>Search for compressor</A>"

	user << browse(dat, "window=computer;size=400x500")
	onclose(user, "computer")



/obj/machinery/computer/turbine_computer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if( href_list["view"] )
		usr.client.eye = src.compressor
	else if( href_list["str"] )
		src.compressor.starter = !src.compressor.starter
	else if (href_list["doors"])
		for(var/obj/machinery/door/poddoor/D in src.doors)
			if (door_status == 0)
				spawn( 0 )
					D.open()
					door_status = 1
			else
				spawn( 0 )
					D.close()
					door_status = 0
	else if( href_list["close"] )
		usr << browse(null, "window=computer")
		usr.machine = null
		return FALSE
	else if(href_list["search"])
		search_turbine()

	src.updateUsrDialog()


/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return
