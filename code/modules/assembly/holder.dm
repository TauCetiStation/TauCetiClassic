/obj/item/device/assembly_holder
	name = "Assembly"
	icon = 'icons/obj/assemblies/new_assemblies.dmi'
	icon_state = "holder"
	item_state = "assembly"
	flags = CONDUCT
	throwforce = 5
	w_class = ITEM_SIZE_SMALL
	throw_speed = 3
	throw_range = 10

	var/secured = 0
	var/obj/item/device/assembly/a_left = null
	var/obj/item/device/assembly/a_right = null
	var/obj/special_assembly = null

/obj/item/device/assembly_holder/proc/attach(obj/item/device/D, obj/item/device/D2, mob/user)
	return

/obj/item/device/assembly_holder/proc/attach_special(obj/O, mob/user)
	return

/obj/item/device/assembly_holder/proc/process_activation(obj/item/device/D)
	return

/obj/item/device/assembly_holder/proc/detached()
	return


/obj/item/device/assembly_holder/IsAssemblyHolder()
	return 1


/obj/item/device/assembly_holder/attach(obj/item/device/D, obj/item/device/D2, mob/user)
	if((!D)||(!D2))	return 0
	if((!isassembly(D))||(!isassembly(D2)))	return 0
	if((D:secured)||(D2:secured))	return 0
	if(user)
		user.remove_from_mob(D)
		user.remove_from_mob(D2)
	D:holder = src
	D2:holder = src
	D.loc = src
	D2.loc = src
	a_left = D
	a_right = D2
	name = "[D.name]-[D2.name] assembly"
	update_icon()
	usr.put_in_hands(src)

	return 1


/obj/item/device/assembly_holder/attach_special(obj/O, mob/user)
	if(!O)	return
	if(!O.IsSpecialAssembly())	return 0

	return


/obj/item/device/assembly_holder/update_icon()
	cut_overlays()
	if(a_left)
		add_overlay("[a_left.icon_state]_left")
		for(var/O in a_left.attached_overlays)
			add_overlay("[O]_l")
	if(a_right)
		src.add_overlay("[a_right.icon_state]_right")
		for(var/O in a_right.attached_overlays)
			add_overlay("[O]_r")
	if(master)
		master.update_icon()

/obj/item/device/assembly_holder/examine(mob/user)
	..()
	if (src in view(1, user))
		if (src.secured)
			to_chat(user, "\The [src] is ready!")
		else
			to_chat(user, "\The [src] can be attached!")


/obj/item/device/assembly_holder/HasProximity(atom/movable/AM)
	if(a_left)
		a_left.HasProximity(AM)
	if(a_right)
		a_right.HasProximity(AM)
	if(special_assembly)
		special_assembly.HasProximity(AM)


/obj/item/device/assembly_holder/Crossed(atom/movable/AM)
	. = ..()
	if(a_left)
		a_left.Crossed(AM)
	if(a_right)
		a_right.Crossed(AM)
	if(special_assembly)
		special_assembly.Crossed(AM)


/obj/item/device/assembly_holder/on_found(mob/finder)
	if(a_left)
		a_left.on_found(finder)
	if(a_right)
		a_right.on_found(finder)
	if(special_assembly)
		if(istype(special_assembly, /obj/item))
			var/obj/item/S = special_assembly
			S.on_found(finder)


/obj/item/device/assembly_holder/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	. = ..()
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()

/obj/item/device/assembly_holder/hear_talk(mob/living/M, msg, verb, datum/language/speaking)
	if(a_left)
		a_left.hear_talk(M,msg,verb,speaking)
	if(a_right)
		a_right.hear_talk(M,msg,verb,speaking)

	return


/obj/item/device/assembly_holder/attack_hand()//Perhapse this should be a holder_pickup proc instead, can add if needbe I guess
	if(a_left && a_right)
		a_left.holder_movement()
		a_right.holder_movement()
	..()
	return

/obj/item/device/assembly_holder/attackby(obj/item/I, mob/user, params)
	if(isscrewdriver(I))
		if(!a_left || !a_right)
			to_chat(user, "<span class='warning'>BUG:Assembly part missing, please report this!</span>")
			return
		a_left.toggle_secure()
		a_right.toggle_secure()
		secured = !secured
		if(secured)
			to_chat(user, "<span class='notice'>\The [src] is ready!</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] can now be taken apart!</span>")
		update_icon()
		return
	else if(I.IsSpecialAssembly())
		attach_special(I, user)
	else
		return ..()

/obj/item/device/assembly_holder/attack_self(mob/user)
	src.add_fingerprint(user)
	if(src.secured)
		if(!a_left || !a_right)
			to_chat(user, "<span class='warning'>Assembly part missing!</span>")
			return
		if(istype(a_left,a_right.type))//If they are the same type it causes issues due to window code
			switch(alert("Which side would you like to use?",,"Left","Right"))
				if("Left")	a_left.attack_self(user)
				if("Right")	a_right.attack_self(user)
			return
		else
			if(!istype(a_left,/obj/item/device/assembly/igniter))
				a_left.attack_self(user)
			if(!istype(a_right,/obj/item/device/assembly/igniter))
				a_right.attack_self(user)
	else
		var/turf/T = get_turf(src)
		if(!T)	return 0
		if(a_left)
			a_left:holder = null
			a_left.loc = T
		if(a_right)
			a_right:holder = null
			a_right.loc = T
		qdel(src)
	return


/obj/item/device/assembly_holder/process_activation(obj/D, normal = 1, special = 1)
	if(!D)	return 0
	if(!secured)
		visible_message("[bicon(src)] *beep* *beep*", "*beep* *beep*")
	if((normal) && (a_right) && (a_left))
		if(a_right != D)
			a_right.pulsed(0)
		if(a_left != D)
			a_left.pulsed(0)
	if(master)
		master.receive_signal()
	return 1

//********-Timer
/obj/item/device/assembly_holder/timer_igniter
	name = "timer-igniter assembly"

/obj/item/device/assembly_holder/timer_igniter/atom_init()
	. = ..()

	var/obj/item/device/assembly/igniter/ign = new(src)
	ign.secured = 1
	ign.holder = src
	var/obj/item/device/assembly/timer/tmr = new(src)
	tmr.time=5
	tmr.secured = 1
	tmr.holder = src
	START_PROCESSING(SSobj, tmr)
	a_left = tmr
	a_right = ign
	secured = 1
	update_icon()
	name = initial(name) + " ([tmr.time] secs)"

	loc.verbs += /obj/item/device/assembly_holder/timer_igniter/verb/configure

/obj/item/device/assembly_holder/timer_igniter/detached()
	loc.verbs -= /obj/item/device/assembly_holder/timer_igniter/verb/configure
	..()

/obj/item/device/assembly_holder/timer_igniter/verb/configure()
	set name = "Set Timer"
	set category = "Object"
	set src in usr

	if (!usr.incapacitated())
		var/obj/item/device/assembly_holder/holder
		if(istype(src,/obj/item/weapon/grenade/chem_grenade))
			var/obj/item/weapon/grenade/chem_grenade/gren = src
			holder=gren.detonator
		var/obj/item/device/assembly/timer/tmr = holder.a_left
		if(!istype(tmr,/obj/item/device/assembly/timer))
			tmr = holder.a_right
		if(!istype(tmr,/obj/item/device/assembly/timer))
			to_chat(usr, "<span class='notice'>This detonator has no timer.</span>")
			return

		if(tmr.timing)
			to_chat(usr, "<span class='notice'>Clock is ticking already.</span>")
		else
			var/ntime = input("Enter desired time in seconds", "Time", "5") as num
			if (ntime>0 && ntime<1000)
				tmr.time = ntime
				name = initial(name) + "([tmr.time] secs)"
				to_chat(usr, "<span class='notice'>Timer set to [tmr.time] seconds.</span>")
			else
				to_chat(usr, "<span class='notice'>Timer can't be [ntime<=0?"negative":"more than 1000 seconds"].</span>")
	else
		to_chat(usr, "<span class='notice'>You cannot do this while [usr.stat?"unconscious/dead":"restrained"].</span>")
