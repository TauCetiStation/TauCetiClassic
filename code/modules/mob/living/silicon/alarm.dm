/datum/alarm
	var/area/area		//the area associated with the alarm. Used to identify the alarm
	var/list/sources	//list of things triggering the alarm. Used to determine when the alarm should be cleared.
	var/list/cameras	//list of cameras that can be switched to, if the player has that capability.

/datum/alarm/New(area/A, list/sourcelist=list(), list/cameralist=list())
	area = A
	sources = sourcelist
	cameras = cameralist
	datum_alarm_list += src

/datum/alarm/Destroy()
	datum_alarm_list -= src
	return ..()

/mob/living/silicon
	var/alarms = list("Motion"=list(), "Fire"=list(), "Atmosphere"=list(), "Power"=list(), "Camera"=list())	//each sublist stores alarms keyed by the area name
	var/list/alarms_to_show = list()
	var/list/alarms_to_clear = list()
	var/list/alarm_types_show = list()
	var/list/alarm_types_clear = list()

/mob/living/silicon/proc/triggerAlarm(class, area/A, list/cameralist, source)
	var/list/alarmlist = alarms[class]

	//see if there is already an alarm of this class for this area
	if (A.name in alarmlist)
		var/datum/alarm/existing = alarmlist[A.name]
		existing.sources += source
		existing.cameras |= cameralist
	else
		alarmlist[A.name] = new /datum/alarm(A, list(source), cameralist)

/mob/living/silicon/proc/cancelAlarm(class, area/A, source)
	var/cleared = 0
	var/list/alarmlist = alarms[class]

	if (A.name in alarmlist)
		var/datum/alarm/alarm = alarmlist[A.name]
		alarm.sources -= source

		if (!(alarm.sources.len))
			cleared = 1
			alarmlist -= A.name

	return !cleared

/mob/living/silicon/proc/queueAlarm(message, type, incoming = 1)
	var/in_cooldown = (alarms_to_show.len > 0 || alarms_to_clear.len > 0)
	if(incoming)
		alarms_to_show += message
		alarm_types_show[type] += 1
	else
		alarms_to_clear += message
		alarm_types_clear[type] += 1

	if(!in_cooldown)
		addtimer(CALLBACK(src, PROC_REF(showQueueAlarms)), 10 SECONDS)

/mob/living/silicon/proc/showQueueAlarms()
	var/list/messages = list()
	var/add_link = FALSE

	if(alarms_to_show.len)
		if(alarms_to_show.len < 5)
			messages += alarms_to_show
		else
			for(var/alarm_type in alarm_types_show)
				messages += "[uppertext(alarm_type)]: [alarm_types_show[alarm_type]] alarms detected."
			add_link = TRUE

		alarms_to_show.Cut()
		alarm_types_show.Cut()

	if(alarms_to_clear.len)
		if(messages.len)
			messages += "---"
		if(alarms_to_clear.len < 3)
			messages += alarms_to_clear
		else
			for(var/alarm_type in alarm_types_clear)
				messages += "[uppertext(alarm_type)]: [alarm_types_clear[alarm_type]] alarms cleared."
			add_link = TRUE

		alarms_to_clear.Cut()
		alarm_types_clear.Cut()

	if(messages.len)
		if(add_link)
			messages += "<a href=?_src_=usr;showalerts=1'>\[Show Alerts\]</a>"
		to_chat(src, jointext(messages, "<br>"))
