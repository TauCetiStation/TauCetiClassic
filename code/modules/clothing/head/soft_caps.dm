/obj/item/clothing/head/soft
	name = "cap"
	desc = "It's a baseball hat"
	icon_state = "greysoft"
	item_state = "greysoft"
	item_state_world = "greysoft_world"
	flags = HEADCOVERSEYES
	siemens_coefficient = 0.9
	body_parts_covered = 0
	dyed_type = DYED_SOFTCAP
	item_action_types = list(/datum/action/item_action/hands_free/flip_cap)

	var/flipped = FALSE
	var/cap_color = "grey"

/datum/action/item_action/hands_free/flip_cap
	name = "Flip Cap"

/obj/item/clothing/head/soft/atom_init(mapload, ...)
	. = ..()
	item_state_world = "[cap_color]soft_world"

/obj/item/clothing/head/soft/wash_act(w_color)
	. = ..()
	var/obj/item/clothing/dye_type = get_dye_type(w_color)
	if(!dye_type)
		return

	var/obj/item/clothing/head/soft/S = dye_type

	item_state_inventory = "[initial(S.icon_state)][flipped ? "_flipped" : ""]"
	item_state_world = initial(S.item_state_world)
	cap_color = initial(S.cap_color)
	update_world_icon()

/obj/item/clothing/head/soft/attack_self(mob/living/carbon/human/user)
	flipped = !flipped
	if(flipped)
		item_state_inventory = "[cap_color]soft_flipped"
		to_chat(user, "You flip the hat backwards.")
	else
		item_state_inventory = "[cap_color]soft"
		to_chat(user, "You flip the hat back in normal position.")

	update_world_icon()
	update_inv_mob()
	update_item_actions()


/obj/item/clothing/head/soft/red
	name = "red cap"
	desc = "It's a baseball hat in a tasteless red color."
	icon_state = "redsoft"
	item_state_world = "redsoft_world"
	cap_color = "red"

/obj/item/clothing/head/soft/blue
	name = "blue cap"
	desc = "It's a baseball hat in a tasteless blue color."
	icon_state = "bluesoft"
	item_state_world = "bluesoft_world"
	cap_color = "blue"

/obj/item/clothing/head/soft/green
	name = "green cap"
	desc = "It's a baseball hat in a tasteless green color."
	icon_state = "greensoft"
	item_state_world = "greensoft_world"
	cap_color = "green"

/obj/item/clothing/head/soft/yellow
	name = "yellow cap"
	desc = "It's a baseball hat in a tasteless yellow color."
	icon_state = "yellowsoft"
	item_state_world = "yellowsoft_world"
	cap_color = "yellow"

/obj/item/clothing/head/soft/grey
	name = "grey cap"
	desc = "It's a baseball hat in a tasteful grey color."
	icon_state = "greysoft"
	item_state_world = "greysoft_world"
	cap_color = "grey"

/obj/item/clothing/head/soft/orange
	name = "orange cap"
	desc = "It's a baseball hat in a tasteless orange color."
	icon_state = "orangesoft"
	item_state_world = "orangesoft_world"
	cap_color = "orange"

/obj/item/clothing/head/soft/mime
	name = "white cap"
	desc = "It's a baseball hat in a tasteless white color."
	icon_state = "mimesoft"
	item_state_world = "mimesoft_world"
	cap_color = "mime"

/obj/item/clothing/head/soft/purple
	name = "purple cap"
	desc = "It's a baseball hat in a tasteless purple color."
	icon_state = "purplesoft"
	item_state_world = "purplesoft_world"
	cap_color = "purple"

/obj/item/clothing/head/soft/rainbow
	name = "rainbow cap"
	desc = "It's a baseball hat in a bright rainbow of colors."
	icon_state = "rainbowsoft"
	item_state_world = "rainbowsoft_world"
	cap_color = "rainbow"

/obj/item/clothing/head/soft/sec
	name = "security cap"
	desc = "It's baseball hat in tasteful red color."
	icon_state = "secsoft"
	item_state_world = "secsoft_world"
	cap_color = "sec"

/obj/item/clothing/head/soft/sec/corp
	name = "corporate security cap"
	desc = "It's baseball hat in corporate colors."
	icon_state = "corpsoft"
	item_state_world = "corpsoft_world"
	cap_color = "corp"

/obj/item/clothing/head/soft/janitor
	name = "janitor cap"
	desc = "It's janitor hat."
	icon_state = "janitorsoft"
	item_state_world = "janitorsoft_world"
	cap_color = "janitor"
	can_get_wet = FALSE

/obj/item/clothing/head/soft/nt_pmc_cap
	name = "NT PMC Cap"
	desc = "Dark cap used by the private security corporation. This one looks good."
	icon_state = "nt_pmcsoft"
	item_state_world = "nt_pmcsoft_world"
	cap_color = "nt_pmc"

/obj/item/clothing/head/soft/paramed
	name = "first responder cap"
	desc = "It's first responder hat. Shows who's saving lives here."
	icon_state = "frsoft"
	item_state_world = "frsoft_world"
	cap_color = "fr"

/obj/item/clothing/head/soft/blueshield
	name = "blueshield cap"
	desc = "It's baseball hat in tasteful blue color with blueshield insignia."
	icon_state = "blueshieldsoft"
	item_state_world = "blueshieldsoft_world"
	cap_color = "blueshield"

/obj/item/clothing/head/soft/cargo
	name = "cargo cap"
	desc = "It's cargo hat."
	icon_state = "cargosoft"
	item_state_world = "cargosoft_world"
	cap_color = "cargo"

