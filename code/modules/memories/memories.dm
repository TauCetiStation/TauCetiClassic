/datum/mind
	var/list/key_memories

/datum/mind/proc/add_key_memory(key, value)
	LAZYSET(key_memories, key, value)

/datum/mind/proc/clear_key_memory(key)
	LAZYREMOVE(key_memories, key)

/datum/mind/proc/has_key_memory(key)
	return LAZYACCESS(key_memories, key)

/datum/mind/proc/get_key_memory(key)
	return LAZYACCESS(key_memories, key)


/mob/proc/can_remember()
	return stat == CONSCIOUS && mind

/mob/verb/list_key_memories()
	set name = "Key Memories"
	set category = "IC"
	set src = usr

	if(!can_remember())
		return

	var/output = "<B>[real_name] Remembers:</B><HR>"
	for(var/key in mind.key_memories)
		var/memory = mind.get_key_memory(key)

		output += "[key] as [memory]<BR>"

	output += "<a href=?src=\ref[mind];add_key_memory=1>Add/Remove a Memory</a><BR>"

	var/datum/browser/popup = new(src, "window=key_memories")
	popup.set_content(output)
	popup.open()

/mob/verb/add_key_memory()
	set name = "Add Key Memory"
	set category = "IC"
	set src = usr

	if(!can_remember())
		return

	if(length(mind.key_memories) > MEM_MAX_COUNT)
		to_chat(src, "<span class='warning'>You remember too much...</span>")
		return

	var/key = sanitize_safe(input(src, "Key Memory", "How would you like to remember the thing?") as null|text, MAX_NAME_LEN)
	if(!key)
		return

	if(!can_remember())
		return

	var/value = sanitize_safe(input(src, "Key Memory", "What would you like to remember? Press cancel to forget.") as null|message, MAX_PAPER_MESSAGE_LEN, extra = FALSE)

	if(!can_remember())
		return

	if(!value)
		mind.clear_key_memory(key)
		return

	mind.add_key_memory(key, value)
	list_key_memories()
