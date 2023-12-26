/datum/pipe_system/component/proc_component/skip_component
	description = "Пропускает следующую компоненту"

/datum/pipe_system/component/proc_component/skip_component/RunTimeAction(datum/pipe_system/process/process)

	DeleteNextComponent()

	return ..()
