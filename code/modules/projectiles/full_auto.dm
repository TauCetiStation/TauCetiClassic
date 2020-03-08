client
	var/atom/selected_target

/client/MouseDown(object, location, control, params)
	if(isatom(location))
		var/delay = 0
		var/mob/living/user = usr
		var/obj/item/weapon/gun/machine_gun = user.get_active_hand()
		if(istype(machine_gun))
			delay = machine_gun.GunFullAutoSpeed()
		if(delay > 0)
			selected_target = object
			while(selected_target)
				if(!machine_gun.fire_checks(user))
					break
				user.face_atom(selected_target)
				machine_gun.DoShooting(selected_target, user, params, FALSE, FALSE)
				if(machine_gun.full_auto_break)
					machine_gun.full_auto_break = FALSE
					selected_target = null
					break
				sleep(delay)
			machine_gun.full_auto_amount_shot = 0

/client/MouseUp(object, location, control, params)
	selected_target = null

/client/MouseDrag(src_object,over_object,src_location,over_location,src_control,over_control,params)
	if(selected_target)
		selected_target = over_object

/obj/item/weapon/gun/proc/GunFullAutoSpeed()
	return full_auto
