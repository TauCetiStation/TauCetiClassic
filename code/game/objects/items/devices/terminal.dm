/obj/item/device/terminal
	name = "Terminal"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	var/list/datum/pipe_system/component/saved_components = list()
	var/datum/pipe_system/component/selected_component
	var/datum/pipe_system/component/target_component
	var/datum/pipe_system/component/selected_program
	var/datum/pipe_system/process/active_process
	var/list/console_output = list()
	var/ram_used = 0
	var/ram_max = 64
	var/state = 0

/obj/item/device/terminal/atom_init()
	. = ..()
	InitDefaultSavedComponents()
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
	if(selected_component)
		data["selected_component"] = selected_component.GetApiObject()

	data["selected_program"] = null
	if(selected_program)
		data["selected_program"] = selected_program.GetApiObject()

	data["target_component"] = null
	if(target_component)
		data["target_component"] = target_component.GetApiObject()

	LAZYINITLIST(saved_components)
	data["saved_components"] = list()
	for(var/datum/pipe_system/component/C in saved_components)
		data["saved_components"][ref(C)] = C.GetApiObject()

	data["active_process_program"] = null
	if(active_process)
		data["active_process_program"] = active_process.GetApiObject()

	return data

/obj/item/device/terminal/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)

	if(..())
		return TRUE

	if(action == "interrupt_active_programm")
		active_process.interrupt = TRUE
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

	if(action == "select_component")
		selected_component = selected_program.ApiChange(action, params)
		return TRUE

	if(action == "set_target_component")
		target_component = FindComponent(params["link_component"])
		return TRUE

	if(target_component)
		params["target_component"] = target_component

	if(selected_program)
		selected_program.ApiChange(action, params)

	target_component = null

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
	selected_component = null
	target_component = null

	return TRUE


/obj/item/device/terminal/proc/FindComponent(ref_component)

	for(var/datum/pipe_system/component/C in saved_components)
		if(ref(C) == ref_component)
			return C.CopyComponent()

/obj/item/device/terminal/proc/InitDefaultSavedComponents()
	LAZYINITLIST(saved_components)

	var/datum/pipe_system/component/data/number/number_component_example = new(src, 0)
	var/datum/pipe_system/component/data/string/string_component_example = new(src, "")
	var/datum/pipe_system/component/data/number/for_cycle_count/for_cycle_count_example = new(src, 10)
	var/datum/pipe_system/component/data/number/for_cycle_initial/for_cycle_initial_example = new(src, 0)
	var/datum/pipe_system/component/proc_component/skip_component/skip_component = new(src)
	var/datum/pipe_system/component/proc_component/stop_program/stop_program = new(src)
	var/datum/pipe_system/component/proc_component/for_cycle/for_cycle = new(src)
	var/datum/pipe_system/component/awaiter/awaiter = new(src)
	var/datum/pipe_system/component/check/checker = new(src)

	LAZYADD(saved_components, number_component_example)
	LAZYADD(saved_components, string_component_example)
	LAZYADD(saved_components, for_cycle_count_example)
	LAZYADD(saved_components, for_cycle_initial_example)
	LAZYADD(saved_components, skip_component)
	LAZYADD(saved_components, stop_program)
	LAZYADD(saved_components, for_cycle)
	LAZYADD(saved_components, awaiter)
	LAZYADD(saved_components, checker)

	return TRUE

/obj/item/device/terminal/proc/DeleteSelectedComponent(datum/source, datum/pipe_system/component/deleted_component)
	if(ref(deleted_component) == ref(selected_program))
		InitNewProgram()

	if(ref(deleted_component) == ref(selected_component))
		selected_component = null

	if(ref(deleted_component) == ref(target_component))
		target_component = null

	return TRUE
