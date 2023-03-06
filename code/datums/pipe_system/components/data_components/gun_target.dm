/datum/pipe_system/component/data/gun_target
	id_component = TARGET_FIRE
	id_data = TARGET_FIRE

/datum/pipe_system/component/data/gun_target/New(datum/P, atom/target = null)

	if(!target)
		return ..()

	value = target
	. = ..()
