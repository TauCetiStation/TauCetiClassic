/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/stacking_machine/machine = null

/obj/machinery/mineral/stacking_unit_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/stacking_unit_console/atom_init_late()
	machine = locate(/obj/machinery/mineral/stacking_machine) in range(5, src)
	if (machine)
		machine.console = src
	else
		qdel(src)

/obj/machinery/mineral/stacking_unit_console/attack_hand(mob/user)
	add_fingerprint(user)
	tgui_interact(user)

/obj/machinery/mineral/stacking_unit_console/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "MiningStackingConsole", name)
		ui.open()

/obj/machinery/mineral/stacking_unit_console/tgui_data(mob/user)
	var/list/data = ..()
	var/list/stacktypes = list()
	for(var/stacktype in machine.stack_storage)
		if(machine.stack_storage[stacktype] > 0)
			stacktypes.Add(list(list(

				"type" = stacktype,
				"amt" = machine.stack_storage[stacktype],
			)))
	data["stacktypes"] = stacktypes
	data["stackingAmt"] = machine.stack_amt
	return data


/obj/machinery/mineral/stacking_unit_console/tgui_act(action, list/params)
	if(..())
		return TRUE

	switch(action)
		if("change_stack")
			machine.stack_amt = clamp(text2num(params["amt"]), 1, 50)
			. = TRUE

		if("release_stack")
			var/stack = params["stack"]
			if(machine.stack_storage[stack] > 0)
				var/stacktype = machine.stack_paths[stack]
				var/obj/item/stack/sheet/S = new stacktype(get_turf(machine.output))
				S.amount = machine.stack_storage[stack]
				machine.stack_storage[stack] = 0
			. = TRUE

	add_fingerprint(usr)



/**********************Mineral stacking unit**************************/
/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = TRUE
	anchored = TRUE
	var/obj/machinery/mineral/stacking_unit_console/console
	var/obj/machinery/mineral/input = null
	var/obj/machinery/mineral/output = null
	var/list/stack_storage[0]
	var/list/stack_paths[0]
	var/stack_amt = 50; // Amount to stack before releassing

/obj/machinery/mineral/stacking_machine/atom_init()
	..()
	for(var/stacktype in subtypesof(/obj/item/stack/sheet/mineral))
		var/obj/item/stack/S = stacktype //= new stacktype(src)
		stack_storage[initial(S.name)] = 0
		stack_paths[initial(S.name)] = stacktype
		//qdel(S)
	stack_storage["glass"] = 0
	stack_paths["glass"] = /obj/item/stack/sheet/glass
	stack_storage["metal"] = 0
	stack_paths["metal"] = /obj/item/stack/sheet/metal
	stack_storage["plasteel"] = 0
	stack_paths["plasteel"] = /obj/item/stack/sheet/plasteel
	stack_storage["phoron glass"] = 0
	stack_paths["phoron glass"] = /obj/item/stack/sheet/glass/phoronglass
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/stacking_machine/atom_init_late()
	for (var/dir in cardinal)
		input = locate(/obj/machinery/mineral/input, get_step(src, dir))
		if(input)
			break
	for (var/dir in cardinal)
		output = locate(/obj/machinery/mineral/output, get_step(src, dir))
		if(output)
			break

/obj/machinery/mineral/stacking_machine/process()
	if (src.output && src.input)
		var/turf/T = get_turf(input)
		for(var/obj/item/O in T.contents)
			if(!O) return
			if(istype(O,/obj/item/stack))
				var/obj/item/stack/S = O
				if(!isnull(stack_storage[S.name]))
					stack_storage[S.name] += S.get_amount()
					qdel(S)
				else
					S.loc = output.loc
			else
				O.loc = output.loc
	//Output amounts that are past stack_amt.
	for(var/sheet in stack_storage)
		if(stack_storage[sheet] >= stack_amt)
			var/stacktype = stack_paths[sheet]
			new stacktype (get_turf(output), stack_amt)
			stack_storage[sheet] -= stack_amt
	console.updateUsrDialog()
	return
