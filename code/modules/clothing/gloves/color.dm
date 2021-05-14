/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	item_color = "yellow"

/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	item_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05

/obj/item/clothing/gloves/fyellow/atom_init()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)


/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	item_state = "bgloves"
	item_color = "black"

	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/black/strip // gloves for stripping items
	siemens_coefficient = 0.2


/obj/item/clothing/gloves/black/hos
	name = "head of security's gloves"

/obj/item/clothing/gloves/black/ce
	name = "chief engineer's gloves"

/obj/item/clothing/gloves/color
	name = "white gloves"
	desc = "These look pretty fancy."
	icon_state = "white"
	item_state = "white"
	item_color = "white"

/obj/item/clothing/gloves/color/orange
	name = "orange gloves"
	color = "#ff7314"

/obj/item/clothing/gloves/color/red
	name = "red gloves"
	color = "#f63c45"

/obj/item/clothing/gloves/color/blue
	name = "blue gloves"
	color = "#4ca7fb"

/obj/item/clothing/gloves/color/purple
	name = "purple gloves"
	color = "#b26bef"

/obj/item/clothing/gloves/color/green
	name = "green gloves"
	color = "#59e663"

/obj/item/clothing/gloves/color/grey
	name = "grey gloves"
	color = "#d4d4d2"

/obj/item/clothing/gloves/color/light_brown
	name = "light brown gloves"
	color = "#eba349"

/obj/item/clothing/gloves/color/brown
	name = "brown gloves"
	color = "#db8732"

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	item_state = "rainbowgloves"
	item_color = "rainbow"

/obj/item/clothing/gloves/rainbow/clown
	item_color = "clown"

/obj/effect/spawner/lootdrop/gloves
	name = "random gloves"
	desc = "These gloves are supposed to be a random color..."
	icon = 'icons/obj/clothing/gloves.dmi'
	icon_state = "random_gloves"
	loot = list(
		/obj/item/clothing/gloves/color/orange = 1,
		/obj/item/clothing/gloves/color/red = 1,
		/obj/item/clothing/gloves/color/blue = 1,
		/obj/item/clothing/gloves/color/purple = 1,
		/obj/item/clothing/gloves/color/green = 1,
		/obj/item/clothing/gloves/color/grey = 1,
		/obj/item/clothing/gloves/color/light_brown = 1,
		/obj/item/clothing/gloves/color/brown = 1,
		/obj/item/clothing/gloves/color = 1,
		/obj/item/clothing/gloves/rainbow = 1)
