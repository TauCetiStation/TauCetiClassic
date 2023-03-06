/datum/pipe_system/component/check/ammo_returned
	id_component = "ammo_returned"

/datum/pipe_system/component/check/ammo_returned/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ammo_return/cache_data = process.GetCacheData(AMMO_RETURN)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
