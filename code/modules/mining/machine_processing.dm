/**********************Mineral processing unit console**************************/

/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1

	var/obj/machinery/mineral/processing_unit/machine = null
	var/machinedir = EAST
	var/show_all_ores = 0

	var/points = 0
	var/obj/item/weapon/card/id/inserted_id

	var/show_value_list = 0
	var/list/ore_values = list(
							"glass" 			= 1,
							"iron" 				= 1,
							"coal" 				= 1,
							"steel" 			= 5,
							"hydrogen"			= 10,
							"uranium" 			= 20,
							"phoron" 			= 20,
							"phoron glass"		= 25,
							"silver" 			= 25,
							"gold" 				= 30,
							"platinum"			= 45,
							"plasteel"			= 50,
							"diamond" 			= 70)

/obj/machinery/mineral/processing_unit_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/processing_unit_console/atom_init_late()
	machine = locate(/obj/machinery/mineral/processing_unit, get_step(src, machinedir))
	if (machine)
		machine.console = src
	else
		qdel(src)

/obj/machinery/mineral/processing_unit_console/ui_interact(mob/user)
	var/dat

	dat += "<hr><table>"

	for(var/ore in machine.ores_processing)

		if(!machine.ores_stored[ore] && !show_all_ores)
			continue

		dat += "<tr><td width = 40><b>[capitalize(ore)]</b></td><td width = 30>[machine.ores_stored[ore]]</td><td width = 100>"
		if(machine.ores_processing[ore])
			switch(machine.ores_processing[ore])
				if(0)
					dat += "<font color='red'>not processing</font>"
				if(1)
					dat += "<font color='orange'>smelting</font>"
				if(2)
					dat += "<font color='yellow'>compressing</font>"
				if(3)
					dat += "<font color='gray'>alloying</font>"
				if(4)
					dat += "<font color='green'>drop</font>"
		else
			dat += "<font color='red'>not processing</font>"
		dat += "</td><td width = 30><a href='?src=\ref[src];toggle_smelting=[ore]'>\[change\]</a></td></tr>"

	dat += "</table><hr>"

	dat += "Currently displaying [show_all_ores ? "all ore types" : "only available ore types"] <A href='?src=\ref[src];toggle_ores=1'>\[[show_all_ores ? "show less" : "show more"]\]</a><br>"
	dat += "The ore processor is currently <A href='?src=\ref[src];toggle_power=1'>[(machine.active ? "<font color='lime'><b>processing</b></font>" : "<font color='maroon'><b>disabled</b></font>")]</a><br>"

	dat += "<br>"
	dat += "<hr>"

	dat += text("<b>Current unclaimed points:</b> [points]<br>")

	if(istype(inserted_id))
		dat += text("You have [inserted_id.mining_points] mining points collected. <A href='?src=\ref[src];eject=1'>Eject ID</A><br>")
		dat += text("<A href='?src=\ref[src];claim=1'>Claim points.</A><br>")
	else
		dat += text("No ID inserted.  <A href='?src=\ref[src];insert=1'>Insert ID</A><br>")

	dat += "<br>"

	dat += "Resources Value List: <A href='?src=\ref[src];show_values=1'>\[[show_value_list ? "close" : "open"]\]</a><br>"
	if(show_value_list)
		dat += "<div class='statusDisplay'>[get_ore_values()]</div>"

	var/datum/browser/popup = new(user, "window=processor_console", "Ore Processor Console", 400, 550)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/processing_unit_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["toggle_smelting"])
		var/choice = input("What setting do you wish to use for processing [href_list["toggle_smelting"]]?") as null|anything in list("Smelting","Compressing","Alloying","Drop","Nothing")
		if(!choice)
			return FALSE
		switch(choice)
			if("Nothing") choice = 0
			if("Smelting") choice = 1
			if("Compressing") choice = 2
			if("Alloying") choice = 3
			if("Drop") choice = 4
		machine.ores_processing[href_list["toggle_smelting"]] = choice
	if(href_list["toggle_power"])
		machine.active = !machine.active
	if(href_list["toggle_ores"])
		show_all_ores = !show_all_ores
	if(href_list["eject"])
		inserted_id.loc = loc
		inserted_id.verb_pickup()
		inserted_id = null
	if(href_list["claim"])
		inserted_id.mining_points += points
		points = 0
	if(href_list["insert"])
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I))
			if(!usr.drop_item())
				return FALSE
			I.loc = src
			inserted_id = I
		else
			to_chat(usr, "<span class='warning'>No valid ID.</span>")
	if(href_list["show_values"])
		show_value_list = !show_value_list

	src.updateUsrDialog()

/obj/machinery/mineral/processing_unit_console/proc/get_ore_values()
	var/dat = "<table border='0' width='300'>"
	for(var/ore in ore_values)
		var/value = ore_values[ore]
		dat += "<tr><td>[capitalize(ore)]</td><td>[value]</td></tr>"
	dat += "</table>"
	return dat

/obj/machinery/mineral/processing_unit_console/attackby(obj/item/weapon/W, mob/user, params)
	if(istype(W,/obj/item/weapon/card/id))
		var/obj/item/weapon/card/id/I = usr.get_active_hand()
		if(istype(I) && !istype(inserted_id))
			if(!user.drop_item())
				return
			I.loc = src
			inserted_id = I
			updateUsrDialog()
	else
		..()

/**********************Mineral processing unit**************************/
/obj/machinery/mineral/processing_unit
	name = "material processor" //This isn't actually a goddamn furnace, we're in space and it's processing platinum and flammable phoron...
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = 1
	anchored = 1
	light_range = 3
	speed_process = TRUE
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/processing_unit_console/console = null
	var/sheets_per_tick = 10
	var/list/ores_processing = list()
	var/list/ores_stored = list()
	var/list/ore_data = list()
	var/list/alloy_data = list()
	var/active = 0

/obj/machinery/mineral/processing_unit/atom_init()
	..()
	//TODO: Ore and alloy global storage datum.
	for(var/alloytype in typesof(/datum/alloy)-/datum/alloy)
		alloy_data += new alloytype()
	for(var/oretype in typesof(/datum/ore)-/datum/ore)
		var/datum/ore/OD = new oretype()
		ore_data[OD.oretag] = OD
		ores_processing[OD.oretag] = 0
		ores_stored[OD.oretag] = 0
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/processing_unit/atom_init_late()
	//Locate our output and input machinery.
	for (var/dir in cardinal)
		input = locate(/obj/machinery/mineral/input, get_step(src, dir))
		if(input)
			break
	for (var/dir in cardinal)
		output = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(output)
			break

/obj/machinery/mineral/processing_unit/process()

	if (!src.output || !src.input) return

	var/list/tick_alloys = list()

	//Grab some more ore to process next tick.
	for(var/i = 0,i<sheets_per_tick,i++)
		var/obj/item/weapon/ore/O = locate() in input.loc
		var/obj/item/stack/sheet/M = locate() in input.loc
		if(M)	M.loc = output.loc
		if(!O)	break
		if(!isnull(ores_stored[O.oretag])) ores_stored[O.oretag]++
		qdel(O)

	if(!active)
		return

	//Process our stored ores and spit out sheets.
	var/sheets = 0
	for(var/metal in ores_stored)
		if(sheets >= sheets_per_tick) break
		if(ores_stored[metal] > 0 && ores_processing[metal] != 0)
			var/datum/ore/O = ore_data[metal]
			if(!O) continue
			if(ores_processing[metal] == 4) //Drop.
				var/can_make = clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(ores_stored[metal] < 1)
					continue
				for(var/i=0,i<can_make,i++)
					ores_stored[metal]--
					new O.start(output.loc)
			else if(ores_processing[metal] == 3 && O.alloy) //Alloying.
				for(var/datum/alloy/A in alloy_data)
					if(A.metaltag in tick_alloys)
						continue
					tick_alloys += A.metaltag
					var/enough_metal
					if(!isnull(A.requires[metal]) && ores_stored[metal] >= A.requires[metal]) //We have enough of our first metal, we're off to a good start.
						enough_metal = 1
						for(var/needs_metal in A.requires)
							//Check if we're alloying the needed metal and have it stored.
							if(ores_processing[needs_metal] != 3 || ores_stored[needs_metal] < A.requires[needs_metal])
								enough_metal = 0
								break
					if(!enough_metal)
						continue
					else
						var/total
						for(var/needs_metal in A.requires)
							ores_stored[needs_metal] -= A.requires[needs_metal]
							total += A.requires[needs_metal]
							total = max(1,round(total*A.product_mod)) //Always get at least one sheet.
							sheets += total-1
						for(var/i=0,i<total,i++)
							console.points += A.points
							new A.product(output.loc)
			else if(ores_processing[metal] == 2 && O.compresses_to) //Compressing.
				var/can_make = clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(can_make%2>0) can_make--
				if(!can_make || ores_stored[metal] < 1)
					continue
				for(var/i=0,i<can_make,i+=2)
					ores_stored[metal]-=2
					sheets+=2
					console.points += O.points
					new O.compresses_to(output.loc)
			else if(ores_processing[metal] == 1 && O.smelts_to) //Smelting.
				var/can_make = clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(!can_make || ores_stored[metal] < 1)
					continue
				for(var/i=0,i<can_make,i++)
					ores_stored[metal]--
					sheets++
					console.points += O.points
					new O.smelts_to(output.loc)
			else
				ores_stored[metal]--
				sheets++
				new /obj/item/weapon/ore/slag(output.loc)
		else
			continue
