/mob/living/carbon/human/attack_paw(mob/M)
	..()
	if (M.a_intent == "help")
		help_shake_act(M)
	else
		if (istype(wear_mask, /obj/item/clothing/mask/muzzle))
			return

		for(var/mob/O in viewers(src, null))
			O.show_message(text("\red <B>[M.name] has bit []!</B>", src), 1)

		var/damage = rand(1, 3)
		var/dam_zone = pick(BP_CHEST , BP_L_ARM , BP_R_ARM , BP_L_LEG , BP_R_LEG)
		var/obj/item/organ/external/BP = bodyparts_by_name[ran_zone(dam_zone)]
		apply_damage(damage, BRUTE, BP, run_armor_check(BP, "melee"))

		for(var/datum/disease/D in M.viruses)
			if(istype(D, /datum/disease/jungle_fever))
				var/mob/living/carbon/human/H = src
				src = null
				src = H.monkeyize()
				contract_disease(D,1,0)
	return
