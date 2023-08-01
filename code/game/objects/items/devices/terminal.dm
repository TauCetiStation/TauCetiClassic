/obj/item/device/terminal
	name = "Terminal"
	var/list/datum/pipe_system/component/saved_components = list()
	var/datum/pipe_system/component/first_component_program
	var/datum/pipe_system/component/selected_component


/obj/item/device/terminal/atom_init()
	. = ..()

/obj/item/device/terminal/proc/SelectComponent(datum/pipe_system/component/C)

	selected_component = C

	return selected_component

/obj/item/device/terminal/Topic(href, href_list)
	. = ..()

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

	selected_component.ApiChange(href_list)

	return selected_component
