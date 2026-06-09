/datum/component/tied
	// object we bound to
	var/atom/movable/master

	var/datum/component/bounded/bounded_component

	var/datum/beam/current_beam

/datum/component/tied/Initialize(atom/_tied_to, _beam_type, _bean_icon_state, _beam_color)
	master = _tied_to
	var/atom/parent_atom = parent
	current_beam = parent_atom.Beam(master, icon_state=_bean_icon_state, time=INFINITY, beam_type=_beam_type, beam_sleep_time = 1 MINUTE, bcolor = _beam_color)

	bounded_component = parent.AddComponent(/datum/component/bounded, master, 0, 1, CALLBACK(src, PROC_REF(resolve_stranded)))

	RegisterSignal(master, list(COMSIG_PARENT_QDELETING), PROC_REF(untie))
	RegisterSignal(parent, list(COMSIG_PARENT_QDELETING), PROC_REF(untie))

	RegisterSignal(master, list(COMSIG_PARENT_ATTACKBY), PROC_REF(try_untie))
	RegisterSignal(parent, list(COMSIG_PARENT_ATTACKBY), PROC_REF(try_untie))

/datum/component/tied/Destroy()
	UnregisterSignal(master, list(COMSIG_PARENT_QDELETING, COMSIG_PARENT_ATTACKBY))
	UnregisterSignal(parent, list(COMSIG_PARENT_QDELETING, COMSIG_PARENT_ATTACKBY))

	QDEL_NULL(current_beam)
	QDEL_NULL(bounded_component)

	master = null
	bounded_component = null
	current_beam = null
	return ..()

/datum/component/tied/proc/resolve_stranded(datum/component/bounded/bounds)
	var/atom/movable/parent_atom = parent
	if(get_dist(master, parent) == 2 && !parent_atom.anchored)
		step_towards(parent, master)
		current_beam.recalculate()
		var/dist = get_dist(parent, get_turf(master))
		if(dist >= bounds.min_dist && dist <= bounds.max_dist)
			return TRUE

	untie()
	return TRUE

/datum/component/tied/proc/try_untie(datum/source, obj/item/tool,  mob/living/user, params)
	if(!iscutter(tool))
		return

	untie()

/datum/component/tied/proc/untie()
	qdel(src)
