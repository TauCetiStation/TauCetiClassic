var/const/MANIPULATOR_WIRE_ACTIVATE = 1
var/const/MANIPULATOR_WIRE_AFTER_ACTIVATE = 2

/datum/wires/manipulator
	holder_type = /obj/machinery/manipulator
	wire_count = 3
	window_y = 240

/datum/wires/manipulator/can_use()
	var/obj/machinery/manipulator/M = holder
	return M.panel_open

/datum/wires/manipulator/update_cut(index, mended)
	var/obj/machinery/manipulator/M = holder

	switch(index)
		if(MANIPULATOR_WIRE_ACTIVATE)
			if(!M.can_activate())
				M.remember_trigger = TRUE
				return

			M.activate()

		if(MANIPULATOR_WIRE_AFTER_ACTIVATE)
			M.after_activate()

/datum/wires/manipulator/update_pulsed(index)
	var/obj/machinery/manipulator/M = holder

	switch(index)
		if(MANIPULATOR_WIRE_ACTIVATE)
			if(!M.can_activate())
				M.remember_trigger = TRUE
				return

			M.activate()

		if(MANIPULATOR_WIRE_AFTER_ACTIVATE)
			M.after_activate()
