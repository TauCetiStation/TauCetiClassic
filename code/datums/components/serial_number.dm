// still not sure if this component is worth it

/datum/component/serial_number
	var/serial_number

/datum/component/serial_number/Initialize()
	if(!ismovable(parent))
		return COMPONENT_INCOMPATIBLE

	serial_number = add_zero("[rand(0, 999999)]", 6)
	if(SSticker.current_state < GAME_STATE_SETTING_UP)
		// late signal handler should allow us to register event items
		RegisterSignal(SSticker, COMSIG_TICKER_ROUND_STARTING, PROC_REF(register_in_inventory))

	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

/datum/component/serial_number/proc/register_in_inventory()
	SIGNAL_HANDLER

	var/atom/movable/I = parent
	var/area/A = get_area(I)

	if(!A || !length(A.inventory_papers))
		return

	for(var/obj/item/weapon/paper/inventory/P as anything in A.inventory_papers)
		P.add_item("[CASE(A, NOMINATIVE_CASE)]", "[CASEPLUS(I, NOMINATIVE_CASE)]", serial_number)

/datum/component/serial_number/proc/on_examine(datum/source, mob/user)
	SIGNAL_HANDLER
	to_chat(user, "<span class = 'notice'>\nСерийный номер: [serial_number]</span>")

/* inventory papers */

/obj/item/weapon/paper/inventory
	name = "Inventory"
	info = "Processing..."

	var/processing = FALSE
	var/list/inventory_area = list()
	var/list/inventory_data = list()

/obj/item/weapon/paper/inventory/atom_init()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/item/weapon/paper/inventory/Destroy()
	for(var/area_type as anything in inventory_area)
		var/area/A = get_area_by_type(area_type)
		LAZYREMOVE(A.inventory_papers, src)
	return ..()

/obj/item/weapon/paper/inventory/atom_init_late()
	if(!inventory_area)
		return

	for(var/area_type as anything in inventory_area)
		var/area/A = get_area_by_type(area_type)
		LAZYADD(A.inventory_papers, src)

/obj/item/weapon/paper/inventory/proc/add_item(area_name, item_name, serial_number)
	if(!(area_name in inventory_data))
		inventory_data[area_name] = list()
	if(!(item_name in inventory_data[area_name]))
		inventory_data[area_name][item_name] = list()

	inventory_data[area_name][item_name] += serial_number

/obj/item/weapon/paper/inventory/show_content(mob/user, forceshow = FALSE, forcestars = FALSE, infolinks = FALSE, view = TRUE)
	// need to compile data once after all initializations
	// can't hook it at init/signals because of races with all other stuff (area init, items init, component init and component signal handler)
	if(info == initial(info) && SSticker.current_state >= GAME_STATE_PLAYING && length(inventory_data))
		if(processing)
			return
		processing = TRUE
		update_inventory()

	..()

/obj/item/weapon/paper/inventory/proc/update_inventory()
	info = ""
	// it feels like 2010
	// todo: sort it at client? maybe make it tgui tool
	sortTim(inventory_data, GLOBAL_PROC_REF(cmp_text_asc))
	for(var/area_name as anything in inventory_data)
		info += "<table border='1'><caption style='font-weight: bold;'>[capitalize(area_name)]</caption><th>Наименование</th><th>Серийный номер</th>"
		sortTim(inventory_data[area_name], GLOBAL_PROC_REF(cmp_text_asc))
		for(var/item_name as anything in inventory_data[area_name])
			info += "<tr><td>[item_name] ([length(inventory_data[area_name][item_name])])</td><td></td></tr>"
			sortTim(inventory_data[area_name][item_name], GLOBAL_PROC_REF(cmp_text_asc))
			for(var/serial_number as anything in inventory_data[area_name][item_name])
				info += "<tr><td></td><td>[serial_number]</td></tr>"
		info += "</table>"

	inventory_data.Cut()
	processing = FALSE

/obj/item/weapon/paper/inventory/brig_armoury
	inventory_area = list(/area/station/security/armoury)
