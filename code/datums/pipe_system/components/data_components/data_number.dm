/datum/pipe_system/component/data/number
	id_component = PIPE_SYSTEM_DATA_NUMBER
	description = "(PIPE_SYSTEM_DATA_NUMBER) Числовая информация"
	var/max_value = 10
	var/min_value = 0

/datum/pipe_system/component/data/number/CheckValidData(value_data)

	if(!isnum(value_data))
		return FALSE

	if(value_data > max_value)
		return FALSE

	if(value_data < min_value)
		return FALSE

	return TRUE

/datum/pipe_system/component/data/number/GetApiObject(loop_safety)
	var/list/data = ..(loop_safety)

	data["max_value"] = max_value
	data["min_value"] = min_value

	return data

