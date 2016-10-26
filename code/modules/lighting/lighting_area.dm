/area
	luminosity           = TRUE
	var/dynamic_lighting = TRUE

/area/New()
	. = ..()

	if(dynamic_lighting)
		luminosity = FALSE

/atom/proc/change_area(area/old_area, area/new_area)
	return
