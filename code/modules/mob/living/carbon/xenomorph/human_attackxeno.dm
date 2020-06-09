/*----------------------------------------
This is what happens, when alien attack.
----------------------------------------*/
/mob/living/carbon/xenomorph/UnarmedAttack(atom/A)
	..()
	A.attack_alien(src)

/atom/proc/attack_alien(mob/user)
	attack_paw(user)
	return

// Baby aliens
/mob/living/carbon/xenomorph/facehugger/UnarmedAttack(atom/A)
	if(ismob(A))
		SetNextMove(CLICK_CD_MELEE)
	A.attack_facehugger(src)

/atom/proc/attack_facehugger(mob/user)
	return

/mob/living/carbon/xenomorph/larva/UnarmedAttack(atom/A)
	if(ismob(A))
		SetNextMove(CLICK_CD_MELEE)
	A.attack_larva(src)

/atom/proc/attack_larva(mob/user)
	return

/mob/living/carbon/xenomorph/larva/get_unarmed_attack()
	var/retDam = 1
	var/retDamType = BRUTE
	var/retFlags = DAM_SHARP
	var/retVerb = "gnaw"
	var/retSound = 'sound/weapons/bite.ogg'
	var/retMissSound = 'sound/weapons/punchmiss.ogg'

	if(HULK in mutations)
		retDam += 4

	return list("damage" = retDam, "type" = retDamType, "flags" = retFlags, "verb" = retVerb, "sound" = retSound,
				"miss_sound" = retMissSound)

/mob/living/carbon/human/attack_larva(mob/living/carbon/xenomorph/larva/attacker)
	if(attacker.a_intent == INTENT_HARM && stat != DEAD)
		var/attack_obj = attacker.get_unarmed_attack()
		var/atk_damage = attack_obj["damage"]
		attacker.amount_grown = min(attacker.amount_grown + atk_damage, attacker.max_grown)
	return ..()
