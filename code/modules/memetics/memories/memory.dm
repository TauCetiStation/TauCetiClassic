/datum/meme/memory
	category = MEME_CATEGORY_MEMORY

	hidden = FALSE
	can_forget = TRUE

	stack_type = MEME_STACK_KEEP_BOTH

	// A message displayed to player when they gain the memory.
	var/gain_txt
	// A message displayed to player when they lose the memory.
	var/lose_txt

	// Possible strings of text shown to player when they try to remember the memory and fail.
	var/list/forgetting_txts

	var/list/active_for = list()
	var/list/active_memory_timers = list()

	// Memory can be degraded by brainLoss, head trauma.
	var/list/reliabilities = list()
	var/list/display_name = list()

/datum/meme/memory/get_name(mob/user)
	var/dis_name = name
	if(ismob(user))
		dis_name = display_name[user]
		var/star_coeff = 100 - reliabilities[user]
		if(star_coeff > 0)
			dis_name = stars(dis_name, star_coeff)
	return dis_name

/datum/meme/memory/on_attach(atom/host, reliability=100)
	. = ..()
	if(. && ismob(host))
		if(gain_txt)
			to_chat(host, "<span class='notice'>[gain_txt]</span>")

		reliabilities[host] = reliability

		var/dis_name = name
		if(host.stacked_memes && host.stacked_memes[stack_id])
			dis_name += " #[length(host.stacked_memes[stack_id])]"

		display_name[host] = dis_name

/datum/meme/memory/on_detach(atom/old_host)
	if(ismob(old_host))
		if(lose_txt)
			to_chat(host, "<span class='warning'>[lose_txt]</span>")
		reliabilities -= old_host
		display_name -= old_host
	..()

/datum/meme/memory/on_pass(atom/host, atom/new_host)
	if(ismob(host) && ismob(new_host))
		reliabilities[new_host] = reliabilities[host]
		display_name[new_host] = display_name[host]

/datum/meme/memory/on_speak(datum/spoken_info/SI)
	var/datum/spoken_info/warped_SI = SI.copy()
	warped_SI.spoken_verb = "[warped_SI.spoken_verb] something about <span class='meme'>[get_name(SI.speaker)]</span>"
	warped_SI.message = pick("Blah-blah-blah!", "Yadda-yadda-yadda!", "Gibbity-goob-doob!")
	return warped_SI

/datum/meme/memory/on_hear(datum/spoken_info/SI)
	try_affect(SI.speaker, SI.hearer)

/datum/meme/memory/affect(atom/host, atom/A)
	if(ismob(A))
		host.pass_memes(A, list(id))

/datum/meme/memory/proc/get_forgetting_txt()
	return pick(forgetting_txts)

/datum/meme/memory/proc/adjustReliability(mob/host, value)
	reliabilities[host] += value
	if(reliabilities[host] <= 0)
		host.remove_meme(id)

/datum/meme/memory/proc/try_remember(mob/user)
	if(prob(reliabilities[user]))
		return TRUE

	to_chat(user, "<span class='warning'>[get_forgetting_txt()]</span>")
	adjustReliability(user, -10)
	return FALSE



#define DEF_MEMORY_ACTIVE_TIME 5 MINUTES

/mob
	// The list of memories that are actively remembered. Is used when entering passwords as to not choose a password each time you enter it.
	var/list/active_memes

/*
 * HELPER PROCS
 */
/mob/proc/forget_memories(value)
	var/list/memories = list()
	for(var/meme_id in attached_memes)
		var/datum/meme/M = attached_memes[meme_id]
		if(istype(M, /datum/meme/memory))
			memories += M

	if(!memories.len)
		return

	while(value > 0)
		var/datum/meme/memory/M = pick(memories)
		var/adjust_val = pick(0, M.reliabilities[src])

		M.adjustReliability(src, -adjust_val)

		value -= adjust_val

/mob/proc/activate_memory(memory_id, active_time = DEF_MEMORY_ACTIVE_TIME)
	var/datum/meme/memory/M = attached_memes[memory_id]
	if(!M)
		return

	if(M.active_for[src])
		return

	if(!active_memes)
		active_memes = list()
	if(!active_memes[M.stack_id])
		active_memes[M.stack_id] = list()

	var/memory_timer_id = addtimer(CALLBACK(src, .proc/deactivate_memory, memory_id), active_time, TIMER_STOPPABLE)

	active_memes[M.stack_id] += M

	M.active_for[src] = TRUE
	M.active_memory_timers[src] = memory_timer_id

/mob/proc/deactivate_memory(memory_id)
	var/datum/meme/memory/M = attached_memes[memory_id]
	if(!M)
		return

	if(!M.active_for[src])
		return

	active_memes[M.stack_id] -= M
	if(!length(active_memes[M.stack_id]))
		active_memes -= M.stack_id
	if(!active_memes.len)
		active_memes = null

	M.active_for -= src
	deltimer(M.active_memory_timers[src])
	M.active_memory_timers -= src

// Handles "remembering" a memory of certain stack id.
// "Active" memories get a priority.
// Otherwise, asks to pick an active memory.
/mob/proc/handle_appropriate_memories(stack_id, input_message)
	var/list/pos_active_memories = active_memes[stack_id]
	if(pos_active_memories)
		return pos_active_memories

	var/list/pos_memories = get_stacked_memes(stack_id)
	if(pos_memories)
		if(pos_memories.len == 1)
			var/datum/meme/memory/M = pos_memories[1]
			activate_memory(M.id)
			return M
		else
			var/list/options = list()
			for(var/datum/meme/memory/M in pos_memories)
				options["[M.get_name(src)]"] = M

			var/chosen = input(src, input_message ? input_message : "Please choose an appropriate memory for task.", "Remembrance.") as null|anything in options
			if(chosen)
				var/datum/meme/memory/M = options[chosen]
				activate_memory(M.id)
				return M

	return null
