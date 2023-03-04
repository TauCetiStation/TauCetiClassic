/datum/gun_modular/component/awaiter
	id_component = "awaiter"
	var/datum/gun_modular/component/checker = null
	var/datum/gun_modular/component/waiting_component = null
	var/datum/gun_modular/component/timeout_component = null
	var/list/signal_checker_wait = list(COMSIG_GUN_CHECK_SUCCESS)
	var/invoke_waiting_component = FALSE

/datum/gun_modular/component/awaiter/New(obj/item/gun_modular/module/P, datum/gun_modular/component/waiting_component, datum/gun_modular/component/checker, list/signal_checker_wait, datum/gun_modular/component/timeout_component = null)
	. = ..()

	src.waiting_component = waiting_component
	src.timeout_component = timeout_component
	src.checker = checker
	src.signal_checker_wait = signal_checker_wait

/datum/gun_modular/component/awaiter/Action(datum/process_fire/process)

	RegisterSignal(src.checker, signal_checker_wait, CALLBACK(src, .proc/InvokeWaitingComponent, process))

	RegisterSignal(process, COMSIG_GUN_COMPONENT_ACTION, CALLBACK(src, .proc/InvokeCheckerComponent, process))

	RegisterSignal(process, COMSIG_GUN_COMPONENT_ACTION_LAST, CALLBACK(src, .proc/InvokeTimeoutComponent, process))

	return ..()

/datum/gun_modular/component/awaiter/CopyComponentGun()
	var/datum/gun_modular/component/awaiter/new_component = ..()

	new_component.checker = checker.CopyComponentGun()
	new_component.waiting_component = waiting_component.CopyComponentGun()
	new_component.timeout_component = timeout_component.CopyComponentGun()
	new_component.signal_checker_wait = signal_checker_wait
	new_component.invoke_waiting_component = invoke_waiting_component

	return new_component


/datum/gun_modular/component/awaiter/proc/InvokeWaitingComponent(datum/process_fire/process)

	UnregisterSignalsAll(process)
	var/datum/gun_modular/component/C = process.GetActiveComponent()
	C.ChangeNextComponent(waiting_component.CopyComponentGun())
	invoke_waiting_component = TRUE

/datum/gun_modular/component/awaiter/proc/InvokeCheckerComponent(datum/process_fire/process)

	if(invoke_waiting_component)
		return FALSE

	invoke_waiting_component = TRUE
	src.checker.Action(process)
	invoke_waiting_component = FALSE

/datum/gun_modular/component/awaiter/proc/InvokeTimeoutComponent(datum/process_fire/process)

	UnregisterSignalsAll(process)
	src.timeout_component.Action(process)

/datum/gun_modular/component/awaiter/proc/UnregisterSignalsAll(datum/process_fire/process)

	UnregisterSignal(src.checker, signal_checker_wait)
	UnregisterSignal(process, list(COMSIG_GUN_COMPONENT_ACTION_LAST, COMSIG_GUN_COMPONENT_ACTION))
