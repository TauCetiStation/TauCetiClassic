/datum/quirk/high_pain_threshold
	name = QUIRK_HIGH_PAIN_THRESHOLD
	desc = "Ваш болевой порог повышен. Влияет только на издаваемые вами звуки."
	value = 0
	mob_trait = TRAIT_HIGH_PAIN_THRESHOLD
	gain_text = "<span class='danger'>Вы хотите показать свою силу. Вы попытаетесь игнорировать любую боль.</span>"
	lose_text = "<span class='notice'>Вы устали превозмогать боль.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/low_pain_threshold
	name = QUIRK_LOW_PAIN_THRESHOLD
	desc = "Ваш болевой порог понижен. Влияет только на издаваемые вами звуки. "
	value = 0
	mob_trait = TRAIT_LOW_PAIN_THRESHOLD
	gain_text = "<span class='danger'>Вам страшно от одной лишь мысли о боли.</span>"
	lose_text = "<span class='notice'>Вы больше не хотите выглядеть слабаком. Теперь вы пытаетесь терпеть боль.</span>"

	req_species_flags = list(
		NO_PAIN = FALSE,
	)



/datum/quirk/no_taste
	name = QUIRK_AGEUSIA
	desc = "Всё для вас одинаково пресно на вкус! Токсичная еда остаётся ядовитой для вас."
	value = 0
	mob_trait = TRAIT_AGEUSIA
	gain_text = "<span class='notice'>Вы не различаете вкуса еды!</span>"
	lose_text = "<span class='notice'>Вы снова ощущаете вкус!</span>"

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
	lose_text = "<span class='notice'>Вы снова различаете цвета!</span>"

	var/current_type = "greyscale"

/datum/quirk/daltonism/post_add()
	var/mob/living/carbon/human/H = quirk_holder
	H.daltonism = TRUE

	var/list/types = list(
		"Серый"              = "greyscale",
		"Красный"            = "thermal",
		"Синий"              = "rbg_d",
		"Тёмно зелёный"      = "nvg_military",
		"Зелёный"            = "meson",
		"Оранжевый"          = "sepia",
		"Жёлтый-синий"       = "bgr_d",
		"Фиолетовый-жёлтый"  = "brg_d",
		"Зелёный-синий"      = "gbr_d",
		"Фиолетовый-красный" = "grb_d",
		)

	var/choose = input(H, "Выберите тип дальтонизма", "Цвет") in types
	current_type = types[choose]
	H.sightglassesmod = current_type
