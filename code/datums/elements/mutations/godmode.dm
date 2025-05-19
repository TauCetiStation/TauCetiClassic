// element trait ELEMENT_TRAIT_GODMODE
// todo: all direct checks for ELEMENT_TRAIT_GODMODE should be replaced with more specific trait checks when possible

/datum/element/mutation/godmode
	traits = list(
		TRAIT_IMMOVABLE,
		TRAIT_NO_BREATHE,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
		TRAIT_MORPH_IMMUNE,
		TRAIT_SHOCK_IMMUNE,
	)

/datum/element/mutation/godmode/on_gain(mob/living/L)

	L.resetStuttering()

	L.mob_general_damage_mod.ModMultiplicative(0, src)
	L.mob_metabolism_mod.ModMultiplicative(0, src)

	L.rejuvenate()

/datum/element/mutation/godmode/on_loose(mob/living/L)
	L.mob_general_damage_mod.RemoveMods(src)
	L.mob_metabolism_mod.RemoveMods(src)
