/datum/gun_modular/component/proc_gun/user_addFingerptint
	id_component = "user_addFingerptint"

/datum/gun_modular/component/proc_gun/user_addFingerptint/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		return ..()

	if(!cache_data.IsValid())
		return ..()

	var/mob/user = cache_data.GetData()

	if(!istype(user))
		return ..()

	parent.add_fingerprint(user)
	return ..()
