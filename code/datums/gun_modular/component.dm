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

	if(!next_component)
		next_component = C
		return TRUE

	return next_component.AddLastComponent(C)

/datum/gun_modular/component/proc/GetLastComponent()

	if(!next_component)
		return src

	return next_component.GetLastComponent()

/datum/gun_modular/component/proc/Action(datum/process_fire/process)

	var/datum/gun_modular/component/data/cache_data = process.GetCacheData(USER_FIRE)

	if(cache_data)
		var/mob/user = cache_data.GetData()
		to_chat(user, "<span>[id_component]</span>")

	if(!next_component)
		return TRUE

	return next_component.Action(process)

/datum/gun_modular/component/proc/CopyComponentGun()

	var/datum/gun_modular/component/new_component = new src.type(parent)

	if(next_component)
		new_component.next_component = next_component.CopyComponentGun()

	return new_component
