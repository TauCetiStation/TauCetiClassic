/mob/handle_drowning()
	return

/mob/living/can_drown()
	return TRUE

/mob/living/simple_animal/hostile/carp/can_drown() // its a CRAP!
	return FALSE

/mob/living/simple_animal/hostile/carp/dog/can_drown() // not a CRAP!
	return TRUE

/mob/living/carbon/human/can_drown()
	if(!internal && !istype(wear_mask, /obj/item/clothing/mask/snorkel))
		var/obj/item/organ/internal/lungs/L = locate() in organs
		return (L && !L.has_gills)
	return FALSE

/mob/living/handle_drowning()
	if(!can_drown() || !loc.is_flooded(lying))
		return FALSE
	to_chat(src, "<span class='danger'>You choke and splutter as you inhale water!</span>")
	return TRUE // Presumably chemical smoke can't be breathed while you're underwater.
