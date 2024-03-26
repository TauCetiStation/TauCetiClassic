/area/proc/set_dynamic_lighting(new_dynamic_lighting = TRUE)
	if (new_dynamic_lighting == dynamic_lighting)
		return FALSE

	dynamic_lighting = new_dynamic_lighting

	if(dynamic_lighting)
		for(var/turf/T in src)
			T.lighting_build_overlay()
	else
		for(var/turf/T in src)
			if(T.lighting_object)
				T.lighting_clear_overlay()

	return TRUE
