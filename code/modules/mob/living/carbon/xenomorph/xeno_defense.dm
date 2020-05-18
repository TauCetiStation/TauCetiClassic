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

/mob/living/carbon/xenomorph/attack_paw(mob/living/carbon/monkey/M)
	if(!ismonkey(M))	return//Fix for aliens receiving double messages when attacking other aliens.

	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return
	..()

	switch(M.a_intent)

		if (INTENT_HELP)
			help_shake_act(M)
		else
			if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
				return
			if (health > 0)
				playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
				visible_message("<span class='warning'><B>[M.name] has bit [src]!</B></span>")
				adjustBruteLoss(rand(1, 3))
				updatehealth()
	return

/mob/living/carbon/xenomorph/attack_slime(mob/living/carbon/slime/M)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if(M.Victim) return // can't attack while eating!

	if (health > -100)

		visible_message("<span class='warning'><B>The [M.name] glomps [src]!</B></span>")

		var/damage = rand(1, 3)

		if(istype(M, /mob/living/carbon/slime/adult))
			damage = rand(10, 40)
		else
			damage = rand(5, 35)

		adjustBruteLoss(damage)

		if(M.powerlevel > 0)
			var/stunprob = 10
			var/power = M.powerlevel + rand(0,3)

			switch(M.powerlevel)
				if(1 to 2) stunprob = 20
				if(3 to 4) stunprob = 30
				if(5 to 6) stunprob = 40
				if(7 to 8) stunprob = 60
				if(9) 	   stunprob = 70
				if(10) 	   stunprob = 95

			if(prob(stunprob))
				M.powerlevel -= 3
				if(M.powerlevel < 0)
					M.powerlevel = 0

				visible_message("<span class='warning'><B>The [M.name] has shocked [src]!</B></span>")

				Weaken(power)
				if (stuttering < power)
					stuttering = power
				Stun(power)

				var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
				s.set_up(5, 1, src)
				s.start()

				if (prob(stunprob) && M.powerlevel >= 8)
					adjustFireLoss(M.powerlevel * rand(6,10))


		updatehealth()

	return
