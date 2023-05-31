//////////////////////////////////////// Action Buttons ///////////////////////////////////////////////

/obj/mecha/proc/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	cycle_action.Grant(user, src)
	lights_action.Grant(user, src)
	stats_action.Grant(user, src)
	strafing_action.Grant(user, src)


/obj/mecha/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Remove(user)
	internals_action.Remove(user)
	cycle_action.Remove(user)
	lights_action.Remove(user)
	stats_action.Remove(user)
	strafing_action.Remove(user)


/datum/action/innate/mecha
	check_flags = AB_CHECK_INCAPACITATED
	button_icon = 'icons/hud/actions_mecha.dmi'
	action_type = AB_INNATE
	var/obj/mecha/chassis

/datum/action/innate/mecha/Grant(mob/living/L, obj/mecha/M)
	if(M)
		chassis = M
		target = M
	..()

/datum/action/innate/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/innate/mecha/proc/availability()
	if(!owner)
		return FALSE

	if(!chassis)
		return FALSE

	if(chassis.occupant != owner)
		return FALSE

	return TRUE

//////////////////////////////////////// General Ability Actions  ///////////////////////////////////////////////


/datum/action/innate/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/mech_eject/Activate()
	if(!availability())
		return

	chassis.container_resist(chassis.occupant)

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/innate/mecha/mech_toggle_internals/Activate()
	if(!availability())
		return

	chassis.toggle_internal_tank()
	updateicon()

/datum/action/innate/mecha/mech_toggle_internals/proc/updateicon()
	if(chassis.use_internal_tank)
		button_icon_state = "mech_internals_[chassis.use_internal_tank? "on" : "off"]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_cycle_equip
	name = "Cycle Equipment"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/mecha/mech_cycle_equip/Activate()
	if(!availability())
		return

	var/list/available_equipment = list()
	for(var/obj/item/mecha_parts/mecha_equipment/M in chassis.equipment)
		if(M.selectable)
			available_equipment += M

	if(!available_equipment.len)
		chassis.occupant_message("<span class='warning'>No equipment available!</span>")
		return
	if(!chassis.selected)
		if(!chassis.check_fumbling("<span class='notice'>You fumble around, figuring out how to switch selected equipment.</span>"))
			return
		chassis.selected = available_equipment[1]
		chassis.occupant_message("<span class='notice'>You select [chassis.selected].</span>")
		send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
		button_icon_state = "mech_cycle_equip_on"
		playsound(chassis, 'sound/mecha/mech_switch_equip.ogg', VOL_EFFECTS_MASTER, 70, FALSE, null, -3)
		updateicon()
		return
	var/number = 0
	for(var/A in available_equipment)
		number++
		if(A == chassis.selected)
			if(!chassis.check_fumbling("<span class='notice'>You fumble around, figuring out how to switch selected equipment.</span>"))
				return
			if(available_equipment.len == number)
				chassis.selected = null
				chassis.occupant_message("<span class='notice'>You switch to no equipment.</span>")
			else
				chassis.selected = available_equipment[number + 1]
				chassis.occupant_message("<span class='notice'>You switch to [chassis.selected].</span>")
				playsound(chassis, 'sound/mecha/mech_switch_equip.ogg', VOL_EFFECTS_MASTER, 70, FALSE, null, -3)
			send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
			updateicon()
			return

/datum/action/innate/mecha/mech_cycle_equip/proc/updateicon()
	button_icon_state = "mech_cycle_equip_[chassis.selected? "on" : "off"]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/mecha/mech_toggle_lights/Activate()
	if(!availability())
		return

	chassis.toggle_lights()
	updateicon()

/datum/action/innate/mecha/mech_toggle_lights/proc/updateicon()
	button_icon_state = "mech_lights_[chassis.lights? "on" : "off"]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/innate/mecha/mech_view_stats/Activate()
	if(!availability())
		return

	chassis.view_stats()

///////////////////////////////////////////////

/datum/action/innate/mecha/strafe
	name = "Toggle Strafing. Fixes mech gaze."
	button_icon_state = "strafe_off"

/datum/action/innate/mecha/strafe/Activate()
	if(!availability())
		return

	chassis.toggle_strafe()
	updateicon()

/datum/action/innate/mecha/strafe/proc/updateicon()
	button_icon_state = "strafe_[chassis.strafe? "on" : "off"]"
	chassis.occupant.update_action_buttons()


//////////////////////////////////////// Specific Ability Actions  ///////////////////////////////////////////////

/datum/action/innate/mecha/mech_toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/mech_toggle_thrusters/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/marauder/M = chassis
	M.toggle_thrusters()
	updateicon()

/datum/action/innate/mecha/mech_toggle_thrusters/proc/updateicon()
	var/obj/mecha/combat/marauder/M = chassis
	button_icon_state = "mech_thrusters_[M.thrusters_active? "on" : "off"]"
	M.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_defence_mode
	name = "Toggle an defence mod. Blocks some damage"
	button_icon_state = "mech_defense_mode_off"

/datum/action/innate/mecha/mech_defence_mode/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/durand/D = chassis
	D.defence_mode()
	updateicon()

/datum/action/innate/mecha/mech_defence_mode/proc/updateicon()
	var/obj/mecha/combat/durand/D = chassis
	button_icon_state = "mech_defense_mode_[D.defence? "on" : "off"]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/mech_overload_mode/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/gygax/G = chassis
	G.overload()
	updateicon()

/datum/action/innate/mecha/mech_overload_mode/proc/updateicon()
	var/obj/mecha/combat/gygax/G = chassis
	button_icon_state = "mech_overload_[G.overload? "on" : "off"]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_smoke
	name = "Smoke"
	button_icon_state = "mech_smoke"

/datum/action/innate/mecha/mech_smoke/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/marauder/M = chassis
	M.smoke()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/mecha/mech_zoom/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/marauder/M = chassis
	M.zoom()
	updateicon()

/datum/action/innate/mecha/mech_zoom/proc/updateicon()
	var/obj/mecha/combat/marauder/M = chassis
	button_icon_state = "mech_zoom_[M.zoom_mode? "on" : "off"]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/innate/mecha/mech_switch_damtype/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/phazon/P = chassis
	P.switch_damtype()
	updateicon()

/datum/action/innate/mecha/mech_switch_damtype/proc/updateicon()
	var/obj/mecha/combat/phazon/P = chassis
	button_icon_state = "mech_damtype_[P.damtype]"
	chassis.occupant.update_action_buttons()

///////////////////////////////////////////////

/datum/action/innate/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!availability())
		return

	var/obj/mecha/combat/phazon/P = chassis
	P.switch_phasing()
	updateicon()

/datum/action/innate/mecha/mech_toggle_phasing/proc/updateicon()
	var/obj/mecha/combat/phazon/P = chassis
	button_icon_state = "mech_phasing_[P.phasing? "on" : "off"]"
	chassis.occupant.update_action_buttons()
