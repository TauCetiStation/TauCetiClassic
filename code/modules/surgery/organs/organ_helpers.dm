/mob/proc/get_int_organ(typepath) //int stands for internal
	return

/mob/proc/get_organs_zone(zone)
	return

/mob/proc/get_organ_slot(slot) //is it a brain, is it a brain_tumor?
	return

/mob/proc/get_int_organ_tag(tag) //is it a brain, is it a brain_tumor?
	return

/mob/living/carbon/get_int_organ(typepath)
	return (locate(typepath) in organs_by_name)

/mob/living/carbon/proc/get_int_organ_by_name(tag_to_check)
	return organs_by_name[tag_to_check]

/mob/living/carbon/get_organ_slot(slot)
	return internal_organs_slot[slot]

/mob/living/carbon/get_int_organ_tag(tag)
	for(var/obj/item/organ/internal/O in organs)
		if(tag == O.organ_tag)
			return O

/proc/is_int_organ(atom/A)
	return istype(A, /obj/item/organ/internal)
