/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	if(air_group || (height==0))
		return 1
	if(istype(mover, /obj/item/projectile) || mover.throwing)
		return (!density || lying)
	if(mover.checkpass(PASSMOB))
		return 1
	if(buckled == mover)
		return 1
	if(ismob(mover))
		var/mob/moving_mob = mover
		if ((other_mobs && moving_mob.other_mobs))
			return 1
		if (mover == buckled_mob)
			return 1
	return (!mover.density || !density || lying)

/mob/proc/setMoveCooldown(timeout)
	if(client)
		client.move_delay = max(world.time + timeout, client.move_delay)

/client/North()
	..()

/client/South()
	..()

/client/West()
	..()

/client/East()
	..()

/client/Northeast()
	swap_hand()
	return

/client/Southeast()
	attack_self()
	return

/client/Southwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		C.toggle_throw_mode()
	else
		to_chat(usr, "\red This mob type cannot throw items.")
	return

/client/Northwest()
	if(iscarbon(usr))
		var/mob/living/carbon/C = usr
		if(!C.get_active_hand())
			to_chat(usr, "\red You have nothing to drop in your hand.")
			return
		drop_item()
	else
		to_chat(usr, "\red This mob type cannot drop items.")
	return

//This gets called when you press the delete button.
/client/verb/delete_key_pressed()
	set hidden = 1

	if(!usr.pulling)
		to_chat(usr, "\blue You are not pulling anything.")
		return
	usr.stop_pulling()

/client/verb/swap_hand()
	set hidden = 1
	if(istype(mob, /mob/living/carbon))
		mob:swap_hand()
	if(istype(mob,/mob/living/silicon/robot))
		var/mob/living/silicon/robot/R = mob
		R.cycle_modules()
	return



/client/verb/attack_self()
	set hidden = 1
	if(mob)
		mob.mode()
	return


/client/verb/toggle_throw_mode()
	set hidden = 1
	if(!istype(mob, /mob/living/carbon))
		return
	if (!mob.stat && isturf(mob.loc) && !mob.restrained())
		mob:toggle_throw_mode()
	else
		return


/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob) && mob.stat == CONSCIOUS && isturf(mob.loc))
		return mob.drop_item()
	return


/client/Center()
	/* No 3D movement in 2D spessman game. dir 16 is Z Up
	if (isobj(mob.loc))
		var/obj/O = mob.loc
		if (mob.canmove)
			return O.relaymove(mob, 16)
	*/
	return

/client/proc/Move_object(direct)
	if(mob && mob.control_object)
		if(mob.control_object.density)
			step(mob.control_object,direct)
			if(!mob.control_object)	return
			mob.control_object.dir = direct
		else
			mob.control_object.loc = get_step(mob.control_object,direct)
	return


/client/Move(n, direct)
	if(!mob)
		return // Moved here to avoid nullrefs below

	if(mob.control_object)	Move_object(direct)

	if(isobserver(mob))	return mob.Move(n,direct)

	if(moving)	return 0

	if(world.time < move_delay)	return

	if(mob.stat==DEAD)	return

/*	// handle possible spirit movement
	if(istype(mob,/mob/spirit))
		var/mob/spirit/currentSpirit = mob
		return currentSpirit.Spirit_Move(direct) */

	// handle possible AI movement
	if(isAI(mob))
		return AIMove(n,direct,mob)

	if(mob.monkeyizing)	return//This is sota the goto stop mobs from moving var

	if(isliving(mob))
		var/mob/living/L = mob
		if(L.incorporeal_move)//Move though walls
			Process_Incorpmove(direct)
			return
		if(mob.client)
			if(mob.client.view != world.view)
				if(locate(/obj/item/weapon/gun/energy/sniperrifle, mob.contents))		// If mob moves while zoomed in with sniper rifle, unzoom them.
					var/obj/item/weapon/gun/energy/sniperrifle/s = locate() in mob
					if(s.zoom)
						s.zoom()

	if(Process_Grab())
		return

	if(istype(mob.buckled, /obj/vehicle))
		//manually set move_delay for vehicles so we don't inherit any mob movement penalties
		//specific vehicle move delays are set in code\modules\vehicles\vehicle.dm
		move_delay = world.time
		//drunk driving
		if(mob.confused)
			direct = pick(cardinal)
		return mob.buckled.relaymove(mob,direct)

	if(!mob.canmove)
		return

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(isobj(mob.loc) || ismob(mob.loc))//Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return 0

	if(isturf(mob.loc))

		if(mob.restrained())//Why being pulled while cuffed prevents you from moving
			for(var/mob/M in range(mob, 1))
				if(M.pulling == mob)
					if(!M.restrained() && M.stat == CONSCIOUS && M.canmove && mob.Adjacent(M))
						to_chat(src, "\blue You're restrained! You can't move!")
						return 0
					else
						M.stop_pulling()

		if(mob.pinned.len)
			to_chat(src, "\blue You're pinned to a wall by [mob.pinned[1]]!")
			return 0

		move_delay = world.time//set move delay
		mob.last_move_intent = world.time + 10
		switch(mob.m_intent)
			if("run")
				if(mob.drowsyness > 0)
					move_delay += 6
				move_delay += 1+config.run_speed
			if("walk")
				move_delay += 7+config.walk_speed
		move_delay += mob.movement_delay()

		if(mob.pulledby || mob.buckled) // Wheelchair driving!
			if(istype(mob.loc, /turf/space))
				return // No wheelchair driving in space
			if(istype(mob.pulledby, /obj/structure/stool/bed/chair/wheelchair))
				return mob.pulledby.relaymove(mob, direct)
			else if(istype(mob.buckled, /obj/structure/stool/bed/chair/wheelchair))
				if(ishuman(mob.buckled))
					var/mob/living/carbon/human/driver = mob.buckled
					var/obj/item/organ/external/l_hand = driver.bodyparts_by_name[BP_L_ARM]
					var/obj/item/organ/external/r_hand = driver.bodyparts_by_name[BP_R_ARM]
					if((!l_hand || (l_hand.status & ORGAN_DESTROYED)) && (!r_hand || (r_hand.status & ORGAN_DESTROYED)))
						return // No hands to drive your chair? Tough luck!
				move_delay += 2
				return mob.buckled.relaymove(mob,direct)

		//We are now going to move
		moving = 1
		//Something with pulling things
		if(locate(/obj/item/weapon/grab, mob))
			move_delay = max(move_delay, world.time + 7)
			var/list/L = mob.ret_grab()
			if(istype(L, /list))
				if(L.len == 2)
					L -= mob
					var/mob/M = L[1]
					if(M)
						if ((get_dist(mob, M) <= 1 || M.loc == mob.loc))
							var/turf/T = mob.loc
							. = ..()
							if (isturf(M.loc))
								var/diag = get_dir(mob, M)
								if ((diag - 1) & diag)
								else
									diag = null
								if ((get_dist(mob, M) > 1 || diag))
									step(M, get_dir(M.loc, T))
				else
					for(var/mob/M in L)
						M.other_mobs = 1
						if(mob != M)
							M.animate_movement = 3
					for(var/mob/M in L)
						spawn( 0 )
							step(M, direct)
							return
						spawn( 1 )
							M.other_mobs = null
							M.animate_movement = 2
							return

		else if(mob.confused)
			step(mob, pick(cardinal))
		else
			. = mob.SelfMove(n, direct)

		for (var/obj/item/weapon/grab/G in mob)
			if (G.state == GRAB_NECK)
				mob.set_dir(reverse_dir[direct])
			G.adjust_position()
		for (var/obj/item/weapon/grab/G in mob.grabbed_by)
			G.adjust_position()

		moving = 0
		if(mob && .)
			mob.throwing = 0

		return .

	return

/mob/proc/SelfMove(turf/n, direct)
	return Move(n, direct)

/mob/Move(n,direct)
	//Camera control: arrow keys.
	if (machine && istype(machine, /obj/machinery/computer/security))
		var/obj/machinery/computer/security/console = machine
		var/turf/T = get_turf(console.current)
		for(var/i;i<10;i++)
			T = get_step(T,direct)
		console.jump_on_click(src,T)
		return

	if (pinned.len)
		return

	return ..(n,direct)

///Process_Grab()
///Called by client/Move()
///Checks to see if you are grabbing anything and if moving will affect your grab.
/client/proc/Process_Grab()
	for(var/obj/item/weapon/grab/G in list(mob.l_hand, mob.r_hand))
		if(G.state == GRAB_KILL) //no wandering across the station/asteroid while choking someone
			mob.visible_message("<span class='warning'>[mob] lost \his tight grip on [G.affecting]'s neck!</span>")
			G.hud.icon_state = "kill"
			G.state = GRAB_NECK

///Process_Incorpmove
///Called by client/Move()
///Allows mobs to run though walls
/client/proc/Process_Incorpmove(direct)
	var/turf/mobloc = get_turf(mob)
	if(!isliving(mob))
		return
	var/mob/living/L = mob
	switch(L.incorporeal_move)
		if(1)
			L.loc = get_step(L, direct)
			L.dir = direct
		if(2)
			if(prob(50))
				var/locx
				var/locy
				switch(direct)
					if(NORTH)
						locx = mobloc.x
						locy = (mobloc.y+2)
						if(locy>world.maxy)
							return
					if(SOUTH)
						locx = mobloc.x
						locy = (mobloc.y-2)
						if(locy<1)
							return
					if(EAST)
						locy = mobloc.y
						locx = (mobloc.x+2)
						if(locx>world.maxx)
							return
					if(WEST)
						locy = mobloc.y
						locx = (mobloc.x-2)
						if(locx<1)
							return
					else
						return
				L.loc = locate(locx,locy,mobloc.z)
				spawn(0)
					var/limit = 2//For only two trailing shadows.
					for(var/turf/T in getline(mobloc, L.loc))
						spawn(0)
							anim(T,L,'icons/mob/mob.dmi',,"shadow",,L.dir)
						limit--
						if(limit<=0)	break
			else
				spawn(0)
					anim(mobloc,mob,'icons/mob/mob.dmi',,"shadow",,L.dir)
				L.loc = get_step(L, direct)
			L.dir = direct
	return 1


///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
///Process_Spacemove
///Called by /client/Move()
///For moving in space
///Return 1 for movement 0 for none
/mob/Process_Spacemove(movement_dir = 0)

	if(..())
		return 1

	var/atom/movable/dense_object_backup
	for(var/atom/A in orange(1, get_turf(src)))
		if(isarea(A))
			continue

		else if(isturf(A))
			var/turf/turf = A
			if(istype(turf,/turf/space))
				continue

			if(!turf.density && !mob_negates_gravity())
				continue

			return 1

		else
			var/atom/movable/AM = A
			if(AM == buckled || AM.type == /obj/effect/portal/tsci_wormhole) //hardcoded type check, since idk if we need such feature for something else at all.
				continue
			if(AM.density)
				if(AM.anchored)
					return 1
				if(pulling == AM)
					continue
				dense_object_backup = AM

	if(movement_dir && dense_object_backup)
		if(dense_object_backup.newtonian_move(turn(movement_dir, 180))) //You're pushing off something movable, so it moves
			to_chat(src, "<span class='info'>You push off of [dense_object_backup] to propel yourself.</span>")

		return 1
	return 0

/mob/proc/mob_has_gravity(turf/T)
	return has_gravity(src, T)

/mob/proc/mob_negates_gravity()
	return 0

/mob/proc/update_gravity()
	return

/mob/proc/Move_Pulled(atom/A)
	if (!canmove || restrained() || !pulling)
		return
	if (pulling.anchored)
		return
	if (!pulling.Adjacent(src))
		return
	if (A == loc && pulling.density)
		return
	if (!Process_Spacemove(get_dir(pulling.loc, A)))
		return
	if (ismob(pulling))
		var/mob/M = pulling
		var/atom/movable/t = M.pulling
		M.stop_pulling()
		step(pulling, get_dir(pulling.loc, A))
		if(M)
			M.start_pulling(t)
	else
		step(pulling, get_dir(pulling.loc, A))
	return
