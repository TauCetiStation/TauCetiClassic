/datum/pipe_system/component/data/ref
	id_component = PIPE_SYSTEM_DATA_REF
	description = "(PIPE_SYSTEM_DATA_REF) Ссылочная информация, нельзя менять"

/datum/pipe_system/component/data/ref/CheckValidData(value_data)

	if(!isobj(value_data))
		return FALSE

	return TRUE
