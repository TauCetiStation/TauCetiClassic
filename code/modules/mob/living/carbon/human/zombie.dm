/obj/item/weapon/melee/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
			humans, butchering all other living things to \
			sustain the zombie, smashing open airlock doors and opening \
			child-safe caps on bottles."
	flags = NODROP | ABSTRACT | DROPDEL
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	force = 16
	w_class = ITEM_SIZE_HUGE
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	hitsound = list('sound/voice/growl1.ogg')

	attack_verb = list("bitten and scratched", "scratched")

/obj/item/weapon/melee/zombie_hand/right
	icon_state = "bloodhand_right"

/obj/item/weapon/melee/zombie_hand/afterattack(atom/target, mob/user, proximity, params)
	if(!proximity)
		return

	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(A.welded || A.locked)
			breakairlock(user, A)
		else
			opendoor(user, A)

	if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/A = target

		if(A.blocked)
			breakfiredoor(user, A)
		else
			opendoor(user, A)

	if(isobj(target))
		var/obj/O = target
		if(O.can_buckle && O.buckled_mob)
			O.user_unbuckle_mob(user)

/obj/item/weapon/melee/zombie_hand/proc/opendoor(mob/user, var/obj/machinery/door/A)
	if(!A.density)
		return
	else if(!user.is_busy(A))
		user.visible_message("<span class='warning'>[user] starts to force the door to open with [src]!</span>",\
							 "<span class='warning'>You start forcing the door to open.</span>",\
							 "<span class='warning'>You hear metal strain.</span>")
		playsound(A, 'sound/effects/metal_creaking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(do_after(user, 70, target = A))
			if(A.density && in_range(A, user))
				user.visible_message("<span class='warning'>[user] forces the door to open with [src]!</span>",\
									 "<span class='warning'>You force the door to open.</span>",\
									 "<span class='warning'>You hear a metal screeching sound.</span>")
				A.open(1)

/obj/item/weapon/melee/zombie_hand/proc/breakairlock(mob/user, var/obj/machinery/door/airlock/A)
	if(!A.density)
		return
	else if(!user.is_busy(A))
		var/attempts = 0
		while(A)
			user.visible_message("<span class='warning'>[user] attempts to break open the airlock with [src]!</span>",\
								 "<span class='warning'>You attempt to break open the airlock.</span>",\
								 "<span class='warning'>You hear metal strain.</span>")
			playsound(A, 'sound/effects/metal_creaking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
			if(do_after(user, 100, target = A))
				if(A && A.density && in_range(A, user))
					if(attempts >= 2 && prob(attempts*5))
						user.visible_message("<span class='warning'>[user] broke the airlock with [src]!</span>",\
											 "<span class='warning'>You break the airlock.</span>",\
											 "<span class='warning'>You hear a metal screeching sound.</span>")
						A.door_rupture(user)
						playsound(src, pick('sound/effects/explosion1.ogg', 'sound/effects/explosion2.ogg'), VOL_EFFECTS_MASTER)
						return
				else
					return
				attempts++
			else
				return

/obj/item/weapon/melee/zombie_hand/proc/breakfiredoor(mob/user, var/obj/machinery/door/firedoor/A)
	if(!A.density)
		return
	else if(!user.is_busy(A))
		user.visible_message("<span class='warning'>[user] attempts to break open the emergency shutter with [src]!</span>",\
							 "<span class='warning'>You attempt to break open the emergency shutter.</span>",\
							 "<span class='warning'>You hear metal strain.</span>")
		playsound(A, 'sound/effects/metal_creaking.ogg', VOL_EFFECTS_MASTER, null, FALSE)
		if(do_after(user, 200, target = A))
			if(A.density && in_range(A, user))
				user.visible_message("<span class='warning'>[user] broke the emergency shutter with [src]!</span>",\
									 "<span class='warning'>You break the emergency shutter.</span>",\
									 "<span class='warning'>You hear a metal screeching sound.</span>")
				A.blocked = FALSE
				A.open(1)

/obj/item/weapon/melee/zombie_hand/attack(mob/M, mob/user)
	. = ..()
	if(. && ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!iszombie(H))
			var/target_zone = user.zone_sel.selecting

			if((target_zone == BP_HEAD || target_zone == BP_CHEST) && prob(40))
				target_zone = pick(BP_L_ARM, BP_R_ARM)
			if(target_zone == BP_GROIN && prob(40))
				target_zone = pick(BP_L_LEG, BP_R_LEG)

			H.infect_zombie_virus(target_zone)

/proc/iszombie(mob/living/carbon/human/H)
	if(istype(H.species, /datum/species/zombie))
		return TRUE
	return FALSE

/datum/species/zombie/on_life(mob/living/carbon/human/H)
	if(!H.life_tick % 3)
		return
	var/obj/item/organ/external/LArm = H.bodyparts_by_name[BP_L_ARM]
	var/obj/item/organ/external/RArm = H.bodyparts_by_name[BP_R_ARM]
	var/obj/item/organ/internal/eyes = H.bodyparts_by_name[O_EYES]
	var/obj/item/organ/internal/brain = H.bodyparts_by_name[O_BRAIN]
	if(eyes)
		eyes.damage = 0
	if(brain)
		brain.damage = 0
	H.setBrainLoss(0)
	H.eye_blurry = 0
	H.eye_blind = 0

	if(LArm && !(LArm.is_stump) && !istype(H.l_hand, /obj/item/weapon/melee/zombie_hand))
		H.drop_l_hand()
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand, SLOT_L_HAND)
	if(RArm && !(RArm.is_stump) && !istype(H.r_hand, /obj/item/weapon/melee/zombie_hand/right))
		H.drop_r_hand()
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand/right, SLOT_R_HAND)

	if(H.stat != DEAD && prob(10))
		playsound(H, pick(spooks), VOL_EFFECTS_MASTER)

/datum/species/zombie/handle_death(mob/living/carbon/human/H)
	addtimer(CALLBACK(null, .proc/prerevive_zombie, H), rand(600,700))
	H.update_mutantrace()

/proc/handle_infected_death(mob/living/carbon/human/H)
	if(H.species.name in list(HUMAN, UNATHI, TAJARAN, SKRELL))
		addtimer(CALLBACK(null, .proc/prerevive_zombie, H), rand(600,700))

/proc/prerevive_zombie(mob/living/carbon/human/H)
	var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
	if(H.organs_by_name[O_BRAIN] && BP && !(BP.is_stump))
		if(!H.key && H.mind)
			for(var/mob/dead/observer/ghost in player_list)
				if(ghost.mind == H.mind && ghost.can_reenter_corpse)
					var/answer = alert(ghost,"You are about to turn into a zombie. Do you want to return to body?","I'm a zombie!","Yes","No")
					if(answer == "Yes")
						ghost.reenter_corpse()

		H.visible_message("<span class='danger'>[H]'s body starts to move!</span>")
		addtimer(CALLBACK(null, .proc/revive_zombie, H), 40)

/proc/revive_zombie(mob/living/carbon/human/H)
	var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
	if(!H.organs_by_name[O_BRAIN] || !BP || BP.is_stump)
		return
	if(!iszombie(H))
		H.zombify()
	//H.rejuvenate()
	H.setCloneLoss(0)
	H.setBrainLoss(0)
	H.setHalLoss(0)
	H.SetParalysis(0)
	H.SetStunned(0)
	H.SetWeakened(0)
	H.nutrition = 400
	H.SetSleeping(0)
	H.radiation = 0
	H.heal_overall_damage(H.getBruteLoss(), H.getFireLoss())
	H.restore_blood()

	// remove the character from the list of the dead
	if(H.stat == DEAD)
		dead_mob_list -= H
		alive_mob_list += H
		H.tod = null
		H.timeofdeath = 0
	H.stat = CONSCIOUS
	H.update_canmove()
	H.regenerate_icons()
	H.update_health_hud()

	playsound(H, pick(list('sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')), VOL_EFFECTS_MASTER)
	to_chat(H, "<span class='danger'>Somehow you wake up and your hunger is still outrageous!</span>")
	H.visible_message("<span class='danger'>[H] suddenly wakes up!</span>")

/mob/living/carbon/proc/is_infected_with_zombie_virus()
	for(var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		for(var/datum/disease2/effectholder/e in V.effects)
			if(istype(e.effect, /datum/disease2/effect/zombie))
				return TRUE
	return FALSE

/mob/living/carbon/human/proc/infect_zombie_virus(target_zone = null, forced = FALSE, fast = FALSE)
	if(!forced && !prob(get_bite_infection_chance(src, target_zone)))
		return

	for(var/ID in virus2)
		var/datum/disease2/disease/V = virus2[ID]
		for(var/datum/disease2/effectholder/e in V.effects)
			if(istype(e.effect, /datum/disease2/effect/zombie)) //Already infected
				e.chance = min(100, e.chance + 10) //Make virus develop faster
				V.cooldown_mul = min(3, V.cooldown_mul + 1)
				return

	var/datum/disease2/disease/D = new /datum/disease2/disease
	var/datum/disease2/effectholder/holder = new /datum/disease2/effectholder
	var/datum/disease2/effect/zombie/Z = new /datum/disease2/effect/zombie
	if(target_zone)
		Z.infected_organ = get_bodypart(target_zone)
	holder.effect = Z
	holder.chance = rand(holder.effect.chance_minm, holder.effect.chance_maxm)
	if(fast)
		holder.chance = 100
	D.addeffect(holder)
	D.uniqueID = rand(0,10000)
	D.infectionchance = 100
	D.antigen |= ANTIGEN_Z
	D.spreadtype = "Blood" // not airborn and not contact, because spreading zombie virus through air or hugs is silly

	infect_virus2(src, D, forced = TRUE, ignore_antibiotics = TRUE)

/mob/living/carbon/human/proc/zombify()
	if(iszombie(src))
		return

	switch(species.name)
		if(TAJARAN)
			set_species(ZOMBIE_TAJARAN, TRUE, TRUE)
		if(SKRELL)
			set_species(ZOMBIE_SKRELL, TRUE, TRUE)
		if(UNATHI)
			set_species(ZOMBIE_UNATHI, TRUE, TRUE)
		else
			set_species(ZOMBIE, TRUE, TRUE)

/mob/living/carbon/human/proc/zombie_movement_delay()
	if(!has_gravity(src))
		return -1

	var/tally = species.speed_mod
	if(crawling)
		tally += 7
	else
		var/has_leg = FALSE
		for(var/bodypart_name in list(BP_L_LEG , BP_R_LEG))
			var/obj/item/organ/external/BP = bodyparts_by_name[bodypart_name]
			if(BP && !(BP.is_stump))
				has_leg = TRUE
		if(!has_leg)
			tally += 10

	if(embedded_flag)
		handle_embedded_objects()

	if(buckled)
		tally += 5.5

	if(pull_debuff)
		tally += pull_debuff

	if(wear_suit)
		tally += wear_suit.slowdown

	if(back)
		tally += back.slowdown

	if(shoes)
		tally += shoes.slowdown

	if(health <= 0)
		tally += 0.5
	if(health <= -50)
		tally += 0.5

	return (tally + config.human_delay)

var/list/zombie_list = list()

/proc/add_zombie(mob/living/carbon/human/H)
	H.AddSpell(new /obj/effect/proc_holder/spell/targeted/zombie_findbrains)
	zombie_list += H
	update_all_zombie_icons()

/proc/remove_zombie(mob/living/carbon/human/H)
	var/obj/effect/proc_holder/spell/targeted/zombie_findbrains/spell = locate() in H.spell_list
	H.RemoveSpell(spell)
	qdel(spell)
	zombie_list -= H
	update_all_zombie_icons()

/proc/update_all_zombie_icons()
	spawn(0)
		for(var/mob/living/carbon/human/H in zombie_list)
			if(H.client)
				for(var/image/I in H.client.images)
					if(I.icon_state == "zombie_hud")
						qdel(I)

		for(var/mob/living/carbon/human/H in zombie_list)
			if(H.client)
				for(var/mob/living/carbon/human/Z in zombie_list)
					var/I = image('icons/mob/human_races/r_zombie.dmi', loc = Z, icon_state = "zombie_hud")
					H.client.images += I

/obj/effect/proc_holder/spell/targeted/zombie_findbrains
	name = "Find brains"
	desc = "Allows you to sense alive humans."
	panel = "Zombie"
	charge_max = 300
	clothes_req = 0
	range = -1
	include_user = 1

/obj/effect/proc_holder/spell/targeted/zombie_findbrains/cast(list/targets)
	var/mob/living/carbon/human/user = usr
	var/turf/self_turf = get_turf(user)
	var/mob/living/carbon/human/target = null
	var/min_dist = 999

	for(var/mob/living/carbon/human/H in human_list)
		if(H.stat == DEAD || iszombie(H) || H.z != user.z)
			continue
		var/turf/target_turf = get_turf(H)
		var/target_dist = get_dist(target_turf, self_turf)
		if(target_dist < min_dist)
			min_dist = target_dist
			target = H

	if(!target)
		to_chat(user, "<span class='warning'>You don't sense any brains around</span>")
		return

	var/distance_text = "very close"
	if(min_dist > 100)
		distance_text = "very far"
	else if(min_dist > 40)
		distance_text = "pretty far"
	else if(min_dist > 20)
		distance_text = "not far"
	else if(min_dist > 10)
		distance_text = "close"
	to_chat(user, "<span class='warning'>The brains are [distance_text]</span>")

	var/dir = get_general_dir(self_turf, target)
	var/I = image('icons/mob/human_races/r_zombie.dmi', loc = get_step(self_turf, dir), icon_state = "arrow", dir = dir)
	user.client.images += I
	spawn(50)
		if(user && user.client)
			user.client.images -= I
