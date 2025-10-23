// debug stuff - remove later
/datum/weather/acid_rain/test
	name = "acid rain test"
	target_ztrait = ZTRAIT_STATION
	telegraph_duration = 10
	end_duration = 10
	protect_indoors = FALSE


/mob/verb/spawn_weather()
	set name = "Weather: Spawn Acid Rain"
	set desc = "Spawn Acid Rain."
	set category = "Debug"

	if(!check_rights(R_SPAWN))
		return
	var/mob/user = usr
	if(istype(user) && user.client)
		var/datum/weather/acid_rain/W = locate(/datum/weather/acid_rain/test) in SSweather.existing_weather
		if(!W)
			to_chat(user, "Weather: /datum/weather/acid_rain not found in SSweather.existing_weather")
			return

		if(W.stage == END_STAGE)
			to_chat(user, "Weather: acid_rain_test begins.")
			SSweather.run_weather("acid rain test", ZTRAIT_STATION)
		else if(W.stage < WIND_DOWN_STAGE)
			to_chat(user, "Weather: ending.")
			W.wind_down()
