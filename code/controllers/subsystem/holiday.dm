SUBSYSTEM_DEF(holiday)
	name = "Holiday"
	init_order = SS_INIT_HOLIDAY
	flags = SS_NO_FIRE
	var/list/holidays

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
			if(!holidays)
				holidays = list()
			holidays[holiday.name] = holiday

	if(holidays)
		world.update_status()

	return ..()
