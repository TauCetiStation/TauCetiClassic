/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/datum/rnd_material
	var/name
	var/amount
	var/sheet_size
	var/sheet_type

/datum/rnd_material/New(Name, obj/item/stack/sheet/Sheet_type)
	name = Name
	amount = 0
	sheet_type = Sheet_type
	sheet_size = initial(Sheet_type.perunit)

/datum/rnd_queue_design
	var/name
	var/datum/design/design
	var/amount

/datum/rnd_queue_design/New(datum/design/D, Amount)
	name = D.name
	if(Amount > 1)
		name = "[name] x[Amount]"

	design = D
	amount = Amount

/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	icon_state = "protolathe"

	var/max_material_storage = 100000
	var/efficiency_coeff
	var/list/datum/rnd_material/loaded_materials = list()
	var/list/queue = list()

/obj/machinery/r_n_d/protolathe/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/protolathe(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	RefreshParts()

	loaded_materials[MAT_METAL]    = new /datum/rnd_material("Metal",    /obj/item/stack/sheet/metal)
	loaded_materials[MAT_GLASS]    = new /datum/rnd_material("Glass",    /obj/item/stack/sheet/glass)
	loaded_materials[MAT_SILVER]   = new /datum/rnd_material("Silver",   /obj/item/stack/sheet/mineral/silver)
	loaded_materials[MAT_GOLD]     = new /datum/rnd_material("Gold",     /obj/item/stack/sheet/mineral/gold)
	loaded_materials[MAT_DIAMOND]  = new /datum/rnd_material("Diamond",  /obj/item/stack/sheet/mineral/diamond)
	loaded_materials[MAT_URANIUM]  = new /datum/rnd_material("Uranium",  /obj/item/stack/sheet/mineral/uranium)
	loaded_materials[MAT_PHORON]   = new /datum/rnd_material("Phoron",   /obj/item/stack/sheet/mineral/phoron)
	loaded_materials[MAT_BANANIUM] = new /datum/rnd_material("Bananium", /obj/item/stack/sheet/mineral/clown)

/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	var/am = 0
	for(var/M in loaded_materials)
		am += loaded_materials[M].amount
	return am

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += (M.rating/3)
	efficiency_coeff = max(T, 1)

/obj/machinery/r_n_d/protolathe/proc/check_mat(datum/design/being_built, M)
	var/A = 0
	if(loaded_materials[M])
		A = loaded_materials[M].amount
	A = A / max(1 , (being_built.materials[M]/efficiency_coeff))
	return A


/obj/machinery/r_n_d/protolathe/attackby(obj/item/I, mob/user)
	if (shocked)
		shock(user,50)
	if (I.is_open_container())
		return 1
	if (default_deconstruction_screwdriver(user, "protolathe_t", "protolathe", I))
		if(linked_console)
			linked_console.linked_lathe = null
			linked_console = null
		return

	if(exchange_parts(user, I))
		return

	if (panel_open)
		if(iscrowbar(I))
			for(var/M in loaded_materials)
				if(loaded_materials[M].amount >= loaded_materials[M].sheet_size)
					var/sheet_type = loaded_materials[M].sheet_type
					var/obj/item/stack/sheet/G = new sheet_type(loc)
					G.set_amount(round(loaded_materials[M].amount / G.perunit))
			default_deconstruction_crowbar(I)
			return 1
		else if (is_wire_tool(I) && wires.interact(user))
			return 1
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return 1

	if (disabled)
		return
	if (!linked_console)
		to_chat(user, "\The protolathe must be linked to an R&D console first!")
		return 1
	if (busy)
		to_chat(user, "<span class='warning'>The protolathe is busy. Please wait for completion of previous operation.</span>")
		return 1
	if (!istype(I, /obj/item/stack/sheet))
		to_chat(user, "<span class='warning'>You cannot insert this item into the protolathe!</span>")
		return 1
	if (stat)
		return 1
	if(istype(I,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = I
		if (TotalMaterials() + S.perunit > max_material_storage)
			to_chat(user, "<span class='warning'>The protolathe's material bin is full. Please remove material before adding more.</span>")
			return 1

	var/obj/item/stack/sheet/stack = I
	var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
	if(!I)
		return
	if(amount > stack.get_amount())
		amount = stack.get_amount()
	if(max_material_storage - TotalMaterials() < (amount*stack.perunit))//Can't overfill
		amount = min(stack.get_amount(), round((max_material_storage-TotalMaterials())/stack.perunit))
	if(amount < 0)//No negative numbers
		amount = 0
	if(amount == 0)
		return

	busy = TRUE

	to_chat(user, "<span class='notice'>You add [amount] sheets to the [name].</span>")

	add_overlay("protolathe_[stack.name]")
	sleep(10)
	cut_overlay("protolathe_[stack.name]")

	use_power(max(1000, (3750 * amount / 10)))

	if(stack.get_amount() >= amount)
		for(var/M in loaded_materials)
			if(stack.type == loaded_materials[M].sheet_type)
				loaded_materials[M].amount += amount * stack.perunit
				stack.use(amount)
				break

	busy = FALSE
	if(linked_console)
		nanomanager.update_uis(linked_console)

/obj/machinery/r_n_d/protolathe/proc/queue_design(datum/design/D, amount)
	var/datum/rnd_queue_design/RNDD = new /datum/rnd_queue_design(D, amount)

	if(queue.len) // Something is already being created, put us into queue
		queue += RNDD
	else if(!busy)
		queue += RNDD
		produce_design(RNDD)

/obj/machinery/r_n_d/protolathe/proc/clear_queue()
	queue = list()

/obj/machinery/r_n_d/protolathe/proc/restart_queue()
	if(queue.len && !busy)
		produce_design(queue[1])

/obj/machinery/r_n_d/protolathe/proc/produce_design(datum/rnd_queue_design/RNDD)
	var/datum/design/D = RNDD.design
	var/amount = RNDD.amount
	var/power = 2000
	amount = max(1, min(10, amount))
	for(var/M in D.materials)
		power += round(D.materials[M] * amount / 5)
	power = max(2000, power)
	if(busy)
		to_chat(usr, "<span class='warning'>The [name] is busy right now</span>")
		return
	if (!(D.build_type & PROTOLATHE))
		message_admins("Protolathe exploit attempted by [key_name(usr, usr.client)]! [ADMIN_JMP(usr)]")
		return

	busy = TRUE
	flick("protolathe_n",src)
	use_power(power)

	for(var/M in D.materials)
		if(check_mat(D, M) < amount)
			visible_message("<span class='warning'>The [name] beeps, \"Not enough materials to complete prototype.\"</span>")
			busy = FALSE
			return
	for(var/M in D.materials)
		loaded_materials[M].amount = max(0, (loaded_materials[M].amount - (D.materials[M] / efficiency_coeff * amount)))

	addtimer(CALLBACK(src, .proc/create_design, RNDD), 32 * amount / efficiency_coeff)

/obj/machinery/r_n_d/protolathe/proc/create_design(datum/rnd_queue_design/RNDD)
	if(!linked_console)
		return
	var/datum/design/D = RNDD.design
	var/amount = RNDD.amount
	for(var/i = 1 to amount)
		var/obj/new_item = new D.build_path(loc)
		// This is very important. Almost all items constructed via protolathe are unreliable
		// And are deconstructions of items made by deconstructing other items
		// So consider them tests of "new" construction techniques for an item already known
		// #define MAGIC_2_MANIPULATORS_MAX_OUTPUT_CONSIDERING_IT_SHOULD_ROUND_UP_TO_30_PERCENT_COEFFICIENT 3.75
		new_item.prototipify(min_reliability=linked_console.files.design_reliabilities[D.id] + efficiency_coeff * 12.5,  max_reliability=70 + efficiency_coeff * 12.5)
		new_item.m_amt /= efficiency_coeff
		new_item.g_amt /= efficiency_coeff

		linked_console.files.design_reliabilities[D.id] += linked_console.files.design_reliabilities[D.id] * (RND_RELIABILITY_EXPONENT ** linked_console.files.design_created_prototypes[D.id])
		linked_console.files.design_reliabilities[D.id] = max(round(linked_console.files.design_reliabilities[D.id], 5), 1)
		linked_console.files.design_created_prototypes[D.id]++
	busy = FALSE
	queue -= RNDD

	if(queue.len)
		produce_design(queue[1])

	if(linked_console)
		nanomanager.update_uis(linked_console)

/obj/machinery/r_n_d/protolathe/proc/eject_sheet(sheet_type, amount)
	if(loaded_materials[sheet_type])
		var/available_num_sheets = FLOOR(loaded_materials[sheet_type].amount / loaded_materials[sheet_type].sheet_size, 1)
		if(available_num_sheets > 0)
			var/S = loaded_materials[sheet_type].sheet_type
			var/obj/item/stack/sheet/sheet = new S(loc)
			var/sheet_ammount = min(available_num_sheets, amount)
			sheet.set_amount(sheet_ammount)
			loaded_materials[sheet_type].amount = max(0, loaded_materials[sheet_type].amount - sheet_ammount * loaded_materials[sheet_type].sheet_size)