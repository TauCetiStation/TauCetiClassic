/datum/pipe_system/component/proc_component/machinery_drop_contents/RunTimeAction(datum/pipe_system/process/process)

	var/datum/pipe_system/component/data/ref/target_program/target_program_data = process.GetCacheData(TARGET_PROGRAM_DATA)

	if(!target_program_data.IsValid())
		return ..()

	var/obj/machinery/target_program_machinery = target_program_data.value

	var/datum/pipe_system/component/data/string/program_command/program_command = process.GetCacheData(PROGRAM_COMMAND_DATA)

	if(!target_program_machinery || !istype(target_program_machinery) || !program_command.IsValid())
		return ..()

	if(program_command.value == "drop_contents")
		target_program_machinery.dropContents()

	return ..()
