// oh god who decided these callbacks is a good idea


/proc/is_present_bodypart(zone, mob/M, intentional)
	if(!ishuman(M))
		return TRUE

	var/mob/living/carbon/human/H = M

	var/obj/item/organ/external/BP = H.get_bodypart(zone)
	if(!BP)
		if(intentional)
			to_chat(H, "<span class='notice'>You can't perform this emote without a [parse_zone(zone)]</span>")
		return FALSE

	return TRUE
