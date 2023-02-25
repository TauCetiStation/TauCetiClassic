/datum/gun_modular/component/check/chamber_Chambered
	id_component = "chamber_Chambered"

/datum/gun_modular/component/check/chamber_Chambered/Action(datum/process_fire/process)

	var/obj/item/ammo_casing/chambered = process.GetCacheData(AMMO_FIRE)

	if(isnull(chambered))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
