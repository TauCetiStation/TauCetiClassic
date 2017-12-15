/datum/event/radiation_storm
	announceWhen	= 1
	oneShot			= 1


/datum/event/radiation_storm/announce()


/datum/event/radiation_storm/start()
	world << sound('sound/AI/radiation.ogg')
	command_alert("High levels of radiation detected near the station. Please evacuate into one of the shielded maintenance tunnels.", "Anomaly Alert")
	make_maint_all_access(FALSE)
	SSweather.run_weather("radiation storm",ZLEVEL_STATION)