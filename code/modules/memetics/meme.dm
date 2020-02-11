var/global/datum/meme/list/memes_by_id = list()

/proc/populate_meme_list()
	for(var/meme_type in subtypesof(/datum/meme))
		var/datum/meme/M = new meme_type
		global.memes_by_id[M.id] = M

	for(var/obj/machinery/message_server/server in message_servers)
		if(!isnull(server) && !isnull(server.decryptkey))
			create_meme(/datum/meme/memory/password/PDA, "PDA_password_" + server.decryptkey, server.decryptkey)

	for(var/obj/machinery/nuclearbomb/nuke in poi_list)
		create_meme(/datum/meme/memory/password/nuke, "nuke_password_" + nuke.r_code, nuke.r_code)

/*
 * A meme(fr. "may-may" - bullshit) is a framework for any "information"
 * that a *character* posseses, but a *player* does not.
 * This information, of course can influence the flow of game in any amount of ways.
 * And true to it's name, the information itself, is easily spreadible, and modified.
 */
/datum/meme
	var/name
	var/desc
	var/long_desc

	// How high of a priority this meme takes, when overriding perception-related stuff.
	// Values below(or equal to) 0 do not even override default perception.
	var/perception_priority = 1

	// The unique ID of this very meme. No two memes share it.
	var/id
	// The ID used to determine whether two memes should somehow collide/stack over a spot.
	var/stack_id

	var/stack_type = MEME_STACK_KEEP_NEW

	var/list/atom/hosts

	var/list/flags = list()

	var/category = MEME_CATEGORY_MEME

	// Whether the mob infected with this meme
	// can know, and interact with it.
	var/hidden = TRUE
	// Whether the mob can voluntarily forget this meme.
	var/can_forget = FALSE

	// Some memes should cease existing if there are no hosts
	// of them.
	var/destroy_on_no_hosts = FALSE

/datum/meme/New(my_type, my_id)
	id = my_id
	global.memes_by_id[id] = src

/datum/meme/Destroy()
	var/list/prev_hosts = hosts.Copy()
	for(var/atom/old_host in prev_hosts)
		on_detach(old_host)

	global.memes_by_id -= id

	hosts = null
	return ..()

// Here we register Signals, and perhaps add some visual cues
// the the atom is a carrier of a meme.
/datum/meme/proc/on_attach(atom/host)
	if(!host)
		return FALSE

	LAZYADD(hosts, host)

	if(!host.attached_memes)
		host.attached_memes = list()
	host.attached_memes[id] = src

	if(ismob(host) && !hidden)
		var/mob/M = host
		if(!M.browseable_memes)
			M.browseable_memes = list()
		if(!M.browseable_memes[category])
			M.browseable_memes[category] = list()
		M.browseable_memes[category] += src

	if(flags[MEME_SPREAD_INSPECTION])
		RegisterSignal(host, list(COMSIG_PRE_EXAMINE), .proc/on_pre_examine)
	if(flags[MEME_SPREAD_READING])
		RegisterSignal(host, list(COMSIG_PAPER_READ), .proc/on_read)

	SEND_SIGNAL(host, COMSIG_MEME_ADDED, src)

	return TRUE

// Here we unregister Signals,
// remove the visual cues, and perhaps say something
// to the thing we attached to(if it's a mob).
/datum/meme/proc/on_detach(atom/old_host)
	LAZYREMOVE(hosts, old_host)
	old_host.attached_memes -= id
	if(!old_host.attached_memes.len)
		old_host.attached_memes = null

	if(old_host.stacked_memes && old_host.stacked_memes[stack_id])
		old_host.stacked_memes[stack_id] -= src
		if(!length(old_host.stacked_memes[stack_id]))
			old_host.stacked_memes -= stack_id
		if(!old_host.stacked_memes.len)
			old_host.stacked_memes = null

	if(ismob(old_host) && !hidden)
		var/mob/M = old_host
		M.browseable_memes[category] -= src
		if(!length(M.browseable_memes[category]))
			M.browseable_memes -= category
		if(!M.browseable_memes.len)
			M.browseable_memes = null

	if(flags[MEME_SPREAD_INSPECTION])
		UnregisterSignal(old_host, list(COMSIG_PRE_EXAMINE))
	if(flags[MEME_SPREAD_READING])
		UnregisterSignal(old_host, list(COMSIG_PAPER_READ))

	SEND_SIGNAL(old_host, COMSIG_MEME_REMOVED, src)

	if(!QDELING(src) && destroy_on_no_hosts && !hosts)
		qdel(src)

// How we react to a new meme with same stack_id.
/datum/meme/proc/on_stack(atom/host, datum/meme/other_meme)
	return

// Is called when one host sends memes to another host.
/datum/meme/proc/on_pass(atom/host, atom/new_host)
	return

// How does user perceive this meme's name.
/datum/meme/proc/get_name(mob/user)
	return name

// How is this meme displayed in written text.
/datum/meme/proc/get_meme_text()
	return "<span style='color: #ffffff; background-color: #341c3a'>[name]</span>"

// How a meme reacts to being spoken out load.
// Return /datum/spoken_info or null.
/datum/meme/proc/on_speak(datum/spoken_info/SI)
	return

// How a meme reacts to being heard.
// Return /datum/spoken_info or null.
/datum/meme/proc/on_hear(datum/spoken_info/SI)
	return

// How meme writing reflects on an object.
/datum/meme/proc/on_write(datum/source, obj/writee, text)
	return

/datum/meme/proc/on_pre_examine(datum/source, mob/examiner)
	. = NONE
	if(flags[MEME_PREVENT_INSPECTION])
		. |= COMPONENT_CANCEL_EXAMINE

	try_affect(source, examiner)

// How a meme reacts on being read.
// Either return a series of flags, or the new text.
/datum/meme/proc/on_read(datum/source, mob/reader, text)
	. = NONE
	if(flags[MEME_STAR_TEXT])
		. |= COMPONENT_STAR_TEXT

	if(!reader.can_read())
		return

	try_affect(source, reader)

// Handles counter_memes, please, from your Signal-receiving procs, call this, and not affect() directly.
/datum/meme/proc/try_affect(atom/host, atom/A)
	if(host.counter_memes)
		var/list/to_check = host.counter_memes[MEME_COUNTER_ALL]
		to_check |= host.counter_memes[id]

		for(var/datum/meme/countermeme/CM in to_check)
			if(CM.counter_type & MEME_COUNTER_SPREAD)
				return

	if(A.counter_memes)
		var/list/to_check = A.counter_memes[MEME_COUNTER_ALL]
		to_check |= A.counter_memes[id]

		for(var/datum/meme/countermeme/CM in to_check)
			if(CM.counter_type & MEME_COUNTER_WHILE_PRESENT)
				return

	affect(host, A)

// How the meme affects the thing that
// perceived it, or is spreading it.
/datum/meme/proc/affect(atom/host, atom/A)
	return



/atom
	// An associative list of meme_id = meme.
	var/list/attached_memes
	// An associative list of meme_stack_id = meme "group"(a list)
	var/list/stacked_memes

/mob
	// An associative list of meme category = list of memes in that category.
	var/list/browseable_memes

/mob/proc/can_read()
	return FALSE

/mob/dead/observer/can_read()
	return TRUE

/mob/living/carbon/human/can_read()
	return TRUE

/mob/living/silicon/can_read()
	return TRUE

/*
	HELPER PROCS
*/
/proc/create_meme(meme_type, meme_id, ...)
	if(global.memes_by_id[meme_id])
		return global.memes_by_id[meme_id]

	var/list/arguments = args.Copy()

	var/datum/meme/M = new meme_type(arglist(arguments))

	return M

/atom/proc/attach_meme(meme_id, ...)
	if(attached_memes && attached_memes[meme_id])
		return attached_memes[meme_id]

	var/datum/meme/M = global.memes_by_id[meme_id]
	if(!M)
		return null

	if(counter_memes)
		var/list/to_check = counter_memes[MEME_COUNTER_ALL]
		to_check |= counter_memes[meme_id]

		for(var/datum/meme/countermeme/CM in to_check)
			if(CM.counter_type & MEME_COUNTER_DESTROY)
				return null

	if(stacked_memes && stacked_memes[M.stack_id])
		var/list/to_check = stacked_memes[M.stack_id].Copy()
		for(var/datum/meme/stack_meme in to_check)
			switch(stack_meme.stack_type)
				if(MEME_STACK_KEEP_OLD)
					stack_meme.on_stack(src, M)
					return stack_meme

				if(MEME_STACK_KEEP_NEW)
					M.on_stack(src, stack_meme)

	if(!isnull(M.stack_id))
		if(!stacked_memes)
			stacked_memes = list()
		if(!stacked_memes[M.stack_id])
			stacked_memes[M.stack_id] = list()
		stacked_memes[M.stack_id] += M

	var/list/arguments = args.Copy()
	arguments[1] = src

	M.on_attach(arglist(arguments))
	return M

/atom/proc/remove_meme(meme_id)
	var/datum/meme/M = attached_memes[meme_id]
	if(M)
		M.on_detach(src)

/atom/proc/clear_memes()
	for(var/meme_id in attached_memes)
		remove_meme(meme_id)

/atom/proc/pass_all_memes(atom/target, list/pass_flags=null)
	for(var/meme_id in attached_memes)
		var/datum/meme/M = attached_memes[meme_id]

		var/has_all_flags = TRUE
		for(var/fl in pass_flags)
			if(!M.flags[fl])
				has_all_flags = FALSE
				break

		if(has_all_flags)
			// Since some meme stacking can make the meme above into other meme.
			var/datum/meme/passed_meme = target.attach_meme(meme_id)
			passed_meme.on_pass(src, target)

/atom/proc/pass_memes(atom/target, list/meme_ids)
	for(var/meme_id in meme_ids)
		// Since some meme stacking can make the meme above into other meme.
		var/datum/meme/passed_meme = target.attach_meme(meme_id)
		passed_meme.on_pass(src, target)

/atom/proc/has_meme(meme_id)
	if(!attached_memes)
		return null
	return attached_memes[meme_id]

/atom/proc/get_stacked_memes(memes_stack_id)
	if(!stacked_memes)
		return null
	return stacked_memes[memes_stack_id]
