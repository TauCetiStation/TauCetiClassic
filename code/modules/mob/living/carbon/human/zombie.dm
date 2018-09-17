/obj/item/weapon/melee/zombie_hand
	name = "zombie claw"
	desc = "A zombie's claw is its primary tool, capable of infecting \
			humans, butchering all other living things to \
			sustain the zombie, smashing open airlock doors and opening \
			child-safe caps on bottles."
	flags = NODROP | ABSTRACT | DROPDEL
	icon = 'icons/effects/blood.dmi'
	icon_state = "bloodhand_left"
	force = 10
	w_class = 5.0
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	hitsound = 'sound/hallucinations/growl1.ogg'

	attack_verb = list("bitten and scratched", "scratched")

/obj/item/weapon/melee/zombie_hand/right
	icon_state = "bloodhand_right"

/obj/item/weapon/melee/zombie_hand/afterattack(atom/target, mob/user, proximity)
	if(!proximity)
		return

	if(istype(target, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/A = target

		if(A.welded || A.locked)
			to_chat(user, "<span class='warning'>The door is sealed, it cannot be pried open.</span>")
			return
		else
			opendoor(user, A)

	if(istype(target, /obj/machinery/door/firedoor))
		var/obj/machinery/door/firedoor/A = target

		if(A.blocked)
			to_chat(user, "<span class='warning'>The door is sealed, it cannot be pried open.</span>")
			return
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
		playsound(A.loc, 'sound/effects/metal_creaking.ogg', 50, 0)
		if(do_after(user, 70, target = A))
			if(A.density && in_range(A, user))
				user.visible_message("<span class='warning'>[user] forces the door to open with [src]!</span>",\
									 "<span class='warning'>You force the door to open.</span>",\
									 "<span class='warning'>You hear a metal screeching sound.</span>")
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
	for(var/obj/item/organ/external/organ in H.bodyparts)
		if(!(organ.status & ORGAN_ZOMBIE))
			organ.status |= ORGAN_ZOMBIE
	var/obj/item/organ/external/LArm = H.bodyparts_by_name[BP_L_ARM]
	var/obj/item/organ/external/RArm = H.bodyparts_by_name[BP_R_ARM]

	if(LArm && !(LArm.status & ORGAN_DESTROYED) && !istype(H.l_hand, /obj/item/weapon/melee/zombie_hand))
		H.drop_l_hand()
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand, slot_l_hand)
	if(RArm && !(RArm.status & ORGAN_DESTROYED) && !istype(H.r_hand, /obj/item/weapon/melee/zombie_hand/right))
		H.drop_r_hand()
		H.equip_to_slot_or_del(new /obj/item/weapon/melee/zombie_hand/right, slot_r_hand)

	if(H.stat != DEAD && prob(10))
		playsound(H, pick(spooks), 50, 1)

/datum/species/zombie/handle_death(mob/living/carbon/human/H)
	addtimer(CALLBACK(null, .proc/prerevive_zombie, H), rand(600,700))
	H.update_mutantrace()

/proc/handle_infected_death(mob/living/carbon/human/H)
	if(H.species.name in list(HUMAN, UNATHI, TAJARAN, SKRELL))
		addtimer(CALLBACK(null, .proc/prerevive_zombie, H), rand(600,700))

/proc/prerevive_zombie(mob/living/carbon/human/H)
	var/obj/item/organ/external/BP = H.bodyparts_by_name[BP_HEAD]
	if(H.organs_by_name[O_BRAIN] && BP && !(BP.status & ORGAN_DESTROYED))
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
	if(!H.organs_by_name[O_BRAIN] || !BP || BP.status & ORGAN_DESTROYED)
		return
	if(!iszombie(H))
		H.zombify()
	//H.rejuvenate()
	H.setToxLoss(0)
	H.setOxyLoss(0)
	H.setCloneLoss(0)
	H.setBrainLoss(0)
	H.setHalLoss(0)
	H.SetParalysis(0)
	H.SetStunned(0)
	H.SetWeakened(0)
	H.nutrition = 400
	H.sleeping = 0
	H.radiation = 0

	H.heal_overall_damage(H.getBruteLoss(), H.getFireLoss())
	H.restore_blood()

	// remove the character from the list of the dead
	if(H.stat == DEAD)
		dead_mob_list -= H
		living_mob_list += H
		H.tod = null
		H.timeofdeath = 0
	H.stat = CONSCIOUS
	H.update_canmove()
	H.regenerate_icons()
	H.update_health_hud()

	playsound(H, pick(list('sound/hallucinations/veryfar_noise.ogg','sound/hallucinations/wail.ogg')), 50, 1)
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

	infect_virus2(src, D, TRUE)

/mob/living/carbon/human/proc/zombify()
	if(iszombie(src))
		return

	switch(species.name)
		if(TAJARAN)
			set_species(ZOMBIE_TAJARAN, FALSE, TRUE)
		if(SKRELL)
			set_species(ZOMBIE_SKRELL, FALSE, TRUE)
		if(UNATHI)
			set_species(ZOMBIE_UNATHI, FALSE, TRUE)
		else
			set_species(ZOMBIE, FALSE, TRUE)

/proc/zombie_talk(var/message)
	var/list/message_list = splittext(message, " ")
	var/maxchanges = max(round(message_list.len / 1.5), 2)

	for(var/i = rand(maxchanges / 2, maxchanges), i > 0, i--)
		var/insertpos = rand(1, message_list.len)
		message_list.Insert(insertpos, "[pick("ÃŒ«√»", "ÃÓÁ„Ë", "ÃÓÓÁ„ËËË", "ÃŒŒŒ«√»»»»", "¡ŒÀ‹ÕŒ", "¡ŒÀ‹", "œŒÃŒ√»", "–¿¿¿¿", "¿¿¿¿", "¿––’", "Œ“ –Œ…“≈", "Œ“ –Œ…")]...")

	for(var/i = 1, i <= message_list.len, i++)
		if(prob(50) && !(copytext(message_list[i], length(message_list[i]) - 2) == "..."))
			message_list[i] = message_list[i] + "..."

		if(prob(60))
			message_list[i] = stutter(message_list[i])

		message_list[i] = stars(message_list[i], 80)

		if(prob(60))
			message_list[i] = slur(message_list[i])

	return jointext(message_list, " ")