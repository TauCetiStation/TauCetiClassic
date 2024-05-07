/atom/movable/screen/plane_master
	screen_loc = "CENTER"
	icon_state = "blank"
	appearance_flags = PLANE_MASTER|NO_CLIENT_COLOR
	blend_mode = BLEND_OVERLAY

	//--rendering relay vars--
	///integer: what plane we will relay this planes render to
	var/render_relay_plane = RENDER_PLANE_MASTER
	///bool: Whether this plane should get a render target automatically generated
	var/generate_render_target = TRUE
	///integer: blend mode to apply to the render relay in case you dont want to use the plane_masters blend_mode
	var/blend_mode_override
	///reference: current relay this plane is utilizing to render
	var/atom/movable/render_plane_relay/relay

	var/hidden_for_user = FALSE

//Why do plane masters need a backdrop sometimes? Read https://secure.byond.com/forum/?post=2141928
//Trust me, you need one. Period. If you don't think you do, you're doing something extremely wrong.
/atom/movable/screen/plane_master/proc/backdrop(mob/mymob)
	SHOULD_CALL_PARENT(TRUE)
	if(!isnull(render_relay_plane))
		relay_render_to_plane(mymob, render_relay_plane)
	apply_effects(mymob)

//For filters and other effects
/atom/movable/screen/plane_master/proc/apply_effects(mob/mymob, iscamera = FALSE)
	return

///Level below the floor, for undertile component
/atom/movable/screen/plane_master/underfloor
	name = "underfloor plane master"
	plane = UNDERFLOOR_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/game_world/apply_effects(mob/mymob, iscamera = FALSE)
	remove_filter("AO")
	if(istype(mymob) && mymob?.client?.prefs?.ambientocclusion)
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/game_world_above
	name = "above game world plane master"
	plane = ABOVE_GAME_PLANE
	render_relay_plane = GAME_PLANE
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/seethrough
	name = "seethrough plane master"
	plane = SEETHROUGH_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/ghost
	name = "ghost plane master"
	plane = GHOST_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/ghost_illusion
	name = "ghost illusion plane master"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GHOST_ILLUSION_PLANE
	render_relay_plane = RENDER_PLANE_ABOVE_GAME

/atom/movable/screen/plane_master/ghost_illusion/apply_effects(mob/mymob, iscamera = FALSE)
	remove_filter("ghost_illusion")
	add_filter("ghost_illusion", 1, motion_blur_filter(x = 3, y = 3))

/atom/movable/screen/plane_master/point
	name = "point plane master"
	plane = POINT_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

/**
 * Plane master handling byond internal blackness
 * vars are set as to replicate behavior when rendering to other planes
 * do not touch this unless you know what you are doing
 */
/atom/movable/screen/plane_master/blackness
	name = "darkness plane master"
	plane = BLACKNESS_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blend_mode = BLEND_MULTIPLY
	appearance_flags = parent_type::appearance_flags | PIXEL_SCALE
	//byond internal end
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME
	// because of multiple different blends it more easy to apply client.color on the plane master
	// BUT we should disable client.color for any atoms that use lighting plane or plane 
	// that blends on it (uses LIGHTING_PLANE as render_relay_plane)
	// so we don't apply client.color twice (just add NO_CLIENT_COLOR to atom appearance_flags)
	appearance_flags = parent_type::appearance_flags & ~NO_CLIENT_COLOR // enables CLIENT_COLOR on plane

	invisibility = INVISIBILITY_LIGHTING

/atom/movable/screen/plane_master/lighting/apply_effects(mob/mymob, iscamera = FALSE)
	if(!istype(mymob))
		return

	mymob.overlay_fullscreen("darkness", /atom/movable/screen/fullscreen/darkness)

/atom/movable/screen/plane_master/dynamic_lighting
	name = "dynamic lighting plane master"
	plane = DYNAMIC_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = LIGHTING_PLANE
	blend_mode_override = BLEND_ADD
	render_target = DYNAMIC_LIGHTING_RENDER_TARGET

/atom/movable/screen/plane_master/exposure
	name = "exposure plane master"
	plane = LIGHTING_EXPOSURE_PLANE
	appearance_flags = parent_type::appearance_flags | PIXEL_SCALE
	blend_mode = BLEND_ADD
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

	invisibility = INVISIBILITY_LIGHTING

/atom/movable/screen/plane_master/exposure/apply_effects(mob/mymob, iscamera = FALSE)
	remove_filter("blur_exposure")
	if(!istype(mymob))
		return

	var/enabled = mymob?.client?.prefs?.lampsexposure || FALSE

	if(enabled)
		alpha = 255
		add_filter("blur_exposure", 1, gauss_blur_filter(size = 20)) // by refs such blur is heavy, but tests were okay and this allow us more flexibility with setup. Possible point for improvements
	else
		alpha = 0

/atom/movable/screen/plane_master/lamps_selfglow
	name = "lamps selfglow plane master"
	plane = LIGHTING_LAMPS_SELFGLOW
	blend_mode = BLEND_ADD
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

	invisibility = INVISIBILITY_LIGHTING

/atom/movable/screen/plane_master/lamps_selfglow/apply_effects(mob/mymob, iscamera = FALSE)
	remove_filter("add_lamps_to_selfglow")
	remove_filter("lamps_selfglow_bloom")

	if(!istype(mymob))
		return

	var/level = mymob?.client?.prefs?.glowlevel || FALSE

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
	blend_mode_override = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

	render_target = LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps_glare
	name = "lamps glare plane master"
	plane = LIGHTING_LAMPS_GLARE
	blend_mode_override = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/lamps_glare/apply_effects(mob/mymob, iscamera = FALSE)
	remove_filter("add_lamps_to_glare")
	remove_filter("lamps_glare")

	if(!istype(mymob))
		return

	var/enabled = mymob?.client?.prefs?.lampsglare || FALSE

	if(enabled)
		add_filter("add_lamps_to_glare", 1, layering_filter(render_source = LIGHTING_LAMPS_RENDER_TARGET, blend_mode = BLEND_OVERLAY))
		add_filter("lamps_glare", 1, radial_blur_filter(size = 0.05))

// second, simple and unsimulated, lighting system for environment lighting like starlight
// blends on lighting plane and illuminates masked turfs
// can be used for any global light, planetary sun/sky including
// for local environment lighting look for the plane below 
/atom/movable/screen/plane_master/environment_lighting
	name = "environment lighting plane master"
	plane = ENVIRONMENT_LIGHTING_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = DYNAMIC_LIGHTING_PLANE
	blend_mode_override = BLEND_ADD

	var/atom/movable/screen/fullscreen/environment_lighting_color/color_filter

/atom/movable/screen/plane_master/environment_lighting/apply_effects(mob/mymob, iscamera = FALSE)
	remove_filter("guassian_blur")

	if(!istype(mymob))
		return

	// i have no idea how to make this plane work on the cameras
	if(iscamera)
		alpha = 0

	add_filter("guassian_blur", 1, gauss_blur_filter(10))

	// by default every z-level has one object as environment color holder
	// we place it on user screen to color plane globally
	color_filter = mymob.overlay_fullscreen("environment_lighting_color", /atom/movable/screen/fullscreen/environment_lighting_color)

	if(mymob.z)
		color_filter.attach_to_level(mymob.z)

	RegisterSignal(mymob, COMSIG_MOB_Z_CHANGED, PROC_REF(update_level), override = TRUE)

/atom/movable/screen/plane_master/environment_lighting/proc/update_level(mob/source, new_z)
	if(color_filter)
		color_filter.attach_to_level(new_z)

// for local environment lighting, can be used for areas
// currently we blend it at environment_lighting first just to use same blur filter
/atom/movable/screen/plane_master/environment_lighting_local
	name = "environment lighting local plane master"
	plane = ENVIRONMENT_LIGHTING_LOCAL_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = ENVIRONMENT_LIGHTING_PLANE
	blend_mode_override = BLEND_ADD

/atom/movable/screen/plane_master/above_lighting
	name = "above lighting plane master"
	plane = ABOVE_LIGHTING_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/singularity_0
	name = "singularity_0 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_0
	render_target = SINGULO_RENDER_TARGET_0
	render_relay_plane = null

/atom/movable/screen/plane_master/singularity_1
	name = "singularity_1 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_1
	render_target = SINGULO_RENDER_TARGET_1
	render_relay_plane = null

/atom/movable/screen/plane_master/singularity_2
	name = "singularity_2 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_2
	render_target = SINGULO_RENDER_TARGET_2
	render_relay_plane = null

/atom/movable/screen/plane_master/singularity_3
	name = "singularity_3 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_3
	render_target = SINGULO_RENDER_TARGET_3
	render_relay_plane = null

/atom/movable/screen/plane_master/anomaly
	name = "anomaly plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = ANOMALY_PLANE
	render_target = ANOMALY_RENDER_TARGET
	render_relay_plane = null

/atom/movable/screen/plane_master/area
	name = "area plane"
	plane = AREA_PLANE
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/fullscreen
	name = "fullscreen alert plane"
	plane = FULLSCREEN_PLANE
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/singularity
	name = "singularity plane"
	plane = SINGULARITY_PLANE
	render_relay_plane = RENDER_PLANE_ABOVE_GAME

/atom/movable/screen/plane_master/camera_static
	name = "camera static plane master"
	plane = CAMERA_STATIC_PLANE
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME
