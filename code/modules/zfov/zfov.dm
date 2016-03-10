proc/atan2(x, y)
	if(!(x || y)) return 0
	if(istype(x, /list) && x:len == 2) { y = x[2]; x = x[1] }
	return x >= 0 ? arccos(y / sqrt(x * x + y * y)) : 360 - arccos(y / sqrt(x * x + y * y))

/obj/screen/field_of_view
	icon = 'icons/mob/fov.dmi'
	icon_state = "105"
	layer = 16
	alpha = 40
	mouse_opacity = 0
	screen_loc = "CENTER-7,CENTER-7"

/client/proc/add_fov_overlay()
	if(!fov)
		fov = new()

	if(mob && isliving(mob) && !isAI(mob))
		if(!(fov in screen))
			screen += fov

/client/proc/remove_fov_overlay()
	if(fov in screen)
		screen -= fov

/client
	var/ignore_darky = 0

/mob
	var/face_direction = 0
	var/last_dir = 0

/mob/living
	var/image/blank_image = null
	var/fov_update = 0

/mob/living/New()
	. = ..()

	blank_image = image(loc = src)
	blank_image.name = "darky"
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

/mob/living/proc/ignore_darky()
	if(client)
		if(client.ignore_darky)
			if(client.ignore_darky == 1)
				if(client && client.ignore_darky)
					client.remove_fov_overlay()
					for(var/image/whos_hiding in client.images)
						if(whos_hiding.name == "darky")
							client.images -= whos_hiding
				client.ignore_darky = 2
			return 1
	return 0

/mob/living/proc/call_fov_update(self=0,atom/face_atom)
	if(is_our_eyes_invalid_for_fov())
		return
	if(ignore_darky())
		return
	if(fov_update)//I hope such method will reduce update_fov() calls in the same tick. We want speed, no point in calling update million times in same tick.
		return
	fov_update = 1
	spawn()
		fov_update = 0

	var/new_dir = 0
	if(face_atom)
		new_dir = 1
		var/turf/origin = get_turf(src)
		var/turf/target = get_turf(face_atom)
		face_direction = round(atan2(origin.x-target.x,origin.y-target.y))
	else if(last_dir != dir)
		new_dir = 1
		switch(dir)
			if(NORTH)     face_direction = 180
			if(SOUTH)     face_direction = 0
			if(EAST)      face_direction = 270
			if(WEST)      face_direction = 90

	last_dir = dir
	update_fov(self,new_dir)

/mob/living/proc/i_want_to_override_default_fov(fov)
	return fov

/mob/living/proc/is_our_eyes_invalid_for_fov()
	return 0

/mob/living/silicon/ai/is_our_eyes_invalid_for_fov()
	return 1

var/list/of_non_default_fov_values = list(
	/obj/item/clothing/head/helmet/space = 45
	)

/mob/living/carbon/human/i_want_to_override_default_fov(fov)
	if(head)
		. = of_non_default_fov_values[head]
	if(!.)
		return fov

/mob/living/proc/update_fov(self=0,new_dir=0)
	if(is_our_eyes_invalid_for_fov())
		return

	var/view_range = 7
	var/default_fov = 135 //Per eye!! And don't put less than 1 or more than 179. Actually, use something between 15 and 165 and don't forget to draw new overlay.

	var/fov = i_want_to_override_default_fov(default_fov)

	if(ishuman(src))
		var/mob/living/carbon/human/H = src
		if(H.head && istype(H.head, /obj/item/clothing/head/helmet/space))
			fov = 45

	if(client)
		if(lying)
			client.remove_fov_overlay()
		else
			client.add_fov_overlay()
		if(new_dir)
			var/matrix/M = matrix()
			M.Turn(face_direction)
			M.Scale(3)
			client.fov.transform = M
		if(client.fov.icon_state != "[fov]")
			client.fov.icon_state = "[fov]"
		view_range = client.view+1

	var/eye_left_fov = 360 - fov
	var/eye_right_fov = 0 + fov

	for(var/mob/living/target in view(view_range))
		if(target == src)
			continue

		if(client)
			var/mob_angle = round(atan2(src.x-target.x,src.y-target.y))
			mob_angle -= face_direction
			while(mob_angle < 0)
				mob_angle += 360

			if(mob_angle >= eye_left_fov || mob_angle <= eye_right_fov || lying)
				client.images -= target.blank_image
			else
				client.images |= target.blank_image

		if(!self && target.client)
			target.update_fov(1)
