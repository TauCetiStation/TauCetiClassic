/datum/event/rain
	startWhen = 1
	endWhen = 90

/datum/event/rain/start()

	make_maint_all_access(FALSE)
	SSweather.run_weather("rain", 4)
