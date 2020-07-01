/datum/quirk/high_pain_threshold
	name = QUIRK_HIGH_PAIN_THRESHOLD
	desc = "You can take pain more easily. This quirk only affects sounds."
	value = 0
	mob_trait = TRAIT_HIGH_PAIN_THRESHOLD
	gain_text = "<span class='danger'>You want to show how strong you are. You will try to ignore any pain.</span>"
	lose_text = "<span class='notice'>You no longer want to endure pain, it scares you.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/low_pain_threshold
	name = QUIRK_LOW_PAIN_THRESHOLD
	desc = "You endure pain more difficult. This quirk only affects sounds"
	value = 0
	mob_trait = TRAIT_LOW_PAIN_THRESHOLD
	gain_text = "<span class='danger'>Just the thought of pain makes you tremble in fear.</span>"
	lose_text = "<span class='notice'>You don't want to show yourself to other people anymore that you're a wimp. Now you're trying to ignore the pain.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/no_taste
	name = QUIRK_AGEUSIA
	desc = "You can't taste anything! Toxic food will still poison you."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>You can't taste anything!</span>"
	lose_text = "<span class='notice'>You can taste again!</span>"

/datum/quirk/no_taste/get_incompatible_species()
	. = ..()
	LAZYINITLIST(.)

	for(var/specie_name in all_species)
		var/datum/species/S = all_species[specie_name]
		if(S.taste_sensitivity == TASTE_SENSITIVITY_NO_TASTE)
			. |= specie_name
