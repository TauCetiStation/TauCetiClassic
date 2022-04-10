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

	var/key = input(src, "Key Memory", "How would you like to remember the thing?") as null|text
	if(!key)
		return

	if(!can_remember())
		return

	var/value = input(src, "Key Memory", "What would you like to remember?") as null|text

	if(!can_remember())
		return

	if(!value)
		mind.clear_key_memory(key)
		return

	mind.add_key_memory(key, value)
