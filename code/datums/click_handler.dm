/client
	var/datum/click_handler/CH

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
		owner.CH = null
		owner.mouse_pointer_icon=initial(owner.mouse_pointer_icon)
	return ..()


//Return false from these procs to discard the click afterwards
/datum/click_handler/proc/Click(var/atom/target, location, control, params)
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
/datum/click_handler/proc/is_world_target(var/a)
	if (isatom(a))
		return TRUE

	else if (isatom(a))
		var/atom/A = a
		if (istype(A.loc, /turf))
			return TRUE
	return FALSE

/datum/click_handler/proc/resolve_world_target(var/a)

	if (istype(a, /atom/movable/screen/click_catcher))
		var/atom/movable/screen/click_catcher/CC = a
		return CC.resolve(owner.mob)

	if (istype(a, /turf))
		return a

	else if (istype(a, /atom))
		var/atom/A = a
		if (istype(A.loc, /turf))
			return A
	return null

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

/datum/click_handler/fullauto/MouseDown(object,location,control,params)
	if(!isturf(owner.mob.loc)) // This stops from firing full auto weapons inside closets
		return
	if(reciever.ready_to_fire())
		object = resolve_world_target(object)
		if(object)
			target = object
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
	spawn(reciever.fire_delay + 1)
		do_fire()
		shooting_loop()

/datum/click_handler/fullauto/MouseDrag(over_object,src_location,over_location,src_control,over_control,params)
	src_location = resolve_world_target(src_location)
	if(src_location)
		target = src_location
		return FALSE
	return TRUE

/datum/click_handler/fullauto/MouseUp(object,location,control,params)
	stop_firing()
	return TRUE

/datum/click_handler/fullauto/Destroy()
	stop_firing()//Without this it keeps firing in an infinite loop when deleted
	.=..()

