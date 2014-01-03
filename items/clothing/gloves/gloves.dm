//TC-custom gloves
/obj/item/clothing/gloves/security														//Sec gloves
	desc = "Heavily padded heavy-duty red security gloves."
	name = "Security gloves"
	icon = 'tauceti/items/clothing/gloves/security.dmi'
	tc_custom = 'tauceti/items/clothing/gloves/security.dmi'
	icon_state = "security"
	item_state = "secgloves"
	siemens_coefficient = 0.5
	permeability_coefficient = 0.04
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECITON_TEMPERATURE
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECITON_TEMPERATURE

/obj/item/clothing/gloves/fingerless
	desc = "A pair of gloves. They don't seem to have fingers."
	name = "black fingerless gloves"
	icon = 'tauceti/items/clothing/gloves/fingerless.dmi'
	tc_custom = 'tauceti/items/clothing/gloves/fingerless.dmi'
	icon_state = "fingerless_black"
	item_state = "fingerless_black"
	clipped = 1
	species_restricted = list("exclude","stunglove")