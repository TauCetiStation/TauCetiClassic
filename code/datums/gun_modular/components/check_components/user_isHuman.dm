/datum/gun_modular/component/check/user_isHuman
	id_component = "user_isHuman"

/datum/gun_modular/component/check/user_isHuman/Action(datum/process_fire/process)

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

	if(!ishuman(user))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
