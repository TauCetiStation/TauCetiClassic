var/global/list/holochips = list()
var/global/image/default_holomap = null

// Transport layers (frequency/encryption pairs) for predefined holochips

var/global/list/nuclear_transport_layer = list()
var/global/list/ert_transport_layer = list()
var/global/list/deathsquad_transport_layer = list()

/datum/action/toggle_holomap
	name = "Toggle holomap"
	//check_flags = AB_CHECK_ALIVE

#define HOLOMAP_WALKABLE_TILE "#66666699"
#define HOLOMAP_CONCRETE_TILE "#FFFFFFDD"

/proc/generate_holo_map()
	var/icon/holomap = icon('icons/holomaps/canvas.dmi', "blank")
	var/turf/center = locate(world.maxx/2, world.maxy/2, SSmapping.level_by_trait(ZTRAIT_STATION))
	if(!center)
		return
	var/list/turf/turfs = RANGE_TURFS(world.maxx/2, center)
	for(var/turf/T in turfs)
		if (istype(T, /turf/simulated/floor) || istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle/floor))
			holomap.DrawBox(HOLOMAP_WALKABLE_TILE, T.x, T.y)
		if(istype(T, /turf/simulated/wall) || istype(T, /turf/unsimulated/wall) || locate(/obj/structure/grille) in T || locate(/obj/structure/window) in T)
			holomap.DrawBox(HOLOMAP_CONCRETE_TILE, T.x, T.y)
	return holomap

#undef HOLOMAP_WALKABLE_TILE
#undef HOLOMAP_CONCRETE_TILE

/proc/generate_tls()		// Here we generate unique combinations of frequency/encryption for each predefined holochip sets
	nuclear_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))
	ert_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))
	deathsquad_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))
