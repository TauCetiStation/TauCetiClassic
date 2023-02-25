/datum/gun_modular/component/check/user_isLiving
	id_component = "user_isLiving"

/datum/gun_modular/component/check/user_isLiving/Action(datum/process_fire/process)

	var/mob/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		FailCheck(process)
		return ..()

	if(!istype(user))
		FailCheck(process)
		return ..()

	if(!isliving(user))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
