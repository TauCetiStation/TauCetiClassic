/datum/pipe_system/component/data
	id_component = "DATA"
	var/value
	var/id_data = "DEFAULT"

/datum/pipe_system/component/data/New(datum/P, value_data = null)

	value = value_data
	. = ..()

/datum/pipe_system/component/data/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/cache_data = process.GetCacheData(id_data)

	if(!cache_data)
		process.AddCacheData(src)
		return ..()

	cache_data.ChangeData(src)
	return ..()

/datum/pipe_system/component/data/CopyComponent()

	var/datum/pipe_system/component/data/new_component = ..()

	new_component.value = value
	new_component.id_data = id_data

	return new_component

/datum/pipe_system/component/data/ApiChangeRuntime(action, list/params, vector = "")

	if(action == "set_data")
		return SetData(params["data_change"])

	// if(href_list["get_data"])
	// 	return GetData()

	// if(href_list["is_valid"])
	// 	return IsValid()

	return ..()

/datum/pipe_system/component/data/GetApiObject(loop_safety)
	var/list/data = ..()

	data["id_data"] = id_data
	data["data"] = GetData()
	data["is_valid"] = IsValid()

	return data

/datum/pipe_system/component/data/proc/ChangeData(datum/pipe_system/component/data/data)

	value = data.value

	return TRUE

/datum/pipe_system/component/data/proc/GetData()

	if(isnull(value))
		return FALSE

	return value

/datum/pipe_system/component/data/proc/IsValid()

	if(isnull(value))
		return FALSE

	return TRUE

/datum/pipe_system/component/data/proc/SetData(value_data)

	if(!CheckValidData(value_data))
		return FALSE

	value = value_data

	return TRUE

/datum/pipe_system/component/data/proc/CheckValidData(value_data)

	return FALSE
