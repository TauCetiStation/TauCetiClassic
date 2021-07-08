/**
 * tgui state: machinery_state
 *
 * Same as default state but this one checks if host is machine and if it's operational
 */

var/global/datum/tgui_state/machinery_state/machinery_state = new

/datum/tgui_state/machinery_state/can_use_topic(src_object, mob/user)
	. = user.default_can_use_topic(src_object)
	if(. > UI_CLOSE)
		return min(., can_use_machinery(src_object, user))

/datum/tgui_state/machinery_state/proc/can_use_machinery(src_object, mob/user)
	. = UI_CLOSE
	var/obj/machinery/machine = src_object
	if(istype(machine)
		if(machine.is_interactable(user))
			. = UI_INTERACTIVE
		else if(machine.is_operational(user))
			. = UI_UPDATE
