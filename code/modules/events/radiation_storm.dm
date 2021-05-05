/datum/event/radiation_storm
	announceWhen	= 1
	announcement = new /datum/announcement/centcomm/anomaly/radstorm

/datum/event/radiation_storm/start()
	make_maint_all_access(FALSE)
	SSweather.run_weather("radiation storm", ZTRAIT_STATION)
