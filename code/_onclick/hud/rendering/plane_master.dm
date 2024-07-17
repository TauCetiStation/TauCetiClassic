var/global/list/atom/movable/screen/default_plane_masters

// keeps PM and relays of main window to make them persist in case of client disconnects
// it's worth nothing to recreate them, it's just client object is too fickle and i need to work around it for proper init
// PMs for external maps like with map_view not contained here and handled separately
var/global/list/client_plane_masters = list()

INITIALIZE_IMMEDIATE(/atom/movable/screen/plane_master)
/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR

	plane = LOWEST_EVER_PLANE

	// blend mode to use when applying to the render relays (same as old blend_mode_override)
	blend_mode = BLEND_OVERLAY

	// what planes we will relay this plane render to
	// set to null if you don't want to render plane on anything (for example, if you want to use it for filters)
	// todo: make it associative list(PLANE = BLEND_MODE) if we ever need different blend_mode for different relays
	var/list/render_relay_planes = list(RENDER_PLANE_GAME)

	var/no_render_target = FALSE

/atom/movable/screen/plane_master/atom_init(mapload, map_view)
	. = ..()
	if(!render_target && !no_render_target)
		render_target = PM_RENDER_NAME(type)

	if(map_view)
		assigned_map = map_view
		// don't use fixed size, it can break map_view scaling
		screen_loc = "[map_view]:1,1"

/atom/movable/screen/plane_master/proc/generate_relays()
	. = list()
	if(!isnull(render_relay_planes))
		for(var/relay_plane in render_relay_planes)
			// here I assume that plane always exists with client and we don't need to destroy it,
			// so there is no need to keep render_plane_relay referenced anywhere except for client.screen
			// for outer maps we just cleanup it all at once based on assigned_map value
			var/atom/movable/screen/render_plane_relay/relay = new(null, src, relay_plane)

			. += relay

// Apply/update plane filters and other effects, can be called multiple times
/atom/movable/screen/plane_master/proc/update_effects(client/client)
	SHOULD_CALL_PARENT(TRUE)

	clear_filters()

	if(!client)
		return FALSE

	return TRUE

/* client side */

/client/proc/set_main_screen_plane_masters()
	if(!global.client_plane_masters[ckey])
		global.client_plane_masters[ckey] = list()

		for(var/mytype in global.default_plane_masters)
			var/atom/movable/screen/plane_master/PM = new mytype()
			global.client_plane_masters[ckey] += PM
			global.client_plane_masters[ckey] += PM.generate_relays()

	screen |= global.client_plane_masters[ckey]

/client/proc/update_plane_masters(type, map_view)
	for(var/atom/movable/screen/plane_master/plane in screen)
		if(type && !istype(plane, type))
			continue
		if(map_view && map_view != plane.assigned_map)
			continue
		plane.update_effects(src)
