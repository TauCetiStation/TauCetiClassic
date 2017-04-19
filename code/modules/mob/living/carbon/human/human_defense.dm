/mob/living/carbon/human/bullet_act(obj/item/projectile/P, def_zone)
	if(!has_bodypart(def_zone))
		return -1 // if they don't have the organ in question then the projectile just passes by.

	if(P.impact_force)
		for(var/i = 1 to P.impact_force)
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

	if(check_shields(P.damage, "the [P.name]", P.dir))
		P.on_hit(src, 100, def_zone)
		return 2

	if(istype(P, /obj/item/projectile/bullet/weakbullet))
		var/obj/item/bodypart/BP = get_bodypart(def_zone) // We're checking the outside, buddy!
		if(check_thickmaterial(BP))
			visible_message("<span class='userdanger'>The [P.name] hits [src]'s armor!</span>")
			P.agony /= 2
		apply_effect(P.agony,AGONY,0)
		qdel(P)
		return

	if(istype(P, /obj/item/projectile/energy/electrode) || istype(P, /obj/item/projectile/beam/stun) || istype(P, /obj/item/projectile/bullet/stunslug))
		var/obj/item/bodypart/BP = get_bodypart(def_zone) // We're checking the outside, buddy!
		P.agony *= get_siemens_coefficient_bodypart(BP)
		P.stun *= get_siemens_coefficient_bodypart(BP)
		P.weaken *= get_siemens_coefficient_bodypart(BP)
		P.stutter *= get_siemens_coefficient_bodypart(BP)

		if(P.agony) // No effect against full protection.
			if(prob(max(P.agony, 20)))
				drop_item()
		P.on_hit(src)
		flash_pain()
		to_chat(src, "<span class='userdanger'>You have been shot!</span>")
		qdel(P)
		return

	if(istype(P, /obj/item/projectile/energy/bolt))
		var/obj/item/bodypart/BP = get_bodypart(def_zone) // We're checking the outside, buddy!
		var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
		for(var/bp in body_parts) //Make an unregulated var to pass around.
			if(!bp)
				continue //Does this thing we're shooting even exist?
			if(bp && istype(bp ,/obj/item/clothing)) // If it exists, and it's clothed
				var/obj/item/clothing/C = bp // Then call an argument C to be that clothing!
				if(C.body_parts_covered & BP.body_part) // Is that body part being targeted covered?
					if(C.flags & THICKMATERIAL )
						visible_message("<span class='userdanger'> <B>The [P.name] gets absorbed by [src]'s [C.name]!</span>")
						qdel(P)
						return

		BP = get_bodypart(check_zone(def_zone))
		var/armorblock = run_armor_check(BP, "energy")
		apply_damage(P.damage, P.damage_type, BP, armorblock, P, 0, 0)
		apply_effects(P.stun,P.weaken,0,0,P.stutter,0,0,armorblock)
		flash_pain()
		to_chat(src, "<span class='userdanger'>You have been shot!</span>")
		qdel(P)
		return

	if(istype(P, /obj/item/projectile/bullet))
		var/obj/item/projectile/bullet/B = P

		var/obj/item/bodypart/BP = get_bodypart(check_zone(def_zone))
		var/armor = getarmor_bodypart(BP, "bullet")

		if(B.stoping_power)
			var/force =  (armor/P.damage)*100
			if (force <= 60 && force > 40)
				apply_effects(B.stoping_power/2,B.stoping_power/2,0,0,B.stoping_power/2,0,0,armor)
			else if(force <= 40)
				apply_effects(B.stoping_power,B.stoping_power,0,0,B.stoping_power,0,0,armor)

		//Shrapnel
		if(!species.flags[NO_EMBED] && P.can_embed() && prob(20 + max(P.damage - armor, -10)))
			var/obj/item/weapon/shard/shrapnel/SP = new()
			SP.name = "[P.name] shrapnel"
			SP.desc = "[SP.desc] It looks like it was fired from [P.shot_from]."
			SP.loc = BP
			BP.embed(SP)

	if(istype(P, /obj/item/projectile/neurotoxin))
		var/obj/item/projectile/neurotoxin/B = P

		var/obj/item/bodypart/BP = get_bodypart(check_zone(def_zone))
		var/armor = getarmor_bodypart(BP, "bio")
		if (armor < 100)
			apply_effects(B.stun,B.stun,B.stun,0,0,0,0,armor)
			to_chat(src, "<span class='userdanger'>You feel that yor muscles can`t move!</span>")

	return ..(P, def_zone)

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
	var/bodypartnum = 0

	if(def_zone)
		if(isBODYPART(def_zone))
			return getarmor_bodypart(def_zone, type)
		var/obj/item/bodypart/BP = get_bodypart(def_zone)
		return getarmor_bodypart(BP, type)
		//If a specific bodypart is targetted, check how that bodypart is protected and return the value.

	//If you don't specify a bodypart, it checks ALL your bodyparts for protection, and averages out the values
	for(var/obj/item/bodypart/BP in bodyparts)
		armorval += getarmor_bodypart(BP, type)
		bodypartnum++
	return (armorval/max(bodypartnum, 1))

//this proc returns the Siemens coefficient of electrical resistivity for a particular bodypart.
/mob/living/carbon/human/proc/get_siemens_coefficient_bodypart(obj/item/bodypart/BP)
	if (!BP)
		return 1.0

	var/siemens_coefficient = 1.0

	var/list/clothing_items = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes) // What all are we checking?
	for(var/obj/item/clothing/C in clothing_items)
		if(!istype(C))	//is this necessary?
			continue
		else if(C.body_parts_covered & BP.body_part) // Is that body part being targeted covered?
			if(C.wet)
				siemens_coefficient = 3.0
				var/turf/T = get_turf(src)
				var/obj/effect/decal/cleanable/water/W = locate(/obj/effect/decal/cleanable/water, T)
				if(W)
					W.electrocute_act(60)
			siemens_coefficient *= C.siemens_coefficient

	return siemens_coefficient

//this proc returns the armour value for a particular bodypart.
/mob/living/carbon/human/proc/getarmor_bodypart(obj/item/bodypart/BP, type)
	if(!type || !BP) return 0
	var/protection = 0
	var/list/protective_gear = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes)
	for(var/gear in protective_gear)
		if(gear && istype(gear ,/obj/item/clothing))
			var/obj/item/clothing/C = gear
			if(istype(C) && C.body_parts_covered & BP.body_part)
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

/mob/living/carbon/human/proc/check_shields(damage = 0, attack_text = "the attack", hit_dir = 0)
	if(l_hand && istype(l_hand, /obj/item/weapon))//Current base is the prob(50-d/3)
		var/obj/item/weapon/I = l_hand
		if( (!hit_dir || is_the_opposite_dir(dir, hit_dir)) && prob(I.Get_shield_chance() - round(damage / 3) ))
			visible_message("<span class='userdanger'>[src] blocks [attack_text] with the [l_hand.name]!</span>")
			return 1
	if(r_hand && istype(r_hand, /obj/item/weapon))
		var/obj/item/weapon/I = r_hand
		if( (!hit_dir || is_the_opposite_dir(dir, hit_dir)) && prob(I.Get_shield_chance() - round(damage / 3) ))
			visible_message("<span class='userdanger'>[src] blocks [attack_text] with the [r_hand.name]!</span>")
			return 1
	if(wear_suit && istype(wear_suit, /obj/item/))
		var/obj/item/I = wear_suit
		if(prob(I.Get_shield_chance() - round(damage / 3) ))
			visible_message("<span class='userdanger'>The reactive teleport system flings [src] clear of [attack_text]!</span>")
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

/mob/living/carbon/proc/check_attack_tendons(obj/item/W, mob/living/user)
	if(!W.edge || !W.force || W.damtype != BRUTE)
		return FALSE

	var/obj/item/bodypart/BP = get_bodypart(user.zone_sel.selecting)
	if(!BP || BP.is_stump() || !BP.has_tendon || (BP.status & ORGAN_TENDON_CUT))
		return FALSE

	var/obj/item/weapon/grab/grab
	if(user.a_intent == I_HURT)
		for(var/obj/item/weapon/grab/G in src.grabbed_by)
			if(G.assailant == user && G.state >= GRAB_NECK)
				grab = G
				break
	if(!grab)
		return FALSE

	user.visible_message("<span class='danger'>\The [user] begins to cut \the [src]'s [BP.tendon_name] with \the [W]!</span>")
	user.next_move = world.time + 20

	if(!do_after(user, 20, progress=0))
		return FALSE
	if(!grab || grab.assailant != user || grab.affecting != src)
		return FALSE
	if(!BP || BP.is_stump() || !BP.sever_tendon())
		return FALSE

	user.visible_message("<span class='danger'>\The [user] cut \the [src]'s [BP.tendon_name] with \the [W]!</span>")
	if(W.hitsound)
		playsound(loc, W.hitsound, 50, 1, -1)
	grab.last_action = world.time
	flick(grab.hud.icon_state, grab.hud)
	user.attack_log += "\[[time_stamp()]\]<font color='red'>Hamstrung [src.name] ([src.ckey])</font>"
	src.attack_log += "\[[time_stamp()]\]<font color='orange'>Was hamstrung by [user.name] ([user.ckey])</font>"
	msg_admin_attack("[user.name] ([user.ckey]) hamstrung [src.name] ([src.ckey]) [ADMIN_JMP(user)]")

	return TRUE

// Attacking someone with a weapon while they are neck-grabbed
/mob/living/carbon/proc/check_attack_throat(obj/item/W, mob/user)
	if(user.a_intent == I_HURT)
		for(var/obj/item/weapon/grab/G in src.grabbed_by)
			if(G.assailant == user && G.state >= GRAB_NECK)
				if(attack_throat(W, G, user))
					return TRUE
	return FALSE

// Knifing
/mob/living/carbon/proc/attack_throat(obj/item/W, obj/item/weapon/grab/G, mob/user)

	if(check_zone(user.zone_sel.selecting) != BP_HEAD)
		return 0 // Not targetting correct slot.

	if(!W.edge || !W.force || W.damtype != BRUTE)
		return 0 //unsuitable weapon

	user.visible_message("<span class='danger'>\The [user] begins to slit [src]'s throat with \the [W]!</span>")

	user.next_move = world.time + 20 //also should prevent user from triggering this repeatedly
	if(!do_after(user, 20, progress=0))
		return 0
	if(!(G && G.assailant == user && G.affecting == src)) //check that we still have a grab
		return 0

	var/damage_mod = 1
	//presumably, if they are wearing a helmet that stops pressure effects, then it probably covers the throat as well
	var/obj/item/clothing/head/helmet = get_equipped_item(slot_head)
	if(istype(helmet) && (helmet.body_parts_covered & HEAD) && (helmet.flags & STOPS_PRESSUREDMAGE))
		//we don't do an armor_check here because this is not an impact effect like a weapon swung with momentum, that either penetrates or glances off.
		damage_mod = 1.0 - (helmet.armor["melee"]/100)

	var/total_damage = 0
	var/damage_flags = W.damage_flags()
	for(var/i in 1 to 3)
		var/damage = min(W.force*1.5, 20)*damage_mod
		apply_damage(damage, W.damtype, BP_HEAD, 0, damage_flags, used_weapon=W)
		total_damage += damage

	var/oxyloss = total_damage
	if(total_damage >= 40) //threshold to make someone pass out
		oxyloss = 60 // Brain lacks oxygen immediately, pass out

	adjustOxyLoss(min(oxyloss, 100 - getOxyLoss())) //don't put them over 100 oxyloss

	if(total_damage)
		if(oxyloss >= 40)
			user.visible_message("<span class='danger'>\The [user] slit [src]'s throat open with \the [W]!</span>")
		else
			user.visible_message("<span class='danger'>\The [user] cut [src]'s neck with \the [W]!</span>")

		if(W.hitsound)
			playsound(loc, W.hitsound, 50, 1, -1)

	G.last_action = world.time
	flick(G.hud.icon_state, G.hud)

	user.attack_log += "\[[time_stamp()]\]<font color='red'> Knifed [src.name] ([src.ckey]) with [W]</font>"
	src.attack_log += "\[[time_stamp()]\]<font color='orange'> Got knifed by [user.name] ([user.ckey]) with [W]</font>"
	msg_admin_attack("[key_name(user)] knifed [key_name(src)] with [W] [ADMIN_JMP(user)]")

	return 1

/mob/living/carbon/human/emp_act(severity)
	for(var/obj/O in src)
		if(!O)	continue
		O.emp_act(severity)
	for(var/obj/item/bodypart/BP in bodyparts)
		if(BP.is_stump())
			continue
		BP.emp_act(severity)
		for(var/obj/item/organ/IO in BP.organs)
			if(IO.robotic == 0)
				continue
			IO.emp_act(severity)
	..()


/mob/living/carbon/human/proc/attacked_by(obj/item/I, mob/living/user, def_zone)
	if(!I || !user)	return 0

	var/target_zone = def_zone? check_zone(def_zone) : get_zone_with_miss_chance(user.zone_sel.selecting, src)

	if(user == src) // Attacking yourself can't miss
		target_zone = user.zone_sel.selecting
	if(!target_zone)
		visible_message("<span class='userdanger'>[user] misses [src] with \the [I]!</span>")
		return 0

	var/obj/item/bodypart/BP = get_bodypart(target_zone)
	if(!BP || BP.is_stump())
		to_chat(user, "What [parse_zone(BP.body_zone)]?")
		return 0

	var/hit_area = BP.body_zone

	if(user != src)
		user.do_attack_animation(src)
		if(check_shields(I.force, "the [I.name]", get_dir(user,src) ))
			return 0

	if(istype(I,/obj/item/weapon/card/emag))
		if(!(BP.status & ORGAN_ROBOT))
			to_chat(user, "<span class='userdanger'>That limb isn't robotic.</span>")
			return
		if(BP.sabotaged)
			to_chat(user, "<span class='userdanger'>[src]'s [BP.name] is already sabotaged!</span>")
		else
			to_chat(user, "<span class='userdanger'>You sneakily slide [I] into the dataport on [src]'s [BP.name] and short out the safeties.</span>")
			var/obj/item/weapon/card/emag/emag = I
			emag.uses--
			BP.sabotaged = 1
		return 1

	if(I.attack_verb.len)
		visible_message("<span class='userdanger'>[src] has been [pick(I.attack_verb)] in the [BP.name] with [I.name] by [user]!</span>")
	else
		visible_message("<span class='userdanger'>[src] has been attacked in the [BP.name] with [I.name] by [user]!</span>")

	var/armor = run_armor_check(BP, "melee", "Your armor has protected your [BP.name].", "Your armor has softened hit to your [BP.name].")
	var/weapon_sharp = is_sharp(I)
	var/weapon_edge = has_edge(I)
	if ((weapon_sharp || weapon_edge) && prob(getarmor(target_zone, "melee")))
		weapon_sharp = 0
		weapon_edge = 0

	if(armor >= 100)
		return 0
	if(!I.force)
		return 0

	var/effective_force = I.force
	if(user.a_intent == I_DISARM) // TODO proper update?
		effective_force *= 0.66 //reduced effective force...
		//set the dislocate mult less than the effective force mult so that
		//dislocating limbs on disarm is a bit easier than breaking limbs on harm
		attack_joint(BP, I, effective_force, 0.5, armor) //...but can dislocate joints

	apply_damage(effective_force, I.damtype, BP, armor, I.damage_flags(), used_weapon=I)

	var/bloody = 0
	if(((I.damtype == BRUTE) || (I.damtype == HALLOSS)) && prob(25 + (I.force * 2)))
		I.add_blood(src)	//Make the weapon bloody, not the person.
		if(prob(33))
			bloody = 1
			var/turf/location = loc
			if(istype(location, /turf/simulated))
				location.add_blood(src)
			if(ishuman(user))
				var/mob/living/carbon/human/H = user
				if(get_dist(H, src) <= 1) //people with TK won't get smeared with blood
					H.bloody_body(src)

		switch(hit_area)
			if(BP_HEAD) // Harder to score a stun but if you do it lasts a bit longer
				if(prob(I.force))
					apply_effect(20, PARALYZE, armor)
					visible_message("<span class='userdanger'>[src] has been knocked unconscious!</span>")
				if(prob(I.force + min(100,100 - src.health)) && src != user && I.damtype == BRUTE)
					if(src != user && I.damtype == BRUTE)
						ticker.mode.remove_revolutionary(mind)
						ticker.mode.remove_gangster(mind, exclude_bosses=1)

				if(bloody)//Apply blood
					var/obj/item/equipped = get_equipped_item(slot_wear_mask)
					if(equipped)
						equipped.add_blood(src)
					equipped = get_equipped_item(slot_head)
					if(equipped)
						equipped.add_blood(src)
					equipped = get_equipped_item(slot_glasses)
					if(equipped && prob(33))
						equipped.add_blood(src)

			if(BP_CHEST)//Easier to score a stun but lasts less time
				if(prob((I.force + 10)))
					apply_effect(5, WEAKEN, armor)
					visible_message("<span class='userdanger'>[src] has been knocked down!</span>")

				if(bloody)
					bloody_body(src)
	return 1

/mob/living/carbon/human/proc/attack_joint(obj/item/bodypart/BP, obj/item/W, effective_force, dislocate_mult, blocked)
	if(!BP || (BP.dislocated == 2) || (BP.dislocated == -1) || blocked >= 100)
		return 0
	if(W.damtype != BRUTE)
		return 0

	//want the dislocation chance to be such that the limb is expected to dislocate after dealing a fraction of the damage needed to break the limb
	var/dislocate_chance = effective_force/(dislocate_mult * BP.min_broken_damage * config.organ_health_multiplier)*100
	if(prob(dislocate_chance * blocked_mult(blocked)))
		visible_message("<span class='danger'>[src]'s [BP.joint] [pick("gives way","caves in","crumbles","collapses")]!</span>")
		BP.dislocate(1)
		return 1
	return 0

//this proc handles being hit by a thrown atom
/mob/living/carbon/human/hitby(atom/movable/AM)
	if(istype(AM,/obj/))
		var/obj/O = AM
		var/dtype = BRUTE
		if(istype(O,/obj/item/weapon))
			var/obj/item/weapon/W = O
			dtype = W.damtype
		var/throw_damage = O.throwforce * (AM.fly_speed / 5)

		var/zone
		if (istype(O.thrower, /mob/living))
			var/mob/living/L = O.thrower
			zone = check_zone(L.zone_sel.selecting)
		else
			zone = ran_zone(BP_CHEST, 75)	//Hits a random part of the body, geared towards the chest

		//check if we hit
		if (O.throw_source)
			var/distance = get_dist(O.throw_source, loc)
			zone = get_zone_with_miss_chance(zone, src, min(15*(distance-2), 0))
		else
			zone = get_zone_with_miss_chance(zone, src, 15)

		if(!zone)
			visible_message("<span class='notice'>\The [O] misses [src] narrowly!</span>")
			return
		if ((O.thrower != src) && check_shields(throw_damage, "[O]", get_dir(O,src) ))
			return

		var/obj/item/bodypart/BP = get_bodypart(zone)
		var/hit_area = parse_zone(BP.body_zone)
		var/datum/wound/created_wound

		src.visible_message("<span class='warning'>[src] has been hit in the [hit_area] by [O].</span>")
		var/armor = run_armor_check(BP, "melee", "Your armor has protected your [hit_area].", "Your armor has softened hit to your [hit_area].") //I guess "melee" is the best fit here

		if(armor < 100)
			var/damage_flags = O.damage_flags()
			if(prob(armor))
				damage_flags &= ~(DAM_SHARP|DAM_EDGE)
			created_wound = apply_damage(throw_damage, dtype, zone, armor, damage_flags, O)

		if(ismob(O.thrower))
			var/mob/M = O.thrower
			var/client/assailant = M.client
			if(assailant)
				src.attack_log += text("\[[time_stamp()]\] <font color='orange'>Has been hit with a [O], thrown by [M.name] ([assailant.ckey])</font>")
				M.attack_log += text("\[[time_stamp()]\] <font color='red'>Hit [src.name] ([src.ckey]) with a thrown [O]</font>")
				if(!istype(src,/mob/living/simple_animal/mouse))
					msg_admin_attack("[src.name] ([src.ckey]) was hit by a [O], thrown by [M.name] ([assailant.ckey]) (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[src.x];Y=[src.y];Z=[src.z]'>JMP</a>)")

		//thrown weapon embedded object code.
		if(dtype == BRUTE && istype(O,/obj/item))
			var/obj/item/I = O
			if(!I.can_embed)
				return
			if(!I.is_robot_module())
				var/sharp = is_sharp(I)

				var/damage = throw_damage //the effective damage used for embedding purposes, no actual damage is dealt here
				if (armor)
					damage *= blocked_mult(armor)

				//blunt objects should really not be embedding in things unless a huge amount of force is involved
				var/embed_chance = sharp? damage/I.w_class : damage/(I.w_class*3)
				var/embed_threshold = sharp? 5*I.w_class : 15*I.w_class

				//Sharp objects will always embed if they do enough damage.
				//Thrown sharp objects have some momentum already and have a small chance to embed even if the damage is below the threshold
				if((sharp && prob(damage/(10*I.w_class)*100)) || (damage > embed_threshold && prob(embed_chance)))
					BP.embed(I, supplied_wound = created_wound)

		// Begin BS12 momentum-transfer code.
		if(O.throw_source && AM.fly_speed >= 15)
			var/obj/item/weapon/W = O
			var/momentum = AM.fly_speed/2
			var/dir = get_dir(O.throw_source, src)

			visible_message("<span class='warning'>[src] staggers under the impact!</span>","<span class='danger'>You stagger under the impact!</span>")
			src.throw_at(get_edge_target_turf(src,dir),1,momentum)

			if(!W || !src) return

			if(W.loc == src && W.sharp) //Projectile is embedded and suitable for pinning.
				var/turf/T = near_wall(dir,2)

				if(T)
					src.loc = T
					visible_message("<span class='warning'>[src] is pinned to the wall by [O]!</span>","<span class='danger'>You are pinned to the wall by [O]!</span>")
					src.anchored = 1
					src.pinned += O

/mob/living/carbon/human/bloody_hands(mob/living/source, amount = 2) // dont call this in combination with bloody_body()
	var/obj/item/I = get_equipped_item(slot_gloves)
	if (I)
		var/obj/item/clothing/gloves/G = I
		G.add_blood(source, amount)
	else
		add_blood(source)

		var/obj/item/bodypart/BP = get_bodypart(BP_L_ARM)
		if(BP)
			BP.add_blood(source)
			bloody_hands = amount // TODO move this into hands itself
			bloody_hands_mob = source
		BP = get_bodypart(BP_R_ARM)
		if(BP)
			BP.add_blood(source)
			bloody_hands = amount
			bloody_hands_mob = source

/mob/living/carbon/human/bloody_body(mob/living/source, amount = 2) // will do that for all equipped items and a whole body depending on covered parts
	add_blood(source)

	var/chance = 33
	var/list/equipped_items = get_equipped_items(FALSE)
	var/list/obscured = check_obscured_slots()
	if(equipped_items)
		if(obscured)
			for(var/obj/item/I in equipped_items)
				if(prob(chance) && !obscured[I.slot_equipped])
					I.add_blood(source, amount)
		else
			for(var/obj/item/I in equipped_items)
				if(prob(chance))
					I.add_blood(source, amount)

	var/obscured_flags = 0
	if(obscured && obscured["flags"])
		obscured_flags = obscured["flags"]
	for(var/obj/item/bodypart/BP in bodyparts)
		if(prob(chance) && !(obscured_flags & BP.body_part))
			BP.add_blood(source)
			if(BP.can_grasp)
				bloody_hands = amount
				bloody_hands_mob = source


/mob/living/carbon/human/proc/check_thickmaterial(obj/item/bodypart/BP, type)
//	if(!type)	return 0
	var/thickmaterial = 0
	var/list/body_parts = list(head, wear_mask, wear_suit, w_uniform, gloves, shoes, glasses, l_ear, r_ear)
	for(var/bp in body_parts)
		if(!bp)	continue
		if(bp && istype(bp ,/obj/item/clothing))
			var/obj/item/clothing/C = bp
			if(C.body_parts_covered & BP.body_part)
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
