/*----------------------------------------
This is what happens, when we attack aliens.
----------------------------------------*/
/mob/living/carbon/xenomorph/attack_hand(mob/living/carbon/human/M)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	..()

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)

					Weaken(5)
					if (stuttering < 5)
						stuttering = 5
					Stun(5)

					visible_message("<span class='warning'><B>[src] has been touched with the stun gloves by [M]!</B></span>", blind_message = "<span class='warning'>You hear someone fall.</span>")
					return
				else
					to_chat(M, "<span class='warning'>Not enough charge! </span>")
					return

	switch(M.a_intent)

		if ("help")
			if (health > 0)
				help_shake_act(M)

		if ("grab")
			M.Grab(src)

		if ("hurt")
			var/damage = rand(1, 9)
			if (prob(90))
				if (HULK in M.mutations)//HULK SMASH
					damage += 14
					spawn(0)
						Weaken(damage) // Why can a hulk knock an alien out but not knock out a human? Damage is robust enough.
						step_away(src,M,15)
						sleep(3)
						step_away(src,M,15)
				playsound(src, pick(SOUNDIN_PUNCH), VOL_EFFECTS_MASTER)
				visible_message("<span class='warning'><B>[M] has punched [src]!</B></span>")
				if (damage > 9||prob(5))//Regular humans have a very small chance of weakening an alien.
					Weaken(1,5)
					visible_message("<span class='warning'><B>[M] has weakened [src]!</B></span>", blind_message = "<span class='warning'>You hear someone fall.</span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				playsound(src, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)
				visible_message("<span class='warning'><B>[M] has attempted to punch [src]!</B></span>")

		if ("disarm")
			if (!lying)
				if (prob(5))//Very small chance to push an alien down.
					Weaken(2)
					playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
					visible_message("<span class='warning'><B>[M] has pushed down [src]!</B></span>")
				else
					if (prob(50))
						drop_item()
						playsound(src, 'sound/weapons/thudswoosh.ogg', VOL_EFFECTS_MASTER)
						visible_message("<span class='warning'><B>[M] has disarmed [src]!</B></span>")
					else
						playsound(src, 'sound/weapons/punchmiss.ogg', VOL_EFFECTS_MASTER)
						visible_message("<span class='warning'><B>[M] has attempted to disarm [src]!</B></span>")
	return

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

		if ("help")
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

/mob/living/carbon/xenomorph/attack_animal(mob/living/simple_animal/M)
	if(..())
		return
	if(M.melee_damage_upper == 0)
		M.emote("[M.friendly] [src]")
	else
		if(length(M.attack_sound))
			playsound(src, pick(M.attack_sound), VOL_EFFECTS_MASTER)
		visible_message("<span class='userdanger'><B>[M]</B>[M.attacktext] [src]!</span>")
		var/damage = rand(M.melee_damage_lower, M.melee_damage_upper)
		adjustBruteLoss(damage)
		updatehealth()

/mob/living/carbon/xenomorph/attack_alien(mob/living/carbon/xenomorph/M)
	if (!ticker)
		to_chat(M, "You cannot attack people before the game has started.")
		return

	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	..()

	switch(M.a_intent)

		if ("help")
			AdjustSleeping(-10 SECONDS)
			resting = 0
			AdjustParalysis(-3)
			AdjustStunned(-3)
			AdjustWeakened(-3)
			visible_message("<span class='notice'>[M.name] nuzzles [src] trying to wake it up!</span>")

		else
			if (health > 0)
				playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
				var/damage = rand(1, 3)
				visible_message("<span class='warning'><B>[M.name] has bit [src]!</B></span>")
				adjustBruteLoss(damage)
				updatehealth()
			else
				to_chat(M, "<span class='notice'><B>[name] is too injured for that.</B></span>")
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
