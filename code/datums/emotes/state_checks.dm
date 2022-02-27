/proc/is_stat(stat, mob/M, intentional)
	if(M.stat > stat)
		if(intentional)
			to_chat(M, "<span class='notice'>You can't emote in this state.</span>")
		return FALSE

	return TRUE

/proc/is_not_intentional_or_stat(stat, mob/M, intentional)
	if(!intentional)
		return TRUE

	return is_stat(stat, M, intentional)
