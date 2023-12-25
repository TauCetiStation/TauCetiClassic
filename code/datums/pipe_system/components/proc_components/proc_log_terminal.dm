/datum/pipe_system/component/proc_component/log_terminal/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ref/log_target/terminal_data = process.GetCacheData(LOG_TARGET_DATA)

	if(!terminal_data.IsValid())
		return ..()

	var/obj/item/device/terminal/terminal = terminal_data.value

	if(!terminal || !istype(terminal))
		return ..()

	terminal.AddConsoleOutput("Activate: " + process.active_component.id_component)

	return ..()
