/obj/machinery/door/firedoor
	name = "Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'icons/obj/doors/DoorHazard.dmi'
	icon_state = "door_open"
	var/base_state = "door"
	req_one_access = list(access_atmospherics, access_engine_equip, access_paramedic)
	opacity = 0
	glass = 0
	always_transparent = TRUE
	allow_passglass = FALSE // for balance reasons
	density = FALSE
	layer = SAFEDOOR_LAYER
	base_layer = SAFEDOOR_LAYER
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
	if(world.time - last_bumped <= 10)
		return //Can bump-open one airlock per second. This is to prevent popup message spam.
	last_bumped = world.time
	if(istype(AM, /obj/mecha))
		var/obj/mecha/mecha = AM
		if (mecha.occupant)
			var/mob/M = mecha.occupant
			attack_hand(M)
	return 0


/obj/machinery/door/firedoor/power_change()
	if(powered(STATIC_ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_paw(mob/user)
	if(isxenoadult(user))
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

/obj/machinery/door/firedoor/attack_hulk(mob/living/user)
	. = ..()

	if(.)
		return .

	user.SetNextMove(CLICK_CD_INTERACT)

	if(blocked)
		if(user.hulk_scream(src))
			qdel(src)
		return

	if(density)
		to_chat(user, "<span class='userdanger'>You force your fingers between \
		 the doors and begin to pry them open...</span>")
		playsound(src, 'sound/machines/firedoor_open.ogg', VOL_EFFECTS_MASTER, 30, FALSE, null, -4)
		if (!user.is_busy() && do_after(user, 4 SECONDS, target = src) && !QDELETED(src))
			open(1)

/obj/machinery/door/firedoor/attack_animal(mob/user)
	..()
	if(density && !blocked)
		open()

/obj/machinery/door/firedoor/attack_hand(mob/user)
	add_fingerprint(user)
	if(user.a_intent == INTENT_GRAB && wedged_item && !user.get_active_hand())
		take_out_wedged_item(user)
		return

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
			if(alarmed && !blocked)
				nextstate = CLOSED
				close()

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C, mob/user)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.
	if(iswelding(C))
		var/obj/item/weapon/weldingtool/W = C
		if(W.use(0, user))
			blocked = !blocked
			user.visible_message("<span class='warning'>\The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].</span>",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			playsound(src, 'sound/items/Welder.ogg', VOL_EFFECTS_MASTER)
			update_icon()
			return

	if(density && isscrewing(C))
		hatch_open = !hatch_open
		user.visible_message("<span class='danger'>[user] has [hatch_open ? "opened" : "closed"] \the [src] maintenance hatch.</span>",
									"You have [hatch_open ? "opened" : "closed"] the [src] maintenance hatch.")
		playsound(src, 'sound/items/Screwdriver.ogg', VOL_EFFECTS_MASTER)
		update_icon()
		return

	if(blocked && isprying(C))
		if(!hatch_open)
			to_chat(user, "<span class='danger'>You must open the maintenance hatch first!</span>")
		else if(!user.is_busy(src))
			user.visible_message("<span class='danger'>[user] is removing the electronics from \the [src].</span>",
									"You start to remove the electronics from [src].")
			if(C.use_tool(src, user, 30, volume = 100))
				if(blocked && density && hatch_open)
					user.visible_message("<span class='danger'>[user] has removed the electronics from \the [src].</span>",
										"You have removed the electronics from [src].")

					deconstruct(TRUE)
		return

	if(blocked)
		to_chat(user, "<span class='warning'>\The [src] is welded solid!</span>")
		return

	if(isprying(C) || ( istype(C,/obj/item/weapon/fireaxe) && HAS_TRAIT(C, TRAIT_DOUBLE_WIELDED)))
		if(operating)
			return

		if( blocked && isprying(C) )
			user.visible_message("<span class='warning'>\The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!</span>",\
			"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
			"You hear someone struggle and metal straining.")
			return
		if(user.is_busy(src)) return
		user.visible_message("<span class='warning'>\The [user] starts to force \the [src] [density ? "open" : "closed"] with \a [C]!</span>",\
				"You start forcing \the [src] [density ? "open" : "closed"] with \the [C]!",\
				"You hear metal strain.")
		if(C.use_tool(src, user, 30, volume = 50))
			if( isprying(C) )
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

/obj/machinery/door/firedoor/deconstruct(disassembled = TRUE)
	if(flags & NODECONSTRUCT)
		return ..()
	take_out_wedged_item()
	new /obj/item/weapon/airalarm_electronics(loc)
	if(disassembled || prob(40))
		var/obj/structure/firedoor_assembly/FA = new (loc)
		if(disassembled)
			FA.anchored = TRUE
			FA.density = TRUE
			FA.wired = TRUE
			FA.update_icon()
	..()

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
	if(locate(/obj/structure/window/fulltile) in loc)
		base_state = "doorwin"
		layer_delta = SAFEDOOR_CLOSED_MOD_ABOVE_WINDOW
		opacity = TRUE
		always_transparent = FALSE
	else
		base_state = "door"
		layer_delta = SAFEDOOR_CLOSED_MOD_BEFORE_DOOR
		opacity = FALSE
		always_transparent = TRUE
	..()

	START_PROCESSING(SSmachines, src)
	latetoggle()

/obj/machinery/door/firedoor/do_afterclose()
	for(var/mob/living/L in get_turf(src))
		try_move_adjacent(L)
	..()

/obj/machinery/door/firedoor/do_open()
	..()
	alpha = initial(alpha)
	layer = base_layer
	if(hatch_open)
		hatch_open = FALSE
		visible_message("The maintenance hatch of \the [src] closes.")
		update_icon()
	latetoggle()

/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("[base_state]_opening", src)
		if("closing")
			flick("[base_state]_closing", src)
	return


/obj/machinery/door/firedoor/update_icon()
	var/list/firedoor_overlays = list()
	if(density)
		icon_state = "[base_state]_closed"
		if(hatch_open)
			firedoor_overlays += get_airlock_overlay("hatch", icon, FALSE)
		if(blocked)
			firedoor_overlays += get_airlock_overlay("welded", icon, FALSE)
		if(pdiff_alert)
			firedoor_overlays += get_airlock_overlay("palert", icon, FALSE)//сделать TRUE кога решится проблема со створками
		if(dir_alerts)
			for(var/d in 1 to 4)
				for(var/i in 1 to ALERT_STATES.len)
					if(dir_alerts[d] & (1<<(i-1)))
						firedoor_overlays += get_airlock_overlay("alert_[ALERT_STATES[i]]", icon, FALSE)//сделать TRUE кога решится проблема со створками
	else
		icon_state = "[base_state]_open"
		if(blocked)
			firedoor_overlays += get_airlock_overlay("welded_open", icon, FALSE)

	cut_overlays()
	add_overlay(firedoor_overlays)

	if(underlays.len)
		underlays.Cut()

	if(wedged_item)
		generate_wedge_overlay()

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
