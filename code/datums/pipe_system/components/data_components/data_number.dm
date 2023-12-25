/datum/pipe_system/component/data/number

/datum/pipe_system/component/data/number/CheckValidData(value_data)

	if(!isnum(value_data))
		return FALSE

	return TRUE
