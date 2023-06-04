var/global/const/MANIPULATOR_WIRE_ACTIVATE = 1
var/global/const/MANIPULATOR_WIRE_AFTER_ACTIVATE = 2
var/global/const/MANIPULATOR_WIRE_CHANGE_TARGET_ZONE = 4

/datum/wires/manipulator
	holder_type = /obj/machinery/manipulator
	wire_count = 4
	window_y = 400

/datum/wires/manipulator/can_use()
	var/obj/machinery/manipulator/M = holder
	return M.panel_open

/datum/wires/manipulator/get_status()
	var/obj/machinery/manipulator/M = holder
	. += ..()
	. += "Target selection screen displays: [parse_zone(M.target_zone)]"

/datum/wires/manipulator/update_cut(index, mended)
	update_pulsed(index)

/datum/wires/manipulator/update_pulsed(index)
	var/obj/machinery/manipulator/M = holder

	switch(index)
		if(MANIPULATOR_WIRE_ACTIVATE)
			if(!M.can_activate())
				M.remember_trigger = TRUE
				return

			M.activate()

		if(MANIPULATOR_WIRE_CHANGE_TARGET_ZONE)
			M.cycle_target_zone()
