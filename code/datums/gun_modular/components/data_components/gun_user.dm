/datum/gun_modular/component/data/gun_user
	id_data = USER_FIRE
	id_component = USER_FIRE

/datum/gun_modular/component/data/gun_user/New(obj/item/gun_modular/module/P, mob/user = null)

	if(!user)
		return ..()

	value = user
	. = ..()

/datum/gun_modular/component/data/gun_user/IsValid()

	if(!..())
		return FALSE

	if(isnull(value))
		return FALSE

	if(!istype(value, /mob))
		return FALSE

	return TRUE
