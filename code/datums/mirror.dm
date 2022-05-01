/atom/movable/mirror
	plane = MIRROR_PLANE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	var/angle = 0
	var/power = 1

/atom/movable/mirror/New(angle, icon, icon_state, power)
	..()
	src.icon = icon
	src.icon_state = icon_state
	src.angle = angle
	src.power = power
	update_angle()

/atom/movable/mirror/proc/update_angle()
	transform = null
	color = rgb(128 + min(127*cos(angle)*power, 255), 128 + min(127*sin(angle)*power, 255), 0)
