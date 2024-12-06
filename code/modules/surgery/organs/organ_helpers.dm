/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/living/carbon/human/get_int_organ(typepath)
	return (locate(typepath) in organs_by_name)

/mob/living/carbon/human/proc/get_int_organ_by_name(tag_to_check)
	return organs_by_name[tag_to_check]
