/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(P.impact_force)
		for(var/i=1, i<=P.impact_force, i++)
			step_to(src, get_step(loc, P.dir))
			if(istype(src.loc, /turf/simulated))
				src.loc.add_blood(src)

	if(!(P.original == src && P.firer == src)) //can't block or reflect when shooting yourself
		if(istype(P, /obj/item/projectile/energy) || istype(P, /obj/item/projectile/beam))
			if(check_reflect(def_zone, dir, P.dir)) // Checks if you've passed a reflection% check
				visible_message("<span class='danger'>The [P.name] gets reflected by [src]!</span>", \
								"<span class='userdanger'>The [P.name] gets reflected by [src]!</span>")
				// Find a turf near or on the original location to bounce to
				if(P.starting)
					var/new_x = P.starting.x + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/new_y = P.starting.y + pick(0, 0, 0, 0, 0, -1, 1, -2, 2)
					var/turf/curloc = get_turf(src)

					// redirect the projectile
					P.redirect(new_x, new_y, curloc, src)

				return -1 // complete projectile permutation

	if(istype(P, /obj/item/projectile/bullet/weakbullet))
		var/datum/organ/external/select_area = get_organ(def_zone) // We're checking the outside, buddy!
		if(check_thickmaterial(select_area))
			visible_message("\red <B>The [P.name] hits [src]'s armor!</B>")
			P.agony /= 2
		apply_effect(P.agony,AGONY,0)
		qdel(P)
		return

	if(istype(P, /obj/item/projectile/energy/electrode) || istype(P, /obj/item/projectile/beam/stun) || istype(P, /obj/item/projectile/bullet/stunslug))
		var/datum/organ/external/select_area = get_organ(def_zone) // We're checking the outside, buddy!
		P.agony *= get_siemens_coefficient_organ(select_area)
		P.stun *= get_siemens_coefficient_organ(select_area)
		P.weaken *= get_siemens_coefficient_organ(select_area)
		P.stutter *= get_siemens_coefficient_organ(select_area)

		if(P.agony) // No effect against full protection.
			if(prob(max(P.agony, 20)))
				drop_item()
		P.on_hit(src)
		flash_pain()
		to_chat(src, "\red You have been shot!")
		qdel(P)
		return

	if(istype(P, /obj/item/projectile/energy/bolt))
		var/datum/organ/external/select_area = get_organ(def_zone) // We're checking the outside, buddy!
		var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
		for(var/bp in body_parts) //Make an unregulated var to pass around.
			if(!bp)
				continue //Does this thing we're shooting even exist?
			if(bp && istype(bp ,/obj/item/clothing)) // If it exists, and it's clothed
				var/obj/item/clothing/C = bp // Then call an argument C to be that clothing!
				if(C.body_parts_covered & select_area.body_part) // Is that body part being targeted covered?
					if(C.flags & THICKMATERIAL )
						visible_message("\red <B>The [P.name] gets absorbed by [src]'s [C.name]!</B>")
						qdel(P)
						return

		var/datum/organ/external/organ = get_organ(check_zone(def_zone))
		var/armorblock = run_armor_check(organ, "energy")
		apply_damage(P.damage, P.damage_type, organ, armorblock, P, 0, 0)
		apply_effects(P.stun,P.weaken,0,0,P.stutter,0,0,armorblock)
		flash_pain()
		to_chat(src, "\red You have been shot!")
		qdel(P)
		return

	if(check_shields(P.damage, "the [P.name]"))
		P.on_hit(src, 100, def_zone)
		return 2

	if(istype(P, /obj/item/projectile/bullet))
		var/obj/item/projectile/bullet/B = P

		var/datum/organ/external/organ = get_organ(check_zone(def_zone))
		var/armor = getarmor_organ(organ, "bullet")

		var/delta = max(0, P.damage - (P.damage * (armor/100)))
		if(delta)
			apply_effect(delta,AGONY,armor)
			P.on_hit(src, armor, def_zone)
			//return Nope! ~Zve
		if(delta < 10)
			P.sharp = 0
			P.embed = 0

		if(B.stoping_power)
			var/force =  (armor/P.damage)*100
			if (force <= 60 && force > 40)
				apply_effects(B.stoping_power/2,B.stoping_power/2,0,0,B.stoping_power/2,0,0,armor)
			else if(force <= 40)
				apply_effects(B.stoping_power,B.stoping_power,0,0,B.stoping_power,0,0,armor)

		if((P.embed && prob(20 + max(P.damage - armor, -20))) && P.damage_type == BRUTE)
			var/obj/item/weapon/shard/shrapnel/SP = new()
			(SP.name) = "[P.name] shrapnel"
			(SP.desc) = "[SP.desc] It looks like it was fired from [P.shot_from]."
			(SP.loc) = organ
			organ.embed(SP)

	return (..(P , def_zone))

/mob/living/carbon/human/proc/check_reflect(def_zone, hol_dir, hit_dir) //Reflection checks for anything in your l_hand, r_hand, or wear_suit based on the reflection chance of the object
	if(head && head.IsReflect(def_zone, hol_dir, hit_dir))
		return TRUE
	if(wear_suit && wear_suit.IsReflect(def_zone, hol_dir, hit_dir))
		return TRUE
	if(l_hand && l_hand.IsReflect(def_zone, hol_dir, hit_dir))
		return TRUE
	if(r_hand && r_hand.IsReflect(def_zone, hol_dir, hit_dir))
		return TRUE
	return FALSE

/mob/living/carbon/human/proc/is_in_space_suit(only_helmet = FALSE) //Wearing human full space suit (or only space helmet)?
	if(!head || !(only_helmet || wear_suit))
		return FALSE
	if(istype(head, /obj/item/clothing/head/helmet/space) && (only_helmet || istype(wear_suit, /obj/item/clothing/suit/space)))
		return TRUE
	return FALSE

/mob/living/carbon/human/getarmor(def_zone, type)
	var/armorval = 0
	var/organnum = 0

	if(def_zone)
		if(isorgan(def_zone))
			return getarmor_organ(def_zone, type)
		var/datum/organ/external/affecting = get_organ(def_zone)
		return getarmor_organ(affecting, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/datum/organ/external/organ in organs)
		armorval += getarmor_organ(organ, type)
		organnum++
	return (armorval/max(organnum, 1))

//this proc returns the Siemens coefficient of electrical resistivity for a particular external organ.
/mob/living/carbon/human/proc/get_siemens_coefficient_organ(datum/organ/external/def_zone)
	if (!def_zone)
		return 1.0

	var/siemens_coefficient = 1.0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(!istype(C))	//is this necessary?
			continue
		else if(C.body_parts_covered & def_zone.body_part) // Is that body part being targeted covered?
			if(C.wet)
				siemens_coefficient = 3.0
				var/turf/T = get_turf(src)
				var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
				if(W)
					W.electrocute_act(60)
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular external organ.
/mob/living/carbon/human/proc/getarmor_organ(datum/organ/external/def_zone, type)
	if(!type || !def_zone) return 0
	var/protection = 0
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/gear in protective_gear)
		if(gear && istype(gear ,/obj/item/clothing))
			var/obj/item/clothing/C = gear
			if(istype(C) && C.body_parts_covered & def_zone.body_part)
				protection += C.armor[type]
	return protection

/mob/living/carbon/human/proc/check_head_coverage()

	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & HEAD)
				return 1
	return 0

/mob/living/carbon/human/proc/check_shields(damage = 0, attack_text = "the attack")
	if(l_hand && istype(l_hand, /obj/item/weapon))//Current base is the prob(50-d/3)
		var/obj/item/weapon/I = l_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("\red <B>[src] blocks [attack_text] with the [l_hand.name]!</B>")
			return 1
	if(r_hand && istype(r_hand, /obj/item/weapon))
		var/obj/item/weapon/I = r_hand
		if(I.IsShield() && (prob(50 - round(damage / 3))))
			visible_message("\red <B>[src] blocks [attack_text] with the [r_hand.name]!</B>")
			return 1
	if(wear_suit && istype(wear_suit, /obj/item/))
		var/obj/item/I = wear_suit
		if(I.IsShield() && (prob(35)))
			visible_message("\red <B>The reactive teleport system flings [src] clear of [attack_text]!</B>")
			var/list/turfs = new/list()
			for(var/turf/T in orange(6))
				if(istype(T,/turf/space)) continue
				if(T.density) continue
				if(T.x>world.maxx-6 || T.x<6)	continue
				if(T.y>world.maxy-6 || T.y<6)	continue
				turfs += T
			if(!turfs.len) turfs += pick(/turf in orange(6))
			var/turf/picked = pick(turfs)
			if(!isturf(picked)) return
			src.loc = picked
			return 1
	return 0

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/datum/organ/external/O  in organs)
		if(O.status & ORGAN_DESTROYED)	continue
		O.emp_act(severity)
		for(var/datum/organ/internal/I  in O.internal_organs)
			if(I.robotic == 0)	continue
			I.emp_act(severity)
	..()


/mob/living/carbon/human/proc/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!I || !user)	return 0

	var/target_zone = def_zone? check_zone(def_zone) : get_zone_with_miss_chance(user.zone_sel.selecting, src)

	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_sel.selecting
	if(!target_zone)
		visible_message("\red <B>[user] misses [src] with \the [I]!")
		return 0

	var/datum/organ/external/affecting = get_organ(target_zone)
	if (!affecting)
		return 0
	if(affecting.status & ORGAN_DESTROYED)
		to_chat(user, "What [affecting.display_name]?")
		return 0
	var/hit_area = affecting.display_name

	if(user != src)
		user.do_attack_animation(src)
		if(check_shields(I.force, "the [I.name]"))
			return 0

	if(istype(I,/obj/item/weapon/card/emag))
		if(!(affecting.status & ORGAN_ROBOT))
			to_chat(user, "\red That limb isn't robotic.")
			return
		if(affecting.sabotaged)
			to_chat(user, "\red [src]'s [affecting.display_name] is already sabotaged!")
		else
			to_chat(user, "\red You sneakily slide [I] into the dataport on [src]'s [affecting.display_name] and short out the safeties.")
			var/obj/item/weapon/card/emag/emag = I
			emag.uses--
			affecting.sabotaged = 1
		return 1

	if(I.attack_verb.len)
		visible_message("\red <B>[src] has been [pick(I.attack_verb)] in the [hit_area] with [I.name] by [user]!</B>")
	else
		visible_message("\red <B>[src] has been attacked in the [hit_area] with [I.name] by [user]!</B>")

	var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].")
	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)
	if ((weapon_sharp || weapon_edge) && prob(getarmor(target_zone, "melee")))
		weapon_sharp = 0
		weapon_edge = 0

	if(armor >= 100)	return 0
	if(!I.force)	return 0

	apply_damage(I.force, I.damtype, affecting, armor, sharp=weapon_sharp, edge=weapon_edge, used_weapon=I)

	var/bloody = 0
	if(((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && prob(25 + (I.force * 2)))
		I.add_blood(src)	//Make the weapon bloody, not the person.
//		if(user.hand)	user.update_inv_l_hand()	//updates the attacker's overlay for the (now bloodied) weapon
//		else			user.update_inv_r_hand()	//removed because weapons don't have on-mob blood overlays
		if(prob(33))
			bloody = 1
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				location.add_blood(src)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.bloody_body(src)
					H.bloody_hands(src)

		switch(hit_area)
			if("head")//Harder to score a stun but if you do it lasts a bit longer
				if(prob(I.force))
					apply_effect(20, PARALYZE, armor)
					visible_message("\red <B>[src] has been knocked unconscious!</B>")
				if(prob(I.force + min(100,100 - src.health)) && src != user && I.damtype == BRUTE)
					if(src != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(mind)
						ticker.mode.remove_gangster(mind, exclude_bosses=1)

				if(bloody)//Apply blood
					if(wear_mask)
						wear_mask.add_blood(src)
						update_inv_wear_mask()
					if(head)
						head.add_blood(src)
						update_inv_head()
					if(glasses && prob(33))
						glasses.add_blood(src)
						update_inv_glasses()

			if("chest")//Easier to score a stun but lasts less time
				if(prob((I.force + 10)))
					apply_effect(5, WEAKEN, armor)
					visible_message("\red <B>[src] has been knocked down!</B>")

				if(bloody)
					bloody_body(src)
	return 1

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM)
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		var/throw_damage = O.throwforce*(AM.fly_speed/5)

		var/zone
		if (istype(O.thrower, /mob/living))
			var/mob/living/L = O.thrower
			zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone("chest",75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			zone = get_zone_with_miss_chance(zone, src, min(15*(distance-2), 0))
		else
			zone = get_zone_with_miss_chance(zone, src, 15)

		if(!zone)
			visible_message("\blue \The [O] misses [src] narrowly!")
			return

		O.throwing = 0		//it hit, so stop moving

		if ((O.thrower != src) && check_shields(throw_damage, "[O]"))
			return

		var/datum/organ/external/affecting = get_organ(zone)
		var/hit_area = affecting.display_name

		src.visible_message("\red [src] has been hit in the [hit_area] by [O].")
		var/armor = run_armor_check(affecting, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here

		if(armor < 100)
			apply_damage(throw_damage, dtype, zone, armor, is_sharp(O), has_edge(O), O)

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [M.name] ([assailant.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!istype(src,/mob/living/simple_animal/mouse))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [M.name] ([assailant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && AM.fly_speed >= 15)
			var/obj/item/weapon/W = O
			var/momentum = AM.fly_speed/2
			var/dir = get_dir(O.throw_source, src)

			visible_message("\red [src] staggers under the impact!","\red You stagger under the impact!")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!W || !src) return

			if(W.loc == src && W.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='warning'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O
		AM.fly_speed = 0

/mob/living/carbon/human/proc/bloody_hands(mob/living/source, amount = 2)
	if (gloves)
		gloves.add_blood(source)
		gloves:transfer_blood = amount
		gloves:bloody_hands_mob = source
	else
		add_blood(source)
		bloody_hands = amount
		bloody_hands_mob = source
	update_inv_gloves()		//updates on-mob overlays for bloody hands and/or bloody gloves

/mob/living/carbon/human/proc/bloody_body(mob/living/source)
	if(wear_suit)
		wear_suit.add_blood(source)
		update_inv_wear_suit()
	if(w_uniform)
		w_uniform.add_blood(source)
		update_inv_w_uniform()

/mob/living/carbon/human/proc/check_thickmaterial(datum/organ/external/def_zone, type)
//	if(!type)	return 0
	var/thickmaterial = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes, glasses, l_ear, r_ear)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & def_zone.body_part)
				if(C.flags & THICKMATERIAL)
					thickmaterial = 1
	return thickmaterial

/mob/living/carbon/human/proc/handle_suit_punctures(damtype, damage)

	if(!wear_suit) return
	if(!istype(wear_suit,/obj/item/clothing/suit/space)) return
	if(damtype != BURN && damtype != BRUTE) return

	var/obj/item/clothing/suit/space/SS = wear_suit
	var/reduction_dam = (100 - SS.breach_threshold) / 100
	var/penetrated_dam = max(0, min(50, (damage * reduction_dam) / 1.5)) // - SS.damage)) - Consider uncommenting this if suits seem too hardy on dev.

	if(penetrated_dam) SS.create_breaches(damtype, penetrated_dam)
