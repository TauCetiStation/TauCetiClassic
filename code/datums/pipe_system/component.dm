/datum/pipe_system/component
	var/datum/parent
	var/id_component = "DEFAULT"
	var/datum/pipe_system/component/next_component
	var/datum/pipe_system/component/previous_component

/datum/pipe_system/component/New(datum/P)
	parent = P

/datum/pipe_system/component/proc/ChangeNextComponent(datum/pipe_system/component/C)

	if(!next_component)
		next_component = C
		return TRUE

	var/datum/pipe_system/component/old_next_component = next_component

	next_component = C
	old_next_component.previous_component = C.GetLastComponent()
	old_next_component.previous_component.next_component = old_next_component
	C.previous_component = src
	return TRUE

/datum/pipe_system/component/proc/DeleteNextComponent()

	if(next_component)
		next_component.SelfDelete()

/datum/pipe_system/component/proc/DeletePreviousComponent()

	if(previous_component)
		previous_component.SelfDelete()

/datum/pipe_system/component/proc/SelfDelete()

	if(previous_component)
		previous_component.next_component = next_component

	if(next_component)
		next_component.previous_component = previous_component

	qdel(src)

	return TRUE

/datum/pipe_system/component/proc/AddLastComponent(datum/pipe_system/component/C)

	if(isnull(C))
		return FALSE

	if(!next_component)
		next_component = C
		return TRUE

	return next_component.AddLastComponent(C)

/datum/pipe_system/component/proc/GetLastComponent()

	if(!next_component)
		return src

	return next_component.GetLastComponent()

/datum/pipe_system/component/proc/RunTimeAction(datum/pipe_system/process/process)

	return TRUE

/datum/pipe_system/component/proc/Action(datum/pipe_system/process/process)

	process.SetActiveComponent(src)

	RunTimeAction(process)

	process.activate += 1

	SEND_SIGNAL(process, COMSIG_PIPE_COMPONENT_ACTION)

	if(!next_component)
		SEND_SIGNAL(process, COMSIG_PIPE_COMPONENT_ACTION_LAST)

	return TryActionNextComponent(process)

/datum/pipe_system/component/proc/TryActionNextComponent(datum/pipe_system/process/process)

	if(!next_component)
		return TRUE

	return next_component.Action(process)

/datum/pipe_system/component/proc/CopyComponentGun()

	var/datum/pipe_system/component/new_component = new type(parent)

	new_component.id_component = id_component

	if(next_component)
		new_component.next_component = next_component.CopyComponentGun()

	return new_component

/datum/pipe_system/component/proc/ApiChange(href_list)

	if(href_list["get_this_component"])
		return src

	if(href_list["get_copy_component"])
		return CopyComponentGun()

	if(href_list["change_next_component"])
		return ChangeNextComponent(href_list["change_next_component"])

	if(href_list["add_last_component"])
		return AddLastComponent(href_list["add_last_component"])

	if(href_list["get_last_component"])
		return GetLastComponent()

	if(href_list["self_delete"])
		return SelfDelete()

	if(href_list["delete_next_component"])
		return DeleteNextComponent()

	if(href_list["delete_previous_component"])
		return DeletePreviousComponent()

	return TRUE
