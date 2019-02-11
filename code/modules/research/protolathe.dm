/*
Protolathe

Similar to an autolathe, you load glass and metal sheets (but not other objects) into it to be used as raw materials for the stuff
it creates. All the menus and other manipulation commands are in the R&D console.

Note: Must be placed west/left of and R&D console to function.

*/
/obj/machinery/r_n_d/protolathe
	name = "Protolathe"
	icon_state = "protolathe"
	flags = OPENCONTAINER

	var/max_material_storage = 100000 //All this could probably be done better with a list but meh.
	var/m_amount = 0.0
	var/g_amount = 0.0
	var/gold_amount = 0.0
	var/silver_amount = 0.0
	var/phoron_amount = 0.0
	var/uranium_amount = 0.0
	var/diamond_amount = 0.0
	var/clown_amount = 0.0
	var/efficiency_coeff
	reagents = new()


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
	reagents.my_atom = src

/obj/machinery/r_n_d/protolathe/proc/TotalMaterials() //returns the total of all the stored materials. Makes code neater.
	return m_amount + g_amount + gold_amount + silver_amount + phoron_amount + uranium_amount + diamond_amount + clown_amount

/obj/machinery/r_n_d/protolathe/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_storage = T * 75000
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += (M.rating/3)
	efficiency_coeff = max(T, 1)

/obj/machinery/r_n_d/protolathe/proc/check_mat(datum/design/being_built, M)
	var/A = 0
	switch(M)
		if(MAT_METAL)
			A = m_amount
		if(MAT_GLASS)
			A = g_amount
		if(MAT_GOLD)
			A = gold_amount
		if(MAT_SILVER)
			A = silver_amount
		if(MAT_PHORON)
			A = phoron_amount
		if(MAT_URANIUM)
			A = uranium_amount
		if(MAT_DIAMOND)
			A = diamond_amount
		if("$clown")
			A = clown_amount
		else
			A = reagents.has_reagent(M, (being_built.materials[M]/efficiency_coeff))
			//return reagents.has_reagent(M, (being_built.materials[M]/efficiency_coeff))
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
		if(istype(I, /obj/item/weapon/crowbar))
			for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			if(m_amount >= 3750)
				var/obj/item/stack/sheet/metal/G = new (loc)
				G.set_amount(round(m_amount / G.perunit))
			if(g_amount >= 3750)
				var/obj/item/stack/sheet/glass/G = new (loc)
				G.set_amount(round(g_amount / G.perunit))
			if(phoron_amount >= 2000)
				var/obj/item/stack/sheet/mineral/phoron/G = new (loc)
				G.set_amount(round(phoron_amount / G.perunit))
			if(silver_amount >= 2000)
				var/obj/item/stack/sheet/mineral/silver/G = new (loc)
				G.set_amount(round(silver_amount / G.perunit))
			if(gold_amount >= 2000)
				var/obj/item/stack/sheet/mineral/gold/G = new (loc)
				G.set_amount(round(gold_amount / G.perunit))
			if(uranium_amount >= 2000)
				var/obj/item/stack/sheet/mineral/uranium/G = new (loc)
				G.set_amount(round(uranium_amount / G.perunit))
			if(diamond_amount >= 2000)
				var/obj/item/stack/sheet/mineral/diamond/G = new (loc)
				G.set_amount(round(diamond_amount / G.perunit))
			if(clown_amount >= 2000)
				var/obj/item/stack/sheet/mineral/clown/G = new (loc)
				G.set_amount(round(clown_amount / G.perunit))
			default_deconstruction_crowbar(I)
			return 1
		else if (is_wire_tool(I) && wires.interact(user))
			return 1
		else
			to_chat(user, "\red You can't load the [src.name] while it's opened.")
			return 1

	if (disabled)
		return
	if (!linked_console)
		to_chat(user, "\The protolathe must be linked to an R&D console first!")
		return 1
	if (busy)
		to_chat(user, "\red The protolathe is busy. Please wait for completion of previous operation.")
		return 1
	if (!istype(I, /obj/item/stack/sheet))
		to_chat(user, "\red You cannot insert this item into the protolathe!")
		return 1
	if (stat)
		return 1
	if(istype(I,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = I
		if (TotalMaterials() + S.perunit > max_material_storage)
			to_chat(user, "\red The protolathe's material bin is full. Please remove material before adding more.")
			return 1

	var/obj/item/stack/sheet/stack = I
	var/amount = round(input("How many sheets do you want to add?") as num)//No decimals
	if(!I)
		return
	if(amount < 0)//No negative numbers
		amount = 0
	if(amount == 0)
		return
	if(amount > stack.get_amount())
		amount = stack.get_amount()
	if(max_material_storage - TotalMaterials() < (amount*stack.perunit))//Can't overfill
		amount = min(stack.get_amount(), round((max_material_storage-TotalMaterials())/stack.perunit))

	busy = TRUE

	to_chat(user, "<span class='notice'>You add [amount] sheets to the [name].</span>")

	overlays += "protolathe_[stack.name]"
	sleep(10)
	overlays -= "protolathe_[stack.name]"

	use_power(max(1000, (3750 * amount / 10)))

	if(stack.get_amount() >= amount)
		switch(stack.type)
			if(/obj/item/stack/sheet/metal)
				m_amount += amount * 3750
			if(/obj/item/stack/sheet/glass)
				g_amount += amount * 3750
			if(/obj/item/stack/sheet/mineral/gold)
				gold_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/silver)
				silver_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/phoron)
				phoron_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/uranium)
				uranium_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/diamond)
				diamond_amount += amount * 2000
			if(/obj/item/stack/sheet/mineral/clown)
				clown_amount += amount * 2000

		stack.use(amount)

	busy = FALSE
	updateUsrDialog()
