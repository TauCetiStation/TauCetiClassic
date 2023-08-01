/datum/pipe_system/process
	var/datum/pipe_system/component/first_component
	var/list/datum/pipe_system/component/data/cache_data = list()
	var/datum/pipe_system/component/active_component = null
	var/activate = 0

/datum/pipe_system/process/proc/PrepareCacheData()

	LAZYINITLIST(cache_data)

	return TRUE

/datum/pipe_system/process/proc/GetCacheData(id_data)

	PrepareCacheData()

	if(!cache_data[id_data])
		return FALSE

	var/datum/pipe_system/component/data/cache_data_get = cache_data[id_data]

	return cache_data_get

/datum/pipe_system/process/proc/AddCacheData(datum/pipe_system/component/data/cache)

	var/datum/pipe_system/component/data/cache_data_add = cache
	var/cache_data_id = cache_data_add.id_data

	PrepareCacheData()

	cache_data[cache_data_id] = cache_data_add

	return TRUE

/datum/pipe_system/process/proc/AddComponentGun(datum/pipe_system/component/C)

	var/datum/pipe_system/component/adding_component = C.CopyComponentGun()

	if(!istype(adding_component))
		return FALSE

	if(!first_component)
		first_component = adding_component
		return TRUE

	first_component.AddLastComponent(adding_component)

	return TRUE


/datum/pipe_system/process/proc/RunComponents()

	first_component.Action(src)

	return TRUE

/datum/pipe_system/process/proc/SetActiveComponent(datum/pipe_system/component/C)

	active_component = C

/datum/pipe_system/process/proc/GetActiveComponent()

	return active_component
