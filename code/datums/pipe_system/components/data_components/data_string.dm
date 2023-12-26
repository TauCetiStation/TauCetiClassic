/datum/pipe_system/component/data/string
	id_component = PIPE_SYSTEM_DATA_STRING
	description = "(PIPE_SYSTEM_DATA_STRING) Строковая информация"

/datum/pipe_system/component/data/string/CheckValidData(value_data)

	if(!istext(value_data))
		return FALSE

	return TRUE
