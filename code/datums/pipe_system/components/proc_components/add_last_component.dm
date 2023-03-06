/datum/pipe_system/component/proc_gun/add_last_component
	id_component = "add_last_component"
	var/datum/pipe_system/component/last_component = null

/datum/pipe_system/component/proc_gun/add_last_component/New(datum/P, datum/pipe_system/component/last_component = null)
	src.last_component = last_component

/datum/pipe_system/component/proc_gun/add_last_component/RunTimeAction(datum/pipe_system/process/process)

	if(last_component)
		AddLastComponent(last_component)

	return ..()

/datum/pipe_system/component/proc_gun/add_last_component/CopyComponentGun()

	var/datum/pipe_system/component/proc_gun/add_last_component/new_component = ..()
	new_component.last_component = last_component.CopyComponentGun()

	return new_component

