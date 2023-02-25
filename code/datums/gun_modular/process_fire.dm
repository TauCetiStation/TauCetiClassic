/datum/process_fire
	var/datum/gun_modular/component/first_component
	var/list/datum/gun_modular/component/data/cache_data = list()

/datum/process_fire/proc/PrepareCacheData()

	LAZYINITLIST(cache_data)

	return TRUE

/datum/process_fire/proc/GetCacheData(id_data)

	PrepareCacheData()

	if(!cache_data[id_data])
		return FALSE

	return cache_data[id_data]

/datum/process_fire/proc/AddCacheData(datum/gun_modular/component/data/cache)

	var/datum/gun_modular/component/data/cache_data_add = cache
	var/cache_data_id = cache_data_add.id_data

	PrepareCacheData()

	cache_data[cache_data_id] = cache_data_add

	return TRUE

/datum/process_fire/proc/AddComponentGun(datum/gun_modular/component/C)

	var/datum/gun_modular/component/adding_component = C.CopyComponentGun()

	if(!istype(adding_component))
		return FALSE

	if(!first_component)
		first_component = adding_component
		return TRUE

	first_component.AddLastComponent(adding_component)

	return TRUE


/datum/process_fire/proc/RunComponents()

	first_component.Action(src)

	return TRUE
