/datum/pipe_system/component/proc_component/clear_active_awaiters
	description = "Удаляет все активные компоненты AWAITER"

/datum/pipe_system/component/proc_component/clear_active_awaiters/RunTimeAction(datum/pipe_system/process/process)

	var/list/datum/pipe_system/component/awaiter/active_awaiters = process.GetActiveAwaiters()

	for(var/datum/pipe_system/component/awaiter/active_awaiter in active_awaiters)
		active_awaiter.UnregisterSignalsAll(process)

	return ..()
