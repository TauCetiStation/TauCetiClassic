/atom/movable/mirror
	var/angle = 0
	plane = MIRROR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT

/atom/movable/mirror/proc/update_angle()
	transform = null
	color = rgb(128 + 127*cos(angle), 128 - 127*sin(angle), 0)
	if(cos(angle) < 0)
		icon_state += "_right"
	else
		icon_state += "_left"
