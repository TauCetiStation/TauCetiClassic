var/global/list/atom/movable/screen/all_plane_masters

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

/atom/movable/screen/plane_master/atom_init(mapload, client/client, map_view)
	if(!render_target && !no_render_target)
		render_target = PM_RENDER_NAME(type)

	if(map_view)
		assigned_map = map_view
		// flexible loc CORNER to CORNER should work too
		// don't use fixed size, it can break map_view scaling
		screen_loc = "[map_view]:1,1"

	apply_effects(client, map_view)

	client.screen += src

	if(!isnull(render_relay_planes))
		for(var/relay_plane in render_relay_planes)
			// here I assume that plane always exists with client and we don't need to destroy it,
			// so there is no need to keep render_plane_relay references anywhere except for client.screen
			// for outer maps we just cleanup it all at once based on assigned_map value
			client.screen += new /atom/movable/screen/render_plane_relay(null, client, src, relay_plane)

	return ..()

// Apply/update plane filters and other effects, can be called multiple times
/atom/movable/screen/plane_master/proc/apply_effects(client/client, map_view)
	SHOULD_CALL_PARENT(TRUE)

	clear_filters()

	if(!client)
		return FALSE

	return TRUE

/client/verb/init_plane_masters()
	world.log << "[src]|[ckey]"
	for(var/mytype in global.all_plane_masters)
		new mytype(null, src)
	mob.hud_used.update_parallax_pref()

/client/proc/update_plane_masters_effects(type, map_view)
	for(var/atom/movable/screen/plane_master/plane in screen)
		if(type && istype(plane, type))
			if(map_view && map_view != plane.assigned_map)
				continue
			plane.apply_effects(src)
