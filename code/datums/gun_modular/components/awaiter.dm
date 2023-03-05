/datum/gun_modular/component/awaiter
	id_component = "awaiter"
	var/datum/gun_modular/component/checker = null
	var/datum/gun_modular/component/waiting_component = null
	var/datum/gun_modular/component/timeout_component = null
	var/list/signal_checker_wait = list(COMSIG_GUN_CHECK_SUCCESS)

/datum/gun_modular/component/awaiter/New(obj/item/gun_modular/module/P, datum/gun_modular/component/waiting_component, datum/gun_modular/component/checker, list/signal_checker_wait, datum/gun_modular/component/timeout_component = null)
	. = ..()

	src.waiting_component = waiting_component
	src.timeout_component = timeout_component
	src.checker = checker
	src.signal_checker_wait = signal_checker_wait

/datum/gun_modular/component/awaiter/RunTimeAction(datum/process_fire/process)

	RegisterSignal(process, COMSIG_GUN_COMPONENT_ACTION, CALLBACK(src, .proc/InvokeCheckerComponent, process))

	RegisterSignal(process, COMSIG_GUN_COMPONENT_ACTION_LAST, CALLBACK(src, .proc/InvokeTimeoutComponent, process))

	return ..()

/datum/gun_modular/component/awaiter/CopyComponentGun()

	var/datum/gun_modular/component/awaiter/new_component = ..()

	if(checker)
		new_component.checker = checker.CopyComponentGun()

	if(waiting_component)
		new_component.waiting_component = waiting_component.CopyComponentGun()

	if(timeout_component)
		new_component.timeout_component = timeout_component.CopyComponentGun()

	new_component.signal_checker_wait = signal_checker_wait

	return new_component


/datum/gun_modular/component/awaiter/proc/InvokeWaitingComponent(datum/process_fire/process)

	UnregisterSignalsAll(process)

	if(!waiting_component)
		return FALSE

	InsertComponent(process, waiting_component)

/datum/gun_modular/component/awaiter/proc/InvokeCheckerComponent(datum/process_fire/process)

	if(!src.checker)
		return FALSE

	RunIncludeComponentsChecker(process, src.checker)

/datum/gun_modular/component/awaiter/proc/RunIncludeComponentsChecker(datum/process_fire/process, datum/gun_modular/component/include)

	var/datum/gun_modular/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	process.activate += 1

	if(cache_data)
		var/mob/user = cache_data.GetData()
		to_chat(user, "<span>([process.activate])([src.id_component])[include.id_component]</span>")

	RegisterSignal(include, signal_checker_wait, CALLBACK(src, .proc/InvokeWaitingComponent, process))

	include.RunTimeAction(process)

	UnregisterSignal(include, signal_checker_wait)

	if(include.next_component)
		RunIncludeComponentsChecker(process, include.next_component)

/datum/gun_modular/component/awaiter/proc/InvokeTimeoutComponent(datum/process_fire/process)

	UnregisterSignalsAll(process)

	if(!timeout_component)
		return FALSE

	InsertComponent(process, timeout_component)

/datum/gun_modular/component/awaiter/proc/UnregisterSignalsAll(datum/process_fire/process)

	UnregisterSignal(process, list(COMSIG_GUN_COMPONENT_ACTION_LAST, COMSIG_GUN_COMPONENT_ACTION))

/datum/gun_modular/component/awaiter/proc/InsertComponent(datum/process_fire/process, datum/gun_modular/component/insert_component)

	var/datum/gun_modular/component/active_component = process.GetActiveComponent()
	active_component.ChangeNextComponent(insert_component.CopyComponentGun())
