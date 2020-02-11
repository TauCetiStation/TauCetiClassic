// A countermeme is a meme that deletes any meme instances of counter_id, as well
// Use MEME_COUNTER_ALL counter_id to counter all instances.
/datum/meme/countermeme
	category = MEME_CATEGORY_COUNTERMEME

	stack_type = MEME_STACK_KEEP_BOTH

	var/list/counter_ids

	var/counter_type = MEME_COUNTER_WHILE_PRESENT

/datum/meme/countermeme/New(my_type, my_id, my_counter_ids=list(MEME_COUNTER_ALL))
	..()
	counter_ids = my_counter_ids

/datum/meme/countermeme/on_attach(atom/host, ...)
	. = ..()
	if(.)
		if(!host.counter_memes)
			host.counter_memes = list()
		for(var/counter_id in counter_ids)
			if(!host.counter_memes[counter_id])
				host.counter_memes[counter_id] = list()
			host.counter_memes[counter_id] += src

		if(counter_type & MEME_COUNTER_DESTROY)
			var/list/memes_to_unattach = list()

			if(MEME_COUNTER_ALL in counter_ids)
				memes_to_unattach = host.attached_memes
			else
				memes_to_unattach = counter_ids

			// YES, A MEME_COUNTER_DESTROY and MEME_COUNTER_ALL MEME DESTROYS ITSELF.
			// OTHERWISE IT WOULD BE QUITE OP AND STUFF.
			for(var/meme_id in memes_to_unattach)
				host.remove_meme(meme_id)

/datum/meme/countermeme/on_detach(atom/old_host)
	for(var/counter_id in counter_ids)
		old_host.counter_memes[counter_id] -= src
		if(!length(old_host.counter_memes[counter_id]))
			old_host.counter_memes -= counter_id

	if(!old_host.counter_memes.len)
		old_host.counter_memes = null

	return ..()

/atom
	var/list/counter_memes



// A very strong self-destructing counter-meme.
/datum/meme/countermeme/clear
	counter_type = MEME_COUNTER_DESTROY
