/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	density = 1
	anchored = 1
	var/obj/machinery/mineral/stacking_machine/machine = null
	var/machinedir = SOUTHEAST

/obj/machinery/mineral/stacking_unit_console/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mineral/stacking_unit_console/atom_init_late()
	machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
	if (machine)
		machine.console = src
	else
		qdel(src)

/obj/machinery/mineral/stacking_unit_console/ui_interact(mob/user)
	var/dat

	dat += text("<table>")

	for(var/stacktype in machine.stack_storage)
		if(machine.stack_storage[stacktype] > 0)
			dat += "<tr><td width = 150><b>[capitalize(stacktype)]:</b></td><td width = 30>[machine.stack_storage[stacktype]]</td><td width = 50><A href='?src=\ref[src];release_stack=[stacktype]'>\[release\]</a></td></tr>"
	dat += "</table><hr>"
	dat += text("<br>Stacking: [machine.stack_amt] <A href='?src=\ref[src];change_stack=1'>\[change\]</a><br><br>")

	var/datum/browser/popup = new(user, "window=processor_console", "Stacking Unit Console", 400, 400)
	popup.set_content(dat)
	popup.open()

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	. = ..()
	if(!.)
		return
	if(href_list["change_stack"])
		var/choice = input("What would you like to set the stack amount to?") as null|anything in list(1,5,10,20,50)
		if(!choice)
			return FALSE
		machine.stack_amt = choice
	if(href_list["release_stack"])
		if(machine.stack_storage[href_list["release_stack"]] > 0)
			var/stacktype = machine.stack_paths[href_list["release_stack"]]
			new stacktype (get_turf(machine.output), machine.stack_storage[href_list["release_stack"]])
			machine.stack_storage[href_list["release_stack"]] = 0

	src.updateUsrDialog()


/**********************Mineral stacking unit**************************/
/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	density = 1
	anchored = 1.0
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
