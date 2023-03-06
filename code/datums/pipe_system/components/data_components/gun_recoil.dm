/datum/pipe_system/component/data/gun_recoil
	id_component = RECOIL
	id_data = RECOIL

/datum/pipe_system/component/data/gun_recoil/New(datum/P, recoil = 0)

	if(!recoil)
		return ..()

	value = recoil
	. = ..()


/datum/pipe_system/component/data/gun_recoil/ChangeData(datum/pipe_system/component/data/data)

	value += data.GetData()

	return TRUE
