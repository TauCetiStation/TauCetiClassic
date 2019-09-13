/obj/item/clothing/gloves/yellow
	desc = "These gloves will protect the wearer from electric shock."
	name = "insulated gloves"
	icon_state = "yellow"
	inhand_state = "ygloves"
	siemens_coefficient = 0
	permeability_coefficient = 0.05
	onmob_state="yellow"

/obj/item/clothing/gloves/fyellow                             //Cheap Chinese Crap
	desc = "These gloves are cheap copies of the coveted gloves, no way this can end badly."
	name = "budget insulated gloves"
	icon_state = "yellow"
	inhand_state = "ygloves"
	siemens_coefficient = 1			//Set to a default of 1, gets overridden in New()
	permeability_coefficient = 0.05

	onmob_state="yellow"

/obj/item/clothing/gloves/fyellow/atom_init()
	. = ..()
	siemens_coefficient = pick(0,0.5,0.5,0.5,0.5,0.75,1.5)


/obj/item/clothing/gloves/black
	desc = "These gloves are fire-resistant."
	name = "black gloves"
	icon_state = "black"
	inhand_state = "bgloves"
	onmob_state="brown"

	cold_protection = ARMS
	min_cold_protection_temperature = GLOVES_MIN_COLD_PROTECTION_TEMPERATURE
	heat_protection = ARMS
	max_heat_protection_temperature = GLOVES_MAX_HEAT_PROTECTION_TEMPERATURE

/obj/item/clothing/gloves/black/strip // gloves for stripping items
	siemens_coefficient = 0.2


/obj/item/clothing/gloves/black/hos
	name = "head of security's gloves"
	onmob_state = "hosred"		//Exists for washing machines.

/obj/item/clothing/gloves/black/ce
	name = "chief engineer's gloves"
	onmob_state = "chief"			//Exists for washing machines.


/obj/item/clothing/gloves/orange
	name = "orange gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "orange"
	inhand_state = "orangegloves"
	onmob_state="orange"

/obj/item/clothing/gloves/red
	name = "red gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "red"
	inhand_state = "redgloves"
	onmob_state = "red"

/obj/item/clothing/gloves/rainbow
	name = "rainbow gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "rainbow"
	inhand_state = "rainbowgloves"
	onmob_state = "rainbow"

/obj/item/clothing/gloves/rainbow/clown
	onmob_state = "clown"


/obj/item/clothing/gloves/blue
	name = "blue gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "blue"
	inhand_state = "bluegloves"
	onmob_state="blue"

/obj/item/clothing/gloves/purple
	name = "purple gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "purple"
	inhand_state = "purplegloves"
	onmob_state="purple"

/obj/item/clothing/gloves/green
	name = "green gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "green"
	inhand_state = "greengloves"
	onmob_state="green"

/obj/item/clothing/gloves/grey
	name = "grey gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "gray"
	inhand_state = "graygloves"
	onmob_state="grey"

/obj/item/clothing/gloves/grey/rd
	onmob_state = "director"			//Exists for washing machines. Is not different from gray gloves in any way.

/obj/item/clothing/gloves/grey/hop
	onmob_state = "hop"				//Exists for washing machines. Is not different from gray gloves in any way.


/obj/item/clothing/gloves/light_brown
	name = "light brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "lightbrown"
	inhand_state = "lightbrowngloves"
	onmob_state="light brown"

/obj/item/clothing/gloves/brown
	name = "brown gloves"
	desc = "A pair of gloves, they don't look special in any way."
	icon_state = "brown"
	inhand_state = "browngloves"
	onmob_state="brown"

/obj/item/clothing/gloves/brown/cargo
	onmob_state = "cargo"				//Exists for washing machines. Is not different from brown gloves in any way.
