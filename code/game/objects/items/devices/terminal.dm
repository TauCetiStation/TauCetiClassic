/obj/item/device/terminal
	name = "Terminal"
	icon = 'icons/obj/pda.dmi'
	icon_state = "aicard" // aicard-full
	item_state = "electronic"
	var/list/datum/pipe_system/component/reference_saved_components = list()
	var/list/datum/pipe_system/component/buffer_components = list()
	var/datum/pipe_system/component/first_component_program
	var/datum/pipe_system/component/selected_component
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
	if(selected_component)
		data["selected_component"] = selected_component.GetApiObject()

	data["tree_selected_component"] = null
	if(selected_component)
		data["tree_selected_component"] = selected_component.GetFirstComponent().GetApiObject()

	data["saved_components"] = list()

	LAZYINITLIST(buffer_saved_components)

	for(var/datum/pipe_system/component/C in buffer_saved_components)
		data["saved_components"][ref(C)] = C.GetApiObject()

	return data

/obj/item/device/terminal/tgui_act(action, list/params, datum/tgui/ui, datum/tgui_state/state)

	if(..())
		return TRUE

	var/datum/pipe_system/component/target_component = null
	if(params["target_link_component"])
		var/list/params_find = list()
		params_find["link_component"] = params["target_link_component"]
		for(var/datum/pipe_system/component/C in buffer_saved_components)
			if(istype(C))
				target_component = C.ApiChange("select_component", params_find)
				params["target_component"] = target_component

	var/datum/pipe_system/component/action_component = null
	if(params["action_link_component"])
		var/list/params_find = list()
		params_find["link_component"] = params["action_link_component"]
		for(var/datum/pipe_system/component/C in buffer_saved_components)
			if(istype(C))
				action_component = C.ApiChange("select_component", params_find)
				params["action_component"] = action_component

	if(action == "select_component")
		SelectComponent(action_component.ApiChange(action, params))
		return TRUE

	if(action == "clear_console")
		LAZYCLEARLIST(console_output)

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


/obj/item/device/terminal/proc/InitializeBuffer()

	LAZYINITLIST(buffer_saved_components)
	ram_used = buffer_saved_components.len

	return TRUE

/obj/item/device/terminal/proc/AddObjectInBuffer(object)

	InitializeBuffer()

	if(ram_used >= ram_max)
		return FALSE

	LAZYADD(buffer_saved_components, object)

	ram_used += 1

	return TRUE

/obj/item/device/terminal/proc/RemoveObjectInBuffer(object)

	InitializeBuffer()

	if(!buffer_saved_components.Find(object))
		return FALSE

	LAZYREMOVE(buffer_saved_components, object)

	ram_used -= 1

	return TRUE

/obj/item/device/terminal/proc/FindObjectInBuffer(link_object)

	InitializeBuffer()

	for(var/object in buffer_saved_components)
		if(ref(object) == link_object)
			return object

	return FALSE
