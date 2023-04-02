/*
	Adjacency proc for determining touch range

	This is mostly to determine if a user can enter a square for the purposes of touching something.
	Examples include reaching a square diagonally or reaching something on the other side of a glass window.

	This is calculated by looking for border items, or in the case of clicking diagonally from yourself, dense items.
	This proc will NOT notice if you are trying to attack a window on the other side of a dense object in its turf.  There is a window helper for that.

	Note that in all cases the neighbor is handled simply; this is usually the user's mob, in which case it is up to you
	to check that the mob is not inside of something
*/
/atom/proc/Adjacent(atom/neighbor) // basic inheritance, unused
	return FALSE

// Not a sane use of the function and (for now) indicative of an error elsewhere
/area/Adjacent(atom/neighbor)
	CRASH("Call to /area/Adjacent(), unimplemented proc")


/*
	Adjacency (to turf):
	* If you are in the same turf, always true
	* If you are vertically/horizontally adjacent, ensure there are no border objects
	* If you are diagonally adjacent, ensure you can pass through at least one of the mutually adjacent square.
		* Passing through in this case ignores anything with the throwpass flag, such as tables, racks, and morgue trays.
*/
/turf/Adjacent(atom/neighbor, atom/target = null)
	var/turf/T0 = get_turf(neighbor)
	if(T0 == src)
		return TRUE
	if(get_dist(src,T0) > 1)
		return FALSE

	if(T0.x == x || T0.y == y)
		// Check for border blockages
		return T0.ClickCross(get_dir(T0,src), border_only = 1) && ClickCross(get_dir(src,T0), border_only = 1, target_atom = target)

	// Not orthagonal
	var/in_dir = get_dir(neighbor,src) // eg. northwest (1+8)
	var/d1 = in_dir&(in_dir-1)		// eg west		(1+8)&(8) = 8
	var/d2 = in_dir - d1			// eg north		(1+8) - 8 = 1

	for(var/d in list(d1,d2))
		if(!T0.ClickCross(d, border_only = 1))
			continue // could not leave T0 in that direction

		var/turf/T1 = get_step(T0,d)
		if(!T1 || T1.density || !T1.ClickCross(get_dir(T1,T0) | get_dir(T1,src), border_only = 0))
			continue // couldn't enter or couldn't leave T1

		if(!ClickCross(get_dir(src,T1), border_only = 1, target_atom = target))
			continue // could not enter src

		return TRUE // we don't care about our own density
	return FALSE

/*
Quick adjacency (to turf):
* If you are in the same turf, always true
* If you are not adjacent, then false
*/
/turf/proc/AdjacentQuick(atom/neighbor, atom/target = null)
	var/turf/T0 = get_turf(neighbor)
	if(T0 == src)
		return TRUE

	if(get_dist(src,T0) > 1)
		return FALSE

	return TRUE

/*
	Adjacency (to anything else):
	* Must be on a turf
	* In the case of a multiple-tile object, all valid locations are checked for adjacency.

	Note: Multiple-tile objects are created when the bound_width and bound_height are creater than the tile size.
	This is not used in stock /tg/station currently.
*/
/atom/movable/Adjacent(atom/neighbor)
	if(neighbor == loc) return TRUE
	if(!isturf(loc)) return FALSE
	for(var/turf/T in locs)
		if(isnull(T)) continue
		if(T.Adjacent(neighbor,src)) return TRUE
	return FALSE

// This is necessary for storage items not on your person.
/obj/item/Adjacent(atom/neighbor, recurse = MAX_STORAGE_DEEP_LEVEL)
	if(neighbor == loc) return TRUE
	if(isitem(loc) || isliving(loc))
		if(recurse > 0)
			return loc.Adjacent(neighbor,recurse - 1)
		return FALSE
	return ..()


/*
	This checks if you there is uninterrupted airspace between that turf and this one.
	This is defined as any dense ON_BORDER object, or any dense object without throwpass.
	The border_only flag allows you to not objects (for source and destination squares)
*/
/turf/proc/ClickCross(target_dir, border_only, target_atom = null)
	for(var/obj/O in src)
		if( !O.density || O == target_atom || O.throwpass) continue // throwpass is used for anything you can click through

		if( O.flags&ON_BORDER) // windows have throwpass but are on border, check them first
			if( O.dir & target_dir || O.dir&(O.dir-1) ) // *insert explaining comment here*
				return FALSE

		else if( !border_only ) // dense, not on border, cannot pass over
			return FALSE
	return TRUE
/*
	Aside: throwpass does not do what I thought it did originally, and is only used for checking whether or not
	a thrown object should stop after already successfully entering a square.  Currently the throw code involved
	only seems to affect hitting mobs, because the checks performed against objects are already performed when
	entering or leaving the square.  Since throwpass isn't used on mobs, but only on objects, it is effectively
	useless.  Throwpass may later need to be removed and replaced with a passcheck (bitfield on movable atom passflags).

	Since I don't want to complicate the click code rework by messing with unrelated systems it won't be changed here.
*/
