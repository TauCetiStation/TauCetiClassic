/datum/gun_modular/component/check/fire_result
	id_component = "fire_result"

/datum/gun_modular/component/check/fire_result/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/fire_result/cache_data = process.GetCacheData(FIRE_RESULT)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
