// ex-species - skeleton people
// ELEMENT_TRAIT_SKELETON

/datum/element/mutation/skeleton
	traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_SHOCK_IMMUNE,
		TRAIT_NO_DNA_MUTATIONS,
		TRAIT_NO_FINGERPRINT,
		TRAIT_NO_EMBED,
		TRAIT_NO_MINORCUTS,
		TRAIT_EMOTIONLESS,
		TRAIT_NO_VOMIT,
		TRAIT_NO_BLOOD,
		TRAIT_NEVER_FAT,
		TRAIT_NO_MESSY_GIBS,
	)

	var/list/bodypart_replacements = list(
		BP_CHEST  = /obj/item/organ/external/chest/skeleton,
		BP_GROIN  = /obj/item/organ/external/groin/skeleton,
		BP_HEAD   = /obj/item/organ/external/head/skeleton,
		BP_L_ARM  = /obj/item/organ/external/l_arm/skeleton,
		BP_R_ARM  = /obj/item/organ/external/r_arm/skeleton,
		BP_L_LEG  = /obj/item/organ/external/l_leg/skeleton,
		BP_R_LEG  = /obj/item/organ/external/r_leg/skeleton,
		BP_TAIL   = /obj/item/organ/external/tail/skeleton,
	)

#define SKELETON_MOOD_EVENT "skeleton"

/datum/element/mutation/skeleton/on_gain(mob/living/L)

	L.mind?.pluvian_social_credit = 0 //cursed cant vote

	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, SKELETON_MOOD_EVENT, /datum/mood_event/undead)

	// immune to most damage, vulnerable to brute
	L.mob_brute_mod.ModMultiplicative(2, src)
	//L.mob_burn_mod.ModMultiplicative(0, src) // should they?
	L.mob_oxy_mod.ModMultiplicative(0, src)
	L.mob_tox_mod.ModMultiplicative(0, src)
	L.mob_clone_mod.ModMultiplicative(0, src)

	// no need for food
	L.mob_metabolism_mod.ModMultiplicative(0, src)
	L.nutrition = NUTRITION_LEVEL_NORMAL
	REMOVE_TRAIT(L, TRAIT_FAT, OBESITY_TRAIT)

	// todo: replace with traits
	L.remove_status_flags(CANSTUN|CANPARALYSE)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L

		if(H.f_style)
			H.f_style = "Shaved"
		if(H.h_style)
			H.h_style = "Bald"

		for(var/obj/item/organ/external/BP in H.bodyparts)
			var/obj/item/organ/external/SBP
			if(bodypart_replacements[BP.body_zone])
				var/path = bodypart_replacements[BP.body_zone]
				SBP = new path(null)

			qdel(BP)
			if(SBP)
				SBP.insert_organ(H, FALSE, BP.species)

		for(var/obj/item/organ/internal/IO in H.organs)
			qdel(IO)

		H.regenerate_icons(update_body_preferences = TRUE)

/datum/element/mutation/skeleton/on_loose(mob/living/L)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, SKELETON_MOOD_EVENT)

	L.mob_brute_mod.RemoveMods(src)
	L.mob_oxy_mod.RemoveMods(src)
	L.mob_tox_mod.RemoveMods(src)
	L.mob_clone_mod.RemoveMods(src)

	L.mob_metabolism_mod.RemoveMods(src)

	L.add_status_flags(MOB_STATUS_FLAGS_DEFAULT)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.species.create_organs(H, deleteOld = TRUE)

		H.regenerate_icons(update_body_preferences = TRUE)

#undef SKELETON_MOOD_EVENT
