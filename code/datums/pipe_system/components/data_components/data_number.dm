/datum/pipe_system/component/data/number
	id_component = PIPE_SYSTEM_DATA_NUMBER

/datum/pipe_system/component/data/number/CheckValidData(value_data)

	if(!isnum(value_data))
		return FALSE

	return TRUE
