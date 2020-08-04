/atom
	var/shaking_anim = FALSE

/atom/proc/before_shake_animation(intensity, time, intensity_dropoff)
	return

/atom/proc/after_shake_animation(intensity, time, intensity_dropoff)
	return

/atom/proc/shake_animation(intensity, time, intensity_dropoff = 0.9)
	if(invisibility > 0)
		return
	if(shaking_anim)
		return
	shaking_anim = TRUE
	var/prev_pixel_x = pixel_x
	var/prev_pixel_y = pixel_y
	var/matrix/prev_transform = transform

	var/image/I = image(icon, icon_state)
	I.appearance = src.appearance
	I.plane = plane
	I.layer = layer
	I.loc = src
	I.appearance_flags |= KEEP_APART

	var/list/viewers = list()
	for(var/mob/M in viewers(src))
		if(M.client)
			viewers += M.client

	before_shake_animation(intensity, time, intensity_dropoff, viewers)

	var/prev_invis = invisibility

	flick_overlay(I, viewers, time + 1)

	var/stop_shaking = world.time + time
	while(stop_shaking > world.time)
		var/shiftx = rand(-intensity, intensity)
		var/shifty = rand(-intensity, intensity)

		var/angle = rand(-intensity * 0.5, intensity * 0.5)
		var/matrix/M = matrix(prev_transform)
		M.Turn(angle)

		intensity *= intensity_dropoff

		invisibility = 101
		animate(I, pixel_x = prev_pixel_x + shiftx, pixel_y = prev_pixel_y + shifty, transform = M, time = 0.5)
		animate(pixel_x = prev_pixel_x, pixel_y = prev_pixel_y, transform = prev_transform, time = 0.5)
		sleep(1)

		if(QDELING(src))
			return
		invisibility = prev_invis

	after_shake_animation(intensity, time, intensity_dropoff, viewers)

	qdel(I)
	shaking_anim = FALSE

/turf/before_shake_animation(intensity, time, intensity_dropoff, list/viewers)
	var/image/me = image(icon, icon_state)
	me.appearance = src.appearance
	me.plane = plane
	me.layer = layer
	me.loc = src
	me.appearance_flags |= KEEP_APART

	flick_overlay(me, viewers, time + 1)
	QDEL_IN(me, time + 1)

/turf/simulated/floor/before_shake_animation(intensity, time, intensity_dropoff, list/viewers)
	if(is_catwalk())
		return

	if(!is_plating() && !istype(src, /turf/simulated/floor/plating/airless/asteroid))
		var/image/me = image('icons/turf/floors.dmi', "plating")
		me.plane = plane
		me.layer = layer
		me.loc = src
		me.appearance_flags |= KEEP_APART

		flick_overlay(me, viewers, time + 1)
		QDEL_IN(me, time + 1)
		return

	var/image/me = image(icon, icon_state)
	me.appearance = src.appearance
	me.plane = plane
	me.layer = layer
	me.loc = src
	me.appearance_flags |= KEEP_APART

	flick_overlay(me, viewers, time + 1)
	QDEL_IN(me, time + 1)

/mob/living/after_shake_animation(intensity, time, intensity_dropoff, list/viewers)
	transform = default_transform

/mob/living/shake_animation(intensity, time, intensity_dropoff = 0.9)
	if(invisibility > 0)
		return
	if(notransform)
		return
	if(shaking_anim)
		return
	shaking_anim = TRUE
	var/prev_pixel_x = default_pixel_x
	var/prev_pixel_y = default_pixel_y
	var/matrix/prev_transform = matrix(default_transform)

	var/list/viewers = list()
	for(var/mob/M in viewers(src))
		if(M.client)
			viewers += M.client

	before_shake_animation(intensity, time, intensity_dropoff, viewers)

	var/stop_shaking = world.time + time
	while(stop_shaking > world.time)
		var/shiftx = rand(-intensity, intensity)
		var/shifty = rand(-intensity, intensity)

		var/angle = rand(-intensity * 0.5, intensity * 0.5)
		var/matrix/M = matrix(prev_transform)
		M.Turn(angle)

		intensity *= intensity_dropoff

		animate(src, pixel_x = prev_pixel_x + shiftx, pixel_y = prev_pixel_y + shifty, transform = M, time = 0.5)
		animate(pixel_x = prev_pixel_x, pixel_y = prev_pixel_y, transform = prev_transform, time = 0.5)
		sleep(1)

		if(QDELING(src))
			return

	after_shake_animation(intensity, time, intensity_dropoff, viewers)

	shaking_anim = FALSE
