/datum/pipe_system/component/check/user_isLiving
	id_component = "user_isLiving"

/datum/pipe_system/component/check/user_isLiving/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	var/mob/user = cache_data.GetData()

	if(!istype(user))
		FailCheck(process)
		return ..()

	if(!isliving(user))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
