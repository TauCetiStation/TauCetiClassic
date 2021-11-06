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

/datum/quirk/short_height
	name = QUIRK_SHORT
	desc = "You are shorter than most people"
	value = 0
	mob_trait = TRAIT_SHORT_HEIGHT
	gain_text = "<span class='danger'>You are shorter than most people.</span>"
	lose_text = "<span class='notice'>You are normal height.</span>"

/datum/quirk/short_height/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.appearance_flags |= KEEP_TOGETHER
	var/matrix/Mx = matrix()
	Mx.Scale(0.96)
	Mx.Translate(0,-1)
	H.transform = Mx
	H.default_transform = Mx

/datum/quirk/long_height
	name = QUIRK_LONG
	desc = "You are longer than most people"
	value = 0
	mob_trait = TRAIT_LONG_HEIGHT
	gain_text = "<span class='danger'>You are longer than most people.</span>"
	lose_text = "<span class='notice'>You are normal height.</span>"

/datum/quirk/long_height/on_spawn()
	var/mob/living/carbon/human/H = quirk_holder
	H.appearance_flags |= KEEP_TOGETHER
	var/matrix/Mx = matrix()
	Mx.Scale(1.049)
	Mx.Translate(0, 1)
	H.transform = Mx
	H.default_transform = Mx

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



/datum/quirk/daltonism
	name = QUIRK_DALTONISM
	desc = "You stop feeling the colors of objects."
	value = 0
	mob_trait = TRAIT_DALTONISM
	gain_text = "<span class='notice'>You don't distinguish colors!</span>"
	lose_text = "<span class='notice'>You see the colors!</span>"

	var/current_type = "greyscale"

/datum/quirk/daltonism/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	H.daltonism = TRUE

	var/list/types = list(
		"Grey"            = "greyscale",
		"Red"             = "thermal",
		"Blue"            = "rbg_d",
		"Dark Green"      = "nvg_military",
		"Green"           = "meson",
		"Orange"          = "sepia",
		"Yellow-Blue"     = "bgr_d",
		"Purple-Blue"     = "brg_d",
		"Green-Blue"      = "gbr_d",
		"Purple-Red"      = "grb_d",
		)

	var/choose = input(H, "Choose the type of color blindness", "Color") in types
	current_type = types[choose]
	H.sightglassesmod = current_type
