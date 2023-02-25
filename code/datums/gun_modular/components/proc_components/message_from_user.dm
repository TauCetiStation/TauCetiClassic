/datum/gun_modular/component/proc_gun/message_from_user
	var/message = ""

/datum/gun_modular/component/proc_gun/message_from_user/New(obj/item/gun_modular/module/P, message_send)
	src.message = message_send

/datum/gun_modular/component/proc_gun/message_from_user/Action(datum/process_fire/process)

	var/mob/user = process.GetCacheData(USER_FIRE)

	if(isnull(user))
		return ..()

	if(!istype(user))
		return ..()

	if(message == "")
		return ..()

	to_chat(user, message)
	return ..()
