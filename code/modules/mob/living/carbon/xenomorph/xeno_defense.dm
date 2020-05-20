/mob/living/carbon/xenomorph/get_unarmed_attack()
	var/retDam = 23
	var/retDamType = BRUTE
	var/retFlags = DAM_SHARP
	var/retVerb = "slash"
	var/retSound = 'sound/weapons/slice.ogg'
	var/retMissSound = 'sound/weapons/slashmiss.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/carbon/xenomorph/is_usable_head(targetzone = null)
	return TRUE

/mob/living/carbon/xenomorph/is_usable_arm(targetzone = null)
	return TRUE

/mob/living/carbon/xenomorph/is_usable_leg(targetzone = null)
	return TRUE
