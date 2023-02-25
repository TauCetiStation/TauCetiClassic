/datum/gun_modular/component/check/user_isHuman
	id_component = "user_isHuman"

/datum/gun_modular/component/check/user_isHuman/Action(datum/process_fire/process)

	var/mob/living/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		FailCheck(process)
		return ..()

	if(!istype(user))
		FailCheck(process)
		return ..()

	if(!ishuman(user))
		FailCheck(process)
		return ..()

	SuccessCheck(process)
	return ..()
