/*----------------------------------------
This is what happens, when we attack aliens.
----------------------------------------*/
/mob/living/carbon/alien/get_unarmed_attack()
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

/mob/living/carbon/alien/has_head(targetzone = null)
	return TRUE

/mob/living/carbon/alien/has_arm(targetzone = null)
	return TRUE

/mob/living/carbon/alien/has_leg(targetzone = null)
	return TRUE
