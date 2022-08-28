/datum/environment/space
	name = ENV_TYPE_SPACE

	turf_type = /turf/environment/space
	turf_light_color = COLOR_WHITE

/datum/environment/snow
	name = ENV_TYPE_SNOW

	turf_type = /turf/environment/snow
	gen_type = /datum/map_generator/snow
	turf_light_color = COLOR_BLUE
	area_type = /area/space/snow
	has_weather = TRUE

/datum/environment/trash
	name = ENV_TYPE_TRASH

	turf_type = /turf/environment/ironsand
	gen_type = /datum/map_generator/junkyard
	area_type = /area/space/junk
	has_weather = TRUE
