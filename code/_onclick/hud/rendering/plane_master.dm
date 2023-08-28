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

///Contains just the floor
/atom/movable/screen/plane_master/floor
	name = "floor plane master"
	plane = FLOOR_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

///Contains most things in the game world
/atom/movable/screen/plane_master/game_world
	name = "game world plane master"
	plane = GAME_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/game_world/backdrop(mob/mymob)
	. = ..()
	remove_filter("AO")
	if(istype(mymob) && mymob?.client?.prefs?.ambientocclusion)
		add_filter("AO", 1, drop_shadow_filter(x = 0, y = -2, size = 4, color = "#04080FAA"))

/atom/movable/screen/plane_master/game_world_above
	name = "above game world plane master"
	plane = ABOVE_GAME_PLANE
	render_relay_plane = GAME_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY

/atom/movable/screen/plane_master/ghost
	name = "ghost plane master"
	plane = GHOST_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_NON_GAME

/atom/movable/screen/plane_master/ghost_illusion
	name = "ghost illusion plane master"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = GHOST_ILLUSION_PLANE
	render_relay_plane = RENDER_PLANE_ABOVE_GAME

/atom/movable/screen/plane_master/ghost_illusion/backdrop(mob/mymob)
	. = ..()
	remove_filter("ghost_illusion")
	add_filter("ghost_illusion", 1, motion_blur_filter(x = 3, y = 3))

/atom/movable/screen/plane_master/point
	name = "point plane master"
	plane = POINT_PLANE
	appearance_flags = PLANE_MASTER //should use client color
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
	appearance_flags = PLANE_MASTER | NO_CLIENT_COLOR | PIXEL_SCALE
	//byond internal end
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/lighting
	name = "lighting plane master"
	plane = LIGHTING_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode_override = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/exposure
	name = "exposure plane master"
	plane = LIGHTING_EXPOSURE_PLANE
	appearance_flags = PLANE_MASTER|PIXEL_SCALE //should use client color
	blend_mode = BLEND_ADD
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/exposure/backdrop(mob/mymob) // todo: prefs
	. = ..()
	remove_filter("blur_exposure")
	if(istype(mymob) && mymob?.client?.prefs?.old_lighting)
		return
	add_filter("blur_exposure", 1, gauss_blur_filter(size = 20)) // by refs such blur is heavy, but tests were okay and this allow us more flexibility with setup

/atom/movable/screen/plane_master/lamps_selfglow
	name = "lamps selfglow plane master"
	plane = LIGHTING_LAMPS_SELFGLOW
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_ADD
	blend_mode_override = BLEND_ADD
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/lamps_selfglow/backdrop(mob/mymob) // todo: prefs
	. = ..()
	remove_filter("add_lamps_to_selfglow")
	remove_filter("lamps_selfglow_bloom")

	if(!istype(mymob))
		return
	if(mymob?.client?.prefs?.old_lighting)
		return
	var/bloomsize = 0
	var/bloomoffset = 0
	switch(mymob?.client?.prefs?.bloomlevel)
		if(BLOOM_DISABLE)
			return
		if(BLOOM_LOW)
			bloomsize = 2
			bloomoffset = 1
		if(BLOOM_MED)
			bloomsize = 3
			bloomoffset = 2
		if(BLOOM_HIGH)
			bloomsize = 5
			bloomoffset = 3

	add_filter("add_lamps_to_selfglow", 1, layering_filter(render_source = LIGHTING_LAMPS_RENDER_TARGET, blend_mode = BLEND_OVERLAY))
	add_filter("lamps_selfglow_bloom", 1, bloom_filter(threshold = "#aaaaaa", size = bloomsize, offset = bloomoffset, alpha = 100))

/atom/movable/screen/plane_master/lamps
	name = "lamps plane master"
	plane = LIGHTING_LAMPS_PLANE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode = BLEND_OVERLAY
	blend_mode_override = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

	render_target = LIGHTING_LAMPS_RENDER_TARGET

/atom/movable/screen/plane_master/lamps_glare
	name = "lamps glare plane master"
	plane = LIGHTING_LAMPS_GLARE
	appearance_flags = PLANE_MASTER //should use client color
	blend_mode_override = BLEND_OVERLAY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	render_relay_plane = RENDER_PLANE_GAME

/atom/movable/screen/plane_master/lamps_glare/backdrop(mob/mymob)
	. = ..()
	remove_filter("add_lamps_to_glare")
	remove_filter("lamps_glare")
	if(istype(mymob) && mymob?.client?.prefs?.old_lighting || !mymob?.client?.prefs?.lampsglare)
		return
	add_filter("add_lamps_to_glare", 1, layering_filter(render_source = LIGHTING_LAMPS_RENDER_TARGET, blend_mode = BLEND_OVERLAY))
	add_filter("lamps_glare", 1, radial_blur_filter(size = 0.05))

/atom/movable/screen/plane_master/above_lighting
	name = "above lighting plane master"
	plane = ABOVE_LIGHTING_PLANE
	appearance_flags = PLANE_MASTER //should use client color
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
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	render_relay_plane = RENDER_PLANE_GAME
