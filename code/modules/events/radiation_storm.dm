/datum/event/radiation_storm
	announceWhen	= 1


/datum/event/radiation_storm/announce()

var/global/block_maintenance_off = FALSE

/datum/event/radiation_storm/start()
	command_alert("High levels of radiation detected near the station. Please report to the Med-bay if you feel strange. The entire crew of the station is recommended to find shelter in the technical tunnels of the station. ", "Anomaly Alert", "radiation")
	unbolt_maintenance()
	make_maint_all_access(FALSE)
	global.block_maintenance_off = TRUE
	SSweather.run_weather("radiation storm", ZTRAIT_STATION)
	block_maintenance_off = FALSE
