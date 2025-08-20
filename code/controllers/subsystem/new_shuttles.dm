SUBSYSTEM_DEF(new_shuttles)
	name = "NewShuttles"

	init_order = SS_INIT_DEFAULT

	flags = SS_NO_FIRE
	runlevels = RUNLEVEL_SETUP | RUNLEVEL_GAME

	msg_lobby = "Перезаправляем шаттлы..."

/datum/controller/subsystem/new_shuttles/Initialize()
	for(var/obj/machinery/computer/shuttle_console/Console in global.shuttle_consoles)
		Console.generate_shuttle()

	..()