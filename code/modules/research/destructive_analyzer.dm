/*
Destructive Analyzer

It is used to destroy hand-held objects and advance technological research. Controls are in the linked R&D console.

Note: Must be placed within 3 tiles of the R&D Console
*/
/obj/machinery/r_n_d/destructive_analyzer
	name = "Destructive Analyzer"
	icon_state = "d_analyzer"
	var/obj/item/weapon/loaded_item = null
	var/decon_mod = 0

/obj/machinery/r_n_d/destructive_analyzer/atom_init()
	. = ..()
	component_parts = list()
	component_parts += new /obj/item/weapon/circuitboard/destructive_analyzer(null)
	component_parts += new /obj/item/weapon/stock_parts/scanning_module(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	RefreshParts()

/obj/machinery/r_n_d/destructive_analyzer/RefreshParts()
	..()

	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(obj/O, mob/user)
	if (shocked)
		shock(user,50)
	if(!loaded_item)
		if (default_deconstruction_screwdriver(user, "d_analyzer", "d_analyzer", O))
			update_icon()
			if(linked_console)
				linked_console.linked_destroy = null
				linked_console = null
			return

	if(exchange_parts(user, O))
		return

	default_deconstruction_crowbar(O)

	if (panel_open && is_wire_tool(O) && wires.interact(user))
		return
	if (disabled)
		return
	if (!powered())
		return
	if (!linked_console)
		to_chat(user, "<span class='warning'>\The [name] must be linked to an R&D console first!</span>")
		return
	if (busy)
		to_chat(user, "<span class='warning'>\The [name] is busy right now.</span>")
		return
	if (isitem(O) && !loaded_item)
		if(isrobot(user)) //Don't put your module items in there!
			return
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'>This doesn't seem to have a tech origin!</span>")
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			to_chat(user, "<span class='warning'>You cannot deconstruct this item!</span>")
			return
		if(!do_skill_checks(user))
			return
		busy = TRUE
		loaded_item = O
		user.drop_from_inventory(O, src)
		to_chat(user, "<span class='notice'>You add the [O.name] to the machine!</span>")
		icon_state = "d_analyzer_l"
		flick("d_analyzer_la", src)
		if(linked_console)
			nanomanager.update_uis(linked_console)
		VARSET_IN(src, busy, FALSE, 6)
		return 1
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/deconstruct_item()
	if(busy)
		to_chat(usr, "<span class='warning'>The destructive analyzer is busy at the moment.</span>")
		return
	if(!loaded_item)
		return

	busy = TRUE
	flick("d_analyzer_process", src)
	if(linked_console)
		linked_console.screen = "working"
	addtimer(CALLBACK(src, PROC_REF(finish_deconstructing)), 15)

/obj/machinery/r_n_d/destructive_analyzer/proc/finish_deconstructing()
	busy = FALSE
	if(hacked)
		return

	if(linked_console)
		linked_console.files.check_item_for_tech(loaded_item)
		linked_console.files.research_points += linked_console.files.experiments.get_object_research_value(loaded_item)
		linked_console.files.experiments.do_research_object(loaded_item)

		if(linked_console.linked_lathe)
			linked_console.linked_lathe.loaded_materials[MAT_METAL].amount += round(min((linked_console.linked_lathe.max_material_storage - linked_console.linked_lathe.TotalMaterials()), (loaded_item.m_amt*(decon_mod/10))))
			linked_console.linked_lathe.loaded_materials[MAT_GLASS].amount += round(min((linked_console.linked_lathe.max_material_storage - linked_console.linked_lathe.TotalMaterials()), (loaded_item.g_amt*(decon_mod/10))))

	if(istype(loaded_item,/obj/item/stack/sheet))
		var/obj/item/stack/sheet/S = loaded_item
		if(S.amount == 1)
			qdel(S)
			update_icon()
			loaded_item = null
		else
			S.use(1)
	else
		qdel(loaded_item)
		update_icon()
		loaded_item = null

	use_power(250)
	if(linked_console)
		linked_console.screen = "main"
		nanomanager.update_uis(linked_console)

/obj/machinery/r_n_d/destructive_analyzer/proc/eject_item()
	if(busy)
		to_chat(usr, "<span class='warning'>The destructive analyzer is busy at the moment.</span>")
		return

	if(loaded_item)
		loaded_item.forceMove(loc)
		loaded_item = null
		update_icon()

/obj/machinery/r_n_d/destructive_analyzer/power_change()
	. = ..()
	eject_item()
