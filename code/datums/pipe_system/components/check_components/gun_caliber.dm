/datum/pipe_system/component/check/gun_caliber
	id_component = "gun_caliber"

/datum/pipe_system/component/check/gun_caliber/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ammo_return/ammo_return = process.GetCacheData(AMMO_RETURN)
	var/datum/pipe_system/component/data/gun_caliber_allow/caliber_data = process.GetCacheData(ALLOW_CALIBER)

	if(!ammo_return || !caliber_data)
		FailCheck(process)
		return ..()

	if(!ammo_return.IsValid() || !caliber_data.IsValid())
		FailCheck(process)
		return ..()

	var/obj/item/ammo_casing/ammo = ammo_return.GetData()
	var/caliber = caliber_data.value

	if(ammo.caliber != caliber)
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
