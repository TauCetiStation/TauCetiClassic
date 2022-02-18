/mob/CanPass(atom/movable/mover, turf/target, height=0, air_group=0)
	var/retVal = SEND_SIGNAL(src, COMSIG_ATOM_CANPASS, mover, target, height, air_group)
	if(retVal & COMPONENT_CANTPASS)
		return FALSE
	else if(retVal & COMPONENT_CANPASS)
		return TRUE

	if(air_group || (height==0))
		return 1
	if(istype(mover, /obj/item/projectile) || mover.throwing)
		return (!density || lying)
	if(mover.checkpass(PASSMOB) || checkpass(PASSMOB))
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

/client/verb/drop_item()
	set hidden = 1
	if(!isrobot(mob) && mob.stat == CONSCIOUS && isturf(mob.loc))
		return mob.drop_item()
	return

/client/proc/Move_object(direct)
	if(mob?.control_object)
		if(mob.control_object.density)
			step(mob.control_object, direct)
			if(!mob.control_object)
				return
			mob.control_object.set_dir(direct)
		else
			mob.control_object.forceMove(get_step(mob.control_object, direct))

/client/Move(new_loc, direct, forced = FALSE)
	if(world.time < move_delay) //do not move anything ahead of this check please
		return FALSE

	next_move_dir_add = 0
	next_move_dir_sub = 0
	var/old_move_delay = move_delay
	move_delay = world.time + world.tick_lag

	if(!mob || !mob.loc)
		return FALSE

	if(!new_loc || !direct)
		return FALSE

	if(mob.notransform)
		return FALSE

	if(mob.control_object)
		return Move_object(direct)

	if(!forced)
		if(moving || mob.throwing)
			return FALSE

	if(!isliving(mob))
		return mob.Move(new_loc, direct)

	if(!forced && mob.stat == DEAD)
		mob.ghostize()
		return FALSE

	var/mob/living/L = mob
	if(L.incorporeal_move)//Move though walls
		Process_Incorpmove(direct)
		return FALSE

	Process_Grab()

	if(mob.remote_control)//we're controlling something, our movement is relayed to it
		return mob.remote_control.relaymove(mob, direct)

	if(isAI(mob))
		return AIMove(new_loc, direct, mob)

	if(!forced && !mob.canmove)
		return FALSE

	if(istype(mob.buckled, /obj/vehicle))
		//manually set move_delay for vehicles so we don't inherit any mob movement penalties
		//specific vehicle move delays are set in code\modules\vehicles\vehicle.dm
		move_delay = world.time
		//drunk driving
		if(mob.confused)
			direct = mob.confuse_input(direct)
		return mob.buckled.relaymove(mob,direct)

	if(!mob.lastarea)
		mob.lastarea = get_area(mob.loc)

	if(isobj(mob.loc) || ismob(mob.loc)) //Inside an object, tell it we moved
		var/atom/O = mob.loc
		return O.relaymove(mob, direct)

	if(!mob.Process_Spacemove(direct))
		return FALSE

	if(mob.restrained()) //Why being pulled while cuffed prevents you from moving
		if(mob.pulledby)
			if(!(world.time % 5))
				to_chat(src, "<span class='notice'>You're incapacitated! You can't move!</span>")
			return FALSE

	if(mob.pinned.len)
		if(!(world.time % 5))
			to_chat(src, "<span class='notice'>You're pinned to a wall by [mob.pinned[1]]!</span>")
		return FALSE

	if(SEND_SIGNAL(mob, COMSIG_CLIENTMOB_MOVE, new_loc, direct) & COMPONENT_CLIENTMOB_BLOCK_MOVE)
		return FALSE

	//We are now going to move
	var/add_delay = 0
	mob.last_move_intent = world.time + 10
	switch(mob.m_intent)
		if("run")
			add_delay += RUN_SPEED_SLOWDOWN + config.run_speed
		if("walk")
			add_delay += WALK_SPEED_SLOWDOWN + config.walk_speed
	if(mob.drowsyness > 0)
		add_delay += DROWSY_SPEED_SLOWDOWN
	add_delay += mob.movement_delay()

	mob.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay * ((NSCOMPONENT(direct) && EWCOMPONENT(direct)) ? 2 : 1 ) )) // set it now in case of pulled objects
	//If the move was recent, count using old_move_delay
	//We want fractional behavior and all
	if(old_move_delay + world.tick_lag > world.time)
		//Yes this makes smooth movement stutter if add_delay is too fractional
		//Yes this is better then the alternative
		move_delay = old_move_delay
	else
		move_delay = world.time

	var/grab_move = FALSE
	if(locate(/obj/item/weapon/grab, mob))
		add_delay += 7
		grab_move = TRUE
		var/list/grab_list = mob.ret_grab()
		if(istype(grab_list, /list))
			if(grab_list.len == 2)
				grab_list -= mob
				var/mob/M = grab_list[1]
				if(M)
					if((get_dist(mob, M) <= 1 || M.loc == mob.loc))
						var/turf/T = mob.loc
						. = ..()
						if(isturf(M.loc) && ((get_dist(mob, M) > 1 || ISDIAGONALDIR(get_dir(mob, M)))))
							ISDIAGONALDIR(direct) ? M.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay*2)) : M.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
							step(M, get_dir(M.loc, T))
			else
				for(var/mob/M in grab_list)
					M.other_mobs = 1
					if(mob != M)
						M.animate_movement = SYNC_STEPS
				for(var/mob/M in grab_list)
					spawn(0)
						ISDIAGONALDIR(direct) ? M.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay*2)) : M.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
						step(M, direct)
						return
					spawn(1)
						M.other_mobs = null
						M.animate_movement = SLIDE_STEPS
						return

	if(mob.confused && !mob.crawling)
		direct = mob.confuse_input(direct)
		new_loc = get_step(get_turf(mob), direct)

	if(!grab_move && mob.SelfMove(new_loc, direct))
		. = ..()

	if(ISDIAGONALDIR(direct) && mob.loc == new_loc) //moved diagonally successfully
		add_delay *= 2
	mob.set_glide_size(DELAY_TO_GLIDE_SIZE(add_delay))
	move_delay += add_delay

	for(var/obj/item/weapon/grab/G in mob.GetGrabs())
		if(G.state == GRAB_NECK)
			mob.set_dir(reverse_dir[direct])
		G.adjust_position()
	for(var/obj/item/weapon/grab/G in mob.grabbed_by)
		G.adjust_position()
		new_loc = get_step(L, direct)

	if(.)
		mob.throwing = FALSE
		SEND_SIGNAL(mob, COMSIG_CLIENTMOB_POSTMOVE, new_loc, direct)

	var/atom/movable/P = mob.pulling
	if(P && !ismob(P) && P.density)
		mob.set_dir(turn(mob.dir, 180))

/mob/proc/SelfMove(turf/n, direct)
	if(camera_move(direct))
		return FALSE
	return TRUE

/mob/stop_pulling()
	. = ..()
	pullin?.icon_state = "pull[pulling ? 1 : 0]"
	count_pull_debuff()

/mob/proc/camera_move(Dir = 0)
	if(stat || restrained())
		return FALSE
	if(!machine || !istype(machine, /obj/machinery/computer/security))
		return FALSE
	if(!Adjacent(machine) || !machine.can_interact_with(src))
		return FALSE
	var/obj/machinery/computer/security/console = machine
	var/turf/T = get_turf(console.active_camera)
	var/list/cameras = list()

	for(var/cam_tag in console.camera_cache)
		var/obj/C = console.camera_cache[cam_tag]
		if(C == console.active_camera)
			continue
		if(C.z != T.z)
			continue
		var/dx = C.x - T.x
		var/dy = C.y - T.y
		var/is_in_bounds = FALSE
		switch(Dir)
			if(NORTH)
				is_in_bounds = dy >= abs(dx)
			if(SOUTH)
				is_in_bounds = dy <= -abs(dx)
			if(EAST)
				is_in_bounds = dx >= abs(dy)
			if(WEST)
				is_in_bounds = dx <= -abs(dy)
		if(is_in_bounds)
			cameras += C
	var/minDist = INFINITY
	var/minCam = console.active_camera
	for(var/obj/machinery/camera/C as anything in cameras)
		var/dist = get_dist(T, C)
		if(dist < minDist)
			minCam = C
			minDist = dist
	console.jump_on_click(src, minCam)
	return TRUE

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
			L.set_dir(direct)
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
			L.set_dir(direct)
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


/mob/proc/slip(weaken_duration, obj/slipped_on, lube)
	SEND_SIGNAL(src, COMSIG_MOB_SLIP, weaken_duration, slipped_on, lube)
	return FALSE

/mob/living/carbon/slip(weaken_duration, obj/slipped_on, lube)
	..()
	return loc.handle_slip(src, weaken_duration, slipped_on, lube)

/mob/living/carbon/slime/slip()
	..()
	return FALSE

/mob/living/carbon/human/slip(weaken_duration, obj/slipped_on, lube)
	if(!(lube & GALOSHES_DONT_HELP))
		if((shoes && (shoes.flags & NOSLIP)) || (wear_suit && (wear_suit.flags & NOSLIP)))
			return FALSE
	return ..()


/mob/proc/update_gravity()
	return

/mob/proc/Move_Pulled(atom/moving_atom)
	if(!pulling || !canmove)
		return FALSE

	if (pulling.anchored || !pulling.Adjacent(src) || restrained())
		stop_pulling()
		return FALSE

	if(moving_atom == loc && pulling.density)
		return FALSE

	if(SEND_SIGNAL(src, COMSIG_LIVING_MOVE_PULLED, moving_atom) & COMPONENT_PREVENT_MOVE_PULLED)
		return FALSE

	var/move_dir = get_dir(pulling.loc, moving_atom)
	if (!Process_Spacemove(move_dir))
		return FALSE
	pulling.Move(get_step(pulling.loc, move_dir), move_dir, glide_size)
	return TRUE

//bodypart selection verbs - Cyberboss
//8: repeated presses toggles through head - eyes - mouth
//9: eyes 8: head 7: mouth
//4: r-arm 5: chest 6: l-arm
//1: r-leg 2: groin 3: l-leg

///Validate the client's mob has a valid zone selected
/client/proc/check_has_body_select()
	return mob && mob.zone_sel && istype(mob.zone_sel, /atom/movable/screen/zone_sel)

/**
 * Hidden verb to set the target zone of a mob to the head
 *
 * (bound to 8) - repeated presses toggles through head - eyes - mouth
 */

///Hidden verb to target the head, bound to 8
/client/verb/body_toggle_head()
	set name = "body-toggle-head"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/next_in_line
	switch(mob.get_targetzone())
		if(BP_HEAD)
			next_in_line = O_EYES
		if(O_EYES)
			next_in_line = O_MOUTH
		else
			next_in_line = BP_HEAD

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(next_in_line, mob)

///Hidden verb to target the eyes, bound to 7
/client/verb/body_eyes()
	set name = "body-eyes"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(O_EYES, mob)

///Hidden verb to target the mouth, bound to 9
/client/verb/body_mouth()
	set name = "body-mouth"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(O_MOUTH, mob)

///Hidden verb to target the right arm, bound to 4
/client/verb/body_r_arm()
	set name = "body-r-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_R_ARM, mob)

///Hidden verb to target the chest, bound to 5
/client/verb/body_chest()
	set name = "body-chest"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_CHEST, mob)

///Hidden verb to target the left arm, bound to 6
/client/verb/body_l_arm()
	set name = "body-l-arm"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_L_ARM, mob)

///Hidden verb to target the right leg, bound to 1
/client/verb/body_r_leg()
	set name = "body-r-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_R_LEG, mob)

///Hidden verb to target the groin, bound to 2
/client/verb/body_groin()
	set name = "body-groin"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_GROIN, mob)

///Hidden verb to target the left leg, bound to 3
/client/verb/body_l_leg()
	set name = "body-l-leg"
	set hidden = TRUE

	if(!check_has_body_select())
		return

	var/atom/movable/screen/zone_sel/selector = mob.zone_sel
	selector.set_selected_zone(BP_L_LEG, mob)
