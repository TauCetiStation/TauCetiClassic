/datum/map_template/shelter
	var/shelter_id
	var/description
	var/blacklisted_turfs
	var/whitelisted_turfs
	var/banned_areas

/datum/map_template/shelter/New()
	. = ..()
	blacklisted_turfs = typecacheof(/turf/unsimulated)
	blacklisted_turfs += typecacheof(/turf/simulated/mineral)
	blacklisted_turfs += typecacheof(/turf/simulated/shuttle)
	blacklisted_turfs += typecacheof(/turf/simulated/wall)
	whitelisted_turfs = list()
	banned_areas = typecacheof(/area/shuttle)
	banned_areas += typecacheof(/area/station/civilian/holodeck)
	banned_areas += typecacheof(/area/shuttle/vox)
	banned_areas += typecacheof(/area/shuttle/syndicate)
	banned_areas += typecacheof(/area/shuttle/supply)

/datum/map_template/shelter/proc/id()
	if(shelter_id)
		return shelter_id
	else
		return null

/datum/map_template/shelter/proc/check_deploy(turf/deploy_location)
	var/affected = get_affected_turfs(deploy_location, centered=TRUE)
	for(var/turf/T in affected)
		var/area/A = get_area(T)
		if(is_type_in_typecache(A, banned_areas))
			return SHELTER_DEPLOY_BAD_AREA

		var/banned = is_type_in_typecache(T, blacklisted_turfs)
		var/permitted = is_type_in_typecache(T, whitelisted_turfs)
		if(banned && !permitted)
			return SHELTER_DEPLOY_BAD_TURFS

		for(var/obj/O in T)
			if(O.density && O.anchored)
				return SHELTER_DEPLOY_ANCHORED_OBJECTS
	return SHELTER_DEPLOY_ALLOWED

/datum/map_template/shelter/New()
	. = ..()
	whitelisted_turfs = typecacheof(/turf/simulated/mineral)

/datum/map_template/shelter/alpha
	name = "Shelter Alpha"
	shelter_id = "shelter_alpha"
	description = "A cosy self-contained pressurized shelter, with built-in navigation, entertainment, medical facilities and a sleeping area! Order now, and we'll throw in a TINY FAN, absolutely free!"
	mappath = "maps/templates/shelter_1.dmm"

/datum/map_template/shelter/beta
	name = "Shelter Beta"
	shelter_id = "shelter_beta"
	description = "Good, convenient shelter. Suitable for survival."
	mappath = "maps/templates/shelter_2.dmm"

/datum/map_template/shelter/gamma
	name = "Shelter Gamma"
	shelter_id = "shelter_gamma"
	description = "Rare and expensive shelter. Hmm, maybe invite my friends to a party?"
	mappath = "maps/templates/shelter_3.dmm"
