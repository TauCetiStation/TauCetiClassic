/datum/gun_modular/component/check/chamber_Chambered
	id_component = "chamber_Chambered"

/datum/gun_modular/component/check/chamber_Chambered/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/cache_data = process.GetCacheData(AMMO_FIRE)

	if(!cache_data)
		FailCheck(process)
		return ..()

	var/obj/item/ammo_casing/chambered = cache_data.GetData()

	if(isnull(chambered))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
