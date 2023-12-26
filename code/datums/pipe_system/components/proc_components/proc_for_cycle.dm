/datum/pipe_system/component/proc_component/for_cycle
	id_component = PIPE_SYSTEM_PROC_FOR_CYCLE
	var/datum/pipe_system/component/cycle_component
	description = "(PIPE_SYSTEM_PROC_FOR_CYCLE) Реализация цикла FOR, использует FOR_CYCLE_COUNT_DATA и FOR_CYCLE_INITIAL_DATA для того чтобы внедрить в цепочку компоненту cycle_component определенное количество раз"

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

	for(var/i = initial_cycle, i < count_cycle, i++)
		InsertNextComponent(cycle_component.CopyComponent())

	return ..()

/datum/pipe_system/component/proc_component/for_cycle/CopyComponent()
	var/datum/pipe_system/component/proc_component/for_cycle/new_component = ..()

	if(cycle_component)
		new_component.cycle_component = cycle_component.CopyComponent()
		new_component.cycle_component.previous_component = new_component

	return new_component


/datum/pipe_system/component/proc_component/for_cycle/GetApiObject(loop_safety)
	var/list/data = ..(loop_safety)

	data["cycle_component"] = null
	if(cycle_component && !loop_safety)
		data["cycle_component"] = cycle_component.GetApiObject()

	return data

/datum/pipe_system/component/proc_component/for_cycle/ApiChange(action, list/params, vector)

	if(!PingFromRef(params["link_component"]))
		var/result = FALSE
		if(cycle_component && vector != PIPE_SYSTEM_BACK)
			result = cycle_component.ApiChange(action, params, PIPE_SYSTEM_FORWARD)
			if(result != FALSE)
				return result

	return ..(action, params, vector)

/datum/pipe_system/component/proc_component/for_cycle/ApiChangeRuntime(action, list/params, vector = "")

	if(action == "set_cycle_component" && params["target_component"])
		return SetCycleComponent(params["target_component"])

	return ..()

/datum/pipe_system/component/proc_component/for_cycle/proc/SetCycleComponent(datum/pipe_system/component/cycle_component)

	src.cycle_component = cycle_component

	if(src.cycle_component)
		src.cycle_component.previous_component = src

	return TRUE

/datum/pipe_system/component/proc_component/for_cycle/AfterDeleteChildComponent(datum/pipe_system/component/C)
	if(..())
		return TRUE

	if(ref(cycle_component) == ref(C))
		return SetCycleComponent(C.next_component)

	return FALSE
