/datum/pipe_system/component/proc_component/for_cycle
	var/datum/pipe_system/component/cycle_component


/datum/pipe_system/component/proc_component/for_cycle/New(datum/P, datum/pipe_system/component/cycle_component)

	src.cycle_component = cycle_component

	return ..()

/datum/pipe_system/component/proc_component/for_cycle/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/number/for_cycle_count/for_cycle_count_data = process.GetCacheData(FOR_CYCLE_COUNT_DATA)
	var/datum/pipe_system/component/data/number/for_cycle_initial/for_cycle_initial_data = process.GetCacheData(FOR_CYCLE_INITIAL_DATA)

	if(!for_cycle_count_data.IsValid() || !for_cycle_initial_data.IsValid() || !cycle_component)
		return ..()

	var/initial_cycle = for_cycle_initial_data.value
	var/count_cycle = for_cycle_count_data.value

	for(var/initial in range(initial_cycle, count_cycle))
		InsertNextComponent(cycle_component.CopyComponent())

	return ..()

/datum/pipe_system/component/proc_component/for_cycle/ApiChangeRuntime(action, list/params, vector = "")

	if(action == "set_cycle_component" && params["target_component"])
		return SetCycleComponent(params["target_component"])

	return ..()

/datum/pipe_system/component/proc_component/for_cycle/proc/SetCycleComponent(datum/pipe_system/component/cycle_component)

	src.cycle_component = cycle_component

	if(src.cycle_component)
		src.cycle_component.previous_component = src

	return TRUE
