/datum
	var/list/status_traits
	var/list/datum_components //for /datum/components
	var/list/comp_lookup //it used to be for looking up components which had registered a signal but now anything can register
	var/list/signal_procs
	var/signal_enabled = FALSE
	var/isprocessing = 0
	var/gc_destroyed //Time when this object was destroyed.
	var/list/active_timers
	var/list/filter_data

#ifdef REFERENCE_TRACKING
	var/running_find_references
	var/last_find_references = 0
#endif

// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy(force = FALSE, ...)
	tag = null

	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if (timer.spent)
			continue
		qdel(timer)

	//BEGIN: ECS SHIT
	signal_enabled = FALSE

	var/list/dc = datum_components
	if(dc)
		var/all_components = dc[/datum/component]
		if(length(all_components))
			for(var/I in all_components)
				var/datum/component/C = I
				qdel(C, FALSE, TRUE)
		else
			var/datum/component/C = all_components
			qdel(C, FALSE, TRUE)
		dc.Cut()

	var/list/lookup = comp_lookup
	if(lookup)
		for(var/sig in lookup)
			var/list/comps = lookup[sig]
			if(length(comps))
				for(var/i in comps)
					var/datum/component/comp = i
					comp.UnregisterSignal(src, sig)
			else
				var/datum/component/comp = comps
				comp.UnregisterSignal(src, sig)
		comp_lookup = lookup = null

	for(var/target in signal_procs)
		UnregisterSignal(target, signal_procs[target])
	//END: ECS SHIT

	return QDEL_HINT_QUEUE

/datum/proc/process()
	set waitfor = FALSE
	STOP_PROCESSING(SSobj, src)
	return FALSE

/datum/proc/add_filter(name, priority, list/params)
	LAZYINITLIST(filter_data)
	var/list/p = params.Copy()
	p["priority"] = priority
	filter_data[name] = p
	update_filters()

/datum/proc/update_filters()
	var/atom/A = src//Here's a "Fint Ushami" and this will work even with images.
	A.filters = null
	filter_data = sortTim(filter_data, /proc/cmp_filter_data_priority, TRUE)
	for(var/f in filter_data)
		var/list/data = filter_data[f]
		var/list/arguments = data.Copy()
		arguments -= "priority"
		A.filters += filter(arglist(arguments))
	UNSETEMPTY(filter_data)

/datum/proc/transition_filter(name, time, list/new_params, easing, loop)
	var/filter = get_filter(name)
	if(!filter)
		return

	var/list/old_filter_data = filter_data[name]

	var/list/params = old_filter_data.Copy()
	for(var/thing in new_params)
		params[thing] = new_params[thing]

	animate(filter, new_params, time = time, easing = easing, loop = loop)
	for(var/param in params)
		filter_data[name][param] = params[param]

/datum/proc/change_filter_priority(name, new_priority)
	if(!filter_data || !filter_data[name])
		return

	filter_data[name]["priority"] = new_priority
	update_filters()

/datum/proc/get_filter(name)
	var/atom/A = src//Here's a "Fint Ushami" and this will work even with images.
	if(filter_data && filter_data[name])
		return A.filters[filter_data.Find(name)]

/datum/proc/remove_filter(name_or_names)
	if(!filter_data)
		return

	var/list/names = islist(name_or_names) ? name_or_names : list(name_or_names)

	for(var/name in names)
		if(filter_data[name])
			filter_data -= name
	update_filters()

/datum/proc/clear_filters()
	var/atom/A = src//Here's a "Fint Ushami" and this will work even with images.
	filter_data = null
	A.filters = null
