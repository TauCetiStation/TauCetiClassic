/atom/movable/screen/parallax_layer/elite
	icon = 'icons/effects/parallax_elite.dmi'

/atom/movable/screen/parallax_layer/elite/layer_1
	icon_state = "layer1"
	speed = 0.6
	layer = 1

/atom/movable/screen/parallax_layer/elite/layer_2
	icon_state = "layer2"
	speed = 1
	layer = 2

/atom/movable/screen/parallax_layer/elite/layer_3
	icon_state = "layer3"
	speed = 1.4
	layer = 3

/atom/movable/screen/parallax_layer/elite/milky_way
	var/icon/base_icon = 'icons/effects/parallax_elite_milky_way.dmi'
	icon = null
	icon_state = "milky_way"
	absolute = TRUE
	speed = 0
	layer = 4

/atom/movable/screen/parallax_layer/elite/milky_way/New()
	var/_offset = rand(1, 1220 - 960)
	var/icon/II = new(base_icon, icon_state)
	II.Crop(_offset, 1, _offset + 479, 479)
	icon = II
	_offset = rand(60, 200)
	var/turn_step = rand(0, 3)
	var/matrix/transform = matrix()
	transform.TurnTo(0, 90 * turn_step)
	animate(src, transform = transform)
	if (turn_step % 2)
		absolute_offset_x = _offset
	else
		absolute_offset_y = _offset
	..()

/atom/movable/screen/parallax_layer/elite/milky_way/update_o()
	return //Shit wont move

/atom/movable/screen/parallax_layer/elite/planet
	icon_state = "planet"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE //Status of seperation
	var/angle = null
	var/angle_to = null //For debug
	var/angle_last = null //For debug
	var/ticks = null //For debug
	var/next_fire = null
	speed = 0.5
	layer = 30

/atom/movable/screen/parallax_layer/elite/planet/New()
	absolute_offset_x = rand(60, 200)
	absolute_offset_y = rand(60, 200)
	..()

/atom/movable/screen/parallax_layer/elite/planet/atom_init()
	. = ..()
	START_PROCESSING(SSfastprocess, src)

/atom/movable/screen/parallax_layer/elite/planet/update_status(mob/M)
	var/turf/T = get_turf(M)
	invisibility = 0
	if(T && is_station_level(T.z))
		icon_state = "planet"
		speed = 0.5
	else if (T && is_mining_level(T.z))
		icon_state = "planet_big"
		speed = 0.3
	else
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/parallax_layer/elite/planet/update_o()
	return //Shit wont move

/atom/movable/screen/parallax_layer/elite/planet/process()
	if (!SSsun)
		return
	if (world.time < next_fire)
		return
	if (SSsun.nexttime == 3600)
		return // skip when Sun SS not started yet
	if (angle != SSsun.angle)
		if (angle == null)
			rotate(SSsun.angle)
			return // skip when we are not rotated yet
		rotate(SSsun.angle, SSsun.rate > 0, SSsun.next_fire - world.time)
		next_fire = SSsun.next_fire + 1

/atom/movable/screen/parallax_layer/elite/planet/proc/rotate(_angle, cw = TRUE, _ticks = null)
	var/_angle_to = _angle
	if (cw)
		if (angle > _angle)
			_angle += 360
	else
		if (angle < _angle)
			_angle -= 360
	var/matrix/transform = matrix()
	transform.TurnTo(angle, _angle)
	angle_last = angle
	angle = _angle_to
	angle_to = _angle
	ticks = _ticks
	animate(src, _ticks, transform = transform)
