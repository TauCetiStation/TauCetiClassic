var/global/const/MANIPULATOR_WIRE_ACTIVATE = 1
var/global/const/MANIPULATOR_WIRE_AFTER_ACTIVATE = 2
var/global/const/MANIPULATOR_WIRE_CHANGE_TARGET_ZONE = 4
var/global/const/MANIPULATOR_WIRE_ATTACK_SELF_ON_INTERACTION = 8
var/global/const/MANIPULATOR_WIRE_AUTO_ACTIVATION = 16

/datum/wires/manipulator
	holder_type = /obj/machinery/manipulator
	wire_count = 5
	window_y = 560

/datum/wires/manipulator/can_use()
	var/obj/machinery/manipulator/M = holder
	return M.panel_open

/datum/wires/manipulator/get_status()
	var/obj/machinery/manipulator/M = holder
	. += ..()
	. += "Target selection screen displays: [parse_zone(M.target_zone)]"
	. += "The 'Activate Instead' light is [M.attack_self_interaction ? "on" : "off"]."
	. += "The 'Auto Activation' light is [M.auto_activation ? "on" : "off"]."

/datum/wires/manipulator/update_cut(index, mended)
	var/obj/machinery/manipulator/M = holder

	switch(index)
		if(MANIPULATOR_WIRE_AUTO_ACTIVATION)
			M.auto_activation = mended
			return

		if(MANIPULATOR_WIRE_ATTACK_SELF_ON_INTERACTION)
			M.attack_self_interaction = !mended
			return

	update_pulsed(index)

/datum/wires/manipulator/update_pulsed(index)
	var/obj/machinery/manipulator/M = holder

	switch(index)
		if(MANIPULATOR_WIRE_ACTIVATE)
			if(!M.can_activate())
				return

			M.forced = TRUE
			M.activate()

		if(MANIPULATOR_WIRE_CHANGE_TARGET_ZONE)
			M.cycle_target_zone()

		if(MANIPULATOR_WIRE_ATTACK_SELF_ON_INTERACTION)
			M.next_attack_self_interaction = TRUE
