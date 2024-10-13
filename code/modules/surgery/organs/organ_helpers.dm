/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/proc/get_organ_slot(slot) //is it a brain, is it a brain_tumor?
	return

/mob/living/carbon/human/get_int_organ(typepath)
	return (locate(typepath) in organs_by_name)

/mob/living/carbon/human/get_organ_slot(slot)
	return internal_organs_slot[slot]

/mob/living/carbon/human/proc/get_int_organ_by_name(tag_to_check)
	return organs_by_name[tag_to_check]
