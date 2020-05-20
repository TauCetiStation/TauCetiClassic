#define BOUNDED_TIP "Is bounded."
#define BOUNDS_TIP(B) "Is bounding [B.parent]."

/datum/mechanic_tip/bounded
	tip_name = BOUNDED_TIP

/datum/mechanic_tip/bounded/New(datum/component/bounded/B)
	description = "Appears to not be able to get too far away from [B.bound_to]."

/datum/mechanic_tip/bound

/datum/mechanic_tip/bound/New(datum/component/B)
	tip_name = BOUNDS_TIP(B)
	description = "Appears to not allow [B.parent] to get too far away from itself."



// A component you put on things you want to be bounded to other things.
// Warning! Can only be bounded to one thing at once.
/datum/component/bounded
	var/atom/bound_to
	var/min_dist = 0
	var/max_dist = 0

	// This callback can be used to customize how out-of-bounds situations are
	// resolved. Return TRUE if the situation was resolved.
	// This component will pass itself into it.
	var/datum/callback/resolve_callback

/datum/component/bounded/Initialize(atom/_bound_to, _min_dist, _max_dist, datum/callback/_resolve_callback)
	bound_to = _bound_to
	min_dist = _min_dist
	max_dist = _max_dist

	resolve_callback = _resolve_callback

	RegisterSignal(bound_to, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED), .proc/check_bounds)
	RegisterSignal(bound_to, list(COMSIG_PARENT_QDELETED), .proc/on_bound_destroyed)
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), .proc/check_bounds)
	RegisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE), .proc/on_try_move)

	var/datum/mechanic_tip/bounded/bounded_tip = new(src)
	var/datum/mechanic_tip/bound/bound_tip = new(src)

	parent.AddComponent(/datum/component/mechanic_desc, list(bounded_tip))
	bound_to.AddComponent(/datum/component/mechanic_desc, list(bound_tip))

	// First bounds update.
	check_bounds()

/datum/component/bounded/Destroy()
	UnregisterSignal(bound_to, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED))

	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(BOUNDED_TIP))
	SEND_SIGNAL(bound_to, COMSIG_TIPS_REMOVE, list(BOUNDS_TIP(src)))

	bound_to = null
	return ..()

// This proc is called when we are for some reason out of bounds.
// The default bounds resolution does not take in count density, or etc.
/datum/component/bounded/proc/resolve_stranded()
	if(resolve_callback && resolve_callback.Invoke(src))
		return

	var/atom/movable/AM = parent
	var/turf/parent_turf = get_turf(AM)
	var/turf/T = get_turf(bound_to)

	var/new_x = parent_turf.x
	var/new_y = parent_turf.y

	// A very exotic case of item being in inventory, or some bull like that.
	var/did_jump = FALSE
	if(bound_to in AM)
		jump_out_of(AM, bound_to)
		did_jump = TRUE
	else if(AM.loc != parent_turf)
		jump_out_of(AM.loc, AM)
		did_jump = TRUE

	if(did_jump)
		var/list/opts_x = list(-1, 1)
		var/list/opts_y = list(-1, 1)
		if(prob(50))
			opts_x += 0
		else
			opts_y += 0

		new_x = T.x + min_dist * pick(opts_x)
		new_y = T.y + min_dist * pick(opts_y)
		AM.forceMove(locate(new_x, new_y, T.z))
		return

	if(parent_turf.x > T.x + max_dist)
		new_x = T.x + max_dist
	else if(parent_turf.x < T.x - max_dist)
		new_x = T.x - max_dist
	else if(parent_turf.x <= T.x + min_dist)
		new_x = T.x + min_dist
	else if(parent_turf.x >= T.x - min_dist)
		new_x = T.x - min_dist

	if(parent_turf.y > T.y + max_dist)
		new_y = T.y + max_dist
	else if(parent_turf.y < T.y - max_dist)
		new_y = T.y - max_dist
	else if(parent_turf.y <= T.y + min_dist)
		new_y = T.y + min_dist
	else if(parent_turf.y >= T.y - min_dist)
		new_y = T.y - min_dist

	AM.forceMove(locate(new_x, new_y, T.z))

// Is called when bounds are inside bounded(or vice-versa), yet they shouldn't be.
/datum/component/bounded/proc/jump_out_of(atom/container, atom/movable/escapee)
	if(istype(escapee, /obj/item))
		if(istype(container, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = container
			S.remove_from_storage(escapee, get_turf(container))
		else if(istype(container, /mob))
			var/mob/M = container
			M.drop_from_inventory(escapee, get_turf(container))

// This proc is called when the bounds move.
/datum/component/bounded/proc/check_bounds()
	var/dist = get_dist(parent, get_turf(bound_to))
	if(dist < min_dist || dist > max_dist)
		resolve_stranded()

// This proc is called when bound thing tries to move.
/datum/component/bounded/proc/on_try_move(datum/source, atom/newLoc, dir)
	var/turf/T = get_turf(bound_to)
	var/dist = get_dist(newLoc, T)
	if(dist == -1 && newLoc == T)
		dist = 0
	if(dist < min_dist || dist > max_dist)
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	return NONE

/datum/component/bounded/proc/on_bound_destroyed(force, qdel_hint)
	// Perhaps add an abilities to resolve this situation with a callback? ~Luduk
	qdel(src)

#undef BOUNDED_TIP
#undef BOUNDS_TIP
