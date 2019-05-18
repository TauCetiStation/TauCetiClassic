/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER

	var/g_amount = 0
	var/gold_amount = 0
	var/diamond_amount = 0
	var/uranium_amount = 0
	var/max_material_amount = 75000.0
	var/efficiency_coeff
	reagents = new(0)

/obj/machinery/r_n_d/circuit_imprinter/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/circuit_imprinter(src)
	component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	component_parts += new /obj/item/weapon/reagent_containers/glass/beaker(src)
	RefreshParts()
	reagents.my_atom = src

/obj/machinery/r_n_d/circuit_imprinter/RefreshParts()
	var/T = 0
	for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
		reagents.maximum_volume += G.volume
		G.reagents.trans_to(src, G.reagents.total_volume)
	for(var/obj/item/weapon/stock_parts/matter_bin/M in component_parts)
		T += M.rating
	max_material_amount = T * 75000.0
	T = 0
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		T += M.rating
	efficiency_coeff = 2 ** (T - 1)

/obj/machinery/r_n_d/circuit_imprinter/blob_act()
	if (prob(50))
		qdel(src)

/obj/machinery/r_n_d/circuit_imprinter/meteorhit()
	qdel(src)
	return

/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(datum/design/being_built, M)
	switch(M)
		if(MAT_GLASS)
			return (g_amount - (being_built.materials[M]/efficiency_coeff) >= 0) ? 1 : 0
		if(MAT_GOLD)
			return (gold_amount - (being_built.materials[M]/efficiency_coeff) >= 0) ? 1 : 0
		if(MAT_DIAMOND)
			return (diamond_amount - (being_built.materials[M]/efficiency_coeff) >= 0) ? 1 : 0
		else
			return (reagents.has_reagent(M, (being_built.materials[M]/efficiency_coeff)) != 0) ? 1 : 0

/obj/machinery/r_n_d/circuit_imprinter/proc/TotalMaterials()
	return g_amount + gold_amount + diamond_amount + uranium_amount

/obj/machinery/r_n_d/circuit_imprinter/attackby(obj/item/O, mob/user)
	if (shocked)
		shock(user,50)
	if (default_deconstruction_screwdriver(user, "circuit_imprinter_t", "circuit_imprinter", O))
		if(linked_console)
			linked_console.linked_imprinter = null
			linked_console = null
		return

	if(exchange_parts(user, O))
		return

	if (panel_open)
		if(iscrowbar(O))
			for(var/obj/item/weapon/reagent_containers/glass/G in component_parts)
				reagents.trans_to(G, G.reagents.maximum_volume)
			if(g_amount >= 3750)
				new /obj/item/stack/sheet/glass(loc, round(g_amount / 3750))
			if(gold_amount >= 2000)
				new /obj/item/stack/sheet/mineral/gold(loc, round(gold_amount / 2000))
			if(diamond_amount >= 2000)
				new /obj/item/stack/sheet/mineral/diamond(loc, round(diamond_amount / 2000))
			default_deconstruction_crowbar(O)
			return
		else if(is_wire_tool(O) && wires.interact(user))
			return
		else
			to_chat(user, "\red You can't load the [src.name] while it's opened.")
			return
	if (disabled)
		return
	if (!linked_console)
		to_chat(user, "\The [name] must be linked to an R&D console first!")
		return 1
	if (O.is_open_container())
		return
	if (!istype(O, /obj/item/stack/sheet/glass) && !istype(O, /obj/item/stack/sheet/mineral/gold) && !istype(O, /obj/item/stack/sheet/mineral/diamond))
		to_chat(user, "\red You cannot insert this item into the [name]!")
		return
	if (stat)
		return
	if (busy)
		to_chat(user, "\red The [name] is busy. Please wait for completion of previous operation.")
		return
	var/obj/item/stack/sheet/stack = O
	if ((TotalMaterials() + stack.perunit) > max_material_amount)
		to_chat(user, "\red The [name] is full. Please remove glass from the protolathe in order to insert more.")
		return

	var/amount = round(input("How many sheets do you want to add?") as num)
	if(amount < 0)
		amount = 0
	if(amount == 0)
		return
	if(amount > stack.get_amount())
		amount = min(stack.get_amount(), round((max_material_amount-TotalMaterials())/stack.perunit))

	busy = 1
	use_power(max(1000, (3750*amount/10)))
	spawn(16)
		if(stack.get_amount() >= amount)
			to_chat(user, "\blue You add [amount] sheets to the [src.name].")
			if(istype(stack, /obj/item/stack/sheet/glass))
				g_amount += amount * 3750
			else if(istype(stack, /obj/item/stack/sheet/mineral/gold))
				gold_amount += amount * 2000
			else if(istype(stack, /obj/item/stack/sheet/mineral/diamond))
				diamond_amount += amount * 2000
			stack.use(amount)
		busy = 0
		src.updateUsrDialog()
