/datum/gun_modular/component/check/user_isHULK
	id_component = "user_isHULK"

/datum/gun_modular/component/check/user_isHULK/Action(datum/process_fire/process)

	var/mob/living/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		FailCheck(process)
		return ..()

	if(!istype(user))
		FailCheck(process)
		return ..()

	if (HULK in user.mutations)
		SuccessCheck(process)
		return ..()

	FailCheck(process)
	return ..()
