
/obj/machinery/computer/station_alert
	name = "Station Alert Console"
	desc = "Used to access the station's automated alert system."
	icon_state = "atmos"
	light_color = "#e6ffff"
	circuit = /obj/item/weapon/circuitboard/stationalert
	var/alarms = list("Fire"=list(), "Atmosphere"=list(), "Power"=list())
	var/muted = 0
	required_skills = list(/datum/skill/engineering = SKILL_LEVEL_NOVICE, /datum/skill/command = SKILL_LEVEL_NONE)

/obj/machinery/computer/station_alert/atom_init()
	. = ..()
	station_alert_list += src

/obj/machinery/computer/station_alert/Destroy()
	station_alert_list -= src
	return ..()

/obj/machinery/computer/station_alert/ui_interact(mob/user)
	if(!do_skill_checks(user))
		return
	var/dat = ""
	dat += {"
		<td>Mute Mode: </td><td>[muted ? "On" : "Off"]</td>
		<A href='byond://?src=\ref[src];command=mute'>[muted ? "On" : "Off"]</A><BR><BR>"}
	for (var/cat in src.alarms)
		dat += text("<B>[]</B><BR>\n", cat)
		var/list/L = src.alarms[cat]
		if (L.len)
			for (var/alarm in L)
				var/list/alm = L[alarm]
				var/area/A = alm[1]
				var/list/sources = alm[3]
				dat += "<NOBR>"
				dat += "&bull; "
				dat += "[A.name]"
				if (sources.len > 1)
					dat += text(" - [] sources", sources.len)
				dat += "</NOBR><BR>\n"
		else
			dat += "-- All Systems Nominal<BR>\n"
		dat += "<BR>\n"

	var/datum/browser/popup = new(user, "window=alerts", "Current Station Alerts")
	popup.set_content(dat)
	popup.open()

/obj/machinery/computer/station_alert/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if(href_list["command"])
		switch(href_list["command"])
			if("mute")
				muted = !muted
	updateUsrDialog()

/obj/machinery/computer/station_alert/proc/triggerAlarm(class, area/A, O, alarmsource)
	if(stat & (BROKEN))
		return
	var/list/L = src.alarms[class]
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/sources = alarm[3]
			if (!(alarmsource in sources))
				sources += alarmsource
				updateDialog()
			return 1
	var/obj/machinery/camera/C = null
	var/list/CL = null
	if (O && istype(O, /list))
		CL = O
		if (CL.len == 1)
			C = CL[1]
	else if (O && istype(O, /obj/machinery/camera))
		C = O
	L[A.name] = list(A, (C) ? C : O, list(alarmsource))
	updateDialog()
	return 1


/obj/machinery/computer/station_alert/proc/cancelAlarm(class, area/A, obj/origin)
	if(stat & (BROKEN))
		return
	var/list/L = src.alarms[class]
	var/cleared = 0
	for (var/I in L)
		if (I == A.name)
			var/list/alarm = L[I]
			var/list/srcs  = alarm[3]
			if (origin in srcs)
				srcs -= origin
			if (srcs.len == 0)
				cleared = 1
				L -= I
	updateDialog()
	return !cleared


/obj/machinery/computer/station_alert/process()
	update_icon()
	..()
// todo: rewrite it as repeated sound, also better to wait when playsound will be ready to support 516 sound atom
//	if((icon_state == "atmos_alert_2") && !muted)
//		playsound(src, 'sound/machines/atmos_alarm.ogg', VOL_EFFECTS_MASTER, vary = FALSE)
	return

/obj/machinery/computer/station_alert/update_icon()
	if (stat & NOPOWER)
		icon_state = "atmos0"
	else if(stat & BROKEN)
		icon_state = "atmosb"
	else
		var/active_alarms = 0
		for (var/cat in src.alarms)
			var/list/L = src.alarms[cat]
			if(L.len) active_alarms = 1
		if(active_alarms)
			icon_state = "atmos_alert_2"
		else
			icon_state = "atmos_alert_0"
