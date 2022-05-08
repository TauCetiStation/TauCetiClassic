/datum/quirk/high_pain_threshold
	name = QUIRK_HIGH_PAIN_THRESHOLD
	desc = "Вы легче переносите боль. Эта особенность влияет лишь на звуки, издаваемые вами."
	value = 0
	mob_trait = TRAIT_HIGH_PAIN_THRESHOLD
	gain_text = "<span class='danger'>Вы хотите показать, насколько вы сильны. Вы попытаетесь игнорировать любую боль.</span>"
	lose_text = "<span class='notice'>Вы устали превозмогать боль.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/low_pain_threshold
	name = QUIRK_LOW_PAIN_THRESHOLD
	desc = "Боль для вас более мучительна. Эта особенность влияет лишь на звуки, издаваемые вами. "
	value = 0
	mob_trait = TRAIT_LOW_PAIN_THRESHOLD
	gain_text = "<span class='danger'>От одной лишь мысли о боли вас начинает трясти от страха.</span>"
	lose_text = "<span class='notice'>Вы больше не хотите казаться слизняком в глазах окружающих. Теперь вы будете пытаться игнорировать боль.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/no_taste
	name = QUIRK_AGEUSIA
	desc = "Всё для вас одинаково пресно на вкус! Токсичная еда остаётся ядовитой для вас."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>Вы потеряли вкус!</span>"
	lose_text = "<span class='notice'>Вы снова ощущаете вкус! </span>"

/datum/quirk/no_taste/get_incompatible_species()
	. = ..()
	LAZYINITLIST(.)

	for(var/specie_name in all_species)
		var/datum/species/S = all_species[specie_name]
		if(S.taste_sensitivity == TASTE_SENSITIVITY_NO_TASTE)
			. |= specie_name



/datum/quirk/daltonism
	name = QUIRK_DALTONISM
	desc = "Вы не различаете цвета."
	value = 0
	mob_trait = TRAIT_DALTONISM
	gain_text = "<span class='notice'>Вы перестали различать цвета!</span>"
	lose_text = "<span class='notice'>Вы снова можете насладиться красками этого мира!</span>"

	var/current_type = "ахроматопсия"

/datum/quirk/daltonism/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	H.daltonism = TRUE

	var/list/types = list(
		"протаномалия"  = PROTANOMALY_FILTER,
		"протанопия"    = PROTANOPIA_FILTER,
		"дейтраномалия" = DEUTERANOMALY_FILTER,
		"дейтранопия"   = DEUTERANOPIA_FILTER,
		"тританомалия"  = TRITANOMALY_FILTER,
		"тританопия"    = TRITANOPIA_FILTER,
		"ахроматопсия"  = ACHROMATOPSIA_FILTER
		)

	var/choose = input(H, "Выберите тип дальтонизма", "Тип") in types
	current_type = types[choose]
	H.sightglassesmod = current_type
