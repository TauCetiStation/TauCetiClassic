/datum/pipe_system/component/data/string

/datum/pipe_system/component/data/string/CheckValidData(value_data)

	if(!istext(value_data))
		return FALSE

	return TRUE
