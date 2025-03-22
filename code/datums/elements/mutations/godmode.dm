/datum/element/mutation/godmode
	traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
	)

/datum/element/mutation/godmode/on_gain(mob/living/L)

	L.mob_brute_mod.ModMultiplicative(0, src)
	L.mob_burn_mod.ModMultiplicative(0, src)
	L.mob_oxy_mod.ModMultiplicative(0, src)
	L.mob_tox_mod.ModMultiplicative(0, src)
	L.mob_clone_mod.ModMultiplicative(0, src)
	L.mob_brain_mod.ModMultiplicative(0, src)

	L.rejuvenate()

/datum/element/mutation/godmode/on_loose(mob/living/L)
	L.mob_brute_mod.RemoveModifiers(src)
	L.mob_burn_mod.RemoveModifiers(src)
	L.mob_oxy_mod.RemoveModifiers(src)
	L.mob_tox_mod.RemoveModifiers(src)
	L.mob_clone_mod.RemoveModifiers(src)
	L.mob_brain_mod.RemoveModifiers(src)
