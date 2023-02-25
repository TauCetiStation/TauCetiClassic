/datum/gun_modular/component/check
	var/datum/gun_modular/component/success_component
	var/datum/gun_modular/component/fail_component

/datum/gun_modular/component/check/New(obj/item/gun_modular/module/P, var/datum/gun_modular/component/success_component, var/datum/gun_modular/component/fail_component)
	. = ..()

	src.success_component = success_component
	src.fail_component = fail_component

/datum/gun_modular/component/check/Action(datum/process_fire/process)
	return ..()

/datum/gun_modular/component/check/proc/FailCheck(datum/process_fire/process)

	if(!istype(fail_component, /datum/gun_modular/component))
		return FALSE

	next_component.ChangeNextComponent(fail_component.CopyComponentGun())

/datum/gun_modular/component/check/proc/SuccessCheck(datum/process_fire/process)

	if(!istype(success_component, /datum/gun_modular/component))
		return FALSE

	next_component.ChangeNextComponent(success_component.CopyComponentGun())
