/datum/pipe_system/component/proc_component/machinery_airlock_open
	description = "(TARGET_PROGRAM_DATA, TERMINAL_DATA, PROGRAM_COMMAND_DATA(open_airlock)) Функция открытия шлюза"

/datum/pipe_system/component/proc_component/machinery_airlock_open/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ref/target_program/target_program_data = process.GetCacheData(TARGET_PROGRAM_DATA)
	var/datum/pipe_system/component/data/ref/terminal/terminal_data = process.GetCacheData(TERMINAL_DATA)
	var/datum/pipe_system/component/data/string/program_command/program_command = process.GetCacheData(PROGRAM_COMMAND_DATA)

	if(!program_command || !terminal_data || !target_program_data)
		return ..()

	if(!target_program_data.IsValid() || !terminal_data.IsValid() || !program_command.IsValid())
		return ..()

	if(!istype(target_program_data.value, /obj/machinery/door/airlock))
		return ..()

	if(program_command.value != "open_airlock")
		return ..()

	var/obj/machinery/door/airlock/target_program_airlock = target_program_data.value

	var/obj/item/device/terminal/terminal = terminal_data.value

	sleep(15)
	if(in_range(terminal, target_program_airlock))
		target_program_airlock.unbolt()
		target_program_airlock.open()

	return ..()
