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

/atom/movable/screen/parallax_layer/elite/asteroid
	icon_state = "asteroid"
	blend_mode = BLEND_OVERLAY
	absolute = TRUE
	speed = 0.5
	layer = 30

/atom/movable/screen/parallax_layer/elite/asteroid/New()
	absolute_offset_x = SSparallax.planet_x_offset
	absolute_offset_y = SSparallax.planet_y_offset
	var/rotary_speed = rand(3.0, 5.0) MINUTES
	SpinAnimation(rotary_speed, -1, prob(50))
	..()

/atom/movable/screen/parallax_layer/elite/asteroid/update_status(mob/M)
	var/turf/T = get_turf(M)
	if(T && is_station_level(T.z))
		invisibility = 0
	else
		invisibility = INVISIBILITY_ABSTRACT

/atom/movable/screen/parallax_layer/elite/asteroid/update_o()
	return //Shit wont move

/atom/movable/screen/parallax_layer/elite/milky_way
	var/icon/base_icon = 'icons/effects/parallax_elite_milky_way.dmi'
	icon = null
	icon_state = "milky_way"
	absolute = TRUE
	speed = 0
	layer = 4

/atom/movable/screen/parallax_layer/elite/milky_way/New()
	. = ..()
	var/dims = getviewsize(world.view)
	var/scale = rand(0.5, 1.0)
	var/turn_step = rand(0, 3)

	var/icon/II = new(base_icon, icon_state)
	II.Scale(II.Width() * scale, II.Height() * scale)

	var/_offset = rand(1, II.Width() - dims[turn_step % 2 + 1] * world.icon_size)
	II.Crop(_offset, 1, _offset + dims[1] * world.icon_size - 1, dims[2] * world.icon_size - 1)

	icon = II

	var/matrix/transform = matrix()
	transform.TurnTo(0, 90 * turn_step)
	animate(src, transform = transform)

	_offset = rand(60, 200)
	if (turn_step % 2)
		absolute_offset_x = _offset
	else
		absolute_offset_y = _offset
	..()

/atom/movable/screen/parallax_layer/elite/milky_way/update_o()
	return //Shit wont move
