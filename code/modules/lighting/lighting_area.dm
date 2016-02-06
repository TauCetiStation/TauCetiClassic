/area
	luminosity           = TRUE
	var/dynamic_lighting = TRUE

/area/New()
	. = ..()

	if(dynamic_lighting)
		luminosity = FALSE

/atom/proc/change_area(var/area/old_area, var/area/new_area)
	return
