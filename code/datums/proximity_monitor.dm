/datum/proximity_monitor
	///The atom we are tracking
	var/atom/host
	///The atom that will receive HasProximity calls.
	var/atom/hasprox_receiver
	///The range of the proximity monitor. Things moving wihin it will trigger HasProximity calls.
	var/current_range
	///If we don't check turfs in range if the host's loc isn't a turf
	var/ignore_if_not_on_turf
	///The signals of the connect range component, needed to monitor the turfs in range.
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)

/datum/proximity_monitor/New(atom/_host, range, _ignore_if_not_on_turf = TRUE)
	ignore_if_not_on_turf = _ignore_if_not_on_turf
	current_range = range
	set_host(_host)

/datum/proximity_monitor/proc/set_host(atom/new_host, atom/new_receiver)
	if(new_host == host)
		return
	if(host) //No need to delete the connect range and containers comps. They'll be updated with the new tracked host.
		UnregisterSignal(host, list(COMSIG_MOVABLE_MOVED, COMSIG_PARENT_QDELETING))
	if(hasprox_receiver)
		UnregisterSignal(hasprox_receiver, COMSIG_PARENT_QDELETING)
	if(new_receiver)
		hasprox_receiver = new_receiver
		if(new_receiver != new_host)
			RegisterSignal(new_receiver, COMSIG_PARENT_QDELETING, PROC_REF(on_host_or_receiver_del))
	else if(hasprox_receiver == host) //Default case
		hasprox_receiver = new_host
	host = new_host
	RegisterSignal(new_host, COMSIG_PARENT_QDELETING, PROC_REF(on_host_or_receiver_del))
	update_connect_range()

/datum/proximity_monitor/proc/update_connect_range()
	if(isnull(current_range))
		qdel(GetComponent(/datum/component/connect_range))
		UnregisterSignal(host, COMSIG_MOVABLE_MOVED)
		return
	RegisterSignal(host, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
	//If the connect_range component exists already, this will just update its args. No errors or duplicates.
	AddComponent(/datum/component/connect_range, host, loc_connections, current_range, !ignore_if_not_on_turf)

/datum/proximity_monitor/proc/on_host_or_receiver_del(datum/source)
	SIGNAL_HANDLER
	qdel(src)

/datum/proximity_monitor/Destroy()
	host = null
	hasprox_receiver = null
	return ..()

/datum/proximity_monitor/proc/set_range(range)
	if(range == current_range)
		return FALSE
	. = TRUE
	current_range = range
	update_connect_range()

/datum/proximity_monitor/proc/on_moved(atom/movable/source, atom/old_loc)
	SIGNAL_HANDLER
	if(source == host)
		hasprox_receiver?.HasProximity(host)

/datum/proximity_monitor/proc/set_ignore_if_not_on_turf(does_ignore = TRUE)
	if(ignore_if_not_on_turf == does_ignore)
		return
	ignore_if_not_on_turf = does_ignore
	update_connect_range()

/datum/proximity_monitor/proc/on_entered(atom/source, atom/movable/arrived)
	SIGNAL_HANDLER
	if(source != host)
		hasprox_receiver?.HasProximity(arrived)
