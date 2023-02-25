/datum/gun_modular/component/proc_gun/user_addFingerptint
	id_component = "user_addFingerptint"

/datum/gun_modular/component/proc_gun/user_addFingerptint/Action(datum/process_fire/process)

	var/mob/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		return ..()

	if(!istype(user))
		return ..()

	parent.add_fingerprint(user)
	return ..()
