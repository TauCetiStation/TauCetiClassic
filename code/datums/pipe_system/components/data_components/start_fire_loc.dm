/datum/pipe_system/component/data/start_fire_loc
	id_component = START_FIRE_LOC
	id_data = START_FIRE_LOC

/datum/pipe_system/component/data/start_fire_loc/New(datum/P, atom/start_loc = null)

	. = ..()

	if(!start_loc)
		value = get_turf(parent)
		return ..()

	value = start_loc

	return TRUE

/datum/pipe_system/component/data/start_fire_loc/IsValid()

	if(!..())
		return FALSE

	if(isnull(value))
		return FALSE

	if(!istype(value, /turf))
		return FALSE

	return TRUE

