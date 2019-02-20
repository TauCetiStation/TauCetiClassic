//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

/obj/machinery/power/emitter
	name = "Emitter"
	desc = "It is a heavy duty industrial laser."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "emitter-off"
	anchored = FALSE
	density = TRUE
	req_access = list(access_engine_equip)

	use_power = 0
	idle_power_usage = 10
	active_power_usage = 300
	allowed_checks = ALLOWED_CHECK_NONE

	var/active = FALSE
	var/powered = FALSE
	var/fire_delay = 100
	var/maximum_fire_delay = 100
	var/minimum_fire_delay = 20
	var/last_shot = 0
	var/shot_number = 0
	var/state = 0
	var/locked = FALSE

/obj/machinery/power/emitter/atom_init()
	. = ..()
	if(state == 2 && anchored)
		connect_to_network()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/power/emitter/atom_init_late(board_path = /obj/item/weapon/circuitboard/emitter)
	component_parts = list()
	component_parts += new board_path(null)
	component_parts += new /obj/item/weapon/stock_parts/micro_laser(null)
	component_parts += new /obj/item/weapon/stock_parts/manipulator(null)
	RefreshParts()

/obj/machinery/power/emitter/RefreshParts()
	var/max_firedelay = 120
	var/firedelay = 120
	var/min_firedelay = 24
	var/power_usage = 350
	for(var/obj/item/weapon/stock_parts/micro_laser/L in component_parts)
		max_firedelay -= 20 * L.rating
		min_firedelay -= 4 * L.rating
		firedelay -= 20 * L.rating
	maximum_fire_delay = max_firedelay
	minimum_fire_delay = min_firedelay
	fire_delay = firedelay
	for(var/obj/item/weapon/stock_parts/manipulator/M in component_parts)
		power_usage -= 50 * M.rating
	active_power_usage = power_usage

/obj/machinery/power/emitter/verb/rotate()
	set name = "Rotate"
	set category = "Object"
	set src in oview(1)

	if (src.anchored || usr:stat)
		to_chat(usr, "It is fastened to the floor!")
		return 0
	src.dir = turn(src.dir, 90)
	return 1

/obj/machinery/power/emitter/Destroy()
	message_admins("Emitter deleted at ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
	log_game("Emitter deleted at ([x],[y],[z])")
	investigate_log("<font color='red'>deleted</font> at ([x],[y],[z])","singulo")
	return ..()

/obj/machinery/power/emitter/update_icon()
	if (active && avail(active_power_usage))
		icon_state = "emitter-active"
	else if(panel_open)
		icon_state = "emitter-open"
	else
		icon_state = "emitter-off"

/obj/machinery/power/emitter/attack_hand(mob/user)
	. = ..()
	if(.)
		return
	user.SetNextMove(CLICK_CD_RAPID)
	activate(user)

/obj/machinery/power/emitter/proc/activate(mob/user)
	if(state == 2)
		if(!powernet)
			to_chat(user, "The emitter isn't connected to a wire.")
			return 1
		if(!locked || isobserver(user))
			if(active)
				active = 0
				to_chat(user, "You turn off the [src].")
				message_admins("Emitter turned off by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned off by [user.ckey]([user]) in ([x],[y],[z])")
				investigate_log("turned <font color='red'>off</font> by [user.key]","singulo")
			else
				if(panel_open)
					to_chat(user, "<span class='notice'>Close the maintenance panel first.</span>")
					return
				active = 1
				to_chat(user, "You turn on the [src].")
				shot_number = 0
				fire_delay = maximum_fire_delay
				message_admins("Emitter turned on by [key_name(user, user.client)](<A HREF='?_src_=holder;adminmoreinfo=\ref[user]'>?</A>) in ([x],[y],[z] - <A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)",0,1)
				log_game("Emitter turned on by [user.ckey]([user]) in ([x],[y],[z])")
				investigate_log("turned <font color='green'>on</font> by [user.key]","singulo")
			update_icon()
		else
			to_chat(user, "\red The controls are locked!")
	else
		to_chat(user, "\red The [src] needs to be firmly secured to the floor first.")
		return 1


/obj/machinery/power/emitter/emp_act(severity)//Emitters are hardened but still might have issues
//	add_load(1000)
/*	if((severity == 1)&&prob(1)&&prob(1))
		if(src.active)
			src.active = 0
			src.use_power = 1	*/
	return 1

/obj/machinery/containment_field/meteorhit()
	return 0

/obj/machinery/power/emitter/process()
	if(stat & (BROKEN))
		return
	if(src.state != 2 || (!powernet && active_power_usage))
		src.active = 0
		update_icon()
		return
	if(((src.last_shot + src.fire_delay) <= world.time) && (src.active == 1))

		if(!active_power_usage || avail(active_power_usage))
			add_load(active_power_usage)
			if(!powered)
				powered = 1
				update_icon()
				investigate_log("regained power and turned <font color='green'>on</font>","singulo")
		else
			if(powered)
				powered = 0
				update_icon()
				investigate_log("lost power and turned <font color='red'>off</font>","singulo")
			return

		src.last_shot = world.time
		if(src.shot_number < 3)
			src.fire_delay = get_burst_delay()
			src.shot_number ++
		else
			src.fire_delay = get_rand_burst_delay()
			src.shot_number = 0
		var/obj/item/projectile/beam/emitter/A = get_emitter_beam()
		playsound(src.loc, 'sound/weapons/emitter.ogg', 25, 1)
		if(prob(35))
			var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
			s.set_up(5, 1, src)
			s.start()
		A.dir = src.dir
		A.starting = get_turf(src)
		switch(dir)
			if(NORTH)
				A.original = locate(x, y+1, z)
			if(EAST)
				A.original = locate(x+1, y, z)
			if(WEST)
				A.original = locate(x-1, y, z)
			else // Any other
				A.original = locate(x, y-1, z)
		A.process()


/obj/machinery/power/emitter/attackby(obj/item/W, mob/user)

	if(istype(W, /obj/item/weapon/wrench))
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				state = 1
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] secures [src.name] to the floor.", \
					"You secure the external reinforcing bolts to the floor.", \
					"You hear a ratchet")
				src.anchored = 1
			if(1)
				state = 0
				playsound(src.loc, 'sound/items/Ratchet.ogg', 75, 1)
				user.visible_message("[user.name] unsecures [src.name] reinforcing bolts from the floor.", \
					"You undo the external reinforcing bolts.", \
					"You hear a ratchet")
				src.anchored = 0
			if(2)
				to_chat(user, "\red The [src.name] needs to be unwelded from the floor.")
		return

	if(istype(W, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/WT = W
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		switch(state)
			if(0)
				to_chat(user, "\red The [src.name] needs to be wrenched to the floor.")
			if(1)
				if(user.is_busy()) return
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to weld the [src.name] to the floor.", \
						"You start to weld the [src] to the floor.", \
						"You hear welding")
					if (do_after(user,20,target = src))
						if(!src || !WT.isOn()) return
						state = 2
						to_chat(user, "You weld the [src] to the floor.")
						connect_to_network()
				else
					to_chat(user, "\red You need more welding fuel to complete this task.")
			if(2)
				if(user.is_busy()) return
				if (WT.remove_fuel(0,user))
					playsound(src.loc, 'sound/items/Welder2.ogg', 50, 1)
					user.visible_message("[user.name] starts to cut the [src.name] free from the floor.", \
						"You start to cut the [src] free from the floor.", \
						"You hear welding")
					if (do_after(user,20,target = src))
						if(!src || !WT.isOn()) return
						state = 1
						to_chat(user, "You cut the [src] free from the floor.")
						disconnect_from_network()
				else
					to_chat(user, "\red You need more welding fuel to complete this task.")
		return

	if(istype(W, /obj/item/weapon/card/id) || istype(W, /obj/item/device/pda))
		if(emagged)
			to_chat(user, "\red The lock seems to be broken")
			return
		if(src.allowed(user))
			if(active)
				src.locked = !src.locked
				to_chat(user, "The controls are now [src.locked ? "locked." : "unlocked."]")
			else
				src.locked = 0 //just in case it somehow gets locked
				to_chat(user, "\red The controls can only be locked when the [src] is online")
		else
			to_chat(user, "\red Access denied.")
		return


	if(istype(W, /obj/item/weapon/card/emag) && !emagged)
		locked = 0
		emagged = 1
		user.visible_message("[user.name] emags the [src.name].","\red You short out the lock.")
		return

	if(istype(W, /obj/item/weapon/screwdriver))
		if(active)
			to_chat(user, "Turn off the [src] first.")
			return
		if(default_deconstruction_screwdriver(user, "emitter-open", "emitter-off", W))
			return

	if(exchange_parts(user, W))
		return

	if(default_pry_open(W))
		return

	default_deconstruction_crowbar(W)

	..()
	return

/obj/machinery/power/emitter/proc/get_rand_burst_delay()
	return rand(minimum_fire_delay, maximum_fire_delay)

/obj/machinery/power/emitter/proc/get_burst_delay()
	return 2

/obj/machinery/power/emitter/proc/get_emitter_beam()
	return new /obj/item/projectile/beam/emitter(get_turf(src))
