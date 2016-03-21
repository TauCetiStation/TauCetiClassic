/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/final_pixel_y = pixel_y
	var/final_pixel_x = pixel_x
	var/final_dir = dir
	var/final_layer = layer
	var/changed = 0
	if(lying)
		if(lying != lying_prev)
			lying_prev = lying
			get_lying_angle()
			playsound(src, "bodyfall", 50, 1)
			changed++
			ntransform.TurnTo(0,lying_current)
			final_layer = 3.9
			pixel_y = get_standard_pixel_y_offset()
			pixel_x = get_standard_pixel_x_offset()
			final_pixel_y = get_standard_pixel_y_offset(lying_current)
			final_pixel_x = get_standard_pixel_x_offset(lying_current)
			if((dir & (EAST|WEST)) && !buckled) //Facing east or west
				final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	else
		if(lying != lying_prev)
			lying_prev = lying
			changed++
			ntransform.TurnTo(lying_current,0)
			final_pixel_y = get_standard_pixel_y_offset()
			final_pixel_x = get_standard_pixel_x_offset()
			final_layer = initial(layer)
		if(resize != RESIZE_DEFAULT_SIZE)
			resize_rev *= 1/resize
			changed++
			ntransform.Scale(resize)
			resize = RESIZE_DEFAULT_SIZE
	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, pixel_x = final_pixel_x, dir = final_dir, easing = EASE_IN|EASE_OUT, layer = final_layer)
		floating = 0

/mob/living/carbon/proc/get_lying_angle()
	. = lying_current

	if(buckled && istype(buckled, /obj/structure/stool/bed/chair))
		var/obj/structure/stool/bed/chair/C = buckled
		if(C.flipped)
			lying_current = C.flip_angle
	else if(locate(/obj/machinery/optable, loc) || locate(/obj/structure/stool/bed, loc))
		lying_current = 90
	else
		lying_current = pick(90, 270)
