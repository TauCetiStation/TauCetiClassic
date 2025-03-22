// ex-species - slime people, xenobio mutation of slimetoxin
// most of unique mechanics handled with TRAIT_SLIME

/datum/element/mutation/slime
	traits = list(
		TRAIT_SLIME,
		TRAIT_NO_BREATHE,
		TRAIT_INCOMPATIBLE_DNA,
		TRAIT_NO_PAIN,
		TRAIT_RADIATION_IMMUNE,
		TRAIT_VIRUS_IMMUNE,
	)

/datum/element/mutation/on_gain(mob/living/carbon/human/H)
	if(istype(H))
		H.f_style = "Shaved"
		H.h_style = "Bald"
		H.rejuvenate() // fixes slimetoxin damage and regenerates icons
