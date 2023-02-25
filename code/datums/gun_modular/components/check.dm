/datum/gun_modular/component/check
	var/datum/gun_modular/component/success_component = null
	var/datum/gun_modular/component/fail_component = null

/datum/gun_modular/component/check/New(obj/item/gun_modular/module/P, var/datum/gun_modular/component/success_component = null, var/datum/gun_modular/component/fail_component = null)
	. = ..()

	src.success_component = success_component
	src.fail_component = fail_component

/datum/gun_modular/component/check/Action(datum/process_fire/process)
	return ..()

/datum/gun_modular/component/check/proc/FailCheck(datum/process_fire/process)

	if(!fail_component)
		return FALSE

	return ChangeNextComponent(fail_component.CopyComponentGun())

/datum/gun_modular/component/check/proc/SuccessCheck(datum/process_fire/process)

	if(!success_component)
		return FALSE

	return ChangeNextComponent(success_component.CopyComponentGun())

/datum/gun_modular/component/check/CopyComponentGun()

	var/datum/gun_modular/component/check/new_component = ..()

	if(success_component)
		new_component.success_component = success_component.CopyComponentGun()

	if(fail_component)
		new_component.fail_component = fail_component.CopyComponentGun()

	return new_component
