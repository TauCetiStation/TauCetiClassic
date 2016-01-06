/var/const/OPEN = 1
/var/const/CLOSED = 2

#define FIREDOOR_CLOSED_MOD	0.4
#define FIREDOOR_MAX_PRESSURE_DIFF 25 // kPa
/obj/machinery/door/firedoor
	name = "\improper Emergency Shutter"
	desc = "Emergency air-tight shutter, capable of sealing off breached areas."
	icon = 'tauceti/icons/obj/DoorHazard.dmi'
	icon_state = "door_open"
	req_one_access = list(access_atmospherics, access_engine_equip)
	opacity = 0
	density = 0
	layer = DOOR_LAYER - 0.1
	base_layer = DOOR_LAYER - 0.1
	glass = 1

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

/obj/machinery/door/firedoor/New()
	. = ..()
	for(var/obj/machinery/door/firedoor/F in loc)
		if(F != src)
			spawn(1)
				qdel(src)
			return .
	var/area/A = get_area(src)
	ASSERT(istype(A))

	A.all_doors.Add(src)
	areas_added = list(A)

	for(var/direction in cardinal)
		A = get_area(get_step(src,direction))
		if(istype(A) && !(A in areas_added))
			A.all_doors.Add(src)
			areas_added += A


/obj/machinery/door/firedoor/Destroy()
	for(var/area/A in areas_added)
		A.all_doors.Remove(src)
	. = ..()


/obj/machinery/door/firedoor/examine()
	set src in view()
	. = ..()
	if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
		usr << "<span class='warning'>WARNING: Current pressure differential is [pdiff]kPa! Opening door may result in injury!</span>"
	if( islist(users_to_open) && users_to_open.len)
		var/users_to_open_string = users_to_open[1]
		if(users_to_open.len >= 2)
			for(var/i = 2 to users_to_open.len)
				users_to_open_string += ", [users_to_open[i]]"
		usr << "These people have opened \the [src] during an alert: [users_to_open_string]."


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
	if(powered(ENVIRON))
		stat &= ~NOPOWER
	else
		stat |= NOPOWER
	return

/obj/machinery/door/firedoor/attack_paw(mob/user as mob)
	if(istype(user, /mob/living/carbon/alien/humanoid))
		if(blocked)
			user << "\red The door is sealed, it cannot be pried open."
			return
		else if(!density)
			return
		else
			user << "\red You force your claws between the doors and begin to pry them open..."
			playsound(src.loc, 'sound/effects/metal_creaking.ogg', 50, 0)
			if (do_after(user,40,target = src))
				if(!src) return
				open(1)
	return

/obj/machinery/door/firedoor/attack_animal(mob/user as mob)
	if(istype(user, /mob/living/simple_animal/hulk))
		if(blocked)
			if(prob(75))
				user.visible_message("\red <B>[user]</B> has punched \the <B>[src]!</B>",\
				"You punch \the [src]!",\
				"\red You feel some weird vibration!")
				playsound(user.loc, 'sound/effects/grillehit.ogg', 50, 1)
				return
			else
				user.say(pick("RAAAAAAAARGH!", "HNNNNNNNNNGGGGGGH!", "GWAAAAAAAARRRHHH!", "NNNNNNNNGGGGGGGGHH!", "AAAAAAARRRGH!" ))
				user.visible_message("\red <B>[user]</B> has destroyed some mechanic in \the <B>[src]!</B>",\
				"You destroy some mechanic in \the [src] door, which holds it in place!",\
				"\red <B>You feel some weird vibration!</B>")
				playsound(user.loc, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), 50, 1)
				qdel(src)
			return
		else if(!density)
			return
		else
			user << "\red You force your fingers between the doors and begin to pry them open..."
			playsound(src.loc, 'sound/effects/metal_creaking.ogg', 30, 1, -4)
			if (do_after(user,40,target = src))
				if(!src) return
				open(1)
	return

/obj/machinery/door/firedoor/attack_hand(mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.

	if(blocked)
		user << "<span class='warning'>\The [src] is welded solid!</span>"
		return

	if(!allowed(user))
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			user << "<span class='warning'>Access denied.</span>"
			return

	for(var/obj/O in src.loc)
		if(istype(O, /obj/machinery/door/airlock) && O.layer == (DOOR_LAYER + DOOR_CLOSED_MOD))
			return

	var/alarmed = 0

	for(var/area/A in areas_added)		//Checks if there are fire alarms in any areas associated with that firedoor
		if(A.fire || A.air_doors_activated)
			alarmed = 1

	var/answer = alert(user, "Would you like to [density ? "open" : "close"] this [src.name]?[ alarmed && density ? "\nNote that by doing so, you acknowledge any damages from opening this\n[src.name] as being your own fault, and you will be held accountable under the law." : ""]",\
	"\The [src]", "Yes, [density ? "open" : "close"]", "No")
	if(answer == "No")
		return
	if(user.stat || user.stunned || user.weakened || user.paralysis || (!user.canmove && !isAI(user)) || (get_dist(src, user) > 1  && !isAI(user)))
		user << "Sorry, you must remain able bodied and close to \the [src] in order to use it."
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
			if(alarmed)
				nextstate = CLOSED
				close()

/obj/machinery/door/firedoor/attackby(obj/item/weapon/C as obj, mob/user as mob)
	add_fingerprint(user)
	if(operating)
		return//Already doing something.
	if(istype(C, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = C
		if(W.remove_fuel(0, user))
			blocked = !blocked
			user.visible_message("\red \The [user] [blocked ? "welds" : "unwelds"] \the [src] with \a [W].",\
			"You [blocked ? "weld" : "unweld"] \the [src] with \the [W].",\
			"You hear something being welded.")
			playsound(src, 'sound/items/Welder.ogg', 100, 1)
			update_icon()
			return

	if(density && istype(C, /obj/item/weapon/screwdriver))
		hatch_open = !hatch_open
		user.visible_message("<span class='danger'>[user] has [hatch_open ? "opened" : "closed"] \the [src] maintenance hatch.</span>",
									"You have [hatch_open ? "opened" : "closed"] the [src] maintenance hatch.")
		update_icon()
		return

	if(blocked && istype(C, /obj/item/weapon/crowbar))
		if(!hatch_open)
			user << "<span class='danger'>You must open the maintenance hatch first!</span>"
		else
			user.visible_message("<span class='danger'>[user] is removing the electronics from \the [src].</span>",
									"You start to remove the electronics from [src].")
			if(do_after(user,30,target = src))
				if(blocked && density && hatch_open)
					playsound(src.loc, 'sound/items/Crowbar.ogg', 100, 1)
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
		user << "\red \The [src] is welded solid!"
		return

	if( istype(C, /obj/item/weapon/crowbar) || ( istype(C,/obj/item/weapon/twohanded/fireaxe) && C:wielded == 1 ) )
		if(operating)
			return

		if( blocked && istype(C, /obj/item/weapon/crowbar) )
			user.visible_message("\red \The [user] pries at \the [src] with \a [C], but \the [src] is welded in place!",\
			"You try to pry \the [src] [density ? "open" : "closed"], but it is welded in place!",\
			"You hear someone struggle and metal straining.")
			return

		user.visible_message("\red \The [user] starts to force \the [src] [density ? "open" : "closed"] with \a [C]!",\
				"You start forcing \the [src] [density ? "open" : "closed"] with \the [C]!",\
				"You hear metal strain.")
		if(do_after(user,30,target = src))
			if( istype(C, /obj/item/weapon/crowbar) )
				if( stat & (BROKEN|NOPOWER) || !density)
					user.visible_message("\red \The [user] forces \the [src] [density ? "open" : "closed"] with \a [C]!",\
					"You force \the [src] [density ? "open" : "closed"] with \the [C]!",\
					"You hear metal strain, and a door [density ? "open" : "close"].")
			else
				user.visible_message("\red \The [user] forces \the [ blocked ? "welded" : "" ] [src] [density ? "open" : "closed"] with \a [C]!",\
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

/obj/machinery/door/firedoor/close()
	latetoggle()
	layer = base_layer + FIREDOOR_CLOSED_MOD
	return ..()

/obj/machinery/door/firedoor/open()
	if(hatch_open)
		hatch_open = 0
		visible_message("The maintenance hatch of \the [src] closes.")
		update_icon()

	latetoggle()
	layer = base_layer
	return ..()


/obj/machinery/door/firedoor/do_animate(animation)
	switch(animation)
		if("opening")
			flick("door_opening", src)
		if("closing")
			flick("door_closing", src)
	return


/obj/machinery/door/firedoor/update_icon()
	overlays.Cut()
	if(density)
		icon_state = "door_closed"
		if(blocked)
			overlays += "welded"
		if(hatch_open)
			overlays += "hatch"
		if(pdiff_alert)
			overlays += "palert"
	else
		icon_state = "door_open"
		if(blocked)
			overlays += "welded_open"
	return

	// CHECK PRESSURE
/obj/machinery/door/firedoor/process()
	..()

	if(density)
		pdiff = getOPressureDifferential(get_turf(src))
		if(pdiff >= FIREDOOR_MAX_PRESSURE_DIFF)
			if(!pdiff_alert)
				pdiff_alert = 1
				update_icon()
		else
			if(pdiff_alert)
				pdiff_alert = 0
				update_icon()


/obj/machinery/door/firedoor/border_only
//These are playing merry hell on ZAS.  Sorry fellas :(
/*
	icon = 'icons/obj/doors/edge_Doorfire.dmi'
	glass = 1 //There is a glass window so you can see through the door
			  //This is needed due to BYOND limitations in controlling visibility
	heat_proof = 1
	air_properties_vary_with_direction = 1

	CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
		if(istype(mover) && mover.checkpass(PASSGLASS))
			return 1
		if(get_dir(loc, target) == dir) //Make sure looking at appropriate border
			if(air_group) return 0
			return !density
		else
			return 1

	CheckExit(atom/movable/mover as mob|obj, turf/target as turf)
		if(istype(mover) && mover.checkpass(PASSGLASS))
			return 1
		if(get_dir(loc, target) == dir)
			return !density
		else
			return 1


	update_nearby_tiles(need_rebuild)
		if(!air_master) return 0

		var/turf/simulated/source = loc
		var/turf/simulated/destination = get_step(source,dir)

		update_heat_protection(loc)

		if(istype(source)) air_master.tiles_to_update += source
		if(istype(destination)) air_master.tiles_to_update += destination
		return 1
*/

/obj/machinery/door/firedoor/multi_tile
	icon = 'icons/obj/doors/DoorHazard2x1.dmi'
	width = 2
