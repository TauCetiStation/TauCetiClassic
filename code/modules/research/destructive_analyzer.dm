//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

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
	var/T = 0
	for(var/obj/item/weapon/stock_parts/S in component_parts)
		T += S.rating
	decon_mod = T

/obj/machinery/r_n_d/destructive_analyzer/meteorhit()
	qdel(src)
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/ConvertReqString2List(list/source_list)
	var/list/temp_list = params2list(source_list)
	for(var/O in temp_list)
		temp_list[O] = text2num(temp_list[O])
	return temp_list


/obj/machinery/r_n_d/destructive_analyzer/attackby(obj/O, mob/user)
	if (shocked)
		shock(user,50)
	if (default_deconstruction_screwdriver(user, "d_analyzer_t", "d_analyzer", O))
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
	if (!linked_console)
		to_chat(user, "<span class='warning'>The protolathe must be linked to an R&D console first!</span>")
		return
	if (busy)
		to_chat(user, "<span class='warning'> The protolathe is busy right now.</span>")
		return
	if (istype(O, /obj/item) && !loaded_item)
		if(isrobot(user)) //Don't put your module items in there!
			return
		if(!O.origin_tech)
			to_chat(user, "<span class='warning'> This doesn't seem to have a tech origin!</span>")
			return
		var/list/temp_tech = ConvertReqString2List(O.origin_tech)
		if (temp_tech.len == 0)
			to_chat(user, "<span class='warning'> You cannot deconstruct this item!</span>")
			return
		busy = 1
		loaded_item = O
		user.drop_item()
		O.loc = src
		to_chat(user, "<span class='notice'>You add the [O.name] to the machine!</span>")
		flick("d_analyzer_la", src)
		addtimer(CALLBACK(src, .proc/unbusy), 10)
		return 1
	return

/obj/machinery/r_n_d/destructive_analyzer/proc/unbusy()
	icon_state = "d_analyzer_l"
	busy = 0

//For testing purposes only.
/*/obj/item/weapon/deconstruction_test
	name = "Test Item"
	desc = "WTF?"
	icon = 'icons/obj/weapons.dmi'
	icon_state = "d20"
	g_amt = 5000
	m_amt = 5000
	origin_tech = "materials=5;phorontech=5;syndicate=5;programming=9"*/
