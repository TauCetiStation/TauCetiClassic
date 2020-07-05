/datum/event/radiation_storm
	announceWhen	= 1

/datum/event/radiation_storm/announce()
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange. The entire crew of the station is recommended to find shelter in the technical tunnels of the station. ", "Anomaly Alert", "radiation")

/datum/event/radiation_storm/start()
	make_maint_all_access(FALSE)
	SSweather.run_weather("radiation storm", ZTRAIT_STATION)
