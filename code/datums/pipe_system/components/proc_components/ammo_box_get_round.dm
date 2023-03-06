/datum/pipe_system/component/proc_gun/ammo_box_get_round
	id_component = "ammo_box_get_round"

/datum/pipe_system/component/proc_gun/ammo_box_get_round/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_ammo_box/ammo_box_data = process.GetCacheData(AMMO_BOX)

	if(!ammo_box_data)
		return ..()

	if(!ammo_box_data.IsValid())
		return ..()

	var/obj/item/ammo_box/ammo_box = ammo_box_data.value

	var/datum/pipe_system/component/data/ammo_return/ammo_return = new(src, ammo_box.get_round())
	ChangeNextComponent(ammo_return)

	return ..()

