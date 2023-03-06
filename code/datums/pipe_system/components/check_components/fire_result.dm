/datum/pipe_system/component/check/fire_result
	id_component = "fire_result_check"

/datum/pipe_system/component/check/fire_result/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/fire_result/cache_data = process.GetCacheData(FIRE_RESULT)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
