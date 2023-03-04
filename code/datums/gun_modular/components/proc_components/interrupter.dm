/datum/gun_modular/component/proc_gun/interrupter
	id_component = "interrupter"

/datum/gun_modular/component/proc_gun/interrupter/Action(datum/process_fire/process)

	SEND_SIGNAL(process, COMSIG_GUN_COMPONENT_ACTION_LAST)

	var/datum/gun_modular/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(!cache_data)
		return ..()

	var/mob/user = cache_data.GetData()
	to_chat(user, "<span>[id_component]</span>")

	return TRUE
