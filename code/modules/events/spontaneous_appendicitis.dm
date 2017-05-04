/datum/event/spontaneous_appendicitis/start()
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(H.client && H.stat != DEAD)
			var/obj/item/organ/appendix/A = H.organs_by_name[BP_APPENDIX]
			if(!istype(A) || (A && A.inflamed))
				continue
			A.inflamed = 1
			A.update_icon()
			break
