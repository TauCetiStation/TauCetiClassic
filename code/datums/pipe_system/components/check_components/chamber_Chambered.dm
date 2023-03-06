/datum/pipe_system/component/check/chamber_Chambered
	id_component = "chamber_Chambered"

/datum/pipe_system/component/check/chamber_Chambered/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/chamber_ammoCase/cache_data = process.GetCacheData(AMMO_FIRE)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
