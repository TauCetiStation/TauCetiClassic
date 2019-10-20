/*----------------------------------------
This is what happens, when alien attack.
----------------------------------------*/
/mob/living/carbon/alien/UnarmedAttack(atom/A)
	..()
	A.attack_alien(src)

/atom/proc/attack_alien(mob/user)
	attack_paw(user)
	return

// Baby aliens
/mob/living/carbon/alien/facehugger/UnarmedAttack(atom/A)
	SetNextMove(CLICK_CD_MELEE)
	A.attack_facehugger(src)

/atom/proc/attack_facehugger(mob/user)
	return

/mob/living/carbon/alien/larva/UnarmedAttack(atom/A)
	..()
	A.attack_larva(src)

/atom/proc/attack_larva(mob/user)
	return

/mob/living/carbon/human/attack_larva(mob/living/carbon/alien/larva/M)
	if(check_shields(0, M.name, get_dir(M,src) ))
		visible_message("<span class='warning'><B>[M] attempted to touch [src]!</B></span>")
		return 0

	switch(M.a_intent)
		if("help")
			M.do_attack_animation(src)
			var/damage = rand(1, 5)
			if(!damage)
				playsound(src, 'sound/weapons/slashmiss.ogg', VOL_EFFECTS_MASTER)
				visible_message("<span class='warning'><B>[M] has lunged at [src]!</B></span>")
				return 0
			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]
			var/armor_block = run_armor_check(BP, "melee")
			playsound(src, 'sound/weapons/bite.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'><B>[M] has bitten [src]!</B></span>")
			apply_damage(damage, BRUTE, BP, armor_block)
			updatehealth()

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(0, M.name, get_dir(M,src) ))
		visible_message("<span class='warning'><B>[M] attempted to touch [src]!</B></span>")
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message(text("<span class='notice'>[M] caresses [src] with its scythe like arm.</span>"))
		if ("grab")
			M.Grab(src)
		if("hurt")
			M.do_attack_animation(src)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(src, 'sound/weapons/slashmiss.ogg', VOL_EFFECTS_MASTER)
				visible_message("<span class='warning'><B>[M] has lunged at [src]!</B></span>")
				return 0
			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]
			var/armor_block = run_armor_check(BP, "melee")

			playsound(src, 'sound/weapons/slice.ogg', VOL_EFFECTS_MASTER)
			visible_message("<span class='warning'><B>[M] has slashed at [src]!</B></span>")

			apply_damage(damage, BRUTE, BP, armor_block)
			if (damage >= 20)
				visible_message("<span class='warning'><B>[M] has wounded [src]!</B></span>")
				apply_effect(rand(3,5), WEAKEN, armor_block)
			updatehealth()

		if("disarm")
			if (prob(80))
				playsound(src, 'sound/weapons/pierce.ogg', VOL_EFFECTS_MASTER)
				Weaken(rand(3,5))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("<span class='warning'><B>[] has tackled down []!</B></span>", M, src), 1)
				if (prob(25))
					M.Weaken(rand(5,8))
			else
				if (prob(80))
					playsound(src, 'sound/weapons/slash.ogg', VOL_EFFECTS_MASTER)
					drop_item()
					visible_message(text("<span class='warning'><B>[] disarmed []!</B></span>", M, src))
				else
					playsound(src, 'sound/weapons/slashmiss.ogg', VOL_EFFECTS_MASTER)
					visible_message(text("<span class='warning'><B>[] has tried to disarm []!</B></span>", M, src))
	return
