/datum/pipe_system/component/proc_gun/ammo_box_return_round
	id_component = "ammo_box_return_round"

/datum/pipe_system/component/proc_gun/ammo_box_return_round/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_ammo_box/ammo_box_data = process.GetCacheData(AMMO_BOX)
	var/datum/pipe_system/component/data/ammo_return/ammo_return_data = process.GetCacheData(AMMO_RETURN)

	if(!ammo_box_data || !ammo_return_data)
		return ..()

	if(!ammo_box_data.IsValid() || !ammo_return_data.IsValid())
		return ..()

	var/obj/item/ammo_box/ammo_box = ammo_box_data.value
	var/obj/item/ammo_casing/ammo = ammo_return_data.value

	ammo_box.stored_ammo.Insert(1, ammo)

	return ..()

