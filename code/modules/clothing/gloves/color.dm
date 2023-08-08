/obj/item/clothing/gloves/insulated
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "insulated"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/budget_insulated                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "insulated"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/budget_insulated/atom_init()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)


/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"

	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/black/strip // gloves for stripping items
	siemens_coefficient = 0.2

/obj/item/clothing/gloves/black/hos
	name = "head of security's gloves"
	desc = "Heavily padded heavy-duty black tactical gloves. Especially for the Head of Security."
	siemens_coefficient = 0.5 //just like security gloves

/obj/item/clothing/gloves/black/ce
	name = "chief engineer's gloves"

/obj/item/clothing/gloves/white
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "latex"
	item_state = "lgloves"

/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	item_state = "orangegloves"

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	item_state = "redgloves"

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"

/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	item_state = "bluegloves"

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	item_state = "purplegloves"

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	item_state = "greengloves"

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	item_state = "graygloves"

/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	item_state = "lightbrowngloves"

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	item_state = "browngloves"

/obj/item/clothing/gloves/yellow
	name = "yellow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "yellow"
	item_state = "ygloves"

/obj/effect/spawner/lootdrop/gloves
	name = "random gloves"
	desc = "These gloves are supposed to be a random color..."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "random_gloves"
	loot = list(
		/obj/item/clothing/gloves/yellow = 1,
		/obj/item/clothing/gloves/orange = 1,
		/obj/item/clothing/gloves/red = 1,
		/obj/item/clothing/gloves/blue = 1,
		/obj/item/clothing/gloves/purple = 1,
		/obj/item/clothing/gloves/green = 1,
		/obj/item/clothing/gloves/grey = 1,
		/obj/item/clothing/gloves/light_brown = 1,
		/obj/item/clothing/gloves/brown = 1,
		/obj/item/clothing/gloves/white = 1,
		/obj/item/clothing/gloves/rainbow = 1
	)
