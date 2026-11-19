// ex-species - zombie people
// ELEMENT_TRAIT_ZOMBIE

/datum/element/mutation/zombie
	traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_HEMOCOAGULATION,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_NO_EMBED,
		TRAIT_EMOTIONLESS,
		TRAIT_GLOWING_EYES,
		TRAIT_NIGHT_EYES,
	)

#define ZOMBIE_MOOD_EVENT "zombie"

/datum/element/mutation/zombie/on_gain(mob/living/L)

	L.mind?.pluvian_social_credit = 0 //cursed cant vote

	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, ZOMBIE_MOOD_EVENT, /datum/mood_event/undead)

	// immune to most damage, vulnerable to brute
	L.mob_brute_mod.ModMultiplicative(1.8, src)
	L.mob_oxy_mod.ModMultiplicative(0, src)
	L.mob_tox_mod.ModMultiplicative(0, src)
	L.mob_clone_mod.ModMultiplicative(0, src)
	L.mob_brain_mod.ModMultiplicative(0, src)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.remove_status_flags(CANSTUN|CANPARALYSE) //CANWEAKEN

		H.drop_l_hand()
		H.drop_r_hand()

		H.AddComponent(/datum/component/mutant_hands)

		var/obj/item/organ/external/head/O = H.bodyparts_by_name[BP_HEAD]
		if(O)
			O.max_damage = 1000

		add_zombie(H)
		H.regenerate_icons(update_body_preferences = TRUE)

		RegisterSignal(H, COMSIG_MOB_DIED, PROC_REF(on_death))

/datum/element/mutation/zombie/on_loose(mob/living/L)
	SEND_SIGNAL(L, COMSIG_CLEAR_MOOD_EVENT, ZOMBIE_MOOD_EVENT)

	L.mob_brute_mod.RemoveMods(src)
	L.mob_oxy_mod.RemoveMods(src)
	L.mob_tox_mod.RemoveMods(src)
	L.mob_clone_mod.RemoveMods(src)
	L.mob_brain_mod.RemoveMods(src)

	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.add_status_flags(MOB_STATUS_FLAGS_DEFAULT)
		qdel(H.GetComponent(/datum/component/mutant_hands))

		var/obj/item/organ/external/head/O = H.bodyparts_by_name[BP_HEAD]
		if(O)
			O.max_damage = initial(O.max_damage)

		remove_zombie(H)
		H.regenerate_icons(update_body_preferences = TRUE)

		UnregisterSignal(H, COMSIG_MOB_DIED)

#undef ZOMBIE_MOOD_EVENT

/datum/element/mutation/zombie/proc/on_death(datum/source, gibbed)
	if(gibbed)
		return
	var/mob/living/carbon/human/H = source
	H.preprerevive_zombie(rand(600,700))
