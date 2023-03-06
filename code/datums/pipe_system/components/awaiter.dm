/datum/pipe_system/component/awaiter
	id_component = "awaiter"
	var/datum/pipe_system/component/checker = null
	var/datum/pipe_system/component/waiting_component = null
	var/datum/pipe_system/component/timeout_component = null
	var/list/signal_checker_wait = list(COMSIG_GUN_CHECK_SUCCESS)

/datum/pipe_system/component/awaiter/New(datum/P, datum/pipe_system/component/waiting_component, datum/pipe_system/component/checker, list/signal_checker_wait, datum/pipe_system/component/timeout_component = null)
	. = ..()

	src.waiting_component = waiting_component
	src.timeout_component = timeout_component
	src.checker = checker
	src.signal_checker_wait = signal_checker_wait

/datum/pipe_system/component/awaiter/RunTimeAction(datum/pipe_system/process/process)

	RegisterSignal(process, COMSIG_GUN_COMPONENT_ACTION, CALLBACK(src, .proc/InvokeCheckerComponent, process))

	RegisterSignal(process, COMSIG_GUN_COMPONENT_ACTION_LAST, CALLBACK(src, .proc/InvokeTimeoutComponent, process))

	return ..()

/datum/pipe_system/component/awaiter/CopyComponentGun()

	var/datum/pipe_system/component/awaiter/new_component = ..()

	if(checker)
		new_component.checker = checker.CopyComponentGun()

	if(waiting_component)
		new_component.waiting_component = waiting_component.CopyComponentGun()

	if(timeout_component)
		new_component.timeout_component = timeout_component.CopyComponentGun()

	new_component.signal_checker_wait = signal_checker_wait

	return new_component


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

	var/datum/pipe_system/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	process.activate += 1

	if(cache_data)
		var/mob/user = cache_data.GetData()
		to_chat(user, "<span>([process.activate])([id_component])[include.id_component]</span>")

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

	UnregisterSignal(process, list(COMSIG_GUN_COMPONENT_ACTION_LAST, COMSIG_GUN_COMPONENT_ACTION))

/datum/pipe_system/component/awaiter/proc/InsertComponent(datum/pipe_system/process/process, datum/pipe_system/component/insert_component)

	var/datum/pipe_system/component/active_component = process.GetActiveComponent()
	active_component.ChangeNextComponent(insert_component.CopyComponentGun())
