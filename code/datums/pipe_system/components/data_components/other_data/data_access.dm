/datum/pipe_system/component/data/access
	id_data = ACCESS_DATA
	description = "(ACCESS_DATA) Информация о доступе"

/datum/pipe_system/component/data/access/IsValid()

	LAZYINITLIST(value)

	return ..()
