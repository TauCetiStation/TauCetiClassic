////////////////////////
//Turret Control Panel//
////////////////////////

/area
	// Turrets use this list to see if individual power/lethal settings are allowed
	var/list/turret_controls = list()

/obj/machinery/turretid
	name = "Turret control panel"
	desc = "Used to control a room's automated defenses."
	icon = 'icons/obj/machines/turret_control.dmi'
	icon_state = "control_standby"
	anchored = 1
	density = 0
	allowed_checks = ALLOWED_CHECK_NONE // we use isLocked proc to open UI.

	var/enabled = 0
	var/lethal = 0
	var/locked = 1
	var/area/control_area //can be area name, path or nothing.

	var/check_arrest = 1	//checks if the perp is set to arrest
	var/check_records = 1	//checks if a security record exists at all
	var/check_weapons = 0	//checks if it can shoot people that have a weapon they aren't authorized to have
	var/check_access = 1	//if this is active, the turret shoots everything that does not meet the access requirements
	var/check_anomalies = 1	//checks if it can shoot at unidentified lifeforms (ie xenos)
	var/check_n_synth = 0 	//if active, will shoot at anything not an AI or cyborg
	var/shot_synth = 0	//if active and in letal, will shoot any cyborgs
	var/ailock = 0 			// AI cannot use this
	var/special_control = 0 //AI (and only AI) can set shot_synth

	req_access = list(access_ai_upload)

/obj/machinery/turretid/stun
	enabled = 1
	check_n_synth = 1
	icon_state = "control_stun"

/obj/machinery/turretid/stun/AI_special
	special_control = 1

/obj/machinery/turretid/lethal
	enabled = 1
	lethal = 1
	check_n_synth = 1
	icon_state = "control_kill"

/obj/machinery/turretid/Destroy()
	if(control_area)
		var/area/A = control_area
		if(A && istype(A))
			A.turret_controls -= src
	return ..()

/obj/machinery/turretid/atom_init()
	. = ..()
	if(!control_area)
		control_area = get_area(src)
	else if(istext(control_area))
		for(var/area/A in all_areas)
			if(A.name && A.name==control_area)
				control_area = A
				break

	if(control_area)
		var/area/A = control_area
		if(istype(A))
			A.turret_controls += src
		else
			control_area = null

	power_change() //Checks power and initial settings

/obj/machinery/turretid/proc/isLocked(mob/user)
	if(ailock && issilicon(user))
		to_chat(user, "<span class='notice'>There seems to be a firewall preventing you from accessing this device.</span>")
		return TRUE

	if(locked && !issilicon(user) && !isobserver(user))
		to_chat(user, "<span class='notice'>Access denied.</span>")
		return TRUE

	return FALSE

/obj/machinery/turretid/is_operational_topic()
	return !(stat & (NOPOWER|BROKEN))

/obj/machinery/turretid/attackby(obj/item/weapon/W, mob/user)
	if(stat & BROKEN)
		return

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(src.allowed(usr))
			if(emagged)
				to_chat(user, "<span class='notice'>The turret control is unresponsive.</span>")
			else
				locked = !locked
				to_chat(user, "<span class='notice'>You [ locked ? "lock" : "unlock"] the panel.</span>")
		return
	return ..()
/obj/machinery/turretid/emag_act(mob/user)
	if(emagged)
		return FALSE
	to_chat(user, "<span class='danger'>You short out the turret controls' access analysis module.</span>")
	emagged = 1
	locked = 0
	ailock = 0
	return TRUE

/obj/machinery/turretid/ui_interact(mob/user)
	if(isLocked(user))
		return

	var/dat = text({"
		<table width="100%" cellspacing="0" cellpadding="4">
			<tr>
				<td>Status: </td><td>[]</td>
			</tr>
			<tr></tr>
			<tr>
				<td>Lethal Mode: </td><td>[]</td>
			</tr>
			<tr>
				<td>Neutralize All Non-Synthetics: </td><td>[]</td>
			</tr>
			<tr>
				<td>Neutralize All Cyborgs: </td><td>[]</td>
			</tr>
			<tr>
				<td>Check Weapon Authorization: </td><td>[]</td>
			</tr>
			<tr>
				<td>Check Security Records: </td><td>[]</td>
			</tr>
			<tr>
				<td>Check Arrest Status: </td><td>[]</td>
			</tr>
			<tr>
				<td>Check Access Authorization: </td><td>[]</td>
			</tr>
			<tr>
				<td>Check misc. Lifeforms: </td><td>[]</td>
			</tr>
		</table>"},

		"<A href='?src=\ref[src];command=enable'>[enabled ? "On" : "Off"]</A>",
		"<A href='?src=\ref[src];command=lethal'>[lethal ? "On" : "Off"]</A>",
		"<A href='?src=\ref[src];command=check_n_synth'>[check_n_synth ? "Yes" : "No"]</A>",
		"[(special_control && isAI(user)) ? "<A href='?src=\ref[src];command=shot_synth'>[shot_synth ? "Yes" : "No"]</A>" : "NOT ALLOWED"]",
		"<A href='?src=\ref[src];command=check_weapons'>[check_weapons ? "Yes" : "No"]</A>",
		"<A href='?src=\ref[src];command=check_records'>[check_records ? "Yes" : "No"]</A>",
		"<A href='?src=\ref[src];command=check_arrest'>[check_arrest ? "Yes" : "No"]</A>",
		"<A href='?src=\ref[src];command=check_access'>[check_access ? "Yes" : "No"]</A>",
		"<A href='?src=\ref[src];command=check_anomalies'>[check_anomalies ? "Yes" : "No"]</A>")

	var/datum/browser/popup = new(user, "window=autoseccontrol", "Turret Installation Controller", 400, 320)
	popup.set_content(dat)
	popup.open()

/obj/machinery/turretid/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["command"])
		var/log_action = null
		var/list/toggle = list("disabled","enabled")
		switch(href_list["command"])
			if("enable")
				enabled = !enabled
				log_action = "[toggle[enabled+1]] the turrets"
			if("lethal")
				lethal = !lethal
				log_action = "[toggle[lethal+1]] the turrets lethal mode."
			if("check_n_synth")
				check_n_synth = !check_n_synth
			if("shot_synth")
				shot_synth = !shot_synth
			if("check_weapons")
				check_weapons = !check_weapons
			if("check_records")
				check_records = !check_records
			if("check_arrest")
				check_arrest = !check_arrest
			if("check_access")
				check_access = !check_access
			if("check_anomalies")
				check_anomalies = !check_anomalies

		if(log_action)
			log_admin("[key_name(usr)] has [log_action]")
			message_admins("[key_name_admin(usr)] has [log_action]")

		updateTurrets()
	updateUsrDialog()

/obj/machinery/turretid/proc/updateTurrets()
	if(istype(control_area))
		var/datum/turret_checks/TC = new
		TC.enabled = enabled
		TC.lethal = lethal
		TC.check_n_synth = check_n_synth
		TC.check_access = check_access
		TC.check_records = check_records
		TC.check_arrest = check_arrest
		TC.check_weapons = check_weapons
		TC.check_anomalies = check_anomalies
		TC.shot_synth = shot_synth
		TC.ailock = ailock

		for (var/obj/machinery/porta_turret/aTurret in control_area)
			aTurret.setState(TC)

	update_icon()

/obj/machinery/turretid/power_change()
	..()
	if(!(stat & NOPOWER))
		updateTurrets()

/obj/machinery/turretid/update_icon(slave = FALSE)
	..()
	if(stat & NOPOWER)
		icon_state = "control_off"
		set_light(0)
	else if (enabled)
		if (lethal)
			icon_state = "control_kill"
			set_light(1.5, 1,"#990000")
		else
			icon_state = "control_stun"
			set_light(1.5, 1,"#ff9900")
	else
		icon_state = "control_standby"
		set_light(1.5, 1,"#003300")
	if(!slave && istype(control_area))
		for(var/obj/machinery/turretid/tid in control_area.turret_controls)
			tid.update_icon(TRUE)

/obj/machinery/turretid/emp_act(severity)
	if(enabled)
		//if the turret is on, the EMP no matter how severe disables the turret for a while
		//and scrambles its settings, with a slight chance of having an emag effect

		check_arrest = pick(0, 1)
		check_records = pick(0, 1)
		check_weapons = pick(0, 1)
		check_access = pick(0, 0, 0, 0, 1)	// check_access is a pretty big deal, so it's least likely to get turned on
		check_anomalies = pick(0, 1)

		enabled=0
		updateTurrets()
		addtimer(CALLBACK(src, .proc/emp_act_post), rand(60,600))

	..()

/obj/machinery/turretid/proc/emp_act_post()
	if(!enabled)
		enabled=1
		updateTurrets()
