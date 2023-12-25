/datum/pipe_system/component
	var/datum/parent
	var/id_component = "DEFAULT"
	var/datum/pipe_system/component/next_component
	var/datum/pipe_system/component/previous_component

/datum/pipe_system/component/New(datum/P)
	parent = P

/datum/pipe_system/component/Destroy(force, ...)
	return ..()

/datum/pipe_system/component/proc/InsertNextComponent(datum/pipe_system/component/C)

	C.previous_component = src

	if(!next_component)
		next_component = C
		return TRUE

	var/datum/pipe_system/component/old_next_component = next_component

	next_component = C
	old_next_component.previous_component = C.GetLastComponent()
	old_next_component.previous_component.next_component = old_next_component
	return TRUE

/datum/pipe_system/component/proc/DeleteNextComponent()

	if(next_component)
		return next_component.SelfDelete()

/datum/pipe_system/component/proc/DeletePreviousComponent()

	if(previous_component)
		return previous_component.SelfDelete()

/datum/pipe_system/component/proc/SelfDelete()

	if(previous_component)
		previous_component.AfterDeleteChildComponent(src)

	if(next_component)
		next_component.AfterDeleteChildComponent(src)

	SEND_SIGNAL(parent, COMSIG_PIPE_COMPONENT_DELETE, src)

	next_component = null
	previous_component = null
	parent = null

	qdel(src)

	return TRUE

/datum/pipe_system/component/proc/AfterDeleteChildComponent(datum/pipe_system/component/C)

	if(ref(next_component) == ref(C))
		return SetNextComponent(C.next_component)

	if(ref(previous_component) == ref(C))
		return SetPreviousComponent(C.previous_component)

	return FALSE

/datum/pipe_system/component/proc/SetNextComponent(datum/pipe_system/component/C)

	next_component = C

	if(C)
		C.previous_component = src

	return TRUE

/datum/pipe_system/component/proc/SetPreviousComponent(datum/pipe_system/component/C)

	previous_component = C

	if(C)
		C.next_component = src

	return TRUE

/datum/pipe_system/component/proc/AddLastComponent(datum/pipe_system/component/C)

	if(isnull(C))
		return FALSE

	if(!next_component)
		next_component = C
		C.previous_component = src
		return TRUE

	return next_component.AddLastComponent(C)

/datum/pipe_system/component/proc/GetLastComponent()

	if(!next_component)
		return src

	return next_component.GetLastComponent()

/datum/pipe_system/component/proc/GetFirstComponent()

	if(!previous_component)
		return src

	return previous_component.GetFirstComponent()

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

/datum/pipe_system/component/proc/CopyComponent()

	var/datum/pipe_system/component/new_component = new type(parent)

	new_component.id_component = id_component

	if(next_component)
		new_component.next_component = next_component.CopyComponent()
		new_component.next_component.previous_component = new_component

	return new_component

/datum/pipe_system/component/proc/ApiChange(action, list/params, vector = "")

	if(!PingFromRef(params["link_component"]))
		var/result = FALSE
		if(next_component && vector != PIPE_SYSTEM_BACK)
			result = next_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

		if(previous_component && vector != PIPE_SYSTEM_FORWARD)
			result = previous_component.ApiChange(action, params, PIPE_SYSTEM_BACK)
			if(result != FALSE)
				return result

		return FALSE

	if(action == "select_component")
		return src

	// if(action == "add_last_component")
	// 	return AddLastComponent(href_list["add_last_component"])

	if(action == "self_delete")
		return SelfDelete()

	if(action == "insert_next_component" && params["target_component"])
		return InsertNextComponent(params["target_component"])

	if(action == "delete_next_component")
		return DeleteNextComponent()

	if(action == "delete_previous_component")
		return DeletePreviousComponent()

	return TRUE

/datum/pipe_system/component/proc/PingFromRef(link_component)
	if(link_component != ref(src))
		return FALSE
	return TRUE

/datum/pipe_system/component/proc/GetApiObject(loop_safety = FALSE)

	var/list/data = list()

	if(next_component && !loop_safety)
		data["next_component"] = next_component.GetApiObject()

	if(previous_component)
		data["previous_component"] = previous_component.GetApiObject(TRUE)

	data["id_component"] = id_component

	data["link_component"] = ref(src)

	return data
