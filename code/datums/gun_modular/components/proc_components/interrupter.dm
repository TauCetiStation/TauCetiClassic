/datum/gun_modular/component/proc_gun/interrupter
	id_component = "interrupter"

/datum/gun_modular/component/proc_gun/interrupter/Action(datum/process_fire/process)

	var/mob/user = process.GetCacheData(USER_FIRE)
	to_chat(user, "<span>[id_component]</span>")

	return TRUE
