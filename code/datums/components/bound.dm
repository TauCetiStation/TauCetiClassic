#define BOUNDED_TIP "Is bounded."
#define BOUNDS_TIP(B) "Is bounding [B.parent]."

/datum/mechanic_tip/bounded
	tip_name = BOUNDED_TIP

/datum/mechanic_tip/bounded/New(datum/component/bounded/B)
	description = "Appears to not be able to get too far away from [B.master]."

/datum/mechanic_tip/bound

/datum/mechanic_tip/bound/New(datum/component/B)
	tip_name = BOUNDS_TIP(B)
	description = "Appears to not allow [B.parent] to get too far away from itself."



// A component you put on things you want to be bounded to other things.
// Warning! Can only be bounded to one thing at once.
/datum/component/bounded
	// object we bound to
	var/atom/master
	var/min_dist = 0
	var/max_dist = 0

	// Does the component have a visible radius?
	var/vis_radius = FALSE

	// This callback can be used to customize how out-of-bounds situations are
	// resolved. Return TRUE if the situation was resolved.
	// This component will pass itself into it.
	var/datum/callback/resolve_callback
	// Callback to call when master destroyed
	var/datum/callback/master_destroyed_callback
	// Time to hide visible raduis
	var/hide_radius_timer

/datum/component/bounded/Initialize(atom/_bound_to, _min_dist, _max_dist, datum/callback/_resolve_callback, datum/callback/_master_destroyed_callback, tips = TRUE, _vis_radius = TRUE)
	master = _bound_to
	min_dist = _min_dist
	max_dist = _max_dist
	vis_radius = _vis_radius

	resolve_callback = _resolve_callback
	master_destroyed_callback = _master_destroyed_callback

	RegisterSignal(master, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED), PROC_REF(check_bounds))
	RegisterSignal(master, list(COMSIG_PARENT_QDELETING), PROC_REF(on_master_destroyed))
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(on_parent_destroyed))
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(check_bounds))
	RegisterSignal(parent, list(COMSIG_MOVABLE_PRE_MOVE), PROC_REF(on_try_move))

	if(tips)
		var/datum/mechanic_tip/bounded/bounded_tip = new(src)
		var/datum/mechanic_tip/bound/bound_tip = new(src)

		parent.AddComponent(/datum/component/mechanic_desc, list(bounded_tip))
		master.AddComponent(/datum/component/mechanic_desc, list(bound_tip))

	if(vis_radius && ismob(parent))
		master.AddComponent(/datum/component/vis_radius, _max_dist)

	// First bounds update.
	check_bounds()

/datum/component/bounded/Destroy()
	UnregisterSignal(master, list(COMSIG_MOVABLE_MOVED, COMSIG_MOVABLE_LOC_MOVED))

	SEND_SIGNAL(parent, COMSIG_TIPS_REMOVE, list(BOUNDED_TIP))
	SEND_SIGNAL(master, COMSIG_TIPS_REMOVE, list(BOUNDS_TIP(src)))

	if(vis_radius)
		qdel(master.GetComponent(/datum/component/vis_radius))
		deltimer(hide_radius_timer)

	master = null
	return ..()

// This proc is called when we are for some reason out of bounds.
// The default bounds resolution does not take in count density, or etc.
/datum/component/bounded/proc/resolve_stranded()
	if(resolve_callback && resolve_callback.Invoke(src))
		return

	var/atom/movable/AM = parent
	var/turf/parent_turf = get_turf(AM)
	var/turf/T = get_turf(master)

	var/new_x = parent_turf.x
	var/new_y = parent_turf.y

	// A very exotic case of item being in inventory, or some bull like that.
	var/did_jump = FALSE
	if(master in AM)
		jump_out_of(AM, master)
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
	if(isitem(escapee))
		if(istype(container, /obj/item/weapon/storage))
			var/obj/item/weapon/storage/S = container
			S.remove_from_storage(escapee, get_turf(container))
		else if(istype(container, /mob))
			var/mob/M = container
			M.drop_from_inventory(escapee, get_turf(container))

// This proc is called when the bounds move.
/datum/component/bounded/proc/check_bounds()
	var/dist = get_dist(parent, get_turf(master))
	if(dist < min_dist || dist > max_dist)
		resolve_stranded()

// This proc is called when bound thing tries to move.
/datum/component/bounded/proc/on_try_move(datum/source, atom/newLoc, dir)
	var/turf/T = get_turf(master)
	var/dist = get_dist(newLoc, T)
	if(dist == -1 && newLoc == T)
		dist = 0
	if(dist < min_dist || dist > max_dist)
		try_show_radius()
		return COMPONENT_MOVABLE_BLOCK_PRE_MOVE
	return NONE

/datum/component/bounded/proc/change_max_dist(dist)
	max_dist = dist
	if(vis_radius && ismob(parent))
		// Del old
		qdel(master.GetComponent(/datum/component/vis_radius))
		deltimer(hide_radius_timer)
		// Create new
		master.AddComponent(/datum/component/vis_radius, max_dist)

/datum/component/bounded/proc/try_show_radius()
	if(!ismob(parent))
		return

	var/mob/M = parent
	if(M.client)
		SEND_SIGNAL(master, COMSIG_SHOW_RADIUS, parent)
		if(hide_radius_timer)
			deltimer(hide_radius_timer)
		hide_radius_timer = addtimer(CALLBACK(src, PROC_REF(hide_radius)), 20, TIMER_STOPPABLE)

/datum/component/bounded/proc/hide_radius()
	SEND_SIGNAL(master, COMSIG_HIDE_RADIUS)

/datum/component/bounded/proc/on_bound_destroyed()
	// Perhaps add an abilities to resolve this situation with a callback? ~Luduk
	qdel(src)

/datum/component/bounded/proc/on_parent_destroyed()
	on_bound_destroyed()

/datum/component/bounded/proc/on_master_destroyed()
	if(master_destroyed_callback)
		master_destroyed_callback.Invoke()
	on_bound_destroyed()

#undef BOUNDED_TIP
#undef BOUNDS_TIP
