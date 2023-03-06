/datum/pipe_system/component/check/user_isHuman
	id_component = "user_isHuman"

/datum/pipe_system/component/check/user_isHuman/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		FailCheck(process)
		return ..()

	if(!cache_data.IsValid())
		FailCheck(process)
		return ..()

	var/mob/living/user = cache_data.GetData()

	if(!istype(user))
		FailCheck(process)
		return ..()

	if(!ishuman(user))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
