// Where do we go when we reach the edge of a map
/datum/space_level/proc/get_next_z()
	if(!linkage)
		return null

	if(linkage == SELFLOOPING)
		return z_value

	if(linkage == CROSSLINKED) // crosslinked level can go to any other crosslinked level
		var/accessable_z_levels = list()

		for(var/Z in SSmapping.levels_by_trait(ZTRAIT_LINKAGE))
			var/datum/space_level/L = SSmapping.get_level(Z)
			if(L.linkage != CROSSLINKED)
				continue

			if(is_station_level(Z))
				accessable_z_levels["[Z]"] = 5
			else if(is_mining_level(Z))
				accessable_z_levels["[Z]"] = 10
			else if(SSmapping.level_trait(Z, ZTRAIT_SPACE_RUINS))
				accessable_z_levels["[Z]"] = 12
			else
				accessable_z_levels["[Z]"] = 40

		var/move_to_z = z_value
		var/safety = 1
		while(move_to_z == z_value)
			var/move_to_z_str = pickweight(accessable_z_levels)
			move_to_z = text2num(move_to_z_str)
			safety++
			if(safety > 10)
				break

		return move_to_z

	return null