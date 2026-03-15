// ex-species - slime people, xenobio mutation of slimetoxin
// ELEMENT_TRAIT_SLIME

/datum/element/mutation/slime
	traits = list(
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
	)

/datum/element/mutation/slime/on_gain(mob/living/carbon/human/H)
	if(istype(H))
		H.f_style = "Shaved"
		H.h_style = "Bald"
		H.regenerate_icons(update_body_preferences = TRUE)
		H.rejuvenate() // fixes slimetoxin damage (also calls regenerate_icons second time...)

/datum/element/mutation/zombie/on_loose(mob/living/carbon/human/H)
	if(istype(H))
		H.regenerate_icons(update_body_preferences = TRUE)
