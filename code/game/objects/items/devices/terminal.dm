/obj/item/device/terminal
	name = "Terminal"
	var/list/datum/pipe_system/component/saved_components = list()
	var/datum/pipe_system/component/first_component_program
	var/datum/pipe_system/component/selected_component
	var/datum/pipe_system/process/active_process
	var/list/console_output = list()
	var/ram_used = 0
	var/ram_max = 10

/obj/item/device/terminal/atom_init()
	. = ..()

/obj/item/device/terminal/attack_atom(atom/attacked_atom, mob/living/user, params)
	. = ..()

	if(!istype(attacked_atom, /obj/machinery))
		return

	var/obj/machinery/target = attacked_atom

	var/datum/pipe_system/process/process = new()

	var/datum/pipe_system/component/data/log_target/terminal_logger = new(src, src)
	var/datum/pipe_system/component/awaiter/logger = new(src, null, terminal_logger, null)
	process.AddComponentPipe(logger)

	var/datum/pipe_system/component/data/target_program/target_machinery = new(src, target)
	process.AddComponentPipe(target_machinery)

	var/datum/pipe_system/component/data/program_command/program_command = new(src, "drop_contents")
	process.AddComponentPipe(program_command)

	var/datum/pipe_system/component/data/access/access = new(src, 1)
	process.AddComponentPipe(access)

	target.interact_program(process)

/obj/item/device/terminal/proc/AddConsoleOutput(console_message)

	LAZYINITLIST(console_output)
	LAZYADD(console_output, console_message)

	return console_output

/obj/item/device/terminal/proc/SelectComponent(datum/pipe_system/component/C)

	selected_component = C

	return selected_component

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

	if(selected_component)
		selected_component.ApiChange(href_list)

	return selected_component
