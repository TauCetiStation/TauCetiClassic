/mob/living/carbon/human/attack_hand(mob/living/carbon/human/M)
	if (istype(loc, /turf) && istype(loc.loc, /area/start))
		to_chat(M, "No attacking people at spawn, you jackass.")
		return
	..()

	if((M != src) && check_shields(0, M.name, get_dir(M,src)))
		visible_message("\red <B>[M] attempted to touch [src]!</B>")
		return 0

	if(M.wear_suit && istype(M.wear_suit, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/V = M.wear_suit
		V.attack_reaction(M, REACTION_INTERACT_UNARMED, src)

	if(src.wear_suit && istype(src.wear_suit, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/V = src.wear_suit
		V.attack_reaction(src, REACTION_ATACKED, M)

	if(M.gloves && istype(M.gloves,/obj/item/clothing/gloves))
		M.do_attack_animation(src)
		var/obj/item/clothing/gloves/G = M.gloves
		if(G.cell)
			if(M.a_intent == "hurt")//Stungloves. Any contact will stun the alien.
				if(G.cell.charge >= 2500)
					G.cell.use(2500)
					G.update_icon()
					var/mob/living/carbon/human/target = src
					var/obj/item/organ/external/BP = get_bodypart(M.zone_sel.selecting) // We're checking the outside, buddy!
					var/calc_power
					if((prob(25) && !istype(G, /obj/item/clothing/gloves/yellow)) && (target != M))
						visible_message("\red <B>[M] accidentally touched \himself with the stun gloves!</B>")
						M.attack_log += text("\[[time_stamp()]\] <font color='red'>Attempted to touch [src.name] ([src.ckey]) with stungloves</font>")
						src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been unsuccessfully touched with stungloves by [M.name] ([M.ckey])</font>")
						msg_admin_attack("[M.name] ([M.ckey]) failed to stun [src.name] ([src.ckey]) with stungloves (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")
						target = M
						calc_power = 150 * get_siemens_coefficient_organ(BP)
					else
						visible_message("\red <B>[src] has been touched with the stun gloves by [M]!</B>")
						M.attack_log += text("\[[time_stamp()]\] <font color='red'>Stungloved [src.name] ([src.ckey])</font>")
						src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been stungloved by [M.name] ([M.ckey])</font>")
						msg_admin_attack("[M.name] ([M.ckey]) stungloved [src.name] ([src.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[M.x];Y=[M.y];Z=[M.z]'>JMP</a>)")
						calc_power = 100 * get_siemens_coefficient_organ(BP)
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
			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]
			var/armor_block = run_armor_check(BP, "melee")

			if(HULK in M.mutations)
				damage += 5

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
		if("help")
			if(health < config.health_threshold_crit && health > config.health_threshold_dead)
				if(M.species && M.species.flags[NO_BREATHE])
					to_chat(M, "<span class='notice bold'>Your species can not perform CPR!</span>")
					return FALSE
				if(species && species.flags[NO_BREATHE])
					to_chat(M, "<span class='notice bold'>You can not perform CPR on these species!</span>")
					return FALSE
				if((M.head && (M.head.flags & HEADCOVERSMOUTH)) || (M.wear_mask && (M.wear_mask.flags & MASKCOVERSMOUTH)))
					to_chat(M, "<span class='notice bold'>Remove your mask!</span>")
					return FALSE
				if((head && (head.flags & HEADCOVERSMOUTH)) || (wear_mask && (wear_mask.flags & MASKCOVERSMOUTH)))
					to_chat(M, "<span class='notice bold'>Remove his mask!</span>")
					return FALSE

				var/obj/effect/equip_e/human/O = new /obj/effect/equip_e/human()
				O.source = M
				O.target = src
				O.s_loc = M.loc
				O.t_loc = loc
				O.place = "CPR"
				requests += O
				spawn(0)
					O.process()
				return 1
			else if(!(M == src && apply_pressure(M, M.zone_sel.selecting)))
				help_shake_act(M)
				return 1

		if("grab")
			if(M == src || anchored || M.lying)
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
			grabbed_by += G
			G.synch()
			LAssailant = M

			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
			visible_message("<span class='warning'>[M] has grabbed [src] passively!</span>")
			return 1

		if("hurt")
			M.do_attack_animation(src)
			var/datum/unarmed_attack/attack = M.species.unarmed

			M.attack_log += text("\[[time_stamp()]\] <font color='red'>[pick(attack.attack_verb)]ed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been [pick(attack.attack_verb)]ed by [M.name] ([M.ckey])</font>")
			msg_admin_attack("[key_name(M)] [pick(attack.attack_verb)]ed [key_name(src)]")

			var/damage = rand(0, 5)//BS12 EDIT
			if(!damage)
				playsound(loc, attack.miss_sound, 25, 1, -1)
				visible_message("\red <B>[M] tried to [pick(attack.attack_verb)] [src]!</B>")
				return 0



			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]
			var/armor_block = run_armor_check(BP, "melee")

			if(HULK in M.mutations)
				damage += 5

			playsound(loc, attack.attack_sound, 25, 1, -1)

			visible_message("\red <B>[M] [pick(attack.attack_verb)]ed [src]!</B>")
			//Rearranged, so claws don't increase weaken chance.
			if(damage >= 5 && prob(50))
				visible_message("\red <B>[M] has weakened [src]!</B>")
				apply_effect(2, WEAKEN, armor_block)

			attack.handle_effects(M, src)

			damage += attack.damage
			apply_damage(damage, attack.damage_type, BP, armor_block, attack.damage_flags())


		if("disarm")
			M.do_attack_animation(src)
			M.attack_log += text("\[[time_stamp()]\] <font color='red'>Disarmed [src.name] ([src.ckey])</font>")
			src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been disarmed by [M.name] ([M.ckey])</font>")

			msg_admin_attack("[key_name(M)] disarmed [src.name] ([src.ckey])")

			if(w_uniform)
				w_uniform.add_fingerprint(M)
			var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(M.zone_sel.selecting)]

			if(istype(r_hand,/obj/item/weapon/gun) || istype(l_hand,/obj/item/weapon/gun))
				var/obj/item/weapon/gun/W = null
				var/chance = 0

				if (istype(l_hand,/obj/item/weapon/gun))
					W = l_hand
					chance = hand ? 40 : 20

				if (istype(r_hand,/obj/item/weapon/gun))
					W = r_hand
					chance = !hand ? 40 : 20

				if (prob(chance))
					visible_message("<spawn class=danger>[src]'s [W] goes off during struggle!")
					var/list/turfs = list()
					for(var/turf/T in view())
						turfs += T
					var/turf/target = pick(turfs)
					return W.afterattack(target,src)

			var/randn = rand(1, 100)
			if (randn <= 25)
				var/armor_check = run_armor_check(BP, "melee")
				apply_effect(3, WEAKEN, armor_check)
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				if(armor_check < 2)
					visible_message("<span class='danger'>[M] has pushed [src]!</span>")
				else
					visible_message("<span class='warning'>[M] attempted to push [src]!</span>")
				return

			var/talked = 0	// BubbleWrap

			if(randn <= 60)
				//BubbleWrap: Disarming breaks a pull
				if(pulling)
					visible_message("\red <b>[M] has broken [src]'s grip on [pulling]!</B>")
					talked = 1
					stop_pulling()

				//BubbleWrap: Disarming also breaks a grab - this will also stop someone being choked, won't it?
				if(istype(l_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/lgrab = l_hand
					if(lgrab.affecting)
						visible_message("\red <b>[M] has broken [src]'s grip on [lgrab.affecting]!</B>")
						talked = 1
					spawn(1)
						qdel(lgrab)
				if(istype(r_hand, /obj/item/weapon/grab))
					var/obj/item/weapon/grab/rgrab = r_hand
					if(rgrab.affecting)
						visible_message("\red <b>[M] has broken [src]'s grip on [rgrab.affecting]!</B>")
						talked = 1
					spawn(1)
						qdel(rgrab)
				//End BubbleWrap

				if(!talked)	//BubbleWrap
					if( (l_hand && l_hand.flags & ABSTRACT) || (r_hand && r_hand.flags & ABSTRACT) )
						return
					else
						drop_item()
						visible_message("\red <B>[M] has disarmed [src]!</B>")
				playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)
				return


			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			visible_message("\red <B>[M] attempted to disarm [src]!</B>")
	return

/*
	We want to ensure that a mob may only apply pressure to one bodypart of one mob at any given time. Currently this is done mostly implicitly through
	the behaviour of do_after() and the fact that applying pressure to someone else requires a grab:

	If you are applying pressure to yourself and attempt to grab someone else, you'll change what you are holding in your active hand which will stop do_mob()
	If you are applying pressure to another and attempt to apply pressure to yourself, you'll have to switch to an empty hand which will also stop do_mob()
	Changing targeted zones should also stop do_mob(), preventing you from applying pressure to more than one body part at once.
*/
/mob/living/carbon/human/proc/apply_pressure(mob/living/user, target_zone)
	var/obj/item/organ/external/BP = get_bodypart(target_zone)
	if(!BP || !(BP.status & ORGAN_BLEEDING) || (BP.status & ORGAN_ROBOT))
		return FALSE

	if(user.is_busy())
		return FALSE

	if(BP.applied_pressure)
		var/message = "<span class='warning'>[ismob(BP.applied_pressure)? "Someone" : "\A [BP.applied_pressure]"] is already applying pressure to [user == src? "your [BP.name]" : "[src]'s [BP.name]"].</span>"
		to_chat(user, message)
		return FALSE

	if(user == src)
		user.visible_message("\The [user] starts applying pressure to \his [BP.name]!", "You start applying pressure to your [BP.name]!")
	else
		user.visible_message("\The [user] starts applying pressure to [src]'s [BP.name]!", "You start applying pressure to [src]'s [BP.name]!")

	INVOKE_ASYNC(src, .proc/do_apply_pressure, user, target_zone, BP)

	return TRUE

/mob/living/carbon/human/proc/do_apply_pressure(mob/living/user, target_zone, obj/item/organ/external/BP)
	BP.applied_pressure = user

	//apply pressure as long as they stay still and keep grabbing
	do_mob(user, src, INFINITY, target_zone, progress = 0)

	BP.applied_pressure = null

	if(user == src)
		user.visible_message("\The [user] stops applying pressure to \his [BP.name]!", "You stop applying pressure to your [BP.name]!")
	else
		user.visible_message("\The [user] stops applying pressure to [src]'s [BP.name]!", "You stop applying pressure to [src]'s [BP.name]!")

/mob/living/carbon/human/proc/afterattack(atom/target, mob/living/user, inrange, params)
	return
