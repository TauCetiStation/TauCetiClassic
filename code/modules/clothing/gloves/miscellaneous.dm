/obj/item/clothing/gloves/captain
	desc = "Regal blue gloves, with a nice gold trim. Swanky."
	name = "captain's gloves"
	icon_state = "captain"
	item_state = "egloves"
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/cyborg
	desc = "beep... boop... borp..."
	name = "cyborg gloves"
	icon_state = "black"
	item_state = "r_hands"
	siemens_coefficient = 1.0

/obj/item/clothing/gloves/swat
	desc = "These tactical gloves are fire-resistant."
	name = "SWAT Gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0.6
	permeability_coefficient = 0.05

	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/combat //Combined effect of SWAT gloves and insulated gloves
	desc = "These tactical gloves are somewhat fire and impact resistant."
	name = "combat gloves"
	icon_state = "black"
	item_state = "swat_gl"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/combat/wizard
	name = "Magic Gloves"
	desc = "A pair of shockproof gloves, look very magical."
	icon_state = "wizard"
	item_state = "wizardgloves"

/obj/item/clothing/gloves/latex
	name = "latex gloves"
	desc = "Sterile latex gloves."
	icon_state = "latex"
	item_state = "lgloves"
	siemens_coefficient = 0.30
	permeability_coefficient = 0.01
	germ_level = 0

/obj/item/clothing/gloves/latex/nitrile
	name = "nitrile gloves"
	desc = "Sterile nitrile gloves"
	icon_state = "nitrile"
	item_state = "ngloves"

/obj/item/clothing/gloves/botanic_leather
	desc = "These leather gloves protect against thorns, barbs, prickles, spikes and other harmful objects of floral origin."
	name = "botanist's leather gloves"
	icon_state = "leather"
	item_state = "ggloves"
	permeability_coefficient = 0.9
	siemens_coefficient = 0.9

/obj/item/clothing/gloves/security														//Sec gloves
	desc = "Heavily padded heavy-duty black security gloves."
	name = "security gloves"
	icon_state = "security_black"
	item_state = "security_black"
	siemens_coefficient = 0.5
	permeability_coefficient = 0.04
	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/fingerless
	desc = "A pair of gloves. They don't seem to have fingers."
	name = "black fingerless gloves"
	icon_state = "fingerless_black"
	item_state = "fingerless_black"
	species_restricted = list("exclude", VOX_ARMALIS)
	species_restricted_locked = FALSE
	clipped = TRUE

	dyed_type = DYED_FINGERLESS_GLOVES

/obj/item/clothing/gloves/fingerless/red
	name = "red fingerless gloves"
	icon_state = "fingerless_red"
	item_state = "fingerless_red"

/obj/item/clothing/gloves/fingerless/orange
	name = "orange fingerless gloves"
	icon_state = "fingerless_orange"
	item_state = "fingerless_orange"

/obj/item/clothing/gloves/fingerless/green
	name = "green fingerless gloves"
	icon_state = "fingerless_green"
	item_state = "fingerless_green"

/obj/item/clothing/gloves/fingerless/blue
	name = "blue fingerless gloves"
	icon_state = "fingerless_blue"
	item_state = "fingerless_blue"

/obj/item/clothing/gloves/fingerless/purple
	name = "purple fingerless gloves"
	icon_state = "fingerless_purple"
	item_state = "fingerless_purple"

/obj/item/clothing/gloves/fingerless/yellow
	name = "yellow fingerless gloves"
	icon_state = "fingerless_yellow"
	item_state = "fingerless_yellow"

/obj/item/clothing/gloves/fingerless/rainbow
	name = "rainbow fingerless gloves"
	icon_state = "fingerless_rainbow"
	item_state = "fingerless_rainbow"

/obj/item/clothing/gloves/security/marinad
	desc = "These were made to hold a full automatic gun."
	name = "marine gloves"
	icon_state = "marinad"
	item_state = "bgloves"

/obj/item/clothing/gloves/left
	name = "left black glove"
	desc = "The left one of a pair of black gloves. Wonder where the other one went..."
	icon_state = "left_glove"
	item_state = "left_glove"

/obj/item/clothing/gloves/combat/police
	desc = "Fist of the Law."
	name = "police gloves"
	icon_state = "police_gloves"
	item_state = "police_gloves"
