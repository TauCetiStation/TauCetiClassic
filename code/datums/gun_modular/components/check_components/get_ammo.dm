/datum/gun_modular/component/check/get_ammo
	id_component = "get_ammo"

/datum/gun_modular/component/check/get_ammo/RunTimeAction(datum/process_fire/process)

	var/datum/gun_modular/component/data/gun_get_ammo/cache_data = process.GetCacheData(GET_AMMO)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	if(!cache_data.value)
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
