SUBSYSTEM_DEF(garbage)
	name = "Garbage"

	priority      = SS_PRIORITY_GARBAGE
	wait          = SS_WAIT_GARBAGE
	display_order = SS_DISPLAY_GARBAGE

	flags = SS_FIRE_IN_LOBBY | SS_POST_FIRE_TIMING | SS_BACKGROUND | SS_NO_INIT

	var/list/collection_timeout = list(0, 2 MINUTES, 10 SECONDS)	// deciseconds to wait before moving something up in the queue to the next level

	//Stat tracking
	var/delslasttick = 0			// number of del()'s we've done this tick
	var/gcedlasttick = 0			// number of things that gc'ed last tick
	var/totaldels = 0
	var/totalgcs = 0

	var/highest_del_time = 0
	var/highest_del_tickusage = 0

	var/list/pass_counts
	var/list/fail_counts

	var/list/items = list()			// Holds our qdel_item statistics datums

	//Queue
	var/list/queues

/datum/controller/subsystem/garbage/PreInit()
	queues = new(GC_QUEUE_COUNT)
	pass_counts = new(GC_QUEUE_COUNT)
	fail_counts = new(GC_QUEUE_COUNT)
	for(var/i in 1 to GC_QUEUE_COUNT)
		queues[i] = list()
		pass_counts[i] = 0
		fail_counts[i] = 0

/datum/controller/subsystem/garbage/stat_entry(msg)
	var/list/counts = list()
	for (var/list/L in queues)
		counts += length(L)
	msg += "Q:[counts.Join(",")]|D:[delslasttick]|G:[gcedlasttick]|"
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
	msg += " P:[pass_counts.Join(",")]"
	msg += "|F:[fail_counts.Join(",")]"
	..(msg)

/datum/controller/subsystem/garbage/fire()
	//the fact that this resets its processing each fire (rather then resume where it left off) is intentional.
	var/queue = GC_QUEUE_PREQUEUE

	while (state == SS_RUNNING)
		switch (queue)
			if (GC_QUEUE_PREQUEUE)
				HandlePreQueue()
				queue = GC_QUEUE_PREQUEUE+1
			if (GC_QUEUE_CHECK)
				HandleQueue(GC_QUEUE_CHECK)
				queue = GC_QUEUE_CHECK+1
			if (GC_QUEUE_HARDDELETE)
				HandleQueue(GC_QUEUE_HARDDELETE)
				break

	if (state == SS_PAUSED) //make us wait again before the next run.
		state = SS_RUNNING

//If you see this proc high on the profile, what you are really seeing is the garbage collection/soft delete overhead in byond.
//Don't attempt to optimize, not worth the effort.
/datum/controller/subsystem/garbage/proc/HandlePreQueue()
	var/list/tobequeued = queues[GC_QUEUE_PREQUEUE]
	var/static/count = 0
	if (count)
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		tobequeued.Cut(1,c+1)

	for (var/ref in tobequeued)
		count++
		Queue(ref, GC_QUEUE_PREQUEUE+1)
		if (MC_TICK_CHECK)
			break
	if (count)
		tobequeued.Cut(1,count+1)
		count = 0

/datum/controller/subsystem/garbage/proc/HandleQueue(level = GC_QUEUE_CHECK)
	if (level == GC_QUEUE_CHECK)
		delslasttick = 0
		gcedlasttick = 0
	var/cut_off_time = world.time - collection_timeout[level] //ignore entries newer then this
	var/list/queue = queues[level]
	var/static/lastlevel
	var/static/count = 0
	if (count) //runtime last run before we could do this.
		var/c = count
		count = 0 //so if we runtime on the Cut, we don't try again.
		var/list/lastqueue = queues[lastlevel]
		lastqueue.Cut(1, c+1)

	lastlevel = level

	for (var/refID in queue)
		if (!refID)
			count++
			if (MC_TICK_CHECK)
				break
			continue

		var/GCd_at_time = queue[refID]
		if(GCd_at_time > cut_off_time)
			break // Everything else is newer, skip them
		count++

		var/datum/D
		D = locate(refID)

		if (!D || D.gc_destroyed != GCd_at_time) // So if something else coincidently gets the same ref, it's not deleted by mistake
			++gcedlasttick
			++totalgcs
			pass_counts[level]++
			if (MC_TICK_CHECK)
				break
			continue

		// Something's still referring to the qdel'd object.
		fail_counts[level]++
		switch (level)
			if (GC_QUEUE_CHECK)
				#ifdef GC_FAILURE_HARD_LOOKUP
				D.find_references()
				#endif
				var/type = D.type
				var/datum/qdel_item/I = items[type]
				log_qdel("GC: -- \ref[D] | [type] was unable to be GC'd --")
				I.failures++
			if (GC_QUEUE_HARDDELETE)
				HardDelete(D)
				if (MC_TICK_CHECK)
					break
				continue

		Queue(D, level+1)

		if (MC_TICK_CHECK)
			break
	if (count)
		queue.Cut(1,count+1)
		count = 0

/datum/controller/subsystem/garbage/proc/PreQueue(datum/D)
	if (D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		queues[GC_QUEUE_PREQUEUE] += D
		D.gc_destroyed = GC_QUEUED_FOR_QUEUING

/datum/controller/subsystem/garbage/proc/Queue(datum/D, level = GC_QUEUE_CHECK)
	if (isnull(D))
		return
	if (D.gc_destroyed == GC_QUEUED_FOR_HARD_DEL)
		level = GC_QUEUE_HARDDELETE
	if (level > GC_QUEUE_COUNT)
		HardDelete(D)
		return
	var/gctime = world.time
	var/refid = "\ref[D]"

	D.gc_destroyed = gctime
	var/list/queue = queues[level]
	if (queue[refid])
		queue -= refid // Removing any previous references that were GC'd so that the current object will be at the end of the list.

	queue[refid] = gctime

//this is mainly to separate things profile wise.
/datum/controller/subsystem/garbage/proc/HardDelete(datum/D)
	var/time = world.timeofday
	var/tick = TICK_USAGE
	var/ticktime = world.time
	++delslasttick
	++totaldels
	var/type = D.type
	var/refID = "\ref[D]"

	del(D)

	tick = (TICK_USAGE-tick+((world.time-ticktime)/world.tick_lag*100))

	var/datum/qdel_item/I = items[type]

	I.hard_deletes++
	I.hard_delete_time += TICK_DELTA_TO_MS(tick)


	if (tick > highest_del_tickusage)
		highest_del_tickusage = tick
	time = world.timeofday - time
	if (!time && TICK_DELTA_TO_MS(tick) > 1)
		time = TICK_DELTA_TO_MS(tick)/100
	if (time > highest_del_time)
		highest_del_time = time
	if (time > 10)
		log_qdel("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete)")
		message_admins("Error: [type]([refID]) took longer than 1 second to delete (took [time/10] seconds to delete).")
		postpone(time)

/datum/controller/subsystem/garbage/proc/HardQueue(datum/D)
	if (D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		queues[GC_QUEUE_PREQUEUE] += D
		D.gc_destroyed = GC_QUEUED_FOR_HARD_DEL

/datum/controller/subsystem/garbage/Recover()
	if (istype(SSgarbage.queues))
		for (var/i in 1 to SSgarbage.queues.len)
			queues[i] |= SSgarbage.queues[i]


/datum/qdel_item
	var/name = ""
	var/qdels = 0			//Total number of times it's passed thru qdel.
	var/destroy_time = 0	//Total amount of milliseconds spent processing this type's Destroy()
	var/failures = 0		//Times it was queued for soft deletion but failed to soft delete.
	var/hard_deletes = 0 	//Different from failures because it also includes QDEL_HINT_HARDDEL deletions
	var/hard_delete_time = 0//Total amount of milliseconds spent hard deleting this type.
	var/no_respect_force = 0//Number of times it's not respected force=TRUE
	var/no_hint = 0			//Number of times it's not even bother to give a qdel hint
	var/slept_destroy = 0	//Number of times it's slept in its destroy

/datum/qdel_item/New(mytype)
	name = "[mytype]"


// Should be treated as a replacement for the 'del' keyword.
// Datums passed to this will be given a chance to clean up references to allow the GC to collect them.
/proc/qdel(datum/D, force = FALSE, ...)
	if(!istype(D))
		del(D)
		return
	var/datum/qdel_item/I = SSgarbage.items[D.type]
	if (!I)
		I = SSgarbage.items[D.type] = new /datum/qdel_item(D.type)
	I.qdels++


	if(isnull(D.gc_destroyed))
		if (SEND_SIGNAL(D, COMSIG_PARENT_PREQDELETED, force)) // Give the components a chance to prevent their parent from being deleted
			return
		D.gc_destroyed = GC_CURRENTLY_BEING_QDELETED
		var/start_time = world.time
		var/start_tick = world.tick_usage
		var/hint = D.Destroy(arglist(args.Copy(2))) // Let our friend know they're about to get fucked up.
		SEND_SIGNAL(D, COMSIG_PARENT_QDELETED, force, hint) // Let the (remaining) components know about the result of Destroy
		if(world.time != start_time)
			I.slept_destroy++
		else
			I.destroy_time += TICK_USAGE_TO_MS(start_tick)
		if(!D)
			return
		switch(hint)
			if (QDEL_HINT_QUEUE)		//qdel should queue the object for deletion.
				SSgarbage.PreQueue(D)
			if (QDEL_HINT_IWILLGC)
				D.gc_destroyed = world.time
				SSdemo.mark_destroyed(D)
				return
			if (QDEL_HINT_LETMELIVE)	//qdel should let the object live after calling destory.
				if(!force)
					D.gc_destroyed = null //clear the gc variable (important!)
					return
				// Returning LETMELIVE after being told to force destroy
				// indicates the objects Destroy() does not respect force
				#ifdef TESTING
				if(!I.no_respect_force)
					testing("WARNING: [D.type] has been force deleted, but is \
						returning an immortal QDEL_HINT, indicating it does \
						not respect the force flag for qdel(). It has been \
						placed in the queue, further instances of this type \
						will also be queued.")
				#endif
				I.no_respect_force++

				SSgarbage.PreQueue(D)
			if (QDEL_HINT_HARDDEL)		//qdel should assume this object won't gc, and queue a hard delete using a hard reference to save time from the locate()
				SSdemo.mark_destroyed(D)
				SSgarbage.HardQueue(D)
			if (QDEL_HINT_HARDDEL_NOW)	//qdel should assume this object won't gc, and hard del it post haste.
				SSdemo.mark_destroyed(D)
				SSgarbage.HardDelete(D)
			if (QDEL_HINT_FINDREFERENCE)//qdel will, if TESTING is enabled, display all references to this object, then queue the object for deletion.
				SSgarbage.PreQueue(D)
				#ifdef TESTING
				D.find_references()
				#endif
			else
				#ifdef TESTING
				if(!I.no_hint)
					testing("WARNING: [D.type] is not returning a qdel hint. It is being placed in the queue. Further instances of this type will also be queued.")
				#endif
				I.no_hint++
				SSgarbage.PreQueue(D)
		if(D)
			SSdemo.mark_destroyed(D)
	else if(D.gc_destroyed == GC_CURRENTLY_BEING_QDELETED)
		CRASH("[D.type] destroy proc was called multiple times, likely due to a qdel loop in the Destroy logic")

#ifdef TESTING
/client/var/running_find_references

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
				testing("Found [src.type] \ref[src] in [thing.type]'s \ref[thing] [varname] var.")
			else if(islist(variable))
				if(src in variable)
					testing("Found [src.type] \ref[src] in [thing.type]'s \ref[thing] [varname] list var.")
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

	var/datum/browser/popup = new(usr, "window=qdeletedlog")
	popup.set_content(dat)
	popup.open()
	
#endif
