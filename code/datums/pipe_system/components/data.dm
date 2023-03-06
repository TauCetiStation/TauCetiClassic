/datum/pipe_system/component/data
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

/datum/pipe_system/component/data/CopyComponentGun()

	var/datum/pipe_system/component/data/new_component = ..()

	new_component.value = value
	new_component.id_data = id_data

	return new_component

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
