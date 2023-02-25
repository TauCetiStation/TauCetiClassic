/datum/gun_modular/component/data/gun_recoil
	id_component = RECOIL
	id_data = RECOIL

/datum/gun_modular/component/data/gun_recoil/New(obj/item/gun_modular/module/P, recoil = 0)

	if(!recoil)
		return ..()

	value = recoil
	. = ..()


/datum/gun_modular/component/data/gun_recoil/ChangeData(new_value)

	value += new_value

	return TRUE
