/obj/item/clothing/shoes/syndigaloshes
	desc = "A pair of brown shoes. They seem to have extra grip."
	name = "brown shoes"
	icon_state = "brown"
	item_state = "brown"
	permeability_coefficient = 0.05
	flags = NOSLIP
	origin_tech = "syndicate=3"
	var/list/clothing_choices = list()
	siemens_coefficient = 0.8
	species_restricted = null

/obj/item/clothing/shoes/mime
	name = "mime shoes"
	icon_state = "mime"
	item_color = "mime"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/swat
	name = "SWAT shoes"
	desc = "When you want to turn up the heat."
	icon_state = "swat"
	item_state = "wjboots"
	flags = NOSLIP
	siemens_coefficient = 0.6
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/combat //Basically SWAT shoes combined with galoshes.
	name = "combat boots"
	desc = "When you REALLY want to turn up the heat"
	icon_state = "swat"
	item_state = "wjboots"
	flags = NOSLIP
	siemens_coefficient = 0.6
	clipped_status = CLIPPABLE

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/shoes/combat/cut // Basically combat shoes but for xenos.
	name = "mangled combat boots"
	desc = "When you REALLY want to turn up the heat<br>They have the toe caps cut off of them."
	icon_state = "swat_cut"
	clipped_status = CLIPPED
	species_restricted = list("exclude", DIONA, VOX)

/obj/item/clothing/shoes/space_ninja
	name = "ninja shoes"
	desc = "A pair of running shoes. Excellent for running and even better for smashing skulls."
	icon_state = "s-ninja"
	permeability_coefficient = 0.01
	flags = NOSLIP
	siemens_coefficient = 0.2

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

/obj/item/clothing/shoes/tourist
	name = "flip-flops"
	desc = "These cheap sandals don't look very comfortable."
	icon_state = "tourist"
	permeability_coefficient = 1
	species_restricted = null
	w_class = ITEM_SIZE_SMALL

/obj/item/clothing/shoes/sandal
	desc = "A pair of rather plain, wooden sandals."
	name = "sandals"
	icon_state = "wizard"
	species_restricted = null
	body_parts_covered = 0

/obj/item/clothing/shoes/sandal/brown
	name = "Brown Sandals"
	desc = "Sweet looking brown sandals. Do not wear them with socks!"
	icon_state = "sandals-brown"
	item_color = "sandals-brown"

/obj/item/clothing/shoes/sandal/pink
	name = "Pink Sandals"
	desc = "They radiate a cheap plastic aroma like from hell ramen."
	icon_state = "sandals-pink"
	item_color = "sandals-pink"

/obj/item/clothing/shoes/sandal/marisa
	desc = "A pair of magic, black shoes."
	name = "magic shoes"
	icon_state = "black"
	body_parts_covered = LEGS

/obj/item/clothing/shoes/galoshes
	desc = "Rubber boots."
	name = "galoshes"
	icon_state = "galoshes"
	permeability_coefficient = 0.05
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	species_restricted = null

/obj/item/clothing/shoes/clown_shoes
	desc = "The prankster's standard-issue clowning shoes. Damn they're huge!"
	name = "clown shoes"
	icon_state = "clown"
	item_state = "clown_shoes"
	slowdown = SHOES_SLOWDOWN+1
	item_color = "clown"
//	var/footstep = 1	//used for squeeks whilst walking
	species_restricted = null

/obj/item/clothing/shoes/clown_shoes/play_unique_footstep_sound()
	..()
	playsound(src, pick(SOUNDIN_CLOWNSTEP), VOL_EFFECTS_MASTER)

/obj/item/clothing/shoes/jackboots
	name = "jackboots"
	desc = "Nanotrasen-issue Security combat boots for combat scenarios or combat situations. All combat, all the time."
	icon_state = "wjboots"
	item_state = "wjboots"
	item_color = "hosred"
	siemens_coefficient = 0.7
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/cult
	name = "boots"
	desc = "A pair of boots worn by the followers of Nar-Sie."
	icon_state = "cult"
	item_state = "cult"
	item_color = "cult"
	siemens_coefficient = 0.7

	cold_protection = LEGS
	min_cold_protection_temperature = SHOE_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = LEGS
	max_heat_protection_temperature = SHOE_MAX_HEAT_PROTECTION_TEMPERATURE
	species_restricted = null

/obj/item/clothing/shoes/cyborg
	name = "cyborg boots"
	desc = "Shoes for a cyborg costume."
	icon_state = "boots"

/obj/item/clothing/shoes/slippers
	name = "bunny slippers"
	desc = "Fluffy!"
	icon_state = "slippers"
	item_state = "slippers"
	species_restricted = null
	w_class = ITEM_SIZE_SMALL

/obj/item/clothing/shoes/slippers_worn
	name = "worn bunny slippers"
	desc = "Fluffy..."
	icon_state = "slippers_worn"
	item_state = "slippers_worn"
	w_class = ITEM_SIZE_SMALL

/obj/item/clothing/shoes/laceup
	name = "laceup shoes"
	desc = "The height of fashion, and they're pre-polished!"
	icon_state = "laceups"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/swimmingfins
	desc = "Help you swim good."
	name = "swimming fins"
	icon_state = "flippers"
	flags = NOSLIP
	slowdown = SHOES_SLOWDOWN+1
	species_restricted = null

/obj/item/clothing/shoes/centcom
	name = "dress shoes"
	desc = "They appear impeccably polished."
	icon_state = "laceups"
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/rosas_shoes
	name = "white shoes"
	icon_state = "rosas_shoes"
	item_color = "rosas_shoes"
	permeability_coefficient = 0.01

/obj/item/clothing/shoes/western
	name = "western boots"
	icon_state = "western_boots"
	item_color = "western_boots"

/obj/item/clothing/shoes/magboots/syndie
	desc = "Light-weighted magnetic boots that have a custom syndicate paintjob for use in combat."
	name = "gorlex magboots"
	icon_state = "syndiemag0"
	magboot_state = "syndiemag"
	slowdown_off = 1

/obj/item/clothing/shoes/workboots
	name = "work boots"
	icon_state = "workboots"
	item_color = "workboots"
	item_state = "b_shoes"  // need sprites for this
	clipped_status = CLIPPABLE

/obj/item/clothing/shoes/roman
	name = "roman sandals"
	desc = "Sandals with buckled leather straps on it."
	icon_state = "roman"
	item_state = "roman"

/obj/item/clothing/shoes/boots/nt_pmc_boots
	name = "NT PMC Boots"
	desc = "Private security boots. Now with extra grip."
	flags = NOSLIP
	icon_state = "nt_pmc_boots"
	item_state = "r_feet"
	item_color = "nt_pmc_boots"

/obj/item/clothing/shoes/boots/lizard_boots
	name = "Lizard Boots"
	desc = "Private security boots for Unathi."
	flags = NOSLIP
	icon_state = "Lizard_Boots"
	item_state = "r_feet"
	item_color = "Lizard_Boots"
	species_restricted = list(UNATHI)

/obj/item/clothing/shoes/heels
	name = "Heels"
	icon_state = "high_shoes"

/obj/item/clothing/shoes/heels/alternate
	icon_state = "high_shoes2"

/obj/item/clothing/shoes/boots/German
	name = "Black Boots"
	desc = "Deutschland army boots."
	icon_state = "Black_Boots"
	item_state = "jackboots"
	item_color = "Black_Boots"

/obj/item/clothing/shoes/brown_cut
	name = "Cut Brown Boots"
	desc = "Some shoes that was cut to fit unathi foot in it."
	icon_state = "brown-cut"
	item_color = "brown-cut"
	species_restricted = null

/obj/item/clothing/shoes/footwraps
	name = "Footwraps"
	desc = "Just some rags that you wrap around your foot to feel more comfortable. Better than nothing."
	icon_state = "footwraps"
	item_color = "footwraps"
	species_restricted = null