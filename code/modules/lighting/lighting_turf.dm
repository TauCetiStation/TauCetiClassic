// Causes any affecting light sources to be queued for a visibility update, for example a door got opened.
/turf/proc/reconsider_lights()
	lighting_corner_NE?.vis_update()
	lighting_corner_SE?.vis_update()
	lighting_corner_SW?.vis_update()
	lighting_corner_NW?.vis_update()

/turf/proc/lighting_clear_overlay()
	if(!lighting_object)
		return

	qdel(lighting_object, TRUE) //Shitty fix for lighting objects persisting after death

/turf/proc/lighting_build_overlay()
	if(lighting_object)
		return

	new/atom/movable/lighting_object(src)

// Used to get a scaled lumcount.
/turf/proc/get_lumcount(minlum = 0, maxlum = 1)
	var/area/A = loc
	if(!A.dynamic_lighting) // white unsim area
		// todo: do proper calculation of lums from area overlay
		return 1

	var/static_lums = 0
	if(level_light_source && SSmapping.initialized) // todo: casts
		var/datum/space_level/SL = SSmapping.z_list[z]
		static_lums = GET_LUM_FROM_COLOR(SL.color_holder)

	var/total_dynamic_lums = 0
	var/datum/lighting_corner/L
	L = lighting_corner_NE
	if (L)
		total_dynamic_lums += L.lum_r + L.lum_b + L.lum_g
	L = lighting_corner_SE
	if (L)
		total_dynamic_lums += L.lum_r + L.lum_b + L.lum_g
	L = lighting_corner_SW
	if (L)
		total_dynamic_lums += L.lum_r + L.lum_b + L.lum_g
	L = lighting_corner_NW
	if (L)
		total_dynamic_lums += L.lum_r + L.lum_b + L.lum_g

	total_dynamic_lums /= 12 // 4 corners, each with 3 channels, get the average.

	total_dynamic_lums = (max(total_dynamic_lums, static_lums) - minlum) / (maxlum - minlum)

	return CLAMP01(total_dynamic_lums)

// Can't think of a good name, this proc will recalculate the has_opaque_atom variable.
/turf/proc/recalc_atom_opacity()
	has_opaque_atom = opacity
	if (!has_opaque_atom)
		for (var/atom/A in src.contents) // Loop through every movable atom on our tile PLUS ourselves (we matter too...)
			if (A.opacity)
				has_opaque_atom = TRUE
				break

/turf/proc/change_area(area/old_area, area/new_area)
	if(SSlighting.initialized)
		if (new_area.dynamic_lighting != old_area.dynamic_lighting)
			if (new_area.dynamic_lighting)
				lighting_build_overlay()
			else
				lighting_clear_overlay()

/turf/proc/generate_missing_corners()
	if (!lighting_corner_NE)
		lighting_corner_NE = new/datum/lighting_corner(src, NORTH|EAST)
	
	if (!lighting_corner_SE)
		lighting_corner_SE = new/datum/lighting_corner(src, SOUTH|EAST)
	
	if (!lighting_corner_SW)
		lighting_corner_SW = new/datum/lighting_corner(src, SOUTH|WEST)
	
	if (!lighting_corner_NW)
		lighting_corner_NW = new/datum/lighting_corner(src, NORTH|WEST)
	
	lighting_corners_initialised = TRUE

