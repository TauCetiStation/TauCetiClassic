// environment lighting - second unsimulated lighting system for z-levels and areas
// still WiP and need some sorting
//
// todo:
// * move level color holder to SSenviromnent and merge SSenviromnent into SSmapping
// * add better instruments to create /area/ lighting
//   * update get_lumcount to properly count lums from the area
// * update Set Level Light verb and add animation setup
// * more globally - update parallax, do better blending

// z-level mask we use to apply environment color for clients
// done as a separate effect so we can change it in a centralised way and apply animations
/obj/effect/level_color_holder
	name = "environment_lighting_holder"
	icon = 'icons/hud/screen1_full.dmi'
	icon_state = "white"
	plane = ENVIRONMENT_LIGHTING_PLANE
	appearance_flags = NO_CLIENT_COLOR | PIXEL_SCALE
	var/locked = FALSE

// shared image we use as a mask for environment turfs
var/global/image/level_light_mask = create_level_light_mask() // global
/proc/create_level_light_mask()
	var/image/I = image('icons/blank.dmi', "white")
	I.plane = ENVIRONMENT_LIGHTING_PLANE

	return I

// standart mask for /area/ without dynamic lighting, just to make it look smoother at borders
var/global/obj/effect/area_unsimulated_light_mask = create_area_light_mask()

// creates mask you can use as area overlay to add local environment lighting
/proc/create_area_light_mask(color)
	var/obj/effect/E = new
	E.icon = 'icons/blank.dmi'
	E.icon_state = "white"
	E.plane = ENVIRONMENT_LIGHTING_LOCAL_PLANE
	E.appearance_flags = NO_CLIENT_COLOR | PIXEL_SCALE

	if(color)
		E.color = color

	return E

// adds level lighting mask to turfs around if any level_light_source nearby
// SSlighting does this once globally during initialization
/turf/proc/recast_level_light(old)
	if(!SSlighting.initialized)
		return

	for(var/turf/T as anything in RANGE_TURFS(1, src))
		if(T.level_light_source) // source turfs should be already masked by atom_init
			continue
		if(T.opacity || T.has_opaque_atom)
			continue
		var/has_level_source_around = FALSE
		for(var/turf/T2 in RANGE_TURFS(1, T))
			if(T2.level_light_source && !T2.has_opaque_atom)
				has_level_source_around = TRUE
				break
		if(has_level_source_around)
			ENABLE_LEVEL_LIGHTING(T)
		else
			DISABLE_LEVEL_LIGHTING(T)
