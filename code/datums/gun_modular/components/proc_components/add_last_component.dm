/datum/gun_modular/component/proc_gun/add_last_component
	id_component = "add_last_component"
	var/datum/gun_modular/component/last_component = null

/datum/gun_modular/component/proc_gun/add_last_component/New(obj/item/gun_modular/module/P, datum/gun_modular/component/last_component = null)
	src.last_component = last_component

/datum/gun_modular/component/proc_gun/add_last_component/Action(datum/process_fire/process)

	if(last_component)
		AddLastComponent(last_component)

	return ..()

/datum/gun_modular/component/proc_gun/add_last_component/CopyComponentGun()

	var/datum/gun_modular/component/proc_gun/add_last_component/new_component = ..()
	new_component.last_component = last_component.CopyComponentGun()

	return new_component

