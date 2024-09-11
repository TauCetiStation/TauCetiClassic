SUBSYSTEM_DEF(holiday)
	name = "Holiday"
	init_order = SS_INIT_HOLIDAY
	flags = SS_NO_FIRE
	var/list/datum/holiday/holidays = list()
	var/list/staffwho_prefix = list()

/datum/controller/subsystem/holiday/Initialize(start_timeofday)
	if(!config.allow_holidays)
		return ..() //Holiday stuff was not enabled in the config!

	var/YY = text2num(time2text(world.timeofday, "YY"))
	var/MM = text2num(time2text(world.timeofday, "MM"))
	var/DD = text2num(time2text(world.timeofday, "DD"))

	for(var/H in subtypesof(/datum/holiday))
		var/datum/holiday/holiday = new H
		if(holiday.shouldCelebrate(DD, MM, YY))
			holiday.celebrate()
			holidays[holiday.name] = holiday

	if(length(holidays))
		world.update_status()

	return ..()

/datum/controller/subsystem/holiday/proc/get_staffwho_prefix(ckey)
	if(staffwho_prefix[ckey])
		return staffwho_prefix[ckey]
	if(!length(holidays))
		return ""
	staffwho_prefix[ckey] = pick(holidays[holidays[1]].staffwho_prefixs)
	return staffwho_prefix[ckey]

/datum/controller/subsystem/holiday/proc/get_no_staff_text()
	if(!length(holidays))
		return ""
	return holidays[holidays[1]].staffwho_no_staff

/datum/controller/subsystem/holiday/proc/get_admin_name(group)
	if(!length(holidays))
		return default_admin_names[group]
	if(!holidays[holidays[1]].staffwho_group_name)
		return default_admin_names[group]
	return holidays[holidays[1]].staffwho_group_name[group]
