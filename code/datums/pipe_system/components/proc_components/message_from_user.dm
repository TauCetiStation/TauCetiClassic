/datum/pipe_system/component/proc_gun/message_from_user
	id_component = "message_from_user"
	var/message = ""

/datum/pipe_system/component/proc_gun/message_from_user/New(datum/P, message_send = "")
	src.message = message_send

/datum/pipe_system/component/proc_gun/message_from_user/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		return ..()

	if(!cache_data.IsValid())
		return ..()

	var/mob/user = cache_data.GetData()

	if(message == "")
		return ..()

	to_chat(user, message)
	return ..()

/datum/pipe_system/component/proc_gun/message_from_user/CopyComponentGun()

	var/datum/pipe_system/component/proc_gun/message_from_user/new_component = ..()
	new_component.message = message

	return new_component

