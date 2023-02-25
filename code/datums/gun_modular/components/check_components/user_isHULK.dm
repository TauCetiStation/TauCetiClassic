/datum/gun_modular/component/check/user_isHULK/Action(datum/process_fire/process)

	var/mob/living/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		FailCheck(process)

	if(!istype(user))
		FailCheck(process)

	if (HULK !in user.mutations)
		FailCheck(process)

	SuccessCheck(process)

	return ..()
