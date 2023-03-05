/datum/gun_modular/component/check/ammo_returned
	id_component = "ammo_returned"

/datum/gun_modular/component/check/ammo_returned/RunTimeAction(datum/process_fire/process)

	var/datum/gun_modular/component/data/ammo_return/cache_data = process.GetCacheData(AMMO_RETURN)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
