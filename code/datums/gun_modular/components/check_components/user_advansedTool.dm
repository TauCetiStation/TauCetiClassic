/datum/gun_modular/component/check/user_advansedTool
	id_component = "user_advansedTool"

/datum/gun_modular/component/check/user_advansedTool/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		FailCheck(process)
		return ..()

	var/mob/living/user = cache_data.GetData()

	if(isnull(user))
		FailCheck(process)
		return ..()

	if(!istype(user))
		FailCheck(process)
		return ..()

	if(!user.IsAdvancedToolUser())
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
