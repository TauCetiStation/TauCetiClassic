/datum/gun_modular/component/data/start_fire_loc
	id_component = START_FIRE_LOC
	id_data = START_FIRE_LOC

/datum/gun_modular/component/data/start_fire_loc/New(obj/item/gun_modular/module/P, atom/start_loc = null)

	. = ..()

	if(!start_loc)
		value = get_turf(parent)
		return ..()

	value = start_loc

	return TRUE

/datum/gun_modular/component/data/start_fire_loc/IsValid()

	if(!..())
		return FALSE

	if(isnull(value))
		return FALSE

	if(!istype(value, /turf))
		return FALSE

	return TRUE

