/atom/movable
	layer = OBJ_LAYER
	appearance_flags = TILE_BOUND|PIXEL_SCALE

	var/last_move = null
	var/anchored = FALSE
	var/move_speed = 10
	var/l_move_time = 1
	var/throwing = 0
	var/turf/throw_source = null
	var/throw_speed = 2
	var/throw_range = 7
	var/fly_speed = 0  // Used to get throw speed param exposed in proc, so we could use it in hitby reactions.
	var/moved_recently = 0
	var/mob/pulledby = null
	var/can_be_pulled = TRUE

	var/moving_diagonally = 0

	var/w_class = 0

	var/inertia_dir = 0
	var/atom/inertia_last_loc
	var/inertia_moving = 0
	var/inertia_next_move = 0
	var/inertia_move_delay = 5

	var/datum/forced_movement/force_moving = null	//handled soley by forced_movement.dm

	var/freeze_movement = FALSE

	// A (nested) list of contents that need to be sent signals to when moving between areas. Can include src.
	var/list/area_sensitive_contents

/atom/movable/Destroy()

	var/turf/T = loc

	unbuckle_mob()

	if(loc)
		loc.handle_atom_del(src)
	for(var/atom/movable/AM in contents)
		qdel(AM)
	invisibility = 101
	if(pulledby)
		pulledby.stop_pulling()

	. = ..()

	loc = null
	// If we have opacity, make sure to tell (potentially) affected light sources.
	if (opacity && istype(T))
		var/old_has_opaque_atom = T.has_opaque_atom
		T.recalc_atom_opacity()
		if (old_has_opaque_atom != T.has_opaque_atom)
			T.reconsider_lights()

	vis_locs = null //clears this atom out of all viscontents
	vis_contents.Cut()

// Previously known as HasEntered()
// This is automatically called when something enters your square
//oldloc = old location on atom, inserted when forceMove is called and ONLY when forceMove is called!
/atom/movable/Crossed(atom/movable/AM)
	SEND_SIGNAL(src, COMSIG_MOVABLE_CROSSED, AM)

/atom/movable/Move(NewLoc, Dir = 0, step_x = 0, step_y = 0)
	if(!loc || !NewLoc || freeze_movement)
		return FALSE

	if (SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, NewLoc, dir) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return

	var/is_diagonal = ISDIAGONALDIR(Dir)
	var/atom/oldloc = loc
	var/old_dir = dir

	if(loc != NewLoc)
		if (!is_diagonal) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal
			var/v = Dir & NORTH_SOUTH
			var/h = Dir & EAST_WEST

			moving_diagonally = FIRST_DIAG_STEP
			. = step(src, v)
			if(moving_diagonally) // forcemove, bump, etc. can interrupt diagonal movement
				if(.)
					moving_diagonally = SECOND_DIAG_STEP
					if(!step(src, h))
						set_dir(v)
				else
					dir = old_dir // blood trails uses dir
					. = step(src, h)
					if(.)
						moving_diagonally = SECOND_DIAG_STEP
						if(!step(src, v))
							set_dir(h)

				moving_diagonally = 0

	if(!loc || (loc == oldloc && oldloc != NewLoc))
		last_move = 0
		return FALSE

	if(!is_diagonal && moving_diagonally != SECOND_DIAG_STEP)
		move_speed = world.time - l_move_time
		l_move_time = world.time

	last_move = Dir

	if(. && buckled_mob && !handle_buckled_mob_movement(loc,Dir)) //movement failed due to buckled mob
		. = 0

	if(dir != old_dir)
		SEND_SIGNAL(src, COMSIG_ATOM_CHANGE_DIR, dir)

	if(.)
		Moved(oldloc, Dir)

/atom/movable/proc/Moved(atom/OldLoc, Dir)
	if(!ISDIAGONALDIR(Dir))
		// https://github.com/TauCetiStation/TauCetiClassic/issues/12899
		SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir)

		if(moving_diagonally)
			return

	for(var/atom/movable/AM in contents)
		AM.locMoved(OldLoc, Dir)

	if (!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)

	update_parallax_contents()

	 // Cycle through the light sources on this atom and tell them to update.
	for(var/datum/light_source/L as anything in light_sources)
		L.source_atom.update_light()

	if (orbiters)
		for (var/thing in orbiters)
			var/datum/orbit/O = thing
			O.Check()
	if (orbiting)
		orbiting.Check()
	SSdemo.mark_dirty(src)

// https://github.com/TauCetiStation/TauCetiClassic/issues/12899
/atom/movable/proc/locMoved(atom/OldLoc, Dir)
	SEND_SIGNAL(src, COMSIG_MOVABLE_LOC_MOVED, OldLoc, Dir)
	for(var/atom/movable/AM in contents)
		AM.locMoved(OldLoc, Dir)

/atom/movable/proc/setLoc(T, teleported=0)
	loc = T

/atom/movable/Bump(atom/A, non_native_bump)
	STOP_THROWING(src, A)

	if(A && non_native_bump)
		A.Bumped(src)



/atom/movable/proc/forceMove(atom/destination, keep_pulling = FALSE, keep_buckled = FALSE, keep_moving_diagonally = FALSE)
	if(!destination)
		return
	if(pulledby && !keep_pulling)
		pulledby.stop_pulling()
	var/atom/oldloc = loc
	var/same_loc = (oldloc == destination)
	var/area/old_area = get_area(oldloc)
	var/area/destarea = get_area(destination)
	loc = destination
	if(!keep_moving_diagonally)
		moving_diagonally = FALSE
	if(!same_loc)
		if(oldloc)
			oldloc.Exited(src, destination)
			if(old_area && old_area != destarea)
				old_area.Exited(src, destination)
		for(var/atom/movable/AM in oldloc)
			AM.Uncrossed(src)
		destination.Entered(src, oldloc)
		if(destarea && old_area != destarea)
			destarea.Entered(src, oldloc)

		for(var/atom/movable/AM in destination)
			if(AM == src)
				continue
			AM.Crossed(src, oldloc)
	Moved(oldloc, 0)

/mob/forceMove(atom/destination, keep_pulling = FALSE, keep_buckled = FALSE)
	if(!keep_pulling)
		stop_pulling()
	if(buckled && !keep_buckled)
		buckled.unbuckle_mob()
	. = ..()
	if(buckled && keep_buckled)
		buckled.loc = loc
		buckled.set_dir(dir)
	update_canmove()

/mob/dead/observer/forceMove(atom/destination, keep_pulling, keep_buckled)
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		return TRUE
	return FALSE

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			O.Move(get_step(O, dir))

	if(isturf(hit_atom) && hit_atom.density)
		Move(get_step(src, turn(dir, 180)))

	return hit_atom.hitby(src, throwingdatum)

/atom/movable/proc/throw_at(atom/target, range, speed, mob/thrower, spin = TRUE, diagonals_first = FALSE, datum/callback/callback, datum/callback/early_callback)
	if (!target || speed <= 0)
		return

	if (pulledby)
		pulledby.stop_pulling()

	//They are moving! Wouldn't it be cool if we calculated their momentum and added it to the throw?
	if (thrower && thrower.last_move && thrower.client && thrower.client.move_delay >= world.time + world.tick_lag*2)
		var/user_momentum = thrower.movement_delay()
		if (!user_momentum) //no movement_delay, this means they move once per byond tick, lets calculate from that instead.
			user_momentum = world.tick_lag

		user_momentum = 1 / user_momentum // convert from ds to the tiles per ds that throw_at uses.

		if (get_dir(thrower, target) & last_move)
			user_momentum = user_momentum //basically a noop, but needed
		else if (get_dir(target, thrower) & last_move)
			user_momentum = -user_momentum //we are moving away from the target, lets slowdown the throw accordingly
		else
			user_momentum = 0


		if (user_momentum)
			//first lets add that momentum to range.
			range *= (user_momentum / speed) + 1
			//then lets add it to speed
			speed += user_momentum
			if (speed <= 0)
				return //no throw speed, the user was moving too fast.

	var/datum/thrownthing/TT = new(src, target, get_turf(target), get_dir(src, target), range, speed, thrower, diagonals_first, callback, early_callback)

	var/dist_x = abs(target.x - src.x)
	var/dist_y = abs(target.y - src.y)
	var/dx = (target.x > src.x) ? EAST : WEST
	var/dy = (target.y > src.y) ? NORTH : SOUTH

	if (dist_x == dist_y)
		TT.pure_diagonal = TRUE

	else if(dist_x <= dist_y)
		var/olddist_x = dist_x
		var/olddx = dx
		dist_x = dist_y
		dist_y = olddist_x
		dx = dy
		dy = olddx
	TT.dist_x = dist_x
	TT.dist_y = dist_y
	TT.dx = dx
	TT.dy = dy
	TT.diagonal_error = dist_x/2 - dist_y
	TT.start_time = world.time

	if(pulledby)
		pulledby.stop_pulling()

	throw_source = get_turf(loc)
	fly_speed = speed
	throwing = TRUE
	if(spin)
		SpinAnimation(5, 1)

	SSthrowing.processing[src] = TT
	if (SSthrowing.state == SS_PAUSED && length(SSthrowing.currentrun))
		SSthrowing.currentrun[src] = TT
	TT.tick()
	return TRUE

//Called whenever an object moves and by mobs when they attempt to move themselves through space
//And when an object or action applies a force on src, see newtonian_move() below
//Return 0 to have src start/keep drifting in a no-grav area and 1 to stop/not start drifting
//Mobs should return 1 if they should be able to move of their own volition, see client/Move() in mob_movement.dm
//movement_dir == 0 when stopping or any dir when trying to move
/atom/movable/proc/Process_Spacemove(movement_dir = 0)
	if(has_gravity(src) && !(ice_slide_count && isiceturf(get_turf(src))))
		return 1

	if(pulledby)
		return 1

	if(throwing)
		return 1

	if(locate(/obj/structure/lattice) in orange(1, get_turf(src))) //Not realistic but makes pushing things in space easier
		return 1

	return 0

/atom/movable/proc/newtonian_move(direction) //Only moves the object if it's under no gravity

	if(!loc || Process_Spacemove(0))
		inertia_dir = 0
		return 0

	inertia_dir = direction
	if(!direction)
		return 1

	inertia_last_loc = loc
	SSspacedrift.processing[src] = src
	return 1

//Overlays
/atom/movable/overlay
	var/atom/master = null
	anchored = TRUE

/atom/movable/overlay/atom_init()
	. = ..()
	for(var/x in verbs)
		verbs -= x

/atom/movable/overlay/attackby(a, b, params)
	if (src.master)
		return master.attackby(a, b)
	return

/atom/movable/overlay/attack_paw(a, b, c)
	if (src.master)
		return master.attack_paw(a, b, c)
	return

/atom/movable/overlay/attack_hand(a, b, c)
	if (src.master)
		return master.attack_hand(a, b, c)
	return

/atom/movable/proc/handle_rotation()
	return

/atom/movable/proc/handle_buckled_mob_movement(newloc,direct)
	if(!buckled_mob.Move(newloc, direct))
		loc = buckled_mob.loc
		last_move = buckled_mob.last_move
		inertia_dir = last_move
		buckled_mob.inertia_dir = last_move
		return 0
	return 1

/atom/movable/CanPass(atom/movable/mover, turf/target, height=1.5)
	if(istype(mover) && buckled_mob == mover)
		return 1
	return ..()

/**
* A wrapper for setDir that should only be able to fail by living mobs.
*
* Called from [/atom/movable/proc/keyLoop], this exists to be overwritten by living mobs with a check to see if we're actually alive enough to change directions
*/
/atom/movable/proc/keybind_face_direction(direction)
	return

/atom/movable/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if(AM.area_sensitive_contents)
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYREMOVE(location.area_sensitive_contents, AM.area_sensitive_contents)

/atom/movable/Entered(atom/movable/AM, atom/oldLoc)
	. = ..()
	if(AM.area_sensitive_contents)
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADD(location.area_sensitive_contents, AM.area_sensitive_contents)

/// See traits.dm. Use this in place of ADD_TRAIT.
/atom/movable/proc/become_area_sensitive(trait_source = GENERIC_TRAIT)
	if(!HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AREA_SENSITIVE), PROC_REF(on_area_sensitive_trait_loss))
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADD(location.area_sensitive_contents, src)
	ADD_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)

/atom/movable/proc/on_area_sensitive_trait_loss()
	SIGNAL_HANDLER

	UnregisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AREA_SENSITIVE))
	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVE(location.area_sensitive_contents, src)

/atom/movable/Destroy()
	if(HAS_TRAIT(src, TRAIT_AREA_SENSITIVE))
		on_area_sensitive_trait_loss()
	return ..()

/* Sizes stuff */

/atom/movable/proc/get_size_flavor()
	switch(w_class)
		if(SIZE_MIDGET)
			. = "midget"
		if(SIZE_MINUSCULE)
			. = "minuscule"
		if(SIZE_TINY)
			. = "tiny"
		if(SIZE_SMALL)
			. = "small"
		if(SIZE_NORMAL to SIZE_LARGE)
			. = "medium"
		if(SIZE_HUMAN)
			. = "human"
		if(SIZE_BIG_HUMAN to SIZE_MASSIVE)
			. = "huge"
		if(SIZE_GYGANT to SIZE_GARGANTUAN)
			. = "gygant"
		else
			. = "unknown"

	. = EMBED_TIP_MINI(., repeat_string_times("*", w_class))

// This proc guarantees no mouse vs queen tomfuckery.
/atom/movable/proc/is_bigger_than(mob/living/target)
	if(w_class - target.w_class >= 3)
		return TRUE
	return FALSE

/proc/get_size_ratio(atom/movable/dividend, atom/movable/divisor)
	return (dividend.w_class / divisor.w_class)

/atom/movable/proc/update_size_class()
	return w_class

/client/var/list/image/outlined_item = list()
/atom/movable/proc/apply_outline(color)
	if(anchored || !usr.client.prefs.outline_enabled)
		return
	if(!color)
		color = usr.client.prefs.outline_color || COLOR_BLUE_LIGHT
	if(usr.client.outlined_item[src])
		return

	if(usr.client.outlined_item.len)
		remove_outline()

	var/image/IMG = image(null, src, layer = layer, pixel_x = -pixel_x, pixel_y = -pixel_y)
	IMG.appearance_flags |= KEEP_TOGETHER | RESET_COLOR | RESET_ALPHA | RESET_TRANSFORM
	IMG.vis_contents += src

	IMG.filters += filter(type = "outline", size = 1, color = color)
	usr.client.images |= IMG
	usr.client.outlined_item[src] = IMG


/atom/movable/proc/remove_outline()
	usr.client.images -= usr.client.outlined_item[src]
	usr.client.outlined_item -= src

/**
 * meant for movement with zero side effects. only use for objects that are supposed to move "invisibly" (like camera mobs or ghosts)
 * if you want something to move onto a tile with a beartrap or recycler or tripmine or mouse without that object knowing about it at all, use this
 * most of the time you want forceMove()
 */
/atom/movable/proc/abstract_move(atom/new_loc)
	var/atom/old_loc = loc
	loc = new_loc
	Moved(old_loc)

// Return what item *should* be thrown, when a mob tries to throw us. Return null for no throw to happen.
/atom/movable/proc/be_thrown(mob/living/thrower, atom/target)
	return src

/*
	Handle trying to be taken by user.
	If it's impossible to be taken by user, appear in fallback.
	If it's impossible to resolve those two rules - return FALSE.
*/
/atom/movable/proc/taken(mob/living/user, atom/fallback)
	forceMove(fallback)
	// We failed to be taken, but still are in some mob. Drop down.
	if(ismob(loc))
		forceMove(loc.loc)

/atom/movable/proc/jump_from_contents(rec_level=1)
	for(var/i in 1 to rec_level)
		if(!ismovable(loc))
			return
		var/atom/movable/AM = loc

		if(!AM.drop_from_contents(src))
			return

/*
	Return TRUE on successful drop.
*/
/atom/movable/proc/drop_from_contents(atom/movable/AM)
	return FALSE

/mob/drop_from_contents(atom/movable/AM)
	if(isitem(AM))
		var/obj/item/I = AM
		if(I.slot_equipped)
			return drop_from_inventory(I, loc, putdown_anim=FALSE)

	AM.forceMove(loc)
	return TRUE

/obj/item/weapon/holder/drop_from_contents(atom/movable/AM)
	AM.forceMove(loc)
	return TRUE

/mob/living/proc/get_radiation_message(rad_dose)
	var/message = ""
	switch(rad_dose)
		if(0 to 299)
			message += "You feel warm."
		if(300 to 499)
			message += "You feel a wave of heat wash over you."
		if(500 to INFINITY)
			message += "You notice your skin is covered in fresh radiation burns."
	return message

#define GEIGER_RANGE 15

/proc/irradiate_one_mob(mob/living/victim, rad_dose)
	if(ishuman(victim))
		var/mob/living/carbon/human/H = victim
		if(H.species.flags[IS_SYNTHETIC])
			return
	victim.apply_effect(rad_dose, IRRADIATE)
	to_chat(victim, "<span class='warning'>[victim.get_radiation_message(rad_dose)]</span>")
	for(var/obj/item/device/analyzer/counter as anything in global.geiger_items_list)
		var/distance_rad_signal = get_dist(counter, victim)
		if(distance_rad_signal <= GEIGER_RANGE)
			var/rad_power = rad_dose
			rad_power *= sqrt(1 / (distance_rad_signal + 1))
			counter.recieve_rad_signal(rad_power, distance_rad_signal)

/proc/irradiate_in_dist(turf/source_turf, rad_dose, effect_distance)
	for(var/mob/living/L in range(source_turf, effect_distance))
		if(ishuman(L))
			var/mob/living/carbon/human/H = L
			if(H.species.flags[IS_SYNTHETIC])
				continue
		var/neighbours_in_turf = 0
		for(var/mob/living/neighbour in L.loc)
			if(neighbour == L)
				continue
			neighbours_in_turf++
		var/rads = rad_dose / (neighbours_in_turf > 0 ? neighbours_in_turf : 1)
		rads *= sqrt(1 / (get_dist(L, source_turf) + 1))
		L.apply_effect(rads, IRRADIATE)
		to_chat(L, "<span class='warning'>[L.get_radiation_message(rad_dose)]</span>")
	for(var/obj/item/device/analyzer/counter as anything in global.geiger_items_list)
		var/distance_rad_signal = get_dist(counter, source_turf)
		if(distance_rad_signal <= GEIGER_RANGE)
			var/rad_power = rad_dose
			rad_power *= sqrt(1 / (distance_rad_signal + 1))
			counter.recieve_rad_signal(rad_power, distance_rad_signal)

#undef GEIGER_RANGE
