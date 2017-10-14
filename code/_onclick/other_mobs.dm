/*
	Humans:
	Adds an exception for gloves, to allow special glove types like the ninja ones.

	Otherwise pretty standard.
*/
/mob/living/carbon/human/UnarmedAttack(atom/A, proximity)
	var/obj/item/clothing/gloves/G = gloves // not typecast specifically enough in defines

	// Special glove functions:
	// If the gloves do anything, have them return 1 to stop
	// normal attack_hand() here.
	if(proximity && istype(G) && G.Touch(A,1))
		return

	A.attack_hand(src)
/atom/proc/attack_hand(mob/user)
	return

/mob/living/carbon/human/RestrainedClickOn(atom/A)
	return

/*
	Animals & All Unspecified
*/
/mob/living/UnarmedAttack(atom/A)
	A.attack_animal(src)
/atom/proc/attack_animal(mob/user)
	return
/mob/living/RestrainedClickOn(atom/A)
	return

/*
	Monkeys
*/
/mob/living/carbon/monkey/UnarmedAttack(atom/A)
	A.attack_paw(src)
/atom/proc/attack_paw(mob/user)
	return

/*
	Monkey RestrainedClickOn() was apparently the
	one and only use of all of the restrained click code
	(except to stop you from doing things while handcuffed);
	moving it here instead of various hand_p's has simplified
	things considerably
*/
/mob/living/carbon/monkey/RestrainedClickOn(atom/A)
	if(a_intent != "harm" || !ismob(A)) return
	if(istype(wear_mask, /obj/item/clothing/mask/muzzle))
		return
	var/mob/living/carbon/ML = A
	var/dam_zone = ran_zone(pick(BP_CHEST , BP_L_HAND , BP_R_HAND , BP_L_LEG , BP_R_LEG))
	var/armor = ML.run_armor_check(dam_zone, "melee")
	if(prob(75))
		ML.apply_damage(rand(1,3), BRUTE, dam_zone, armor)
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[name] has bit [ML]!</B>", 1)
		if(armor >= 100) return
		if(ismonkey(ML))
			for(var/datum/disease/D in viruses)
				if(istype(D, /datum/disease/jungle_fever))
					ML.contract_disease(D,1,0)
	else
		for(var/mob/O in viewers(ML, null))
			O.show_message("\red <B>[src] has attempted to bite [ML]!</B>", 1)

/*
	Slimes
	Nothing happening here
*/
/mob/living/carbon/slime/UnarmedAttack(atom/A)
	A.attack_slime(src)
/atom/proc/attack_slime(mob/user)
	return
/mob/living/carbon/slime/RestrainedClickOn(atom/A)
	return

/*
	New Players:
	Have no reason to click on anything at all.
*/
/mob/dead/new_player/ClickOn()
	return
