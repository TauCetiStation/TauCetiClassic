/datum/pipe_system/component/awaiter
	id_component = "awaiter"
	var/datum/pipe_system/component/checker = null
	var/datum/pipe_system/component/waiting_component = null
	var/datum/pipe_system/component/timeout_component = null
	var/list/signal_checker_wait = list(COMSIG_PIPE_CHECK_SUCCESS)

/datum/pipe_system/component/awaiter/New(datum/P, datum/pipe_system/component/waiting_component, datum/pipe_system/component/checker, list/signal_checker_wait, datum/pipe_system/component/timeout_component = null)
	. = ..()

	if(waiting_component)
		waiting_component.previous_component = src
		src.waiting_component = waiting_component

	if(timeout_component)
		timeout_component.previous_component = src
		src.timeout_component = timeout_component

	if(checker)
		checker.previous_component = src
		src.checker = checker

	src.signal_checker_wait = signal_checker_wait

/datum/pipe_system/component/awaiter/RunTimeAction(datum/pipe_system/process/process)

	RegisterSignal(process, COMSIG_PIPE_COMPONENT_ACTION, CALLBACK(src, .proc/InvokeCheckerComponent, process))

	RegisterSignal(process, COMSIG_PIPE_COMPONENT_ACTION_LAST, CALLBACK(src, .proc/InvokeTimeoutComponent, process))

	return ..()

/datum/pipe_system/component/awaiter/CopyComponent()

	var/datum/pipe_system/component/awaiter/new_component = ..()

	if(checker)
		new_component.checker = checker.CopyComponent()
		new_component.checker.previous_component = new_component

	if(waiting_component)
		new_component.waiting_component = waiting_component.CopyComponent()
		new_component.waiting_component.previous_component = new_component

	if(timeout_component)
		new_component.timeout_component = timeout_component.CopyComponent()
		new_component.timeout_component.previous_component = new_component

	new_component.signal_checker_wait = signal_checker_wait

	return new_component

/datum/pipe_system/component/awaiter/AfterDeleteChildComponent(datum/pipe_system/component/C)
	if(..())
		return TRUE

	if(ref(checker) == ref(C))
		return ChangeCheckerComponent(C.next_component)

	if(ref(waiting_component) == ref(C))
		return ChangeWaitingComponent(C.next_component)

	if(ref(timeout_component) == ref(C))
		return ChangeTimeoutComponent(C.next_component)

	return FALSE

/datum/pipe_system/component/awaiter/ApiChange(action, list/params, vector = "")

	vector = ""
	if(!PingFromRef(params["link_component"]))
		var/result = FALSE
		if(checker && vector != PIPE_SYSTEM_BACK)
			result = checker.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

		if(waiting_component && vector != PIPE_SYSTEM_BACK)
			result = waiting_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

		if(timeout_component && vector != PIPE_SYSTEM_BACK)
			result = timeout_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

	// if(href_list["change_waiting_component"])
	// 	return ChangeWaitingComponent(href_list["change_waiting_component"])

	// if(href_list["change_timeout_component"])
	// 	return ChangeTimeoutComponent(href_list["change_timeout_component"])

	// if(href_list["change_checker_component"])
	// 	return ChangeCheckerComponent(href_list["change_checker_component"])

	// if(href_list["change_signals_wait"])
	// 	return ChangeSignal(href_list["change_signals_wait"])

	return ..(action, params, "")

/datum/pipe_system/component/awaiter/GetApiObject(loop_safety = FALSE)
	var/list/data = ..(loop_safety)

	if(checker && !loop_safety)
		data["checker_component"] = checker.GetApiObject()

	if(waiting_component && !loop_safety)
		data["waiting_component"] = waiting_component.GetApiObject()

	if(timeout_component && !loop_safety)
		data["timeout_component"] = timeout_component.GetApiObject()

	if(signal_checker_wait)
		data["signals_list"] = signal_checker_wait

	return data

/datum/pipe_system/component/awaiter/proc/ChangeWaitingComponent(datum/pipe_system/component/C)
	waiting_component = C

	if(waiting_component)
		waiting_component.previous_component = src

	return TRUE

/datum/pipe_system/component/awaiter/proc/ChangeTimeoutComponent(datum/pipe_system/component/C)
	timeout_component = C

	if(timeout_component)
		timeout_component.previous_component = src

	return TRUE

/datum/pipe_system/component/awaiter/proc/ChangeCheckerComponent(datum/pipe_system/component/C)
	checker = C

	if(checker)
		checker.previous_component = src

	return TRUE

/datum/pipe_system/component/awaiter/proc/ChangeSignal(signals)
	signal_checker_wait = signals

/datum/pipe_system/component/awaiter/proc/InvokeWaitingComponent(datum/pipe_system/process/process)

	UnregisterSignalsAll(process)

	if(!waiting_component)
		return FALSE

	InsertComponent(process, waiting_component)

/datum/pipe_system/component/awaiter/proc/InvokeCheckerComponent(datum/pipe_system/process/process)

	if(!checker)
		return FALSE

	RunIncludeComponentsChecker(process, checker)

/datum/pipe_system/component/awaiter/proc/RunIncludeComponentsChecker(datum/pipe_system/process/process, datum/pipe_system/component/include)

	process.activate += 1

	RegisterSignal(include, signal_checker_wait, CALLBACK(src, .proc/InvokeWaitingComponent, process))

	include.RunTimeAction(process)

	UnregisterSignal(include, signal_checker_wait)

	if(include.next_component)
		RunIncludeComponentsChecker(process, include.next_component)

/datum/pipe_system/component/awaiter/proc/InvokeTimeoutComponent(datum/pipe_system/process/process)

	UnregisterSignalsAll(process)

	if(!timeout_component)
		return FALSE

	InsertComponent(process, timeout_component)

/datum/pipe_system/component/awaiter/proc/UnregisterSignalsAll(datum/pipe_system/process/process)

	UnregisterSignal(process, list(COMSIG_PIPE_COMPONENT_ACTION_LAST, COMSIG_PIPE_COMPONENT_ACTION))

/datum/pipe_system/component/awaiter/proc/InsertComponent(datum/pipe_system/process/process, datum/pipe_system/component/insert_component)

	var/datum/pipe_system/component/active_component = process.GetActiveComponent()
	active_component.InsertNextComponent(insert_component.CopyComponent())
