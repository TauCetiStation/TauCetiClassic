/client
	var/datum/click_handler/client_click_handler

/datum/click_handler
	var/species
	var/handler_name
	var/one_use_flag = 1//drop client.CH after succes ability use
	var/client/owner
	var/icon/mouse_icon


/datum/click_handler/New(client/_owner)
	owner = _owner
	if (mouse_icon)
		owner.mouse_pointer_icon = mouse_icon

/datum/click_handler/Destroy()
	..()
	if (owner)
		owner.client_click_handler = null
		owner.mouse_pointer_icon=initial(owner.mouse_pointer_icon)
	return ..()


//Return false from these procs to discard the click afterwards
/datum/click_handler/proc/Click(atom/target, location, control, params)
	if (mob_check(owner.mob) && use_ability(owner.mob, target))
		//Ability successful
		if (one_use_flag)
			//If we're single use, delete ourselves anyways
			qdel(src)
	return TRUE

/datum/click_handler/proc/MouseDown(object,location,control,params)
	return TRUE

/datum/click_handler/proc/MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
	return TRUE

/datum/click_handler/proc/MouseUp(object,location,control,params)
	return TRUE

/datum/click_handler/proc/MouseMove(object,location,control,params)
	return TRUE

/datum/click_handler/proc/mob_check(mob/living/carbon/human/user) //Check can mob use a ability
	return

/datum/click_handler/proc/use_ability(mob/living/carbon/human/user,atom/target)
	return

//Returns true if the passed thing is an atom on a turf, or a turf itself, false otherwise
/datum/click_handler/proc/is_world_target(a)
	if (isatom(a))
		return TRUE

	else if (isatom(a))
		var/atom/A = a
		if (istype(A.loc, /turf))
			return TRUE
	return FALSE

/****************************
	Full auto gunfire
*****************************/
/datum/click_handler/fullauto
	var/atom/target = null
	var/firing
	var/obj/item/weapon/gun/reciever //The thing we send firing signals to.

/datum/click_handler/fullauto/Click()
	return TRUE //Doesn't work with normal clicks

//Next loop will notice these vars and stop shooting
/datum/click_handler/fullauto/proc/stop_firing()
	target = null

/datum/click_handler/fullauto/proc/do_fire()
	if(target)
		reciever.afterattack(target, owner.mob, FALSE)
		addtimer(CALLBACK(src, PROC_REF(shooting_loop)), 0.1)

/datum/click_handler/fullauto/MouseDown(object,location,control,params)
	if(!isturf(owner.mob.loc)) // This stops from firing full auto weapons inside closets
		return
	if(reciever.ready_to_fire() && is_world_target(object))
		target = object
		owner.mob.face_atom(target)
		shooting_loop()
		return FALSE
	return TRUE

/datum/click_handler/fullauto/proc/shooting_loop()
	if(!owner || !owner.mob)
		return FALSE
	if(!istype(owner.mob.get_active_hand(), reciever))
		stop_firing()
		return
	if(!target)
		return
	if(!reciever.can_fire())
		stop_firing()
		return
	owner.mob.face_atom(target)

	addtimer(CALLBACK(src, PROC_REF(do_fire)), reciever.fire_delay + 0.1)

/datum/click_handler/fullauto/MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
	if(is_world_target(src_location))
		target = src_location
		return FALSE
	return TRUE

/datum/click_handler/fullauto/MouseUp(object,location,control,params)
	stop_firing()
	return TRUE

/datum/click_handler/fullauto/Destroy()
	stop_firing()//Without this it keeps firing in an infinite loop when deleted
	.=..()

