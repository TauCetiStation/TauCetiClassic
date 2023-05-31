#define PROCESS_NONE		0
#define PROCESS_SMELT		1
#define PROCESS_COMPRESS	2
#define PROCESS_ALLOY		3

/**********************Mineral processing unit console**************************/
/obj/machinery/mineral/processing_unit_console
	name = "production machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE

	var/obj/item/weapon/card/id/inserted_id	// Inserted ID card, for points
	var/machinedir = EAST
	var/obj/machinery/mineral/processing_unit/machine = null
	var/show_all_ores = FALSE
	var/list/ore_data = list()
	var/points = 0
	var/static/list/ore_values = list()

/obj/machinery/mineral/processing_unit_console/atom_init()
	. = ..()
	machine = locate(/obj/machinery/mineral/processing_unit) in range(5, src)
	if (machine)
		machine.console = src
		if(!ore_values.len)
			for(var/oretype in subtypesof(/datum/ore))
				var/datum/ore/O = oretype
				ore_values[initial(O.oretag)] = initial(O.points)
	else
		log_debug("Ore processing machine console at [x], [y], [z] could not find its machine!")
		qdel(src)

/obj/machinery/mineral/processing_unit_console/Destroy()
	if(inserted_id)
		inserted_id.forceMove(loc) //Prevents deconstructing from deleting whatever ID was inside it.
	. = ..()

/obj/machinery/mineral/processing_unit_console/attack_hand(mob/user)
	if(..())
		return
	if(!allowed(user))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	tgui_interact(user)

/obj/machinery/mineral/processing_unit_console/attackby(obj/item/I, mob/user)
	if(istype(I, /obj/item/weapon/card/id))
		if(!powered())
			return
		if(!inserted_id && user.unEquip(I))
			I.forceMove(src)
			inserted_id = I
			SStgui.update_uis(src)
		return
	..()

/obj/machinery/mineral/processing_unit_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningOreProcessingConsole", name)
		ui.open()

/obj/machinery/mineral/processing_unit_console/tgui_data(mob/user, datum/tgui/ui, datum/tgui_state/state)
	var/list/data = ..()
	data["unclaimedPoints"] = points

	if(inserted_id)
		data["has_id"] = TRUE
		data["id"] = list(
			"name" = inserted_id.registered_name,
			"points" = inserted_id.mining_points,
		)
	else
		data["has_id"] = FALSE


	var/list/ores = list()
	for(var/ore in machine.ores_processing)
		if(!machine.ores_stored[ore] && !show_all_ores)
			continue
		ores.Add(list(list(
			"ore" = ore,
			"amount" = machine.ores_stored[ore],
			"processing" = machine.ores_processing[ore] ? machine.ores_processing[ore] : 0,
		)))
	data["ores"] = ores
	data["showAllOres"] = show_all_ores
	data["power"] = machine.active
	data["speed"] = machine.speed_process

	return data

/obj/machinery/mineral/processing_unit_console/tgui_static_data(mob/user)
	var/list/static_data = list()
	static_data["ore_values"] = list()
	for(var/orename in ore_values)
		static_data["ore_values"] += list(list("name" = orename, "amount" = ore_values[orename]))
	return static_data

/obj/machinery/mineral/processing_unit_console/tgui_act(action, list/params)
	if(..())
		return TRUE

	add_fingerprint(usr)
	switch(action)
		if("toggleSmelting")
			var/ore = params["ore"]
			var/new_setting = params["set"]
			if(new_setting == null)
				new_setting = input("What setting do you wish to use for processing [ore]]?") as null|anything in list("Smelting","Compressing","Alloying","Nothing")
				if(!new_setting)
					return
				switch(new_setting)
					if("Nothing") new_setting = PROCESS_NONE
					if("Smelting") new_setting = PROCESS_SMELT
					if("Compressing") new_setting = PROCESS_COMPRESS
					if("Alloying") new_setting = PROCESS_ALLOY
			machine.ores_processing[ore] = new_setting
			. = TRUE
		if("power")
			machine.active = !machine.active
			. = TRUE
		if("showAllOres")
			show_all_ores = !show_all_ores
			. = TRUE
		if("logoff")
			if(!inserted_id)
				return
			usr.put_in_hands(inserted_id)
			inserted_id = null
			. = TRUE
		if("claim")
			if(istype(inserted_id))
				if(access_mining_station in inserted_id.access)
					inserted_id.mining_points += points
					points = 0
				else
					to_chat(usr, "<span class='warning'>Required access not found.</span>")
			. = TRUE
		if("insert")
			var/obj/item/weapon/card/id/I = usr.get_active_hand()
			if(istype(I))
				usr.drop_from_inventory(I, src)
				inserted_id = I
			else
				to_chat(usr, "<span class='warning'>No valid ID.</span>")
			. = TRUE

/**********************Mineral processing unit**************************/


/obj/machinery/mineral/processing_unit
	name = "material processor" //This isn't actually a goddamn furnace, we're in space and it's processing platinum and flammable phoron...
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "furnace"
	density = TRUE
	anchored = TRUE
	light_range = 3
	speed_process = TRUE
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/obj/machinery/mineral/processing_unit_console/console = null
	var/sheets_per_tick = 10
	var/list/ores_processing = list()
	var/list/ores_stored = list()
	var/active = FALSE
	var/list/ore_data = list()
	var/list/alloy_data = list()

/obj/machinery/mineral/processing_unit/atom_init()
	..()
	//TODO: Ore and alloy global storage datum.
	for(var/alloytype in subtypesof(/datum/alloy))
		alloy_data += new alloytype()
	for(var/oretype in subtypesof(/datum/ore))
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

	if (!src.output || !src.input)
		return

	var/list/tick_alloys = list()

	//Grab some more ore to process this tick.
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
							if(ores_processing[needs_metal] != PROCESS_ALLOY || ores_stored[needs_metal] < A.requires[needs_metal])
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
			else if(ores_processing[metal] == PROCESS_COMPRESS && O.compresses_to) //Compressing.
				var/can_make = clamp(ores_stored[metal],0,sheets_per_tick-sheets)
				if(can_make%2>0) can_make--
				if(!can_make || ores_stored[metal] < 1)
					continue
				for(var/i=0,i<can_make,i+=2)
					ores_stored[metal]-=2
					sheets+=2
					console.points += O.points
					new O.compresses_to(output.loc)
			else if(ores_processing[metal] == PROCESS_SMELT && O.smelts_to) //Smelting.
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

#undef PROCESS_NONE
#undef PROCESS_SMELT
#undef PROCESS_COMPRESS
#undef PROCESS_ALLOY
