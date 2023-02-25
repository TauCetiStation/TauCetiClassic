/datum/gun_modular/component/data/gun_target
	id_component = TARGET_FIRE
	id_data = TARGET_FIRE

/datum/gun_modular/component/data/gun_target/New(obj/item/gun_modular/module/P, atom/target = null)

	if(!target)
		return ..()

	value = target
	. = ..()
