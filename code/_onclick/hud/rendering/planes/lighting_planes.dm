// Plane master handling byond internal blackness
// 
// currently we don't use it, we need SEE_BLACKNESS to make it work
// without SEE_BLACKNESS byond just don't render anything on unseen tiles
// but SEE_BLACKNESS don't work with SIDE_MAP, so we need to make a choice
// also having it requires some hacks so i just commented it out
/*/atom/movable/screen/plane_master/blackness
	name = "darkness plane master"
	//plane = BLACKNESS_PLANE
	plane = 0
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	appearance_flags = parent_type::appearance_flags | PIXEL_SCALE*/

/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	// because of multiple different blends it more easy to apply client.color on the plane master
	// BUT we should disable client.color for any atoms that use lighting plane or plane 
	// that blends on it (uses LIGHTING_PLANE as render_relay_plane)
	// so we don't apply client.color twice (just add NO_CLIENT_COLOR to atom appearance_flags)
	appearance_flags = parent_type::appearance_flags & ~NO_CLIENT_COLOR // enables CLIENT_COLOR on plane

	invisibility = INVISIBILITY_LIGHTING

/atom/movable/screen/plane_master/lighting/update_effects(client/client)
	if(!..())
		return

	if(!assigned_map)
		update_alpha(value = client.mob.lighting_alpha)
		RegisterSignal(client.mob, COMSIG_MOB_LIGHTING_ALPHA_CHANGED, PROC_REF(update_alpha), override = TRUE)

	// about backdrops and why we need it https://www.byond.com/forum/?post=2141928
	if(assigned_map)
		// todo rewrite fullscreens
		var/atom/movable/screen/fullscreen/darkness/fs = new
		fs.set_map_view(assigned_map)
		client.screen += fs
	else
		client.mob.overlay_fullscreen("darkness", /atom/movable/screen/fullscreen/darkness)

/atom/movable/screen/plane_master/lighting/proc/update_alpha(mob/source, value)
	alpha = value

/atom/movable/screen/plane_master/dynamic_lighting
	name = "dynamic lighting plane master"
	plane = DYNAMIC_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_ADD
	render_relay_planes = list(LIGHTING_PLANE)

// second, simple and unsimulated, lighting system for environment lighting like starlight
// blends on lighting plane and illuminates masked turfs
// can be used for any global light, planetary sun/sky including
// for local environment lighting look for the plane below 
/atom/movable/screen/plane_master/environment_lighting
	name = "environment lighting plane master"
	plane = ENVIRONMENT_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_ADD
	render_relay_planes = list(LIGHTING_PLANE)

	var/atom/movable/screen/fullscreen/environment_lighting_color/color_filter

/atom/movable/screen/plane_master/environment_lighting/update_effects(client/client)
	if(!..())
		return

	add_filter("guassian_blur", 1, gauss_blur_filter(10))

	if(assigned_map)
		// todo rewrite fullscreens
		var/atom/movable/screen/fullscreen/environment_lighting_color/fs = new
		fs.set_map_view(assigned_map)
		fs.attach_to_level(client.mob.z) // placeholder color before i think about a way to set it as camera.z level
		client.screen += fs
	else
		// by default every z-level has one object as environment color holder
		// we place it on user screen to color plane globally
		color_filter = client.mob.overlay_fullscreen("environment_lighting_color", /atom/movable/screen/fullscreen/environment_lighting_color)

		if(client.mob.z)
			color_filter.attach_to_level(client.mob.z)

		RegisterSignal(client.mob, COMSIG_MOB_Z_CHANGED, PROC_REF(update_level), override = TRUE)

/atom/movable/screen/plane_master/environment_lighting/proc/update_level(mob/source, new_z)
	if(color_filter)
		color_filter.attach_to_level(new_z)

/atom/movable/screen/plane_master/environment_lighting/Destroy()
	QDEL_NULL(color_filter)
	return ..()

// for local environment lighting, can be used for areas
// currently we blend it at environment_lighting first just to use same blur filter
/atom/movable/screen/plane_master/environment_lighting_local
	name = "environment lighting local plane master"
	plane = ENVIRONMENT_LIGHTING_LOCAL_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_ADD
	render_relay_planes = list(ENVIRONMENT_LIGHTING_PLANE)

/atom/movable/screen/plane_master/exposure
	name = "exposure plane master"
	plane = LIGHTING_EXPOSURE_PLANE
	appearance_flags = parent_type::appearance_flags | PIXEL_SCALE
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	invisibility = INVISIBILITY_LIGHTING

/atom/movable/screen/plane_master/exposure/update_effects(client/client)
	if(!..())
		return

	var/enabled = client.prefs?.lampsexposure || FALSE

	if(enabled)
		alpha = 255
		add_filter("blur_exposure", 1, gauss_blur_filter(size = 20)) // by refs such blur is heavy, but tests were okay and this allow us more flexibility with setup. Possible point for improvements
	else
		alpha = 0

#define LIGHTING_LAMPS_RENDER_TARGET PM_RENDER_NAME(/atom/movable/screen/plane_master/lamps)

/atom/movable/screen/plane_master/lamps_selfglow
	name = "lamps selfglow plane master"
	plane = LIGHTING_LAMPS_SELFGLOW
	blend_mode = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	invisibility = INVISIBILITY_LIGHTING

/atom/movable/screen/plane_master/lamps_selfglow/update_effects(client/client)
	if(!..())
		return

	var/level = client.prefs?.glowlevel || FALSE

	if(isnull(level))
		return

	var/bloomsize = 0
	var/bloomoffset = 0
	switch(level)
		if(GLOW_LOW)
			bloomsize = 2
			bloomoffset = 1
		if(GLOW_MED)
			bloomsize = 3
			bloomoffset = 2
		if(GLOW_HIGH)
			bloomsize = 5
			bloomoffset = 3
		else
			return

	add_filter("add_lamps_to_selfglow", 1, layering_filter(render_source = LIGHTING_LAMPS_RENDER_TARGET, blend_mode = BLEND_OVERLAY))
	add_filter("lamps_selfglow_bloom", 1, bloom_filter(threshold = "#aaaaaa", size = bloomsize, offset = bloomoffset, alpha = 100))

/atom/movable/screen/plane_master/lamps
	name = "lamps plane master"
	plane = LIGHTING_LAMPS_PLANE
	blend_mode = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lamps_glare
	name = "lamps glare plane master"
	plane = LIGHTING_LAMPS_GLARE
	blend_mode = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/screen/plane_master/lamps_glare/update_effects(client/client)
	if(!..())
		return

	var/enabled = client.prefs?.lampsglare || FALSE

	if(enabled)
		add_filter("add_lamps_to_glare", 1, layering_filter(render_source = LIGHTING_LAMPS_RENDER_TARGET, blend_mode = BLEND_OVERLAY))
		add_filter("lamps_glare", 1, radial_blur_filter(size = 0.05))

#undef LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/above_lighting
	name = "above lighting plane master"
	plane = ABOVE_LIGHTING_PLANE
	blend_mode = BLEND_OVERLAY
