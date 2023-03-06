/datum/pipe_system/component/proc_gun/visible_message_user
	id_component = "visible_message_user"
	var/message = ""
	var/message_hear = ""

/datum/pipe_system/component/proc_gun/visible_message_user/New(datum/P, message_send = "", message_hear = "")
	src.message = message_send
	src.message_hear = message_hear

/datum/pipe_system/component/proc_gun/visible_message_user/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		return ..()

	if(!cache_data.IsValid())
		return ..()

	var/mob/user = cache_data.GetData()

	if(message == "" || message_hear == "")
		return ..()

	user.visible_message(message, message_hear)
	return ..()

/datum/pipe_system/component/proc_gun/visible_message_user/CopyComponentGun()

	var/datum/pipe_system/component/proc_gun/visible_message_user/new_component = ..()
	new_component.message = message
	new_component.message_hear = message_hear

	return new_component

