/datum/pipe_system/component/proc_component/log_terminal
	description = "(TERMINAL_DATA) Функция логирования в терминал, использует TERMINAL_DATA чтобы получить объект терминала для логирования, лучший способ использования с AWAITER"

/datum/pipe_system/component/proc_component/log_terminal/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ref/terminal/terminal_data = process.GetCacheData(TERMINAL_DATA)

	if(!terminal_data.IsValid())
		return ..()

	var/obj/item/device/terminal/terminal = terminal_data.value

	if(!terminal || !istype(terminal))
		return ..()

	terminal.AddConsoleOutput("Activate: " + process.active_component.id_component + " " + process.active_component.description)

	return ..()
