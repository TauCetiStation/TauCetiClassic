/datum/pipe_system/component/data/gun_user
	id_data = USER_FIRE
	id_component = USER_FIRE

/datum/pipe_system/component/data/gun_user/New(datum/P, mob/user = null)

	if(!user)
		return ..()

	value = user
	. = ..()

/datum/pipe_system/component/data/gun_user/IsValid()

	if(!..())
		return FALSE

	if(isnull(value))
		return FALSE

	if(!istype(value, /mob))
		return FALSE

	return TRUE
