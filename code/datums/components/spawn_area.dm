var/global/list/datum/area_group/observer_groups



/datum/area_group
	var/id
	var/list/mob/observers

/datum/area_group/New(id)
	src.id = id

/datum/area_group/Destroy()
	for(var/am in observers)
		deltimer(LAZYACCESS(observers, am))

	observers = null

	LAZYREMOVE(global.observer_groups, id)

	return ..()

/datum/area_group/proc/refresh_observer(mob/living/L, delay)
	var/timer = LAZYACCESS(observers, L)
	if(timer)
		deltimer(timer)

	var/spawn_timer = addtimer(
		CALLBACK(
			src,
			PROC_REF(TrySpawn),
			L
		),
		delay,
		TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
	)

	LAZYSET(observers, L, spawn_timer)

/datum/area_group/proc/add_observer(mob/living/L, delay)
	refresh_observer(L, delay)

	if(LAZYACCESS(observers, L))
		return
	RegisterSignal(L, list(COMSIG_PARENT_QDELETING), PROC_REF(on_observer_qdel))

/datum/area_group/proc/remove_observer(mob/living/L)
	deltimer(LAZYACCESS(observers, L))
	LAZYREMOVE(observers, L)
	UnregisterSignal(L, list(COMSIG_PARENT_QDELETING))

	if(!observers)
		qdel(src)

/datum/area_group/proc/on_observer_qdel(datum/source)
	SIGNAL_HANDLER

	remove_observer(source)

/datum/area_group/proc/TrySpawn(mob/living/L)
	var/area/A = get_area(L)
	if(!A)
		remove_observer(L)
		return

	var/datum/component/spawn_area/SA = A.GetComponent(/datum/component/spawn_area)
	if(!SA)
		remove_observer(L)
		return

	SA.TrySpawn(L)
	refresh_observer(L, SA.spawn_frequency)



/*
 * Spawns atoms nearby sentient players, despawns mobs if player is gone for too long.
 *
 * Instances are spawned on an empty square surrounding an observer with half length of square's side = spawn_range.
 * Instances despawn when no observer is in spawn_range near them.
 */
/datum/component/spawn_area
	/// Callback to a spawn function. Receives: (turf/spawn_turf), should return: list of spawned instances.
	var/datum/callback/spawn_callback
	/// Callback to a despawn function. Receives: (atom/movable/instance).
	var/datum/callback/despawn_callback
	/// Callback to a check spawn function. Receives: (turf/spawn_turf), should return: whether an instance can be spawned on this turf.
	var/datum/callback/check_spawn_callback

	/// Associative list of instance = despawn_timer. Use refresh_instance to renew the timer.
	var/list/atom/movable/despawn_timers

	/*
		Group to which this spawn area belongs to.

		Groups keep track of observers, and hold spawn cooldown timers inside.

		Use register_observer and unregister_observer to add an observer to a group.
	*/
	var/group

	/// Instances will spawn anywhere at this range from an observer.
	var/spawn_range
	/// Minimal distance between two instances.
	var/instance_distance

	/// How often instances spawn.
	var/spawn_frequency
	/// How often instances try to despawn.
	var/despawn_frequency

/datum/component/spawn_area/Initialize(
	group,
	datum/callback/spawn_callback,
	datum/callback/despawn_callback,
	datum/callback/check_spawn_callback,
	spawn_range,
	instance_distance,
	spawn_frequency,
	despawn_frequency,
)
	if(!istype(parent, /area))
		return COMPONENT_INCOMPATIBLE

	src.group = group

	src.spawn_callback = spawn_callback
	src.despawn_callback = despawn_callback
	src.check_spawn_callback = check_spawn_callback

	src.spawn_range = spawn_range
	src.instance_distance = instance_distance

	src.spawn_frequency = spawn_frequency
	src.despawn_frequency = despawn_frequency

	RegisterSignal(parent, list(COMSIG_AREA_ENTERED), PROC_REF(on_entry))

/datum/component/spawn_area/Destroy()
	UnregisterSignal(parent, list(COMSIG_AREA_ENTERED))

	for(var/instance in despawn_timers)
		deltimer(despawn_timers[instance])

	despawn_timers = null

	return ..()

/datum/component/spawn_area/proc/on_entry(datum/source, atom/movable/entering)
	SIGNAL_HANDLER

	if(!isliving(entering))
		return

	var/mob/living/L = entering
	if(!L.client)
		return

	register_observer(entering)

/datum/component/spawn_area/proc/on_exit(datum/source, area/exited, atom/NewLoc)
	SIGNAL_HANDLER

	var/mob/exiting = source

	UnregisterSignal(exiting, list(COMSIG_EXIT_AREA))

	var/area/A = get_area(NewLoc)
	if(!A)
		REMOVE_TRAIT(source, TRAIT_AREA_SENSITIVE, SPAWN_AREA_TRAIT)
		return

	var/datum/component/spawn_area/SA = A.GetComponent(/datum/component/spawn_area)
	if(!SA)
		REMOVE_TRAIT(source, TRAIT_AREA_SENSITIVE, SPAWN_AREA_TRAIT)
		return

/datum/component/spawn_area/proc/on_instance_exit(datum/source, atom/movable/exiting, atom/newLoc)
	SIGNAL_HANDLER

	var/area/A = get_area(newLoc)
	if(!A)
		on_instance_qdel(exiting)
		return

	var/datum/component/spawn_area/SA = A.GetComponent(/datum/component/spawn_area)
	if(!SA)
		on_instance_qdel(exiting)
		return

	transfer_instance(SA, exiting)

/datum/component/spawn_area/proc/on_instance_qdel(datum/source)
	SIGNAL_HANDLER

	deltimer(LAZYACCESS(despawn_timers, source))

	LAZYREMOVE(despawn_timers, source)

	UnregisterSignal(source, list(COMSIG_PARENT_QDELETING, COMSIG_EXIT_AREA))

/datum/component/spawn_area/proc/register_observer(mob/living/L)
	// No need to group areas on different Z-levels, since MultiZ travel is not present. CURRENTLY ~Luduk
	var/g = "[group]_[L.z]"

	var/datum/area_group/AG = LAZYACCESS(global.observer_groups, g)

	if(!AG)
		AG = new /datum/area_group(g)
		LAZYSET(global.observer_groups, g, AG)

	AG.add_observer(L, spawn_frequency)

	RegisterSignal(L, list(COMSIG_EXIT_AREA), PROC_REF(on_exit))

	L.become_area_sensitive(SPAWN_AREA_TRAIT)

/datum/component/spawn_area/proc/unregister_observer(mob/living/L)
	// No need to group areas on different Z-levels, since MultiZ travel is not present. CURRENTLY ~Luduk
	var/g = "[group]_[L.z]"

	var/datum/area_group/AG = LAZYACCESS(global.observer_groups, g)
	if(AG)
		AG.remove_observer(L)

/datum/component/spawn_area/proc/refresh_instance(atom/movable/instance)
	var/timer = LAZYACCESS(despawn_timers, instance)
	if(timer)
		deltimer(timer)

	var/despawn_timer = addtimer(
		CALLBACK(src, PROC_REF(TryDespawn), instance),
		despawn_frequency,
		TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE
	)

	LAZYSET(despawn_timers, instance, despawn_timer)

/datum/component/spawn_area/proc/register_instance(atom/movable/instance)
	RegisterSignal(instance, list(COMSIG_PARENT_QDELETING), PROC_REF(on_instance_qdel))
	RegisterSignal(instance, list(COMSIG_EXIT_AREA), PROC_REF(on_instance_exit))

/datum/component/spawn_area/proc/transfer_instance(datum/component/spawn_area/new_spawn_area, atom/movable/instance)
	new_spawn_area.register_instance(instance)
	LAZYSET(new_spawn_area.despawn_timers, instance, despawn_timers[instance])
	LAZYREMOVE(despawn_timers, instance)
	UnregisterSignal(instance, list(COMSIG_PARENT_QDELETING, COMSIG_EXIT_AREA))

/datum/component/spawn_area/proc/TrySpawn(mob/living/L)
	var/list/pos_turfs = list()
	for(var/t in BORDER_TURFS(spawn_range, L))
		if(!CheckSpawn(t))
			continue

		var/valid = TRUE

		for(var/inst in despawn_timers)
			if(get_dist(inst, t) < instance_distance)
				valid = FALSE
				break

		if(!valid)
			continue

		for(var/m in get_observers(L))
			if(get_dist(m, t) < spawn_range)
				valid = FALSE
				break

		if(!valid)
			continue

		pos_turfs += t

	if(!pos_turfs.len)
		return

	INVOKE_ASYNC(src, PROC_REF(Spawn), pick(pos_turfs))

/datum/component/spawn_area/proc/TryDespawn(atom/movable/instance)
	var/despawning = TRUE

	for(var/observer in get_observers(instance))
		if(get_dist(instance, observer) < spawn_range)
			despawning = FALSE
			break

	if(despawning)
		UnregisterSignal(instance, list(COMSIG_PARENT_QDELETING, COMSIG_EXIT_AREA))
		deltimer(LAZYACCESS(despawn_timers, instance))
		LAZYREMOVE(despawn_timers, instance)
		INVOKE_ASYNC(src, PROC_REF(Despawn), instance)
		return

	refresh_instance(instance)

/datum/component/spawn_area/proc/get_observers(atom/movable/AM)
	var/g = "[group]_[AM.z]"
	var/datum/area_group/AG = LAZYACCESS(global.observer_groups, g)
	if(!AG)
		return

	. = list()
	for(var/mob/obs as anything in AG.observers)
		if(obs.stat == DEAD)
			continue
		. += obs

/datum/component/spawn_area/proc/Spawn(turf/T)
	var/list/atom/movable/instances = spawn_callback.Invoke(T)

	for(var/instance in instances)
		refresh_instance(instance)
		register_instance(instance)

/datum/component/spawn_area/proc/Despawn(atom/movable/instance)
	return despawn_callback.Invoke(instance)

/datum/component/spawn_area/proc/CheckSpawn(turf/T)
	return check_spawn_callback.Invoke(T)
