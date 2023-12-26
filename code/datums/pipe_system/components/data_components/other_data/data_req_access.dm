/datum/pipe_system/component/data/req_access
	id_data = REQ_ACCESS_DATA
	description = "(REQ_ACCESS_DATA) Информация о необходимом доступе"

/datum/pipe_system/component/data/req_access/IsValid()

	LAZYINITLIST(value)

	return ..()
