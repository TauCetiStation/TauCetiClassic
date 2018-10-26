// How to use it? - Mappers
//
// This is a very good power generating mechanism. All you need is a blast furnace with soaring flames and output.
// Not everything is included yet so the turbine can run out of fuel quiet quickly. The best thing about the turbine is that even
// though something is on fire that passes through it, it won't be on fire as it passes out of it. So the exhaust fumes can still
// containt unreacted fuel - plasma and oxygen that needs to be filtered out and re-routed back. This of course requires smart piping
// For a computer to work with the turbine the compressor requires a comp_id matching with the turbine computer's id. This will be
// subjected to a change in the near future mind you. Right now this method of generating power is a good backup but don't expect it
// become a main power source unless some work is done. Have fun. At 50k RPM it generates 60k power. So more than one turbine is needed!
//
// - Numbers
//
// Example setup	 S - sparker
//					 B - Blast doors into space for venting
// *BBB****BBB*		 C - Compressor
// S    CT    *		 T - Turbine
// * ^ *  * V *		 D - Doors with firedoor
// **|***D**|**      ^ - Fuel feed (Not vent, but a gas outlet)
//   |      |        V - Suction vent (Like the ones in atmos
#define COMPFRICTION 5e5
// These are crucial to working of a turbine - the stats modify the power output. TurbGenQ modifies how much raw energy can you get from
// rpms, TurbGenG modifies the shape of the curve - the lower the value the less straight the curve is.
#define TURBGENQ 100000
#define TURBGENG 0.5
////COMPRESSOR//////
/obj/machinery/power/compressor
	name = "compressor"
	desc = "The compressor stage of a gas turbine generator."
	icon_state = "compressor"
	density = TRUE
	var/obj/machinery/power/turbine/turbine
	var/datum/gas_mixture/gas_contained
	var/turf/simulated/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/comp_id = 0
	var/efficiency

/obj/machinery/power/compressor/atom_init()
	. = ..()
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
	// The inlet of the compressor is the direction it faces
	gas_contained = new
	inturf = get_step(src, dir)
	locate_machinery()
	if(!turbine)
		stat |= BROKEN

/obj/machinery/power/compressor/locate_machinery()
	if(turbine)
		return
	turbine = locate() in get_step(src, get_dir(inturf, src))
	if(turbine)
		turbine.locate_machinery()

/obj/machinery/power/compressor/RefreshParts()
	var/E = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		E += M.rating
	efficiency = E / 6

/obj/machinery/power/compressor/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		turbine = null
		inturf = get_step(src, dir)
		locate_machinery()
		if(turbine)
			to_chat(user, "<span class='notice'>Turbine connected.</span>")
			stat &= ~BROKEN
		else
			to_chat(user, "<span class='alert'>Turbine not connected.</span>")
			stat |= BROKEN
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/power/compressor/process()
	if(!turbine)
		stat = BROKEN
	if(stat & BROKEN || panel_open)
		return
	if(!starter)
		return
	overlays.Cut()

	rpm = 0.9* rpm + 0.1 * rpmtarget
	var/datum/gas_mixture/environment = inturf.return_air()

	// It's a simplified version taking only 1/10 of the moles from the turf nearby. It should be later changed into a better version

	var/transfer_moles = environment.total_moles/10
	var/datum/gas_mixture/removed = inturf.remove_air(transfer_moles)
	gas_contained.merge(removed)

// RPM function to include compression friction - be advised that too low/high of a compfriction value can make things screwy

	rpm = max(0, rpm - (rpm*rpm)/(COMPFRICTION*efficiency))

	if(starter && !(stat & NOPOWER))
		use_power(10000)
		if(rpm<1000)
			rpmtarget = 1000
	else
		if(rpm<1000)
			rpmtarget = 0

	if(rpm>50000)
		overlays += image(icon, "comp-o4", FLY_LAYER)
	else if(rpm>10000)
		overlays += image(icon, "comp-o3", FLY_LAYER)
	else if(rpm>2000)
		overlays += image(icon, "comp-o2", FLY_LAYER)
	else if(rpm>500)
		overlays += image(icon, "comp-o1", FLY_LAYER)

/obj/machinery/power/compressor/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(!height || air_group) return 0
	else return ..()

////TURBINE//////
/obj/machinery/power/turbine
	name = "gas turbine generator"
	desc = "A gas turbine used for backup power generation."
	icon_state = "turbine"
	density = TRUE
	var/opened = 0
	var/obj/machinery/power/compressor/compressor
	var/turf/simulated/outturf
	var/lastgen
	var/productivity = 1

/obj/machinery/power/turbine/atom_init()
	. = ..()
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

// The outlet is pointed at the direction of the turbine component
	outturf = get_step(src, dir)
	locate_machinery()
	if(!compressor)
		stat |= BROKEN
	connect_to_network()

/obj/machinery/power/turbine/locate_machinery()
	if(compressor)
		return
	compressor = locate() in get_step(src, get_dir(outturf, src))
	if(compressor)
		compressor.locate_machinery()

/obj/machinery/power/turbine/RefreshParts()
	var/P = 0
	for(var/obj/item/weapon/stock_parts/capacitor/C in component_parts)
		P += C.rating
	productivity = P / 6

/obj/machinery/power/turbine/attackby(obj/item/I, mob/user, params)
	if(default_deconstruction_screwdriver(user, initial(icon_state), initial(icon_state), I))
		return

	if(default_change_direction_wrench(user, I))
		compressor = null
		outturf = get_step(src, dir)
		locate_machinery()
		if(compressor)
			to_chat(user, "<span class='notice'>Compressor connected.</span>")
			stat &= ~BROKEN
		else
			to_chat(user, "<span class='alert'>Compressor not connected.</span>")
			stat |= BROKEN
		return

	if(exchange_parts(user, I))
		return

	default_deconstruction_crowbar(I)

/obj/machinery/power/turbine/process()
	if(!compressor)
		stat = BROKEN
	if((stat & BROKEN) || panel_open)
		return
	if(!compressor.starter)
		return
	overlays.Cut()

	// This is the power generation function. If anything is needed it's good to plot it in EXCEL before modifying
	// the TURBGENQ and TURBGENG values

	lastgen = ((compressor.rpm / TURBGENQ)**TURBGENG) * TURBGENQ * productivity

	add_avail(lastgen)

	// Weird function but it works. Should be something else...

	var/newrpm = ((compressor.gas_contained.temperature) * compressor.gas_contained.total_moles)/4

	newrpm = max(0, newrpm)

	if(!compressor.starter || newrpm > 1000)
		compressor.rpmtarget = newrpm

	if(compressor.gas_contained.total_moles>0)
		var/oamount = min(compressor.gas_contained.total_moles, (compressor.rpm+100)/35000*compressor.capacity)
		var/datum/gas_mixture/removed = compressor.gas_contained.remove(oamount)
		outturf.assume_air(removed)

// If it works, put an overlay that it works!

	if(lastgen > 100)
		overlays += image(icon, "turb-o", FLY_LAYER)

	updateDialog()

/obj/machinery/power/turbine/ui_interact(mob/user)

	if(!Adjacent(user)  || (stat & (NOPOWER|BROKEN)) && !issilicon(user))
		user.unset_machine(src)
		user << browse(null, "window=turbine")
		return

	var/t = "<TT><B>Gas Turbine Generator</B><HR><PRE>"

	t += "Generated power : [round(lastgen)]<BR><BR>"

	t += "Turbine: [round(compressor.rpm)] RPM<BR>"

	t += "Starter: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]"

	t += "</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</TT>"
	var/datum/browser/popup = new(user, "turbine", name)
	popup.set_content(t)
	popup.open()

	return

/obj/machinery/power/turbine/Topic(href, href_list)
	if(..())
		return

	if( href_list["close"] )
		usr << browse(null, "window=turbine")
		usr.unset_machine(src)
		return

	else if( href_list["str"] )
		if(compressor)
			compressor.starter = !compressor.starter

	updateDialog()

/obj/machinery/power/turbine/CanPass(atom/movable/mover, turf/target, height, air_group)
	if(!height || air_group) return 0
	else return ..()

//TURBINE COMPUTER///
/obj/machinery/computer/turbine_computer
	name = "gas turbine control computer"
	desc = "A computer to remotely control a gas turbine."
	icon = 'icons/obj/computer.dmi'
	icon_state = "airtunnel0e"
	circuit = /obj/item/weapon/circuitboard/turbine_computer
	var/obj/machinery/power/compressor/compressor
	var/id = 0

/obj/machinery/computer/turbine_computer/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/turbine_computer/atom_init_late()
	locate_machinery()

/obj/machinery/computer/turbine_computer/locate_machinery()
	if(id)
		for(var/obj/machinery/power/compressor/C in machines)
			if(C.comp_id == id)
				compressor = C
	else
		compressor = locate(/obj/machinery/power/compressor) in range(10, src)

/obj/machinery/computer/turbine_computer/ui_interact(mob/user)
	var/dat
	if(compressor && compressor.turbine)
		dat += {"<BR><B>Gas turbine remote control system</B><HR>
		\nTurbine status: [ compressor.starter ? "<A href='?src=\ref[src];str=1'>Off</A> <B>On</B>" : "<B>Off</B> <A href='?src=\ref[src];str=1'>On</A>"]
		\n<BR>
		\nTurbine speed: [compressor.rpm]rpm<BR>
		\nPower currently being generated: [compressor.turbine.lastgen]W<BR>
		\nInternal gas temperature: [compressor.gas_contained.temperature]K<BR>
		\n</PRE><HR><A href='?src=\ref[src];view=1'>View</A>
		\n</PRE><HR><A href='?src=\ref[src];close=1'>Close</A>
		\n<BR>
		\n"}
	else
		dat += "<B>There is [!compressor ? "no compressor" : " compressor[!compressor.turbine ? " and no turbine" : ""]"].</B><BR>"
		if(!compressor)
			dat += "<A href='?src=\ref[src];search=1'>Search for compressor</A>"

	user << browse(entity_ja(dat), "window=computer;size=400x500")
	onclose(user, "computer")

/obj/machinery/computer/turbine_computer/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if( href_list["view"] )
		usr.client.eye = compressor
	else if( href_list["str"] )
		compressor.starter = !compressor.starter
	else if( href_list["close"] )
		usr << browse(null, "window=computer")
		usr.machine = null
		return FALSE
	else if(href_list["search"])
		locate_machinery()

	updateUsrDialog()


/obj/machinery/computer/turbine_computer/process()
	src.updateDialog()
	return

#undef COMPFRICTION
#undef TURBGENQ
#undef TURBGENG