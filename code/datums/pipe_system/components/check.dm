/datum/pipe_system/component/check
	id_component = PIPE_SYSTEM_CHECKER
	var/datum/pipe_system/component/success_component = null
	var/datum/pipe_system/component/fail_component = null

/datum/pipe_system/component/check/New(datum/P, datum/pipe_system/component/success_component = null, datum/pipe_system/component/fail_component = null)
	. = ..()

	src.success_component = success_component

	src.fail_component = fail_component

/datum/pipe_system/component/check/CopyComponent()

	var/datum/pipe_system/component/check/new_component = ..()

	if(success_component)
		new_component.success_component = success_component.CopyComponent()

	if(fail_component)
		new_component.fail_component = fail_component.CopyComponent()

	return new_component

/datum/pipe_system/component/check/GetApiObject(loop_safety)
	var/list/data = ..(loop_safety)

	data["success_component"] = null
	if(success_component && !loop_safety)
		data["success_component"] = success_component.GetApiObject()

	data["fail_component"] = null
	if(fail_component && !loop_safety)
		data["fail_component"] = fail_component.GetApiObject()

	return data

/datum/pipe_system/component/check/ApiChange(action, list/params, vector)

	if(!PingFromRef(params["link_component"]))
		var/result = FALSE
		if(fail_component && vector != PIPE_SYSTEM_BACK)
			result = fail_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

		if(success_component && vector != PIPE_SYSTEM_BACK)
			result = success_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

	return ..(action, params, vector)

/datum/pipe_system/component/check/ApiChangeRuntime(action, list/params, vector = "")

	if(action == "change_fail_component" && params["target_component"])
		return ChangeFailComponent(params["target_component"])

	if(action == "change_success_component" && params["target_component"])
		return ChangeSuccessComponent(params["target_component"])

	return ..()

/datum/pipe_system/component/check/AfterDeleteChildComponent(datum/pipe_system/component/C)
	if(..())
		return TRUE

	if(ref(fail_component) == ref(C))
		return ChangeFailComponent(C.next_component)

	if(ref(success_component) == ref(C))
		return ChangeSuccessComponent(C.next_component)

	return FALSE

/datum/pipe_system/component/check/proc/ChangeFailComponent(datum/pipe_system/component/C)
	fail_component = C

	if(fail_component)
		fail_component.previous_component = src

/datum/pipe_system/component/check/proc/ChangeSuccessComponent(datum/pipe_system/component/C)

	success_component = C

	if(success_component)
		success_component.previous_component = src

/datum/pipe_system/component/check/proc/FailCheck(datum/pipe_system/process/process)

	SEND_SIGNAL(src, COMSIG_PIPE_CHECK_FAIL)

	if(!fail_component)
		return FALSE

	return InsertNextComponent(fail_component.CopyComponent())

/datum/pipe_system/component/check/proc/SuccessCheck(datum/pipe_system/process/process)

	SEND_SIGNAL(src, COMSIG_PIPE_CHECK_SUCCESS)

	if(!success_component)
		return FALSE

	return InsertNextComponent(success_component.CopyComponent())
