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
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

	switch(M.a_intent)
		if("help")
			M.do_attack_animation(src)
			var/damage = rand(1, 5)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("\red <B>[M] has lunged at [src]!</B>")
				return 0
			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]
			var/armor_block = run_armor_check(BP, "melee")
			playsound(loc, 'sound/weapons/bite.ogg', 25, 1, -1)
			visible_message("\red <B>[M] has bitten [src]!</B>")
			apply_damage(damage, BRUTE, BP, armor_block)
			updatehealth()

/mob/living/carbon/human/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(check_shields(0, M.name, get_dir(M,src) ))
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

	switch(M.a_intent)
		if ("help")
			visible_message(text("\blue [M] caresses [src] with its scythe like arm."))
		if ("grab")
			M.Grab(src)
		if("hurt")
			M.do_attack_animation(src)
			if (w_uniform)
				w_uniform.add_fingerprint(M)
			var/damage = rand(15, 30)
			if(!damage)
				playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
				visible_message("\red <B>[M] has lunged at [src]!</B>")
				return 0
			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]
			var/armor_block = run_armor_check(BP, "melee")

			playsound(loc, 'sound/weapons/slice.ogg', 25, 1, -1)
			visible_message("\red <B>[M] has slashed at [src]!</B>")

			apply_damage(damage, BRUTE, BP, armor_block)
			if (damage >= 20)
				visible_message("\red <B>[M] has wounded [src]!</B>")
				apply_effect(rand(3,5), WEAKEN, armor_block)
			updatehealth()

		if("disarm")
			if (prob(80))
				playsound(loc, 'sound/weapons/pierce.ogg', 25, 1, -1)
				Weaken(rand(3,5))
				for(var/mob/O in viewers(src, null))
					if ((O.client && !( O.blinded )))
						O.show_message(text("\red <B>[] has tackled down []!</B>", M, src), 1)
				if (prob(25))
					M.Weaken(rand(5,8))
			else
				if (prob(80))
					playsound(loc, 'sound/weapons/slash.ogg', 25, 1, -1)
					drop_item()
					visible_message(text("\red <B>[] disarmed []!</B>", M, src))
				else
					playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1, -1)
					visible_message(text("\red <B>[] has tried to disarm []!</B>", M, src))
	return
