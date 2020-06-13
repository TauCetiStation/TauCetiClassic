/mob/living/carbon/human/get_unarmed_attack()
	var/obj/item/organ/external/BPHand = get_bodypart(hand ? BP_L_ARM : BP_R_ARM)
	var/datum/unarmed_attack/attack = BPHand.species.unarmed

	var/retDam = 2 + attack.damage
	var/retDamType = attack.damType
	var/retFlags = attack.damage_flags()
	var/retVerb = pick(attack.attack_verb)
	var/retSound = null
	var/retMissSound = attack.miss_sound

	if(length(attack.attack_sound))
		retSound = pick(attack.attack_sound)

	if(HULK in mutations)
		retDam += 4

	if(istype(gloves, /obj/item/clothing/gloves/boxing))
		retDamType = HALLOSS

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/carbon/human/attack_hand(mob/living/carbon/human/attacker)
	. = ..()

	if(!.)
		return

	if(attacker.wear_suit && istype(attacker.wear_suit, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/V = attacker.wear_suit
		V.attack_reaction(attacker, REACTION_INTERACT_UNARMED, src)

	if(src.wear_suit && istype(src.wear_suit, /obj/item/clothing/suit))
		var/obj/item/clothing/suit/V = src.wear_suit
		V.attack_reaction(src, REACTION_ATACKED, attacker)

/mob/living/carbon/human/helpReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	var/target_zone = attacker.get_targetzone()
	if(health < (config.health_threshold_crit - 30) && target_zone == O_MOUTH)
		INVOKE_ASYNC(src, .proc/perform_av, attacker)
		return TRUE
	else if(stat == DEAD && target_zone == BP_CHEST)
		INVOKE_ASYNC(src, .proc/perform_cpr, attacker)
		return TRUE
	else if(!(attacker == src && apply_pressure(attacker, target_zone)))
		if(target_zone == O_MOUTH && attacker == src)
			attacker.force_vomit(src)
		else
			help_shake_act(attacker)
	return TRUE

/mob/living/carbon/human/disarmReaction(mob/living/carbon/human/attacker, show_message = TRUE)
	if(w_uniform)
		w_uniform.add_fingerprint(attacker)
	return ..()

/*
	We want to ensure that a mob may only apply pressure to one bodypart of one mob at any given time. Currently this is done mostly implicitly through
	the behaviour of do_after() and the fact that applying pressure to someone else requires a grab:

	If you are applying pressure to yourself and attempt to grab someone else, you'll change what you are holding in your active hand which will stop do_mob()
	If you are applying pressure to another and attempt to apply pressure to yourself, you'll have to switch to an empty hand which will also stop do_mob()
	Changing targeted zones should also stop do_mob(), preventing you from applying pressure to more than one body part at once.
*/
/mob/living/carbon/human/proc/apply_pressure(mob/living/user, target_zone)
	var/obj/item/organ/external/BP = get_bodypart(target_zone)
	if(!BP || !(BP.status & ORGAN_BLEEDING) || BP.is_robotic())
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

/mob/living/carbon/human/proc/afterattack(atom/target, mob/user, proximity, params)
	return
