/datum/pipe_system/component/proc_component
	id_component = PIPE_SYSTEM_PROC
	description = "Функциональный компонент, выполняет функцию используя DATA компоненты в качестве входных данных"

/datum/pipe_system/component/proc_component/RunTimeAction(datum/pipe_system/process/process)
	return ..()

