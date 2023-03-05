/datum/gun_modular/component
	var/obj/item/gun_modular/module/parent
	var/id_component = "DEFAULT"
	var/datum/gun_modular/component/next_component
	var/datum/gun_modular/component/previous_component

/datum/gun_modular/component/New(obj/item/gun_modular/module/P)
	parent = P

/datum/gun_modular/component/proc/ChangeNextComponent(datum/gun_modular/component/C)

	if(!next_component)
		next_component = C
		return TRUE

	var/datum/gun_modular/component/old_next_component = next_component

	next_component = C
	old_next_component.previous_component = C.GetLastComponent()
	old_next_component.previous_component.next_component = old_next_component
	C.previous_component = src
	return TRUE

/datum/gun_modular/component/proc/AddLastComponent(datum/gun_modular/component/C)

	if(isnull(C))
		return FALSE

	if(!next_component)
		next_component = C
		return TRUE

	return next_component.AddLastComponent(C)

/datum/gun_modular/component/proc/GetLastComponent()

	if(!next_component)
		return src

	return next_component.GetLastComponent()

/datum/gun_modular/component/proc/RunTimeAction(datum/process_fire/process)

	return TRUE

/datum/gun_modular/component/proc/Action(datum/process_fire/process)

	process.SetActiveComponent(src)

	RunTimeAction(process)

	process.activate += 1

	var/datum/gun_modular/component/data/gun_user/cache_data = process.GetCacheData(USER_FIRE)

	if(cache_data)
		var/mob/user = cache_data.GetData()
		to_chat(user, "<span>([process.activate])[id_component]</span>")

	SEND_SIGNAL(process, COMSIG_GUN_COMPONENT_ACTION)

	if(!next_component)
		SEND_SIGNAL(process, COMSIG_GUN_COMPONENT_ACTION_LAST)

	return TryActionNextComponent(process)

/datum/gun_modular/component/proc/TryActionNextComponent(datum/process_fire/process)

	if(!next_component)
		return TRUE

	return next_component.Action(process)

/datum/gun_modular/component/proc/CopyComponentGun()

	var/datum/gun_modular/component/new_component = new src.type(parent)

	new_component.id_component = id_component

	if(next_component)
		new_component.next_component = next_component.CopyComponentGun()

	return new_component
