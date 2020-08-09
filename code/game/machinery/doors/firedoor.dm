/obj/machinery/door/firedoor
	name = "Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip, access_paramedic)
	opacity = 0
	density = 0
	layer = FIREDOOR_LAYER
	base_layer = FIREDOOR_LAYER
	glass = 0
	door_open_sound  = 'sound/machines/firedoor_open.ogg'
	door_close_sound = 'sound/machines/firedoor_close.ogg'

	//These are frequenly used with windows, so make sure zones can pass.
	//Generally if a firedoor is at a place where there should be a zone boundery then there will be a regular door underneath it.
	block_air_zones = 0

	var/hatch_open = 0
	var/blocked = 0
	var/nextstate = null
	var/net_id
	var/list/areas_added
	var/list/users_to_open
	var/pdiff_alert = 0
	var/pdiff = 0

	var/lockdown = 0 // When the door has detected a problem, it locks.
	var/next_process_time = 0
	var/list/tile_info[4]
	var/list/dir_alerts[4] // 4 dirs, bitflags

	// MUST be in same order as FIREDOOR_ALERT_*
	var/list/ALERT_STATES=list(
		"hot",
		"cold"
	)

/obj/machinery/door/firedoor/atom_init()
	. = ..()
	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			return INITIALIZE_HINT_QDEL
	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		A = get_area(get_step(src, direction))
		if(istype(A) && !(A in areas_added))
			A.all_doors.Add(src)
			areas_added += A


/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	return ..()


/obj/machinery/door/firedoor/examine(mob/user)
	..()
	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		to_chat(user, "<span class='warning'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>")
	if(islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		to_chat(user, "These people have opened \the [src] during an alert: [users_to_open_string].")


/obj/machinery/door/firedoor/Bumped(atom/AM)
	if(p_open || operating)
		return
	if(!density)
		return ..()
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if (mecha.occupant)
			var/mob/M = mecha.occupant
			if(world.time - M.last_bumped <= 10) return //Can bump-open one airlock per second. This is to prevent popup message spam.
			M.last_bumped = world.time
			attack_hand(M)
	return 0


/obj/machinery/door/firedoor/power_change()
	if(powered(STATIC_ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_paw(mob/user)
	if(istype(user, /mob/living/carbon/xenomorph/humanoid))
		if(blocked)
			to_chat(user, "<span class='warning'>The door is sealed, it cannot be pried open.</span>")
			return
		else if(!density)
			return
		else if(!user.is_busy(src))
			to_chat(user, "<span class='warning'>You force your claws between the doors and begin to pry them open...</span>")
			playsound(src, 'sound/effects/metal_creaking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			if (do_after(user,40,target = src) && src)
				open(1)
	return

/obj/machinery/door/firedoor/attack_animal(mob/user)
	if(istype(user, /mob/living/simple_animal/hulk))
		var/mob/living/simple_animal/hulk/H = user
		H.attack_hulk(src)

/obj/machinery/door/firedoor/attack_hand(mob/user)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	if(!allowed(user))
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			to_chat(user, "<span class='warning'>Access denied.</span>")
			return

	var/alarmed = 0

	for(var/area/A in areas_added)		//Checks if there are fire alarms in any areas associated with that firedoor
		if(A.fire || A.air_doors_activated)
			alarmed = 1
			break

	var/answer = alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density ? "\nNote that by doing so, you acknowledge any damages from opening this\n[src.name] as being your own fault, and you will be held accountable under the law." : ""]",\
	"\The [src]", "Yes, [density ? "open" : "close"]", "No")
	if(answer == "No")
		return
	if(user.incapacitated() || (get_dist(src, user) > 1  && !isAI(user)))
		to_chat(user, "Sorry, you must remain able bodied and close to \the [src] in order to use it.")
		return

	var/needs_to_close = 0
	if(density)
		if(alarmed)
			needs_to_close = 1
		spawn()
			open()
	else
		spawn()
			close()

	if(needs_to_close)
		spawn(50)
			alarmed = 0
			for(var/area/A in areas_added)		//Just in case a fire alarm is turned off while the firedoor is going through an autoclose cycle
				if(A.fire || A.air_doors_activated)
					alarmed = 1
					break
			if(alarmed)
				nextstate = CLOSED
				close()

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C, mob/user)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.
	if(iswelder(C))
		var/obj/item/weapon/weldingtool/W = C
		if(W.use(0, user))
			blocked = !blocked
			user.visible_message("<span class='warning'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].</span>",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
			update_icon()
			return

	if(density && isscrewdriver(C))
		hatch_open = !hatch_open
		user.visible_message("<span class='danger'>[user] has [hatch_open ? "opened" : "closed"] \the [src] maintenance hatch.</span>",
									"You have [hatch_open ? "opened" : "closed"] the [src] maintenance hatch.")
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		update_icon()
		return

	if(blocked && iscrowbar(C))
		if(!hatch_open)
			to_chat(user, "<span class='danger'>You must open the maintenance hatch first!</span>")
		else if(!user.is_busy(src))
			user.visible_message("<span class='danger'>[user] is removing the electronics from \the [src].</span>",
									"You start to remove the electronics from [src].")
			if(C.use_tool(src, user, 30, volume = 100))
				if(blocked && density && hatch_open)
					user.visible_message("<span class='danger'>[user] has removed the electronics from \the [src].</span>",
										"You have removed the electronics from [src].")

					new/obj/item/weapon/airalarm_electronics(src.loc)

					var/obj/structure/firedoor_assembly/FA = new/obj/structure/firedoor_assembly(src.loc)
					FA.anchored = 1
					FA.density = 1
					FA.wired = 1
					FA.update_icon()
					qdel(src)
		return

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	if( iscrowbar(C) || ( istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1 ) )
		if(operating)
			return

		if( blocked && iscrowbar(C) )
			user.visible_message("<span class='warning'>\The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!</span>",\
			"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
			"You hear someone struggle and metal straining.")
			return
		if(user.is_busy(src)) return
		user.visible_message("<span class='warning'>\The [user] starts to force \the [src] [density ? "open" : "closed"] with \a [C]!</span>",\
				"You start forcing \the [src] [density ? "open" : "closed"] with \the [C]!",\
				"You hear metal strain.")
		if(C.use_tool(src, user, 30, volume = 50))
			if( iscrowbar(C) )
				if( stat & (BROKEN|NOPOWER) || !density)
					user.visible_message("<span class='warning'>\The [user] forces \the [src] [density ? "open" : "closed"] with \a [C]!</span>",\
					"You force \the [src] [density ? "open" : "closed"] with \the [C]!",\
					"You hear metal strain, and a door [density ? "open" : "close"].")
			else
				user.visible_message("<span class='warning'>\The [user] forces \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \a [C]!</span>",\
					"You force \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \the [C]!",\
					"You hear metal strain and groan, and a door [density ? "open" : "close"].")
			if(density)
				spawn(0)
					open()
			else
				spawn(0)
					close()
			return


/obj/machinery/door/firedoor/proc/latetoggle()
	if(operating || stat & NOPOWER || !nextstate)
		return
	switch(nextstate)
		if(OPEN)
			nextstate = null
			open()
		if(CLOSED)
			nextstate = null
			close()
	return

/obj/machinery/door/firedoor/do_close()
	..()
	layer = base_layer + FIREDOOR_CLOSED_MOD
	START_PROCESSING(SSmachines, src)
	latetoggle()

/obj/machinery/door/firedoor/do_open()
	..()
	layer = base_layer
	if(hatch_open)
		hatch_open = FALSE
		visible_message("The maintenance hatch of \the [src] closes.")
		update_icon()
	latetoggle()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	return


/obj/machinery/door/firedoor/update_icon()
	cut_overlays()
	if(density)
		icon_state = "door_closed"
		if(hatch_open)
			add_overlay("hatch")
		if(blocked)
			add_overlay("welded")
		if(pdiff_alert)
			add_overlay("palert")
		if(dir_alerts)
			for(var/d in 1 to 4)
				var/cdir = cardinal[d]
				for(var/i in 1 to ALERT_STATES.len)
					if(dir_alerts[d] & (1<<(i-1)))
						add_overlay(new/icon(icon,"alert_[ALERT_STATES[i]]", dir=cdir))
	else
		icon_state = "door_open"
		if(blocked)
			add_overlay("welded_open")
	SSdemo.mark_dirty(src)

	// CHECK PRESSURE
/obj/machinery/door/firedoor/process()
	if(density)
		if(next_process_time <= world.time)
			next_process_time = world.time + 100		// 10 second delays between process updates
			var/changed = 0
			lockdown=0
			// Pressure alerts
			pdiff = getOPressureDifferential(src.loc)
			if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
				lockdown = 1
				if(!pdiff_alert)
					pdiff_alert = 1
					changed = 1 // update_icon()
			else
				if(pdiff_alert)
					pdiff_alert = 0
					changed = 1 // update_icon()

			tile_info = getCardinalAirInfo(src.loc,list("temperature","pressure"))
			var/old_alerts = dir_alerts
			for(var/index in 1 to 4)
				var/list/tileinfo=tile_info[index]
				if(tileinfo==null)
					continue // Bad data.
				var/celsius = convert_k2c(tileinfo[1])

				var/alerts=0

				// Temperatures
				if(celsius >= FIREDOOR_MAX_TEMP)
					alerts |= FIREDOOR_ALERT_HOT
					lockdown = 1
				else if(celsius <= FIREDOOR_MIN_TEMP)
					alerts |= FIREDOOR_ALERT_COLD
					lockdown = 1

				dir_alerts[index]=alerts

			if(dir_alerts != old_alerts)
				changed = 1
			if(changed)
				update_icon()
	else
		return PROCESS_KILL
