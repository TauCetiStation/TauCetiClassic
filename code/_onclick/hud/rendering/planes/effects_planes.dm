// effects planes we don't relay directly
// instead we use them as render_source for rendering_plate/game_world filters

/atom/movable/screen/plane_master/singularity_0
	name = "singularity_0 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_0
	render_relay_planes = null

/atom/movable/screen/plane_master/singularity_1
	name = "singularity_1 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_1
	render_relay_planes = null

/atom/movable/screen/plane_master/singularity_2
	name = "singularity_2 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_2
	render_relay_planes = null

/atom/movable/screen/plane_master/singularity_3
	name = "singularity_3 plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = SINGULARITY_EFFECT_PLANE_3
	render_relay_planes = null

// for anomaly effects: gravity pulse, maybe something else
// place your masks on this plane for basic distortion effect (displacement filter)
/atom/movable/screen/plane_master/distortion
	name = "anomaly plane"
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	plane = DISTORTION_PLANE
	render_relay_planes = null
