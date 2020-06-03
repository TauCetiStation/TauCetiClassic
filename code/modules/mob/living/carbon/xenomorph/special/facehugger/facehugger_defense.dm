/mob/living/carbon/xenomorph/facehugger/get_unarmed_attack()
	var/retDam = 2
	var/retDamType = BRUTE
	var/retFlags = DAM_SHARP
	var/retVerb = "gnaw"
	var/retSound = 'sound/weapons/bite.ogg'
	var/retMissSound = 'sound/weapons/punchmiss.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/carbon/xenomorph/facehugger/is_usable_head(targetzone = null)
	return TRUE

/mob/living/carbon/xenomorph/facehugger/is_usable_arm(targetzone = null)
	return TRUE

/mob/living/carbon/xenomorph/facehugger/is_usable_leg(targetzone = null)
	return FALSE
