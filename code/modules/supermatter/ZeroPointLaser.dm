//new supermatter lasers

/obj/machinery/zero_point_emitter
	name = "Zero-point laser"
	desc = "A super-powerful laser."
	icon = 'icons/obj/engine.dmi'
	icon_state = "laser"
	anchored = FALSE
	density = TRUE
	req_access = list(access_research)
	frequency = 1

	use_power = 1
	idle_power_usage = 10
	active_power_usage = 300
	interact_offline = TRUE
	allowed_checks = ALLOWED_CHECK_NONE

	var/active = FALSE
	var/fire_delay = 100
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = FALSE
	var/energy = 0.0001
	var/freq = 50000
	var/id

/obj/machinery/zero_point_emitter/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/zero_point_emitter/update_icon()
	if (active && !(stat & (NOPOWER|BROKEN)))
		icon_state = "laser"//"emitter_+a"
	else
		icon_state = "laser"//"emitter"

/obj/machinery/zero_point_emitter/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	if(state == 2)
		if(!locked || IsAdminGhost(user))
			if(active == 1)
				active = 0
				to_chat(user, "You turn off the [src].")
				use_power = 1
			else
				active = 1
				to_chat(user, "You turn on the [src].")
				shot_number = 0
				fire_delay = 100
				use_power = 2
			update_icon()
		else
			to_chat(user, "<span class='warning'>The controls are locked!</span>")
			return 1
	else
		to_chat(user, "<span class='warning'>The [src] needs to be firmly secured to the floor first.</span>")
		return 1


/obj/machinery/zero_point_emitter/emp_act(severity)//Emitters are hardened but still might have issues
	use_power(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1	*/
	return 1

/obj/machinery/zero_point_emitter/process()
	if(stat & (NOPOWER|BROKEN))
		return
	if(src.state != 2)
		src.active = 0
		return
	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))
		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = 2
			src.shot_number ++
		else
			src.fire_delay = rand(20,100)
			src.shot_number = 0
		use_power(1000)
		var/obj/item/projectile/beam/emitter/A = new /obj/item/projectile/beam/emitter( src.loc )
		playsound(src, 'sound/weapons/guns/gunpulse_emitter.ogg', VOL_EFFECTS_MASTER, 25)
		if(prob(35))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
		A.dir = src.dir
		switch(dir)
			if(NORTH)
				A.yo = 20
				A.xo = 0
			if(EAST)
				A.yo = 0
				A.xo = 20
			if(WEST)
				A.yo = 0
				A.xo = -20
			else // Any other
				A.yo = -20
				A.xo = 0
		A.process()	//TODO: Carn: check this out


/obj/machinery/zero_point_emitter/attackby(obj/item/W, mob/user)

	if(iswrench(W))
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src, 'sound/items/Ratchet.ogg', VOL_EFFECTS_MASTER)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				to_chat(user, "<span class='warning'>The [src.name] needs to be unwelded from the floor.</span>")
		return

	if(iswelder(W))
		var/obj/item/weapon/weldingtool/WT = W
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				to_chat(user, "<span class='warning'>The [src.name] needs to be wrenched to the floor.</span>")
			if(1)
				if(user.is_busy()) return
				if(WT.use(0,user))
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"You start to weld the [src] to the floor.", \
						"You hear welding")
					if(WT.use_tool(src, user, 20, volume = 50))
						state = 2
						to_chat(user, "You weld the [src] to the floor.")
				else
					to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
			if(2)
				if(user.is_busy()) return
				if(WT.use(0,user))
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"You start to cut the [src] free from the floor.", \
						"You hear welding")
					if(WT.use_tool(src, user, 20, volume = 50))
						state = 1
						to_chat(user, "You cut the [src] free from the floor.")
				else
					to_chat(user, "<span class='warning'>You need more welding fuel to complete this task.</span>")
		return

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "<span class='warning'>The lock seems to be broken</span>")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "<span class='warning'>The controls can only be locked when the [src] is online</span>")
		else
			to_chat(user, "<span class='warning'>Access denied.</span>")
		return
	..()
	return

/obj/machinery/zero_point_emitter/emag_act(obj/item/W, mob/user)
	if(!emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags the [src.name].","<span class='warning'>You short out the lock.</span>")
		return TRUE
	return FALSE

/obj/machinery/zero_point_emitter/power_change()
	..()
	update_icon()
	return

/obj/machinery/zero_point_emitter/Topic(href, href_list)
	. = ..()
	if(!.)
		return

	if( href_list["input"] )
		var/i = text2num(href_list["input"])
		var/d = i
		var/new_power = energy + d
		new_power = max(new_power,0.0001)	//lowest possible value
		new_power = min(new_power,0.01)		//highest possible value
		energy = new_power

		for(var/obj/machinery/computer/lasercon/comp in machines)
			if(comp.id == src.id)
				comp.updateDialog()
	else if( href_list["online"] )
		active = !active

		for(var/obj/machinery/computer/lasercon/comp in machines)
			if(comp.id == src.id)
				comp.updateDialog()
	else if( href_list["freq"] )
		var/amt = text2num(href_list["freq"])
		var/new_freq = frequency + amt
		new_freq = max(new_freq,1)		//lowest possible value
		new_freq = min(new_freq,20000)	//highest possible value
		frequency = new_freq

		for(var/obj/machinery/computer/lasercon/comp in machines)
			if(comp.id == src.id)
				comp.updateDialog()

	updateUsrDialog()
