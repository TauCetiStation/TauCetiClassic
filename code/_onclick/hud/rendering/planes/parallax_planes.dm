/atom/movable/screen/plane_master/parallax_white
	name = "parallax whitifier plane master"
	plane = PLANE_SPACE

/atom/movable/screen/plane_master/parallax_white/update_effects(client/client)
	if(!..())
		return

	// todo: parallax layers don't exists on the parallax PM while on camera map
	// probably after fullscreens rewrite need to change /atom/movable/screen/parallax_layer to screen/fullscreen/...
	// and move them to plane_master/parallax/update_effects
	if(assigned_map) 
		return

	if(client.parallax_layers) // works like enabled/disabled flag
		// it just turns default static space plane (with old space sprite) into white mask for parallax effect
		color = list(
			0, 0, 0, 0,
			0, 0, 0, 0,
			0, 0, 0, 0,
			1, 1, 1, 1,
			0, 0, 0, 0
			)
	else
		color = initial(color)

/atom/movable/screen/plane_master/parallax
	name = "parallax plane master"
	plane = PLANE_SPACE_PARALLAX
	blend_mode = BLEND_MULTIPLY
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
