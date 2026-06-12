//Used to process holomaps and other holomap-related stuff
SUBSYSTEM_DEF(holomaps)
	name = "Holomaps"
	init_order    = SS_INIT_HOLOMAPS
	priority      = SS_PRIORITY_HOLOMAPS
	wait          = SS_WAIT_HOLOMAPS

	var/list/processing = list()
	var/list/currentrun = list()

	var/list/image/holomaps = list()

	var/list/holochips = list()

	var/list/holomap_cache = list()
	var/list/holomap_landmarks = list()    //List for shuttles and other stuff that might be useful

	// layers (frequency/encryption pairs) for predefined holochips

	var/list/nuclear_transport_layer = list()
	var/list/ert_transport_layer = list()
	var/list/deathsquad_transport_layer = list()
	var/list/vox_transport_layer = list()

/datum/controller/subsystem/holomaps/Initialize(timeofday)

	holomaps["default"] = image(generate_holo_map())
	generate_holochip_encryption()

	..()

/datum/controller/subsystem/holomaps/stat_entry()
	..("P:[processing.len]")

/datum/controller/subsystem/holomaps/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/datum/thing = currentrun[currentrun.len]
		currentrun.len--

		if(QDELETED(thing))
			processing -= thing
		else
			thing.process(wait * 0.1)

		if (MC_TICK_CHECK)
			return

	process_holomap_markers()

#define HOLOMAP_WALKABLE_TILE "#66666699"
#define HOLOMAP_CONCRETE_TILE "#FFFFFFDD"

/datum/controller/subsystem/holomaps/proc/get_default_holomap()
	return get_custom_holomap("default")

/datum/controller/subsystem/holomaps/proc/get_custom_holomap(key)
	if(!holomaps[key])
		holomaps[key] = image(generate_holo_map())

	return holomaps[key]

/datum/controller/subsystem/holomaps/proc/regenerate_custom_holomap(key)
	holomaps[key] = image(generate_holo_map())
	SEND_SIGNAL(SSholomaps, COMSIG_HOLOMAP_REGENERATED, key)

/datum/controller/subsystem/holomaps/proc/generate_holo_map()
	var/icon/holomap = icon('icons/holomaps/canvas.dmi', "blank")
	var/turf/center = locate(world.maxx/2, world.maxy/2, SSmapping.level_by_trait(ZTRAIT_STATION))
	if(!center)
		return
	var/list/turf/turfs = RANGE_TURFS(world.maxx/2, center)
	for(var/turf/T as anything in turfs)
		if (isfloorturf(T) || istype(T, /turf/unsimulated/floor) || istype(T, /turf/simulated/shuttle/floor))
			holomap.DrawBox(HOLOMAP_WALKABLE_TILE, T.x, T.y)
		if(iswallturf(T) || istype(T, /turf/unsimulated/wall) || locate(/obj/structure/grille) in T || locate(/obj/structure/window) in T || locate(/obj/structure/object_wall) in T)
			holomap.DrawBox(HOLOMAP_CONCRETE_TILE, T.x, T.y)
	return holomap

#undef HOLOMAP_WALKABLE_TILE
#undef HOLOMAP_CONCRETE_TILE

/datum/controller/subsystem/holomaps/proc/generate_holochip_encryption()		// Here we generate unique combinations of frequency/encryption for each predefined holochip sets
	//We need frequency in TEXT and encryption in NUMBER
	nuclear_transport_layer = list(frequency = num2text(rand(1200,1600)), encryption = rand(1,1000))
	ert_transport_layer = list(frequency = num2text(rand(1200,1600)), encryption = rand(1,1000))
	deathsquad_transport_layer = list(frequency = num2text(rand(1200,1600)), encryption = rand(1,1000))
	vox_transport_layer = list(frequency = num2text(rand(1200,1600)), encryption = rand(1,1000))

#define COLOR_HMAP_DEAD "#d3212d"
#define COLOR_HMAP_INCAPACITATED "#ffef00"
#define COLOR_HMAP_DEFAULT "#006e4e"
#define HOLOMAP_OFFSET 16 //Offset for correct placement of markers on holomap. 32 is normal turf, we need center, so 16

/datum/controller/subsystem/holomaps/proc/process_holomap_markers()
	for(var/freq in SSholomaps.holochips)
		for(var/obj/item/holochip/HC in SSholomaps.holochips[freq])
			var/turf/marker_location = get_turf(HC.holder)
			if(!marker_location)
				stack_trace("[HC.holder] | [HC.holder.loc] | [HC.frequency] without turf.")
				continue
			if(!is_station_level(marker_location.z))
				continue
			if(!HC.holder || !iscarbon(HC.holder.loc))
				continue
			var/mob/living/carbon/C = HC.holder.loc
			if(C.head != HC.holder)
				continue
			var/image/I = holomap_cache[HC]
			if(!I)
				var/image/NI = image(HC.holder.icon, icon_state = HC.holder.icon_state)
				NI.transform /= 2.5
				SSholomaps.holomap_cache[HC] = NI
				I = NI
				continue
			I.filters = null
			if(C.stat == DEAD)
				I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_DEAD)
			else if(C.stat == UNCONSCIOUS || C.incapacitated())
				I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_INCAPACITATED)
			else
				I.filters += filter(type = "outline", size = 1, color = COLOR_HMAP_DEFAULT)
			I.pixel_x = (marker_location.x - HOLOMAP_OFFSET) * PIXEL_MULTIPLIER
			I.pixel_y = (marker_location.y - HOLOMAP_OFFSET) * PIXEL_MULTIPLIER
	for(var/obj/machinery/computer/shuttle in holomap_landmarks)
		var/turf/marker_location = get_turf(shuttle)
		if(!marker_location)
			stack_trace("[shuttle.type] without turf.")
			continue
		if(!is_station_level(marker_location.z))
			continue
		if(istype(shuttle, /obj/machinery/computer/syndicate_station))
			if(!(holomap_cache[shuttle]))//shuttle in holomap_cache))
				holomap_cache[shuttle] = image('icons/holomaps/holomap_markers_32x32.dmi', "syndishuttle")
		else if(istype(shuttle, /obj/machinery/computer/vox_stealth))
			if(!(holomap_cache[shuttle]))//shuttle in holomap_cache))
				holomap_cache[shuttle] = image('icons/holomaps/holomap_markers_32x32.dmi', "skipjack")
		var/image/I = holomap_cache[shuttle]
		I.pixel_x = (marker_location.x - HOLOMAP_OFFSET) * PIXEL_MULTIPLIER
		I.pixel_y = (marker_location.y - HOLOMAP_OFFSET) * PIXEL_MULTIPLIER

#undef COLOR_HMAP_DEAD
#undef COLOR_HMAP_INCAPACITATED
#undef COLOR_HMAP_DEFAULT
