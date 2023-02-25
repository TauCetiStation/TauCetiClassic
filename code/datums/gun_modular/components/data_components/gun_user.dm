/datum/gun_modular/component/data/gun_user
	id_data = USER_FIRE

/datum/gun_modular/component/data/gun_user/New(obj/item/gun_modular/module/P, mob/user = null)

	if(!user)
		return ..()

	value = user
	. = ..()
