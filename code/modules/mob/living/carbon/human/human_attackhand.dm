/mob/living/carbon/human/proc/get_unarmed_attack(var/mob/living/carbon/human/target, var/hit_zone)
	for(var/datum/unarmed_attack/u_attack in species.unarmed_attacks)
		if(u_attack.is_usable(src, target, hit_zone))
			if(pulling_punches)
				var/datum/unarmed_attack/soft_variant = u_attack.get_sparring_variant()
				if(soft_variant)
					return soft_variant
			return u_attack
	return null

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return

	var/obj/item/bodypart/r_arm = M:bodyparts_by_name[BP_R_ARM]
	if (M.hand)
		r_arm = M:bodyparts_by_name[BP_L_ARM]
	if(r_arm && !r_arm.is_usable())
		to_chat(M, "\red You can't use your [r_arm.name].")
		return

	..()

	if((M != src) && check_shields(0, M.name, get_dir(M,src)))
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

	if(M.wear_suit && istype(M.wear_suit, /obj/item/clothing/suit/armor/abductor/vest))	//When abductor will hit someone from stelth he will reveal himself
		for(var/obj/item/clothing/suit/armor/abductor/vest/V in list(M.wear_suit))
			if(V.stealth_active)
				V.DeactivateStealth()

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		M.do_attack_animation(src)
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					G.update_icon()
					var/mob/living/carbon/human/target = src
					var/obj/item/bodypart/BP = get_bodypart(M.zone_sel.selecting) // We're checking the outside, buddy!
					var/calc_power
					if((prob(25) && !istype(G, /obj/item/clothing/gloves/yellow)) && (target != M))
						visible_message("\red <B>[M] accidentally touched \himself with the stun gloves!</B>")
						M.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to touch [src.name] ([src.ckey]) with stungloves</font>")
						src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been unsuccessfully touched with stungloves by [M.name] ([M.ckey])</font>")
						msg_admin_attack("[M.name] ([M.ckey]) failed to stun [src.name] ([src.ckey]) with stungloves (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")
						target = M
						calc_power = 150 * get_siemens_coefficient_bodypart(BP)
					else
						visible_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>")
						M.attack_log += text("\[[time_stamp()]\] <font color='red'>Stungloved [src.name] ([src.ckey])</font>")
						src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stungloved by [M.name] ([M.ckey])</font>")
						msg_admin_attack("[M.name] ([M.ckey]) stungloved [src.name] ([src.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")
						calc_power = 100 * get_siemens_coefficient_bodypart(BP)
					target.apply_effects(0,0,0,0,2,0,0,calc_power)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread()
					s.set_up(3, 1, target)
					s.start()
					return 1
				else
					to_chat(M, "\red Not enough charge! ")
					visible_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>")
				return

		if(istype(M.gloves , /obj/item/clothing/gloves/boxing))

			var/damage = rand(0, 9)
			if(!damage)
				playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
				visible_message("\red <B>[M] has attempted to punch [src]!</B>")
				return 0
			var/obj/item/bodypart/BP = get_bodypart(ran_zone(M.zone_sel.selecting))
			var/armor_block = run_armor_check(BP, "melee")

			if(HULK in M.mutations)			damage += 5
			if(dna && dna.mutantrace == "adamantine")
				damage += 5

			playsound(loc, "punch", 25, 1, -1)

			visible_message("\red <B>[M] has punched [src]!</B>")

			apply_damage(damage, HALLOSS, BP, armor_block)
			if(damage >= 9)
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(4, WEAKEN, armor_block)

			return
	else
		if(istype(M,/mob/living/carbon))
//			log_debug("No gloves, [M] is truing to infect [src]")
			M.spread_disease_to(src, "Contact")

	switch(M.a_intent)
		if(I_HELP)
			if(istype(M) && health < config.health_threshold_crit && health > config.health_threshold_dead)
				if(!M.check_has_mouth())
					to_chat(M, "<span class='danger'>You don't have a mouth, you cannot perform CPR!</span>")
					return
				if(!check_has_mouth())
					to_chat(M, "<span class='danger'>They don't have a mouth, you cannot perform CPR!</span>")
					return
				if(M.get_equipped_flags(BP_HEAD) & (HEADCOVERSMOUTH | MASKCOVERSMOUTH))
					to_chat(M, "\blue <B>Remove your mask!</B>")
					return 0
				if(get_equipped_flags(BP_HEAD) & (HEADCOVERSMOUTH | MASKCOVERSMOUTH))
					to_chat(M, "\blue <B>Remove his mask!</B>")
					return 0

				if (!cpr_time)
					return 0

				cpr_time = 0
				spawn(30) // need addtimer() that can work with vars, why we need to make new proc just for setting and unsetting single var?...
					cpr_time = 1

				M.visible_message("<span class='danger'>\The [M] is trying perform CPR on \the [src]!</span>")

				if(!do_after(M, 30, null, src))
					return

				adjustOxyLoss(-(min(getOxyLoss(), 5)))
				updatehealth()
				M.visible_message("<span class='danger'>\The [M] performs CPR on \the [src]!</span>")
				to_chat(src, "<span class='notice'>You feel a breath of fresh air enter your lungs. It feels good.</span>")
				to_chat(M, "<span class='warning'>Repeat at least every 7 seconds.</span>")
			else if(!(M == src && apply_pressure(M, M.zone_sel.selecting)))
				help_shake_act(M)
			return 1

		if(I_GRAB)
			if(M == src || anchored)
				return 0
			for(var/obj/item/weapon/grab/G in src.grabbed_by)
				if(G.assailant == M)
					to_chat(M, "<span class='notice'>You already grabbed [src].</span>")
					return
			if(w_uniform)
				w_uniform.add_fingerprint(M)

			var/obj/item/weapon/grab/G = new /obj/item/weapon/grab(M, src)
			if(buckled)
				to_chat(M, "<span class='notice'>You cannot grab [src], \he is buckled in!</span>")
			if(!G)	//the grab will delete itself in New if affecting is anchored
				return
			M.put_in_active_hand(G)
			G.synch()
			LAssailant = M

			M.do_attack_animation(src)
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			return 1

		if(I_HURT) // TODO update his

			var/rand_damage = rand(1, 5)
			var/block = 0
			var/accurate = 0
			var/hit_zone = M.zone_sel.selecting
			var/obj/item/bodypart/BP = get_bodypart(hit_zone)

			if(!BP || BP.is_stump())
				to_chat(M, "<span class='danger'>They are missing that limb!</span>")
				return 1

			switch(src.a_intent)
				if(I_HELP)
					// We didn't see this coming, so we get the full blow
					rand_damage = 5
					accurate = 1
				if(I_HURT, I_GRAB)
					// We're in a fighting stance, there's a chance we block
					if(src.canmove && src != M && prob(20))
						block = 1

			if (M.grabbed_by.len)
				// Someone got a good grip on them, they won't be able to do much damage
				rand_damage = max(1, rand_damage - 2)

			if(src.grabbed_by.len || src.buckled || !src.canmove || src == M)
				accurate = 1 // certain circumstances make it impossible for us to evade punches
				rand_damage = 5

			// Process evasion and blocking
			var/miss_type = 0
			var/attack_message
			if(!accurate)
				/* ~Hubblenaut
					This place is kind of convoluted and will need some explaining.
					ran_zone() will pick out of 11 zones, thus the chance for hitting
					our target where we want to hit them is circa 9.1%.

					Now since we want to statistically hit our target bodypart a bit more
					often than other organs, we add a base chance of 20% for hitting it.

					This leaves us with the following chances:

					If aiming for chest:
						27.3% chance you hit your target bodypart
						70.5% chance you hit a random other bodypart
						 2.2% chance you miss

					If aiming for something else:
						23.2% chance you hit your target bodypart
						56.8% chance you hit a random other bodypart
						15.0% chance you miss

					Note: We don't use get_zone_with_miss_chance() here since the chances
						  were made for projectiles.
					TODO: proc for melee combat miss chances depending on bodypart?
				*/
				if(prob(80))
					hit_zone = ran_zone(hit_zone)
				if(prob(15) && hit_zone != BP_CHEST) // Missed!
					if(!src.lying)
						attack_message = "[M] attempted to strike [src], but missed!"
					else
						attack_message = "[M] attempted to strike [src], but \he rolled out of the way!"
						src.set_dir(pick(cardinal))
					miss_type = 1

			if(!miss_type && block)
				attack_message = "[M] went for [src]'s [BP.name] but was blocked!"
				miss_type = 2

			// See what attack they use
			var/datum/unarmed_attack/attack = M.get_unarmed_attack(src, hit_zone)
			if(!attack)
				return 0

			M.do_attack_animation(src)
			if(!attack_message)
				attack.show_attack(M, src, hit_zone, rand_damage)
			else
				M.visible_message("<span class='danger'>[attack_message]</span>")

			playsound(loc, ((miss_type) ? (miss_type == 1 ? attack.miss_sound : 'sound/weapons/thudswoosh.ogg') : attack.attack_sound), 25, 1, -1)

			M.attack_log += text("\[[time_stamp()]\] <font color='red'>[pick(attack.attack_verb)]ed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [pick(attack.attack_verb)]ed by [M.name] ([M.ckey])</font>")
			msg_admin_attack("[key_name(M)] [miss_type ? (miss_type == 1 ? "Has missed" : "Was blocked by") : "Has [pick(attack.attack_verb)]"] [key_name(src)] [ADMIN_JMP(M)]")

			if(miss_type)
				return 0

			var/real_damage = rand_damage
			real_damage += attack.get_unarmed_damage(M)
			if(HULK in M.mutations)
				real_damage *= 2 // Hulks do twice the damage
				rand_damage *= 2
			real_damage = max(1, real_damage)

			var/armour = run_armor_check(hit_zone, "melee")
			// Apply additional unarmed effects.
			attack.apply_effects(M, src, armour, rand_damage, hit_zone)

			// Finally, apply damage to target
			apply_damage(real_damage, (attack.deal_halloss ? HALLOSS : BRUTE), hit_zone, armour, damage_flags=attack.damage_flags())


		if(I_DISARM)
			M.do_attack_animation(src)
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

			msg_admin_attack("[key_name(M)] disarmed [src.name] ([src.ckey])")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/bodypart/BP = get_bodypart(ran_zone(M.zone_sel.selecting))

			var/list/holding = list(get_active_hand() = 40, get_inactive_hand = 20)

			//See if they have any guns that might go off
			for(var/obj/item/weapon/gun/W in holding)
				if(W && prob(holding[W]))
					var/list/turfs = list()
					for(var/turf/T in view())
						turfs += T
					if(turfs.len)
						var/turf/target = pick(turfs)
						visible_message("<span class='danger'>[src]'s [W] goes off during the struggle!</span>")
						return W.afterattack(target,src)

			var/randn = rand(1, 100)
			if(!(species.flags[NO_SLIP]) && randn <= 25)
				var/armor_check = run_armor_check(BP, "melee")
				apply_effect(3, WEAKEN, armor_check)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(armor_check < 100)
					visible_message("<span class='danger'>[M] has pushed [src]!</span>")
				else
					visible_message("<span class='warning'>[M] attempted to push [src]!</span>")
				return

			if(randn <= 60)
				//See about breaking grips or pulls
				if(break_all_grabs(M))
					playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
					return


				//Actually disarm them
				for(var/obj/item/I in holding)
					if(dropItemToGround(I))
						visible_message("<span class='danger'>[M] has disarmed [src]!</span>")
						playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
						return

			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>")

//Breaks all grips and pulls that the mob currently has.
/mob/living/carbon/human/proc/break_all_grabs(mob/living/carbon/user)
	var/success = 0
	if(pulling)
		visible_message("<span class='danger'>[user] has broken [src]'s grip on [pulling]!</span>")
		success = 1
		stop_pulling()

	if(istype(l_hand, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/lgrab = l_hand
		if(lgrab.affecting)
			visible_message("<span class='danger'>[user] has broken [src]'s grip on [lgrab.affecting]!</span>")
			success = 1
		spawn(1)
			qdel(lgrab)
	if(istype(r_hand, /obj/item/weapon/grab))
		var/obj/item/weapon/grab/rgrab = r_hand
		if(rgrab.affecting)
			visible_message("<span class='danger'>[user] has broken [src]'s grip on [rgrab.affecting]!</span>")
			success = 1
		spawn(1)
			qdel(rgrab)
	return success

/*
	We want to ensure that a mob may only apply pressure to one bodypart of one mob at any given time. Currently this is done mostly implicitly through
	the behaviour of do_after() and the fact that applying pressure to someone else requires a grab:

	If you are applying pressure to yourself and attempt to grab someone else, you'll change what you are holding in your active hand which will stop do_mob()
	If you are applying pressure to another and attempt to apply pressure to yourself, you'll have to switch to an empty hand which will also stop do_mob()
	Changing targeted zones should also stop do_mob(), preventing you from applying pressure to more than one body part at once.
*/
/mob/living/carbon/human/proc/apply_pressure(mob/living/user, target_zone)
	var/obj/item/bodypart/BP = get_bodypart(target_zone)
	if(!BP || !(BP.status & ORGAN_BLEEDING) || (BP.status & ORGAN_ROBOT))
		return 0

	if(BP.applied_pressure)
		var/message = "<span class='warning'>[ismob(BP.applied_pressure)? "Someone" : "\A [BP.applied_pressure]"] is already applying pressure to [user == src? "your [BP.name]" : "[src]'s [BP.name]"].</span>"
		to_chat(user, message)
		return 0

	if(user == src)
		user.visible_message("\The [user] starts applying pressure to \his [BP.name]!", "You start applying pressure to your [BP.name]!")
	else
		user.visible_message("\The [user] starts applying pressure to [src]'s [BP.name]!", "You start applying pressure to [src]'s [BP.name]!")
	spawn(0)
		BP.applied_pressure = user

		//apply pressure as long as they stay still and keep grabbing
		do_mob(user, src, INFINITY, target_zone, progress = 0)

		BP.applied_pressure = null

		if(user == src)
			user.visible_message("\The [user] stops applying pressure to \his [BP.name]!", "You stop applying pressure to your [BP.name]!")
		else
			user.visible_message("\The [user] stops applying pressure to [src]'s [BP.name]!", "You stop applying pressure to [src]'s [BP.name]!")

	return 1

/mob/living/carbon/human/proc/afterattack(atom/target, mob/living/user, inrange, params)
	return

//Used to attack a joint through grabbing
/mob/living/carbon/human/proc/grab_joint(mob/living/user, def_zone)
	var/has_grab = 0
	for(var/obj/item/weapon/grab/G in list(user.get_active_hand(), user.get_inactive_hand()))
		if(G.affecting == src && G.state == GRAB_NECK)
			has_grab = 1
			break

	if(!has_grab)
		return 0

	if(!def_zone) def_zone = user.zone_sel.selecting
	var/target_zone = check_zone(def_zone)
	if(!target_zone)
		return 0
	var/obj/item/bodypart/BP = get_bodypart(check_zone(target_zone))
	if(!BP || BP.dislocated > 0 || BP.dislocated == -1) //don't use is_dislocated() here, that checks parent
		return 0

	user.visible_message("<span class='warning'>[user] begins to dislocate [src]'s [BP.joint]!</span>")
	if(do_after(user, 100, progress = 0))
		BP.dislocate(1)
		src.visible_message("<span class='danger'>[src]'s [BP.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		return 1
	return 0
