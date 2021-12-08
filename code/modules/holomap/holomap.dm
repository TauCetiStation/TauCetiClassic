var/global/list/holochips = list()
var/global/image/default_holomap = null
var/global/list/holomap_cache = list()
var/global/list/holomap_landmarks = list()    //List for shuttles and other stuff that might be useful

// Transport layers (frequency/encryption pairs) for predefined holochips

var/global/list/nuclear_transport_layer = list()
var/global/list/ert_transport_layer = list()
var/global/list/deathsquad_transport_layer = list()
var/global/list/vox_transport_layer = list()

/datum/action/toggle_holomap
	name = "Toggle holomap"
	check_flags = AB_CHECK_ALIVE
	action_type = AB_INNATE

/datum/action/toggle_holomap/Activate()
	to_chat(owner, "<span class='notice'>You activate the holomap.</span>")
	var/obj/item/holochip/target_holochip = target
	target_holochip.activate_holomap(owner)
	target_holochip = null
	active = TRUE

/datum/action/toggle_holomap/Deactivate()
	var/obj/item/holochip/target_holochip = target
	target_holochip.deactivate_holomap()
	target_holochip = null
	to_chat(owner, "<span class='notice'>You deactivate the holomap.</span>")
	active = FALSE

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

/proc/generate_holochip_encryption()		// Here we generate unique combinations of frequency/encryption for each predefined holochip sets
	nuclear_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))
	ert_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))
	deathsquad_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))
	vox_transport_layer = list(frequency = rand(1200,1600), encryption = rand(1,100))

#define COLOR_HMAP_DEAD "#d3212d"
#define COLOR_HMAP_INCAPACITATED "#ffef00"
#define COLOR_HMAP_DEFAULT "#006e4e"
#define HOLOMAP_MAGIC_NUMBER 16    // Offset for correct placement of markers on holomap.

/proc/process_holomap_markers()
	for(var/obj/item/holochip/HC in global.holochips)
		var/turf/marker_location = get_turf(HC)
		if(!is_station_level(marker_location.z))
			continue
		if(!iscarbon(HC.holder.loc))
			continue
		var/mob/living/carbon/C = HC.holder.loc
		if(C.head != HC.holder)
			continue
		if(!(HC in global.holomap_cache) || !global.holomap_cache[HC])
			var/image/NI = image(HC.holder.icon, icon_state = HC.holder.icon_state)
			NI.transform /= 2
			global.holomap_cache[HC] = NI
		var/image/I = global.holomap_cache[HC]
		I.filters = null
		if(C.stat == DEAD)
			I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_DEAD)
		else if(C.stat == UNCONSCIOUS || C.incapacitated())
			I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_INCAPACITATED)
		else
			I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_DEFAULT)
		I.pixel_x = (marker_location.x - 16) * PIXEL_MULTIPLIER
		I.pixel_y = (marker_location.y - 16) * PIXEL_MULTIPLIER
		I.plane = HUD_PLANE
		I.layer = HUD_LAYER
	for(var/obj/machinery/computer/shuttle in holomap_landmarks)
		var/turf/marker_location = get_turf(shuttle)
		if(!is_station_level(marker_location.z))
			continue
		if(istype(shuttle, /obj/machinery/computer/syndicate_station))
			if(!(shuttle in global.holomap_cache) || !global.holomap_cache[shuttle])
				global.holomap_cache[shuttle] = image('icons/holomaps/holomap_markers_32x32.dmi', "skipjack")
		else if(istype(shuttle, /obj/machinery/computer/vox_stealth))
			if(!(shuttle in global.holomap_cache) || !global.holomap_cache[shuttle])
				global.holomap_cache[shuttle] = image('icons/holomaps/holomap_markers_32x32.dmi', "syndishuttle")
		var/image/I = global.holomap_cache[shuttle]
		I.pixel_x = (marker_location.x - HOLOMAP_MAGIC_NUMBER) * PIXEL_MULTIPLIER
		I.pixel_y = (marker_location.y - HOLOMAP_MAGIC_NUMBER) * PIXEL_MULTIPLIER
		I.plane = HUD_PLANE
		I.layer = HUD_LAYER

#undef COLOR_HMAP_DEAD
#undef COLOR_HMAP_INCAPACITATED
#undef COLOR_HMAP_DEFAULT
