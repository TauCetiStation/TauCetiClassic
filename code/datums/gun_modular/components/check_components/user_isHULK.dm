/datum/gun_modular/component/check/user_isHULK
	id_component = "user_isHULK"

/datum/gun_modular/component/check/user_isHULK/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

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

	if (HULK in user.mutations)
		SuccessCheck(process)
		return ..()

	FailCheck(process)
	return ..()
