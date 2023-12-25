/obj/item/device/terminal
	name = "Terminal"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	var/list/datum/pipe_system/component/saved_components = list()
	var/datum/pipe_system/component/selected_component
	var/datum/pipe_system/component/selected_program
	var/datum/pipe_system/process/active_process
	var/list/console_output = list()
	var/ram_used = 0
	var/ram_max = 20
	var/state = 0

/obj/item/device/terminal/atom_init()
	. = ..()

	RegisterSignal(src, COMSIG_PIPE_COMPONENT_DELETE, PROC_REF(DeleteSelectedComponent))

/obj/item/device/terminal/attack_self(mob/user)
	tgui_interact(user, null)
	. = ..()

/obj/item/device/terminal/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terminal", "Terminal")
		ui.open()

/obj/item/device/terminal/tgui_data(mob/user)

	var/list/data = list()
	data["console_output"] = console_output

	data["selected_component"] = null

	data["saved_components"] = saved_components

	return data

/obj/item/device/terminal/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)

	if(..())
		return TRUE

	if(action == "clear_console")
		LAZYCLEARLIST(console_output)
		return TRUE

	if(action == "init_new_program")
		InitNewProgram()
		return TRUE

	if(action == "set_first_component")
		selected_program = FindComponent(params["link_component"])
		return TRUE

	if(params["target_component_link"])
		params["target_component"] = FindComponent(params["target_component_link"])

	if(selected_program)
		selected_program.ApiChange(action, params)

	return TRUE

/obj/item/device/terminal/attack_atom(atom/attacked_atom, mob/living/user, params)
	. = ..()

	if(istype(attacked_atom, /obj))
		var/obj/scan_object = attacked_atom
		ScanObject(scan_object)
		return

	if(!istype(attacked_atom, /obj/machinery))
		return

	var/obj/machinery/target = attacked_atom

	var/datum/pipe_system/process/process = new()

	process.AddComponentPipe(selected_program)

	target.interact_program(process)

/obj/item/device/terminal/proc/AddConsoleOutput(console_message)

	LAZYINITLIST(console_output)
	LAZYADD(console_output, console_message)

	return console_output

/obj/item/device/terminal/proc/SelectComponent(datum/pipe_system/component/C)

	selected_component = C

	return selected_component


/obj/item/device/terminal/proc/ScanObject(obj/scan_object)

	var/list/datum/pipe_system/component/components = scan_object.get_data_components()

	for(var/datum/pipe_system/component/C in components)
		LAZYADD(saved_components, C)

/obj/item/device/terminal/proc/InitNewProgram(first_ref)

	selected_program = null


/obj/item/device/terminal/proc/FindComponent(ref_component)

	for(var/datum/pipe_system/component/C in saved_components)
		if(ref(C) == ref_component)
			return C.CopyComponent()
