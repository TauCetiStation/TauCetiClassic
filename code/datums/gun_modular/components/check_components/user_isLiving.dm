/datum/gun_modular/component/check/user_isLiving/Action(datum/process_fire/process)

	var/mob/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		FailCheck(process)

	if(!istype(user))
		FailCheck(process)

	if(!isliving(user))
		FailCheck(process)

	SuccessCheck(process)

	return ..()
