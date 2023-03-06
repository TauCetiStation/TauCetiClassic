/datum/pipe_system/component/check
	var/datum/pipe_system/component/success_component = null
	var/datum/pipe_system/component/fail_component = null

/datum/pipe_system/component/check/New(datum/P, var/datum/pipe_system/component/success_component = null, var/datum/pipe_system/component/fail_component = null)
	. = ..()

	src.success_component = success_component
	src.fail_component = fail_component

/datum/pipe_system/component/check/proc/FailCheck(datum/pipe_system/process/process)

	SEND_SIGNAL(src, COMSIG_GUN_CHECK_FAIL)

	if(!fail_component)
		return FALSE

	return ChangeNextComponent(fail_component.CopyComponentGun())

/datum/pipe_system/component/check/proc/SuccessCheck(datum/pipe_system/process/process)

	SEND_SIGNAL(src, COMSIG_GUN_CHECK_SUCCESS)

	if(!success_component)
		return FALSE

	return ChangeNextComponent(success_component.CopyComponentGun())

/datum/pipe_system/component/check/CopyComponentGun()

	var/datum/pipe_system/component/check/new_component = ..()

	if(success_component)
		new_component.success_component = success_component.CopyComponentGun()

	if(fail_component)
		new_component.fail_component = fail_component.CopyComponentGun()

	return new_component
