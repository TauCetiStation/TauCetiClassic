/obj/item/device/terminal
	name = "Terminal"
	var/list/datum/pipe_system/component/saved_components = list()
	var/datum/pipe_system/component/first_component_program
	var/datum/pipe_system/component/selected_component
	var/datum/pipe_system/process/active_process
	var/list/console_output = list()
	var/ram_used = 0
	var/ram_max = 10
	var/state = 0

/obj/item/device/terminal/atom_init()
	. = ..()

	RegisterSignal(src, COMSIG_PIPE_COMPONENT_DELETE, PROC_REF(DeleteSelectedComponent))

	var/datum/pipe_system/component/data/log_target/terminal_logger_data = new(src, src)

	var/datum/pipe_system/component/proc_component/log_terminal/terminal_logger = new(src)
	var/datum/pipe_system/component/data/test_data1 = new(src, "TEST VALUE")
	terminal_logger.AddLastComponent(test_data1)

	var/datum/pipe_system/component/awaiter/logger = new(src, null, terminal_logger, null)

	terminal_logger_data.AddLastComponent(logger)

	var/datum/pipe_system/component/data/test_data2 = new(src, "TEST VALUE 2")
	terminal_logger_data.AddLastComponent(test_data2)

	var/datum/pipe_system/component/data/test_data3 = new(src, "TEST VALUE 3")
	terminal_logger_data.AddLastComponent(test_data3)

	selected_component = terminal_logger_data.CopyComponent()

/obj/item/device/terminal/attack_self(mob/user)
	. = ..()
	tgui_interact(user, null)

/obj/item/device/terminal/tgui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Terminal", "Terminal")
		ui.open()

/obj/item/device/terminal/tgui_data(mob/user)
	var/list/data = list()
	data["console_output"] = console_output

	if(selected_component)
		data["selected_component"] = selected_component.GetApiObject()
	else
		data["selected_component"] = null

	if(selected_component)
		data["tree_selected_component"] = selected_component.GetFirstComponent().GetApiObject()
	else
		data["tree_selected_component"] = null

	return data

/obj/item/device/terminal/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)

	if(..())
		return TRUE

	if(action == "clear_console")
		LAZYCLEARLIST(console_output)

	if(action == "select_component" && selected_component)
		var/new_selected_component = selected_component.ApiChange(action, params)
		if(new_selected_component)
			SelectComponent(new_selected_component)
			return TRUE

	if(selected_component)
		selected_component.ApiChange(action, params)

	return TRUE

/obj/item/device/terminal/attack_atom(atom/attacked_atom, mob/living/user, params)
	. = ..()

	if(!istype(attacked_atom, /obj/machinery))
		return

	var/obj/machinery/target = attacked_atom

	var/datum/pipe_system/process/process = new()

	process.AddComponentPipe(selected_component)

	target.interact_program(process)

/obj/item/device/terminal/proc/AddConsoleOutput(console_message)

	LAZYINITLIST(console_output)
	LAZYADD(console_output, console_message)

	return console_output

/obj/item/device/terminal/proc/SelectComponent(datum/pipe_system/component/C)

	selected_component = C

	return selected_component

/obj/item/device/terminal/proc/DeleteSelectedComponent(obj/item/device/terminal/terminal, datum/pipe_system/component/C)

	if(selected_component == C)
		selected_component = null

	if(C.next_component)
		SelectComponent(C.next_component)
		return TRUE

	if(C.previous_component)
		SelectComponent(C.previous_component)
		return TRUE

	return TRUE

/obj/item/device/terminal/proc/RestoreSavedComponents()
	return TRUE

/obj/item/device/terminal/Topic(href, href_list)
	. = ..()

	if(href_list["clear_console"])
		LAZYCLEARLIST(console_output)

	if(href_list["get_saved_components"])
		return saved_components

	if(href_list["select_component"])
		var/datum/pipe_system/component/component = href_list["select_component"]
		if(istype(component))
			return SelectComponent(component)

	if(href_list["save_component"])
		var/datum/pipe_system/component/component = href_list["save_component"]
		if(istype(component))
			LAZYADD(saved_components, component)
			return saved_components

	if(href_list["remove_component_saved_components"])
		var/datum/pipe_system/component/component = href_list["remove_component_saved_components"]
		if(istype(component))
			LAZYREMOVE(saved_components, component)
			return saved_components

	if(href_list["restore_saved_components"])
		return RestoreSavedComponents()

	return selected_component
