proc/atan2(x, y)
	if(!(x || y)) return 0
	if(istype(x, /list) && x:len == 2) { y = x[2]; x = x[1] }
	return x >= 0 ? arccos(y / sqrt(x * x + y * y)) : 360 - arccos(y / sqrt(x * x + y * y))

proc/get_angle(atom/a, atom/b)
	return atan2(b.y - a.y, b.x - a.x)

proc/get_degree_angle(atom/a, direct, atom/b)
	var/orient = 270
	switch(direct) //set zero to dir atom/a is facing.
		if(NORTH)
			orient = 270
		if(SOUTH)
			orient = 90
		if(WEST)
			orient = 180
		if(EAST)
			orient = 0
	. = get_angle(a, b) + orient

	while(. > 360)
		. -= 360

	if(. == 360)
		. = 0

/obj/screen/field_of_view
	icon = 'icons/mob/fov.dmi'
	icon_state = "105"
	layer = 30
	alpha = 40
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"

/mob/living
	var/image/blank_image = null
	var/fov_update = 0

/mob/living/New()
	. = ..()

	blank_image = image(loc = src)
	blank_image.override = 1

/mob/living/Move()
	. = ..()
	call_fov_update()

/atom/Entered(atom/movable/AM, atom/OldLoc)
	. = ..()

	if(isliving(AM))
		var/mob/living/L = AM
		if(AM && OldLoc != src)
			L.call_fov_update()

/atom/Exited(var/atom/movable/AM, var/atom/newloc)
	. = ..()

	if(isliving(AM))
		var/mob/living/L = AM
		if(!newloc && AM && newloc != src)
			L.call_fov_update()

// If an opaque movable atom moves around we need to potentially update visibility.
/turf/Entered(var/atom/movable/AM, var/atom/OldLoc)
	. = ..()

	if(isliving(AM))
		var/mob/living/L = AM
		L.call_fov_update()

/turf/Exited(var/atom/movable/AM, var/atom/newloc)
	. = ..()

	if(isliving(AM))
		var/mob/living/L = AM
		L.call_fov_update()

/mob/living/Life()
	. = ..()
	fov_update = 0

/mob/living/forceMove(atom/destination)
	if(..())
		call_fov_update()

/obj/item/equipped()
	. = ..()
	if(isliving(loc))
		var/mob/living/L = loc
		L.call_fov_update()

/obj/item/pickup()
	. = ..()
	if(isliving(loc))
		var/mob/living/L = loc
		L.call_fov_update()

/obj/item/dropped()
	if(isliving(loc))
		var/mob/living/L = loc
		L.call_fov_update()
	. = ..()

/mob/living/proc/call_fov_update(self=0)
	if(fov_update)//I hope such method will reduce update_fov() calls in the same tick. We want speed, no point in calling update million times in same tick.
		return
	fov_update = 1
	spawn()
		fov_update = 0
	update_fov(self)

/mob/living/proc/update_fov(self=0)
	var/view_range = 7
	var/fov = 105 //Per eye!!
	var/direct = dir

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.head && istype(H.head, /obj/item/clothing/head/helmet/space))
			fov = 45

	if(client)
		client.fov.dir = dir
		client.fov.icon_state = "[fov]"
		view_range = client.view

	var/eye_left_fov = 360 - fov
	var/eye_right_fov = 0 + fov

	//For visual testing remove:
	//Leave if(client...) part if you want local testing just for yourself.
	//Remove ckey part if you want to test with multiple clients.
	//Also, adjust colours if need (if you want different for every mob, think that's shouldn't very hard to code), otherwise use as is.
	//Or you can code your own method for testing, i prefer turf colouring for myself.
	//if(client && client.ckey == "zve")
	//	for(var/turf/T in view(view_range))
	//		var/mob_angle = get_degree_angle(src, direct, T)
	//		if(mob_angle >= eye_left_fov || mob_angle <= eye_right_fov)
	//			T.color = "#ff0000"
	//		else
	//			T.color = "#ffffff"

	for(var/mob/living/target in view(view_range))
		if(target == src)
			continue

		if(client)
			var/mob_angle = get_degree_angle(src, direct, target)
			if(mob_angle > eye_left_fov || mob_angle < eye_right_fov)
				if(target.blank_image in client.images)
					client.images -= target.blank_image
			else
				client.images |= target.blank_image

		if(!self && target.client)
			target.update_fov(1)
