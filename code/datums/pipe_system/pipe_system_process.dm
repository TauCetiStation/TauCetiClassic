/datum/pipe_system/process
	var/datum/pipe_system/component/first_component
	var/list/datum/pipe_system/component/data/cache_data = list()
	var/datum/pipe_system/component/active_component = null
	var/list/datum/pipe_system/component/awaiter/active_awaiters = list()
	var/activate = 0
	var/activated = FALSE
	var/interrupt = FALSE

/datum/pipe_system/process/proc/PrepareActiveAwaiters()

	LAZYINITLIST(active_awaiters)

	return TRUE

/datum/pipe_system/process/proc/AddActiveAwaiter(datum/pipe_system/component/awaiter/active)

	PrepareActiveAwaiters()

	LAZYADD(active_awaiters, active)

	return TRUE

/datum/pipe_system/process/proc/GetActiveAwaiters()

	PrepareActiveAwaiters()

	return active_awaiters

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

/datum/pipe_system/process/proc/AddComponentPipe(datum/pipe_system/component/C)

	var/datum/pipe_system/component/adding_component = C.CopyComponent()

	if(!istype(adding_component))
		return FALSE

	if(!first_component)
		first_component = adding_component
		return TRUE

	first_component.AddLastComponent(adding_component)

	return TRUE


/datum/pipe_system/process/proc/RunComponents()

	activated = TRUE
	first_component.Action(src)
	activated = FALSE

	return TRUE

/datum/pipe_system/process/proc/SetActiveComponent(datum/pipe_system/component/C)

	active_component = C

/datum/pipe_system/process/proc/GetActiveComponent()

	return active_component

/datum/pipe_system/process/proc/GetApiObject()
	var/list/data = list()

	data["first_component"] = null
	if(first_component)
		data["first_component"] = first_component.GetApiObject()

	data["active_component"] = null
	if(active_component)
		data["active_component"] = active_component.GetApiObject()
