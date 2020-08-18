/*///////////////Circuit Imprinter (By Darem)////////////////////////
	Used to print new circuit boards (for computers and similar systems) and AI modules. Each circuit board pattern are stored in
a /datum/desgin on the linked R&D console. You can then print them out in a fasion similar to a regular lathe. However, instead of
using metal and glass, it uses glass and reagents (usually sulfuric acis).

*/
/obj/machinery/r_n_d/circuit_imprinter
	name = "Circuit Imprinter"
	icon_state = "circuit_imprinter"
	flags = OPENCONTAINER

	var/max_material_amount = 75000.0
	var/efficiency_coeff
	var/list/datum/rnd_material/loaded_materials = list()
	reagents = new(0)
	var/list/queue = list()

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

	loaded_materials[MAT_GLASS]    = new /datum/rnd_material("Glass",    /obj/item/stack/sheet/glass)
	loaded_materials[MAT_GOLD]     = new /datum/rnd_material("Gold",     /obj/item/stack/sheet/mineral/gold)
	loaded_materials[MAT_DIAMOND]  = new /datum/rnd_material("Diamond",  /obj/item/stack/sheet/mineral/diamond)

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

/obj/machinery/r_n_d/circuit_imprinter/proc/check_mat(datum/design/being_built, M)
	if(loaded_materials[M])
		return (loaded_materials[M].amount - (being_built.materials[M]/efficiency_coeff) >= 0) ? 1 : 0
	else
		return (reagents.has_reagent(M, (being_built.materials[M]/efficiency_coeff)) != 0) ? 1 : 0

/obj/machinery/r_n_d/circuit_imprinter/proc/TotalMaterials()
	var/am = 0
	for(var/M in loaded_materials)
		am += loaded_materials[M].amount
	return am

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
			for(var/M in loaded_materials)
				if(loaded_materials[M].amount >= loaded_materials[M].sheet_size)
					var/sheet_type = loaded_materials[M].sheet_type
					var/obj/item/stack/sheet/G = new sheet_type(loc)
					G.set_amount(round(loaded_materials[M].amount / G.perunit))
			default_deconstruction_crowbar(O)
			return
		else if(is_wire_tool(O) && wires.interact(user))
			return
		else
			to_chat(user, "<span class='warning'>You can't load the [src.name] while it's opened.</span>")
			return
	if (disabled)
		return
	if (!linked_console)
		to_chat(user, "\The [name] must be linked to an R&D console first!")
		return 1
	if (O.is_open_container())
		return
	if (!istype(O, /obj/item/stack/sheet/glass) && !istype(O, /obj/item/stack/sheet/mineral/gold) && !istype(O, /obj/item/stack/sheet/mineral/diamond))
		to_chat(user, "<span class='warning'>You cannot insert this item into the [name]!</span>")
		return
	if (stat)
		return
	if (busy)
		to_chat(user, "<span class='warning'>The [name] is busy. Please wait for completion of previous operation.</span>")
		return
	var/obj/item/stack/sheet/stack = O
	if ((TotalMaterials() + stack.perunit) > max_material_amount)
		to_chat(user, "<span class='warning'>The [name] is full. Please remove glass from the protolathe in order to insert more.</span>")
		return

	var/amount = round(input("How many sheets do you want to add?") as num)
	if(amount > stack.get_amount())
		amount = min(stack.get_amount(), round((max_material_amount-TotalMaterials())/stack.perunit))
	if(amount < 0)
		amount = 0
	if(amount == 0)
		return

	busy = 1
	use_power(max(1000, (3750*amount/10)))
	spawn(16)
		if(stack.get_amount() >= amount)
			to_chat(user, "<span class='notice'>You add [amount] sheets to the [src.name].</span>")
			for(var/M in loaded_materials)
				if(stack.type == loaded_materials[M].sheet_type)
					loaded_materials[M].amount += amount * stack.perunit
					stack.use(amount)
					break
		busy = 0
		if(linked_console)
			nanomanager.update_uis(linked_console)

/obj/machinery/r_n_d/circuit_imprinter/proc/queue_design(datum/design/D)
	var/datum/rnd_queue_design/RNDD = new /datum/rnd_queue_design(D, 1)

	if(queue.len) // Something is already being created, put us into queue
		queue += RNDD
	else if(!busy)
		queue += RNDD
		produce_design(RNDD)

/obj/machinery/r_n_d/circuit_imprinter/proc/clear_queue()
	queue = list()

/obj/machinery/r_n_d/circuit_imprinter/proc/restart_queue()
	if(queue.len && !busy)
		produce_design(queue[1])

/obj/machinery/r_n_d/circuit_imprinter/proc/produce_design(datum/rnd_queue_design/RNDD)
	var/datum/design/D = RNDD.design
	var/power = 2000
	for(var/M in D.materials)
		power += round(D.materials[M] / 5)
	power = max(2000, power)
	if (busy)
		to_chat(usr, "<span class='warning'>The [name] is busy right now</span>")
		return
	if (!(D.build_type & IMPRINTER))
		message_admins("Circuit imprinter exploit attempted by [key_name(usr, usr.client)]! [ADMIN_JMP(usr)]")
		return

	busy = TRUE
	flick("circuit_imprinter_ani", src)
	use_power(power)

	for(var/M in D.materials)
		if(!check_mat(D, M))
			visible_message("<span class='warning'>The [name] beeps, \"Not enough materials to complete prototype.\"</span>")
			busy = FALSE
			return
	for(var/M in D.materials)
		if(loaded_materials[M])
			loaded_materials[M].amount = max(0, (loaded_materials[M].amount - (D.materials[M] / efficiency_coeff)))
		else
			reagents.remove_reagent(M, D.materials[M]/efficiency_coeff)

	addtimer(CALLBACK(src, .proc/create_design, RNDD), 16)

/obj/machinery/r_n_d/circuit_imprinter/proc/create_design(datum/rnd_queue_design/RNDD)
	var/datum/design/D = RNDD.design
	var/atom/A = new D.build_path(loc)
	if(isobj(A))
		var/obj/O = A
		O.origin_tech = null
	busy = FALSE
	queue -= RNDD

	if(queue.len)
		produce_design(queue[1])

	if(linked_console)
		nanomanager.update_uis(linked_console)

/obj/machinery/r_n_d/circuit_imprinter/proc/eject_sheet(sheet_type, amount)
	if(loaded_materials[sheet_type])
		var/available_num_sheets = FLOOR(loaded_materials[sheet_type].amount / loaded_materials[sheet_type].sheet_size, 1)
		if(available_num_sheets > 0)
			var/S = loaded_materials[sheet_type].sheet_type
			var/obj/item/stack/sheet/sheet = new S(loc)
			var/sheet_ammount = min(available_num_sheets, amount)
			sheet.set_amount(sheet_ammount)
			loaded_materials[sheet_type].amount = max(0, loaded_materials[sheet_type].amount - sheet_ammount * loaded_materials[sheet_type].sheet_size)