//originally came from tgstation, port more if need (put new procs in same order as on their file version to keep minimal difference).
//pronoun procs, for getting pronouns without using the text macros that only work in certain positions
//datums don't have gender, but most of their subtypes do!
/datum/proc/p_their(capitalized, temp_gender)
	. = "its"
	if(capitalized)
		. = capitalize(.)

//mobs(and atoms but atoms don't really matter write your own proc overrides) also have gender!
/mob/p_their(capitalized, temp_gender)
	if(!temp_gender)
		temp_gender = gender
	. = "its"
	switch(temp_gender)
		if(FEMALE)
			. = "her"
		if(MALE)
			. = "his"
		if(PLURAL)
			. = "their"
	if(capitalized)
		. = capitalize(.)

//humans need special handling, because they can have their gender hidden
/mob/living/carbon/human/p_their(capitalized, temp_gender)
	var/skipface = (wear_mask && (wear_mask.flags_inv & HIDEFACE)) || (head && (head.flags_inv & HIDEFACE))
	if(skipface)
		temp_gender = PLURAL
	return ..()
