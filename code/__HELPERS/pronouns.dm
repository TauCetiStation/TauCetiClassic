/proc/p_they(gender)
	switch(gender)
		if(MALE)
			return "he"
		if(FEMALE)
			return "she"
		if(NEUTER)
			return "it"

	return "they"

/proc/p_them(gender)
	switch(gender)
		if(MALE)
			return "him"
		if(FEMALE)
			return "her"

	return "them"
