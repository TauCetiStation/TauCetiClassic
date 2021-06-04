/atom
	// To prevent the item from being forever invisible, check this flag. If it's TRUE, don't animate.
	var/is_invis_anim = FALSE

/atom/proc/before_shake_animation(intensity, time, intensity_dropoff)
	return

/atom/proc/after_shake_animation(intensity, time, intensity_dropoff)
	return

/atom/proc/do_shake_animation(intensity, time, intensity_dropoff = 0.9)
	if(invisibility > 0)
		return
	if(is_invis_anim)
		return
	is_invis_anim = TRUE
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
	is_invis_anim = FALSE

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

/mob/living/do_shake_animation(intensity, time, intensity_dropoff = 0.9)
	if(invisibility > 0)
		return
	if(notransform)
		return
	if(is_invis_anim)
		return
	is_invis_anim = TRUE
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

	is_invis_anim = FALSE

/atom/movable/proc/pickup_animation(image/I, list/viewers, atom/target, atom/old_loc)
	if (QDELETED(src))
		return
	if (QDELETED(target))
		return
	if (QDELETED(old_loc))
		return

	var/turf/old_turf = get_turf(old_loc)

	I.pixel_x = old_loc.pixel_x + pixel_x
	I.pixel_y = old_loc.pixel_y + pixel_y

	I.loc = old_turf
	I.plane = GAME_PLANE
	I.layer = INFRONT_MOB_LAYER
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	if (ismob(target))
		I.dir = target.dir

	var/list/new_viewers = list()
	for(var/v in viewers)
		var/mob/M = v
		if(M.client)
			new_viewers += M.client

	flick_overlay(I, new_viewers, 7)

	var/matrix/M = new
	M.Turn(pick(30, -30))

	animate(I, transform = M, time = 1)
	sleep(1)
	animate(I, transform = matrix(), time = 1)
	sleep(1)

	var/to_x = (target.x - old_turf.x) * 32 + target.pixel_x
	var/to_y = (target.y - old_turf.y) * 32 + target.pixel_y

	animate(I, pixel_x = to_x, pixel_y = to_y, time = 3, transform = matrix() * 0, easing = CUBIC_EASING)

/atom/movable/proc/do_pickup_animation(atom/target, atom/old_loc)
	if (QDELETED(src))
		return
	if (QDELETED(target))
		return
	if (QDELETED(old_loc))
		return
	if (!Adjacent(target))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.gloves, /obj/item/clothing/gloves/black/strip))
			return

	if(is_invis_anim)
		return
	is_invis_anim = TRUE

	var/list/imgs = get_perceived_images(viewers(target))
	for(var/i in imgs)
		INVOKE_ASYNC(src, .proc/pickup_animation, i, imgs[i], target, old_loc)
	sleep(5)
	if(QDELETED(src))
		return
	is_invis_anim = FALSE

/atom/movable/proc/putdown_animation(image/I, list/viewers, atom/target, mob/user, additional_pixel_x = 0, additional_pixel_y = 0)
	if (QDELETED(src))
		return
	if (QDELETED(target))
		return
	if (QDELETED(user))
		return

	var/turf/old_turf = get_turf(user)

	I.pixel_x = user.pixel_x + pixel_x
	I.pixel_y = user.pixel_y + pixel_y
	I.loc = old_turf
	I.plane = GAME_PLANE
	I.layer = INFRONT_MOB_LAYER
	I.transform = matrix() * 0
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	I.pixel_x = 0
	I.pixel_y = 0

	if (ismob(target))
		I.dir = target.dir

	var/list/new_viewers = list()
	for(var/v in viewers)
		var/mob/M = v
		if(M.client)
			new_viewers += M.client

	flick_overlay(I, new_viewers, 4)

	var/to_x = (target.x - old_turf.x) * 32 + pixel_x + additional_pixel_x + target.pixel_x
	var/to_y = (target.y - old_turf.y) * 32 + pixel_y + additional_pixel_y + target.pixel_y

	animate(I, pixel_x = to_x, pixel_y = to_y, time = 3, transform = matrix(), easing = CUBIC_EASING)

/atom/movable/proc/do_putdown_animation(atom/target, mob/user, additional_pixel_x = 0, additional_pixel_y = 0)
	if (QDELETED(src))
		return
	if (QDELETED(target))
		return
	if (QDELETED(user))
		return
	if (!target.Adjacent(user))
		return

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(istype(H.gloves, /obj/item/clothing/gloves/black/strip))
			return

	if(is_invis_anim)
		return
	is_invis_anim = TRUE

	var/old_invisibility = invisibility // I don't know, it may be used.
	invisibility = 100

	var/old_x = pixel_x
	var/old_y = pixel_y

	var/list/imgs = get_perceived_images(viewers(target))
	for(var/i in imgs)
		INVOKE_ASYNC(src, .proc/putdown_animation, i, imgs[i], target, user, additional_pixel_x, additional_pixel_y)

	sleep(3)
	if (QDELETED(src))
		return
	is_invis_anim = FALSE
	invisibility = old_invisibility
	pixel_x = old_x + additional_pixel_x
	pixel_y = old_y + additional_pixel_y

/atom/movable/proc/simple_move_animation(image/I, list/viewers, atom/target)
	if (QDELETED(src))
		return

	var/turf/old_turf = get_turf(src)

	I.pixel_x = pixel_x
	I.pixel_y = pixel_y
	I.loc = loc
	I.plane = GAME_PLANE
	I.layer = INFRONT_MOB_LAYER
	I.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
	I.mouse_opacity = MOUSE_OPACITY_TRANSPARENT

	var/list/new_viewers = list()
	for(var/v in viewers)
		var/mob/M = v
		if(M.client)
			new_viewers += M.client

	flick_overlay(I, new_viewers, 4)

	var/to_x = (target.x - old_turf.x) * 32 + pixel_x + target.pixel_x
	var/to_y = (target.y - old_turf.y) * 32 + pixel_y + target.pixel_y

	animate(I, pixel_x = to_x, pixel_y = to_y, time = 3, easing = CUBIC_EASING)

/atom/movable/proc/do_simple_move_animation(atom/target)
	if (QDELETED(src))
		return
	if (QDELETED(target))
		return

	if(ishuman(target))
		var/mob/living/carbon/human/H = target
		if(istype(H.gloves, /obj/item/clothing/gloves/black/strip))
			return

	if(is_invis_anim)
		return
	is_invis_anim = TRUE

	var/old_invisibility = invisibility // I don't know, it may be used.
	invisibility = 100

	var/list/imgs = get_perceived_images(viewers(target))
	for(var/i in imgs)
		INVOKE_ASYNC(src, .proc/simple_move_animation, i, imgs[i], target)

	sleep(3)
	if (QDELETED(src))
		return
	is_invis_anim = FALSE
	invisibility = old_invisibility
