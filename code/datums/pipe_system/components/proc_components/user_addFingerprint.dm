/datum/pipe_system/component/proc_gun/user_addFingerptint
	id_component = "user_addFingerptint"

/datum/pipe_system/component/proc_gun/user_addFingerptint/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		return ..()

	if(!cache_data.IsValid())
		return ..()

	var/mob/user = cache_data.GetData()

	if(!istype(user))
		return ..()

	var/obj/parent_obj = parent
	if(!istype(parent_obj, /obj))
		return ..()

	parent_obj.add_fingerprint(user)
	return ..()
