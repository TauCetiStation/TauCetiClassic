/datum/pipe_system/component/proc_component/inject_after_next_component
	id_component = PIPE_SYSTEM_PROC_INJECT_AFTER_NEXT_COMPONENT
	description = "Внедряет компоненту после следующей компоненты"
	var/datum/pipe_system/component/inject_component

/datum/pipe_system/component/proc_component/inject_after_next_component/RunTimeAction(datum/pipe_system/process/process)

	if(next_component && inject_component)
		next_component.InsertNextComponent(inject_component)

	return ..()

/datum/pipe_system/component/proc_component/inject_after_next_component/CopyComponent()
	var/datum/pipe_system/component/proc_component/inject_after_next_component/new_component = ..()

	if(inject_component)
		new_component.inject_component = inject_component.CopyComponent()
		new_component.inject_component.previous_component = new_component

	return new_component

/datum/pipe_system/component/proc_component/inject_after_next_component/proc/SetInjectComponent(datum/pipe_system/component/C)

	inject_component = C

	if(inject_component)
		inject_component.previous_component = src

	return TRUE

/datum/pipe_system/component/proc_component/inject_after_next_component/GetApiObject(loop_safety)
	var/list/data = ..(loop_safety)

	data["inject_component"] = null
	if(inject_component && !loop_safety)
		data["inject_component"] = inject_component.GetApiObject()

	return data

/datum/pipe_system/component/proc_component/inject_after_next_component/ApiChange(action, list/params, vector)

	if(!PingFromRef(params["link_component"]))
		var/result = FALSE
		if(inject_component && vector != PIPE_SYSTEM_BACK)
			result = inject_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

	return ..(action, params, vector)

/datum/pipe_system/component/proc_component/inject_after_next_component/ApiChangeRuntime(action, list/params, vector = "")

	if(action == "set_inject_component" && params["target_component"])
		return SetInjectComponent(params["target_component"])

	return ..()

/datum/pipe_system/component/proc_component/inject_after_next_component/AfterDeleteChildComponent(datum/pipe_system/component/C)
	if(..())
		return TRUE

	if(ref(inject_component) == ref(C))
		return SetInjectComponent(C.next_component)

	return FALSE
