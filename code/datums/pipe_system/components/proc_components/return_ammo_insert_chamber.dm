/datum/pipe_system/component/proc_gun/return_ammo_insert_chamber
	id_component = "return_ammo_insert_chamber"

/datum/pipe_system/component/proc_gun/return_ammo_insert_chamber/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ammo_return/cache_data = process.GetCacheData(AMMO_RETURN)

	if(!cache_data)
		return ..()

	if(!cache_data.IsValid())
		return ..()

	var/obj/item/ammo_casing/ammo = cache_data.value

	var/datum/pipe_system/component/data/chamber_ammoCase/chambered = new(src, ammo)
	ChangeNextComponent(chambered)

	cache_data.value = null

	return ..()
