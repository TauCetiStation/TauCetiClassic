var/datum/subsystem/garbage_collector/SSgarbage

/datum/subsystem/garbage_collector
	name = "Garbage"

	priority      = SS_PRIORITY_GARBAGE
	wait          = SS_WAIT_GARBAGE
	display_order = SS_DISPLAY_GARBAGE

	flags = SS_FIRE_IN_LOBBY | SS_POST_FIRE_TIMING | SS_BACKGROUND | SS_NO_INIT

	var/collection_timeout = 3000// deciseconds to wait to let running procs finish before we just say fuck it and force del() the object
	var/delslasttick = 0		// number of del()'s we've done this tick
	var/gcedlasttick = 0		// number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_time = 0
	var/highest_del_tickusage = 0

	var/list/queue = list() 	// list of refID's of things that should be garbage collected
								// refID's are associated with the time at which they time out and need to be manually del()
								// we do this so we aren't constantly locating them and preventing them from being gc'd

	var/list/tobequeued = list()	//We store the references of things to be added to the queue seperately so we can spread out GC overhead over a few ticks

	var/list/didntgc = list()	// list of all types that have failed to GC associated with the number of times that's happened.
								// the types are stored as strings

	var/list/noqdelhint = list()// list of all types that do not return a QDEL_HINT

#ifdef TESTING
	var/list/qdel_list = list()	// list of all types that have been qdel()eted
#endif

/datum/subsystem/garbage_collector/New()
	NEW_SS_GLOBAL(SSgarbage)

/datum/subsystem/garbage_collector/stat_entry(msg)
	msg += "Q:[queue.len]|D:[delslasttick]|G:[gcedlasttick]|"
	msg += "GR:"
	if (!(delslasttick+gcedlasttick))
		msg += "n/a|"
	else
		msg += "[round((gcedlasttick/(delslasttick+gcedlasttick))*100, 0.01)]%|"

	msg += "TD:[totaldels]|TG:[totalgcs]|"
	if (!(totaldels+totalgcs))
		msg += "n/a|"
	else
		msg += "TGR:[round((totalgcs/(totaldels+totalgcs))*100, 0.01)]%"
	..(msg)

/datum/subsystem/garbage_collector/fire()
	HandleToBeQueued()
	if (state == SS_RUNNING)
		HandleQueue()

//If you see this proc high on the profile, what you are really seeing is the garbage collection/soft delete overhead in byond.
//Don't attempt to optimize, not worth the effort.
/datum/subsystem/garbage_collector/proc/HandleToBeQueued()
	var/list/tobequeued = src.tobequeued
	var/starttime = world.time
	var/starttimeofday = world.timeofday
	while(tobequeued.len && starttime == world.time && starttimeofday == world.timeofday)
		if (MC_TICK_CHECK)
			break
		var/ref = tobequeued[1]
		Queue(ref)
		tobequeued.Cut(1, 2)

/datum/subsystem/garbage_collector/proc/HandleQueue(time_to_stop)
	delslasttick = 0
	gcedlasttick = 0
	var/time_to_kill = world.time - collection_timeout // Anything qdel() but not GC'd BEFORE this time needs to be manually del()
	var/list/queue = src.queue
	var/starttime = world.time
	var/starttimeofday = world.timeofday
	while(queue.len && starttime == world.time && starttimeofday == world.timeofday)
		if (MC_TICK_CHECK)
			break
		var/refID = queue[1]
		if (!refID)
			queue.Cut(1, 2)
			continue

		var/GCd_at_time = queue[refID]
		if(GCd_at_time > time_to_kill)
			break // Everything else is newer, skip them
		queue.Cut(1, 2)
		var/datum/A
		if (!istext(refID))
			del(refID)
		else
			A = locate(refID)
			if (A && A.gc_destroyed == GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
				// Something's still referring to the qdel'd object.  Kill it.
				var/type = A.type
				testing("GC: -- \ref[A] | [type] was unable to be GC'd and was deleted --")
				didntgc["[type]"]++
				var/time = world.timeofday
				var/tick = world.tick_usage
				var/ticktime = world.time
				del(A)
				tick = (world.tick_usage-tick+((world.time-ticktime)/world.tick_lag*100))
				if (tick > highest_del_tickusage)
					highest_del_tickusage = tick
				time = world.timeofday - time
				if (time > highest_del_time)
					highest_del_time = time
				if (time > 15)
					log_game("Error: [type]([refID]) took longer then 1.5 seconds to delete (took [time/10] seconds to delete)")
					message_admins("Error: [type]([refID]) took longer then 1.5 seconds to delete (took [time/10] seconds to delete).")
					postpone(time/5)
					break
				++delslasttick
				++totaldels
			else
				++gcedlasttick
				++totalgcs

/datum/subsystem/garbage_collector/proc/QueueForQueuing(datum/A)
	if (istype(A) && A.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		tobequeued += A
		A.gc_destroyed = GC_QUEUED_FOR_QUEUING

/datum/subsystem/garbage_collector/proc/Queue(datum/A)
	if (!istype(A) || (!isnull(A.gc_destroyed) && A.gc_destroyed >= 0))
		return
	if (A.gc_destroyed == GC_QUEUED_FOR_HARD_DEL)
		del(A)
		return
	var/gctime = world.time
	var/refid = "\ref[A]"

	A.gc_destroyed = gctime

	if (queue[refid])
		queue -= refid // Removing any previous references that were GC'd so that the current object will be at the end of the list.

	queue[refid] = gctime

/datum/subsystem/garbage_collector/proc/HardQueue(datum/A)
	if (istype(A) && A.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		tobequeued += A
		A.gc_destroyed = GC_QUEUED_FOR_HARD_DEL

/datum/subsystem/garbage_collector/Recover()
	if (istype(SSgarbage.queue))
		queue |= SSgarbage.queue
	if (istype(SSgarbage.tobequeued))
		tobequeued |= SSgarbage.tobequeued

// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/D)
	if(!D)
		return
#ifdef TESTING
	SSgarbage.qdel_list += "[D.type]"
#endif
	if(!istype(D))
		del(D)
	else if(isnull(D.gc_destroyed))
		D.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/hint = D.Destroy() // Let our friend know they're about to get fucked up.
		if(!D)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				SSgarbage.QueueForQueuing(D)
			if (QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				return
			if (QDEL_HINT_IWILLGC)		//functionally the same as the above. qdel should assume the object will gc on its own, and not check it.
				return
			if (QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				SSgarbage.HardQueue(D)
			if (QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				del(D)
			if (QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.QueueForQueuing(D)
				#ifdef TESTING
				D.find_references()
				#endif
			else
				if(!("[D.type]" in SSgarbage.noqdelhint))
					SSgarbage.noqdelhint += "[D.type]"
					testing("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				SSgarbage.QueueForQueuing(D)
	else if(D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		CRASH("[D.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")


// Default implementation of clean-up code.
// This should be overridden to remove all references pointing to the object being destroyed.
// Return the appropriate QDEL_HINT; in most cases this is QDEL_HINT_QUEUE.
/datum/proc/Destroy()
	tag = null
	var/list/timers = active_timers
	active_timers = null
	for(var/thing in timers)
		var/datum/timedevent/timer = thing
		if (timer.spent)
			continue
		qdel(timer)
	return QDEL_HINT_QUEUE

/datum/var/gc_destroyed //Time when this object was destroyed.

#ifdef TESTING
/client/var/running_find_references
/datum/var/running_find_references

/datum/verb/find_references()
	set category = "Debug"
	set name = "Find References"
	set background = 1
	set src in world

	running_find_references = type
	if(usr && usr.client)
		if(usr.client.running_find_references)
			testing("CANCELLED search for references to a [usr.client.running_find_references].")
			usr.client.running_find_references = null
			running_find_references = null
			//restart the garbage collector
			SSgarbage.can_fire = 1
			SSgarbage.next_fire = world.time + world.tick_lag
			return

		if(alert("Running this will create a lot of lag until it finishes.  You can cancel it by running it again.  Would you like to begin the search?", "Find References", "Yes", "No") == "No")
			running_find_references = null
			return

	//this keeps the garbage collector from failing to collect objects being searched for in here
	SSgarbage.can_fire = 0

	if(usr && usr.client)
		usr.client.running_find_references = type

	testing("Beginning search for references to a [type].")
	var/list/things = list()
	for(var/client/thing)
		things |= thing
	for(var/datum/thing)
		things |= thing
	testing("Collected list of things in search for references to a [type]. ([things.len] Thing\s)")
	for(var/datum/thing in things)
		if(usr && usr.client && !usr.client.running_find_references) return
		for(var/varname in thing.vars)
			var/variable = thing.vars[varname]
			if(variable == src)
				testing("Found [src.type] \ref[src] in [thing.type]'s [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s [varname] list var.")
	testing("Completed search for references to a [type].")
	if(usr && usr.client)
		usr.client.running_find_references = null
	running_find_references = null

	//restart the garbage collector
	SSgarbage.can_fire = 1
	SSgarbage.next_fire = world.time + world.tick_lag

/client/verb/purge_all_destroyed_objects()
	set category = "Debug"
	if(SSgarbage)
		while(SSgarbage.queue.len)
			var/datum/o = locate(SSgarbage.queue[1])
			if(istype(o) && o.gc_destroyed)
				del(o)
				SSgarbage.totaldels++
			SSgarbage.queue.Cut(1, 2)

/datum/verb/qdel_then_find_references()
	set category = "Debug"
	set name = "qdel() then Find References"
	set background = 1
	set src in world

	qdel(src)
	if(!running_find_references)
		find_references()

/client/verb/show_qdeleted()
	set category = "Debug"
	set name = "Show qdel() Log"
	set desc = "Render the qdel() log and display it"

	var/dat = "<B>List of things that have been qdel()eted this round</B><BR><BR>"

	var/tmplist = list()
	for(var/elem in SSgarbage.qdel_list)
		if(!(elem in tmplist))
			tmplist[elem] = 0
		tmplist[elem]++

	for(var/path in tmplist)
		dat += "[path] - [tmplist[path]] times<BR>"

	usr << browse(dat, "window=qdeletedlog")
#endif
