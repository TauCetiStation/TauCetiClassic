/mob/living/carbon/update_transform()
	var/matrix/ntransform = matrix(transform)
	var/final_pixel_y = pixel_y
	var/final_pixel_x = pixel_x
	var/final_dir = dir
	var/changed = 0

	if(lying_prev && !lying && crawling && !crawl_can_use())
		lying = TRUE
		rest_on()
		playsound(src, 'sound/weapons/tablehit1.ogg', VOL_EFFECTS_MASTER)
		if(ishuman(src))
			var/mob/living/carbon/human/H = src
			var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
			BP.take_damage(5, used_weapon = "Facepalm") // what?.. that guy was insane anyway.
		else
			take_overall_damage(5, used_weapon = "Table")
		Stun(1)
		to_chat(src, "<span class='danger'>Ouch!</span>")
		return

	if(lying)
		if(lying != lying_prev)
			lying_prev = lying
			get_lying_angle()
			playsound(src, pick(SOUNDIN_BODYFALL), VOL_EFFECTS_MASTER)
			changed++
			ntransform.TurnTo(0,lying_current)
			check_crawling()
			if(!buckled)
				rest_on() // We fell, lets relax
			pixel_y = get_standard_pixel_y_offset()
			pixel_x = get_standard_pixel_x_offset()
			final_pixel_y = get_standard_pixel_y_offset(lying_current)
			final_pixel_x = get_standard_pixel_x_offset(lying_current)
			if((dir & (EAST|WEST)) && !buckled) //Facing east or west
				final_dir = pick(NORTH, SOUTH) //So you fall on your side rather than your face or ass
	else
		if(lying != lying_prev)
			lying_prev = lying
			check_crawling()
			if(client)
				client.move_delay += 4
			changed++
			ntransform.TurnTo(lying_current,0)
			final_pixel_y = get_standard_pixel_y_offset()
			final_pixel_x = get_standard_pixel_x_offset()
		if(resize != RESIZE_DEFAULT_SIZE)
			resize_rev *= 1/resize
			changed++
			ntransform.Scale(resize)
			resize = RESIZE_DEFAULT_SIZE
	if(changed)
		animate(src, transform = ntransform, time = 2, pixel_y = final_pixel_y, pixel_x = final_pixel_x, dir = final_dir, easing = EASE_IN|EASE_OUT)
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
