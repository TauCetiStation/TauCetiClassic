/atom/movable
	layer = OBJ_LAYER
	glide_size = 8
	appearance_flags = TILE_BOUND|PIXEL_SCALE|LONG_GLIDE

	var/atom/movable/pulling
	var/atom/movable/moving_from_pull //attempt to resume grab after moving instead of before.
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

	var/list/clients_in_contents
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

/atom/movable/proc/set_glide_size(target = 8)
	SEND_SIGNAL(src, COMSIG_MOVABLE_UPDATE_GLIDE_SIZE, target)
	glide_size = target

	buckled_mob?.set_glide_size(target)

////////////////////////////////////////
// Here's where we rewrite how byond handles movement except slightly different
// To be removed on step_ conversion
// All this work to prevent a second bump
/atom/movable/Move(atom/newloc, direction, glide_size_override = 0)
	. = FALSE
	if(!newloc || newloc == loc)
		return

	if(!direction)
		direction = get_dir(src, newloc)

	set_dir(direction)

	if(!loc.Exit(src, newloc))
		return

	if(!newloc.Enter(src, src.loc))
		return

	if (SEND_SIGNAL(src, COMSIG_MOVABLE_PRE_MOVE, newloc) & COMPONENT_MOVABLE_BLOCK_PRE_MOVE)
		return

	// Past this is the point of no return
	var/atom/oldloc = loc
	var/area/oldarea = get_area(oldloc)
	var/area/newarea = get_area(newloc)
	loc = newloc
	. = TRUE
	oldloc.Exited(src, newloc)
	if(oldarea != newarea)
		oldarea.Exited(src, newloc)

	for(var/i in oldloc)
		if(i == src) // Multi tile objects
			continue
		var/atom/movable/thing = i
		thing.Uncrossed(src)

	newloc.Entered(src, oldloc)
	if(oldarea != newarea)
		newarea.Entered(src, oldloc)

	for(var/i in loc)
		if(i == src) // Multi tile objects
			continue
		var/atom/movable/thing = i
		thing.Crossed(src)

	Moved(oldloc, direction)

/atom/movable/Move(atom/newloc, direction = 0, glide_size_override = 0)
	if(!moving_from_pull)
		check_pulling()
	if(!loc || !newloc || freeze_movement)
		return FALSE

	var/atom/movable/pullee = pulling

	//Early override for some cases like diagonal movement
	if(glide_size_override)
		set_glide_size(glide_size_override)

	var/atom/oldloc = loc

	if(loc != newloc)
		if (!ISDIAGONALDIR(direction)) //Cardinal move
			. = ..()
		else //Diagonal move, split it into cardinal moves
			var/v = direction & NORTH_SOUTH
			var/h = direction & EAST_WEST

			moving_diagonally = FIRST_DIAG_STEP
			. = step(src, v)
			if(.)
				moving_diagonally = SECOND_DIAG_STEP
				if(!step(src, h))
					set_dir(v)
			else
				. = step(src, h)
				if(.)
					moving_diagonally = SECOND_DIAG_STEP
					if(!step(src, v))
						set_dir(h)
			if(moving_diagonally == SECOND_DIAG_STEP && !inertia_moving)
				inertia_next_move = world.time + inertia_move_delay
				newtonian_move(direction)
			moving_diagonally = FALSE
			return

	if(!loc || (loc == oldloc && oldloc != newloc))
		last_move = 0
		return

	if(moving_diagonally != SECOND_DIAG_STEP)
		move_speed = world.time - l_move_time
		l_move_time = world.time

	if(. && pulling && pulling == pullee && pulling != moving_from_pull) //we were pulling a thing and didn't lose it during our move.
		if(pulling.anchored)
			stop_pulling()
		else
			var/pull_dir = get_dir(src, pulling)
			//puller and pullee more than one tile away or in diagonal position and whatever the pullee is pulling isn't already moving from a pull as it'll most likely result in an infinite loop a la ouroborus.
			if(!pulling.pulling?.moving_from_pull && (get_dist(src, pulling) > 1 || (moving_diagonally != SECOND_DIAG_STEP && ((pull_dir - 1) & pull_dir))))
				pulling.moving_from_pull = src
				pulling.Move(oldloc, get_dir(pulling, oldloc), glide_size) //the pullee tries to reach our previous position
				pulling.moving_from_pull = null
			check_pulling()

	//glide_size strangely enough can change mid movement animation and update correctly while the animation is playing
	//This means that if you don't override it late like this, it will just be set back by the movement update that's called when you move turfs.
	if(glide_size_override)
		set_glide_size(glide_size_override)

	last_move = direction

	if(. && buckled_mob && !handle_buckled_mob_movement(loc, direction, glide_size_override)) //movement failed due to buckled mob
		return FALSE

/atom/movable/proc/check_pulling()
	if(pulling)
		var/atom/movable/pullee = pulling
		if(pullee && get_dist(src, pullee) > 1)
			stop_pulling()
			return
		if(!isturf(loc))
			stop_pulling()
			return
		if(pullee && !isturf(pullee.loc) && pullee.loc != loc)
			log_game("DEBUG:[src]'s pull on [pullee] wasn't broken despite [pullee] being in [pullee.loc]. Pull stopped manually.")
			stop_pulling()
			return
		if(pulling.anchored)
			stop_pulling()
			return
	if(pulledby && moving_diagonally != FIRST_DIAG_STEP && get_dist(src, pulledby) > 1) //separated from our puller and not in the middle of a diagonal move.
		pulledby.stop_pulling()

/atom/movable/proc/stop_pulling()
	if(pulling)
		SEND_SIGNAL(src, COMSIG_LIVING_STOP_PULL, pulling)
		SEND_SIGNAL(pulling, COMSIG_ATOM_STOP_PULL, src)

		// What if the signals above somehow deleted pulledby?
		if(pulling)
			pulling.pulledby = null
			pulling = null

/atom/movable/proc/Moved(atom/OldLoc, Dir)
	SHOULD_CALL_PARENT(TRUE)

	if(!inertia_moving)
		inertia_next_move = world.time + inertia_move_delay
		newtonian_move(Dir)

	update_parallax_contents()

	SEND_SIGNAL(src, COMSIG_MOVABLE_MOVED, OldLoc, Dir)

	for(var/atom/movable/AM in contents)
		AM.locMoved(OldLoc, Dir)

	if(orbiters)
		for (var/thing in orbiters)
			var/datum/orbit/O = thing
			O.Check()
	if(orbiting)
		orbiting.Check()
	SSdemo.mark_dirty(src)
	return

/atom/movable/proc/locMoved(atom/OldLoc, Dir)
	SEND_SIGNAL(src, COMSIG_MOVABLE_LOC_MOVED, OldLoc, Dir)
	for(var/atom/movable/AM in contents)
		AM.locMoved(OldLoc, Dir)

/atom/movable/proc/setLoc(T, teleported=0)
	loc = T

/atom/movable/Bump(atom/A, non_native_bump)
	STOP_THROWING(src, A)

	if(A && non_native_bump)
		A.last_bumped = world.time
		A.Bumped(src)


/atom/movable/proc/forceMove(atom/destination, keep_pulling = FALSE)
	if(destination)
		if(pulledby && !keep_pulling)
			pulledby.stop_pulling()
		var/atom/oldloc = loc
		var/same_loc = (oldloc == destination)
		var/area/old_area = get_area(oldloc)
		var/area/destarea = get_area(destination)

		loc = destination

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
		return TRUE
	return FALSE

/mob/living/forceMove(atom/destination, keep_pulling = FALSE)
	if(!keep_pulling)
		stop_pulling()
	if(buckled)
		buckled.unbuckle_mob()
	. = ..()
	update_canmove()

/mob/dead/observer/forceMove(atom/destination, keep_pulling)
	if(destination)
		if(loc)
			loc.Exited(src)
		loc = destination
		loc.Entered(src)
		return TRUE
	return FALSE

//called when src is thrown into hit_atom
/atom/movable/proc/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	hit_atom.hitby(src, throwingdatum)

	if(isobj(hit_atom))
		var/obj/O = hit_atom
		if(!O.anchored)
			O.Move(get_step(O, dir))

	if(isturf(hit_atom) && hit_atom.density)
		Move(get_step(src, turn(dir, 180)))

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
	if(has_gravity(src))
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

/atom/movable/proc/handle_buckled_mob_movement(newloc, direct, glide_size_override)
	if(!buckled_mob.Move(newloc, direct, glide_size_override))
		Move(buckled_mob.loc, direct)
		last_move = buckled_mob.last_move
		inertia_dir = last_move
		buckled_mob.inertia_dir = last_move
		return FALSE
	return TRUE

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
		RegisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AREA_SENSITIVE), .proc/on_area_sensitive_trait_loss)
		for(var/atom/movable/location as anything in get_nested_locs(src) + src)
			LAZYADD(location.area_sensitive_contents, src)
	ADD_TRAIT(src, TRAIT_AREA_SENSITIVE, trait_source)

/atom/movable/proc/on_area_sensitive_trait_loss()
	SIGNAL_HANDLER

	UnregisterSignal(src, SIGNAL_REMOVETRAIT(TRAIT_AREA_SENSITIVE))
	for(var/atom/movable/location as anything in get_nested_locs(src) + src)
		LAZYREMOVE(location.area_sensitive_contents, src)
/* Sizes stuff */

/atom/movable/proc/get_size_flavor()
	switch(w_class)
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
